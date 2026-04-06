import 'dart:async';

import 'package:drift/drift.dart';
import 'package:ev_protocol/ev_protocol.dart';
import 'package:ev_protocol_veilid/src/db/app_database.dart';
import 'package:ev_protocol_veilid/src/sync/veilid_node_interface.dart';

/// Concrete implementation of [EvSyncService] that processes the local
/// [SyncQueue] and pushes records to the Veilid DHT via [VeilidNodeInterface].
///
/// ## Lifecycle
/// ```
/// service.startSync()   → periodic timer begins (default 5s)
/// service.syncNow()     → immediate single pass
/// service.stopSync()    → timers cancelled, stream closed
/// ```
///
/// ## Retry strategy
/// Failed records use exponential backoff:
/// `baseInterval × 2^retryCount` (5s → 10s → 20s → 40s → 80s).
/// After [maxRetries] (default 5), the record is marked `'failed'`.
///
/// ## Cleanup
/// Completed records are retained for debugging. A cleanup timer runs every
/// [cleanupInterval] (default 1 hour) and deletes completed records older
/// than [completedRetention] (default 24 hours).
class VeilidSyncService implements EvSyncService {
  final AppDatabase _db;
  final VeilidNodeInterface _node;

  /// How often the sync loop fires.
  final Duration syncInterval;

  /// Maximum retry attempts before marking a record as failed.
  final int maxRetries;

  /// How long to keep completed records before purging.
  final Duration completedRetention;

  /// How often the cleanup timer fires.
  final Duration cleanupInterval;

  /// Batch size for each sync pass.
  final int batchSize;

  Timer? _syncTimer;
  Timer? _cleanupTimer;
  bool _isProcessing = false;

  final StreamController<EvSyncEvent> _eventController =
      StreamController<EvSyncEvent>.broadcast();

  VeilidSyncService({
    required AppDatabase db,
    required VeilidNodeInterface node,
    this.syncInterval = const Duration(seconds: 5),
    this.maxRetries = 5,
    this.completedRetention = const Duration(hours: 24),
    this.cleanupInterval = const Duration(hours: 1),
    this.batchSize = 10,
  })  : _db = db,
        _node = node;

  // ---------------------------------------------------------------------------
  // EvSyncService interface
  // ---------------------------------------------------------------------------

  @override
  Future<EvResult<void>> startSync() async {
    if (_syncTimer != null) {
      return const EvSuccess(null);
    }

    _syncTimer = Timer.periodic(syncInterval, (_) => _processQueue());
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) => _cleanupCompleted());

    // Run an immediate pass on start
    unawaited(_processQueue());

    return const EvSuccess(null);
  }

  @override
  Future<EvResult<void>> stopSync() async {
    _syncTimer?.cancel();
    _syncTimer = null;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    return const EvSuccess(null);
  }

  @override
  Future<EvResult<int>> syncNow() async {
    final count = await _processQueue();
    return EvSuccess(count);
  }

  @override
  Future<int> pendingSyncCount() async {
    final query = _db.selectOnly(_db.syncQueue)
      ..addColumns([_db.syncQueue.id.count()])
      ..where(
        _db.syncQueue.status.isIn(['pending', 'processing']),
      );

    final result = await query.getSingle();
    return result.read(_db.syncQueue.id.count()) ?? 0;
  }

  @override
  Future<EvSyncStatus> getSyncStatus(EvDhtKey dhtKey) async {
    final row = await (_db.select(_db.syncQueue)
          ..where((t) => t.dhtKey.equals(dhtKey.value))
          ..orderBy([(t) => OrderingTerm.desc(t.queuedAt)])
          ..limit(1))
        .getSingleOrNull();

    if (row == null) return EvSyncStatus.synced;

    return switch (row.status) {
      'completed' => EvSyncStatus.synced,
      'pending' || 'processing' => EvSyncStatus.pendingSync,
      'failed' => EvSyncStatus.syncFailed,
      _ => EvSyncStatus.localOnly,
    };
  }

  @override
  Future<bool> isOnline() => _node.isOnline();

  @override
  Stream<EvSyncEvent> watchSyncEvents() => _eventController.stream;

  // ---------------------------------------------------------------------------
  // Queue processing
  // ---------------------------------------------------------------------------

  /// Processes pending sync queue items. Returns the number of items processed.
  Future<int> _processQueue() async {
    // Prevent concurrent processing
    if (_isProcessing) return 0;
    _isProcessing = true;

    try {
      final now = DateTime.now();

      // Select pending items, respecting backoff for previously failed attempts
      final rows = await (_db.select(_db.syncQueue)
            ..where((t) => t.status.equals('pending'))
            ..where((t) {
              // Only pick up items whose backoff period has elapsed
              return t.lastAttemptAt.isNull() |
                  t.lastAttemptAt.isSmallerThanValue(
                    now.subtract(syncInterval),
                  );
            })
            ..orderBy([
              (t) => OrderingTerm(expression: t.queuedAt, mode: OrderingMode.asc),
            ])
            ..limit(batchSize))
          .get();

      if (rows.isEmpty) {
        _isProcessing = false;
        return 0;
      }

      var processedCount = 0;

      for (final row in rows) {
        // Check backoff for retried items
        if (row.retryCount > 0 && row.lastAttemptAt != null) {
          final backoffDuration = _calculateBackoff(row.retryCount);
          final eligibleAt = row.lastAttemptAt!.add(backoffDuration);
          if (now.isBefore(eligibleAt)) continue;
        }

        // Mark as processing
        await (_db.update(_db.syncQueue)
              ..where((t) => t.id.equals(row.id)))
            .write(const SyncQueueCompanion(status: Value('processing')));

        // Process based on operation type
        final success = await _processItem(row);

        if (success) {
          // Mark completed with timestamp
          await (_db.update(_db.syncQueue)
                ..where((t) => t.id.equals(row.id)))
              .write(SyncQueueCompanion(
            status: const Value('completed'),
            completedAt: Value(DateTime.now()),
          ));

          // Clear isDirty on source record
          await _clearDirtyFlag(row);

          _emitEvent(
            dhtKey: row.dhtKey ?? 'unknown',
            status: EvSyncStatus.synced,
          );

          processedCount++;
        } else {
          final newRetryCount = row.retryCount + 1;

          if (newRetryCount >= maxRetries) {
            // Max retries exceeded — mark as failed
            await (_db.update(_db.syncQueue)
                  ..where((t) => t.id.equals(row.id)))
                .write(SyncQueueCompanion(
              status: const Value('failed'),
              retryCount: Value(newRetryCount),
              lastAttemptAt: Value(DateTime.now()),
              lastError: Value(
                'Max retries ($maxRetries) exceeded',
              ),
            ));

            _emitEvent(
              dhtKey: row.dhtKey ?? 'unknown',
              status: EvSyncStatus.syncFailed,
              error: 'Max retries exceeded',
            );
          } else {
            // Revert to pending, increment retry
            await (_db.update(_db.syncQueue)
                  ..where((t) => t.id.equals(row.id)))
                .write(SyncQueueCompanion(
              status: const Value('pending'),
              retryCount: Value(newRetryCount),
              lastAttemptAt: Value(DateTime.now()),
            ));

            _emitEvent(
              dhtKey: row.dhtKey ?? 'unknown',
              status: EvSyncStatus.pendingSync,
              error: 'Retry $newRetryCount/$maxRetries scheduled',
            );
          }
        }
      }

      return processedCount;
    } finally {
      _isProcessing = false;
    }
  }

  /// Dispatches a single sync queue item to the appropriate node operation.
  Future<bool> _processItem(SyncQueueData row) async {
    try {
      switch (row.operation) {
        case 'create':
        case 'update':
          final result = await _node.publishRecord(
            row.dhtKey ?? 'local-${row.localRecordId}',
            row.payload,
          );
          if (result.success && result.dhtKey != null) {
            // Update the dhtKey on the sync queue row if it changed
            if (result.dhtKey != row.dhtKey) {
              await (_db.update(_db.syncQueue)
                    ..where((t) => t.id.equals(row.id)))
                  .write(SyncQueueCompanion(
                dhtKey: Value(result.dhtKey),
              ));
            }
          }
          return result.success;

        case 'delete':
          if (row.dhtKey == null) return true; // Nothing to delete remotely
          return _node.deleteRecord(row.dhtKey!);

        default:
          return false;
      }
    } catch (e) {
      // Update error on the row
      await (_db.update(_db.syncQueue)
            ..where((t) => t.id.equals(row.id)))
          .write(SyncQueueCompanion(
        lastError: Value(e.toString()),
      ));
      return false;
    }
  }

  /// Clears the `isDirty` flag on the source record after successful sync.
  Future<void> _clearDirtyFlag(SyncQueueData row) async {
    try {
      switch (row.recordType) {
        case 'event':
          await (_db.update(_db.cachedEvents)
                ..where((t) => t.id.equals(row.localRecordId)))
              .write(CachedEventsCompanion(
            isDirty: const Value(false),
            lastSyncedAt: Value(DateTime.now()),
          ));
        case 'rsvp':
          await (_db.update(_db.cachedRsvps)
                ..where((t) => t.id.equals(row.localRecordId)))
              .write(CachedRsvpsCompanion(
            isDirty: const Value(false),
            lastSyncedAt: Value(DateTime.now()),
          ));
        // identity, group, message — extend here as needed
      }
    } catch (_) {
      // Source record may have been deleted; safe to ignore
    }
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  /// Deletes completed sync queue records older than [completedRetention].
  Future<void> _cleanupCompleted() async {
    final cutoff = DateTime.now().subtract(completedRetention);
    await (_db.delete(_db.syncQueue)
          ..where((t) => t.status.equals('completed'))
          ..where((t) => t.completedAt.isSmallerThanValue(cutoff)))
        .go();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Calculates exponential backoff duration for a given retry count.
  /// 5s × 2^retryCount → 5s, 10s, 20s, 40s, 80s
  Duration _calculateBackoff(int retryCount) {
    final seconds = syncInterval.inSeconds * (1 << retryCount);
    return Duration(seconds: seconds);
  }

  void _emitEvent({
    required String dhtKey,
    required EvSyncStatus status,
    String? error,
  }) {
    if (_eventController.isClosed) return;
    _eventController.add(EvSyncEvent(
      dhtKey: EvDhtKey(dhtKey),
      status: status,
      errorMessage: error,
      timestamp: DateTime.now(),
    ));
  }

  /// Disposes resources. Call when the service is no longer needed.
  Future<void> dispose() async {
    await stopSync();
    await _eventController.close();
  }
}
