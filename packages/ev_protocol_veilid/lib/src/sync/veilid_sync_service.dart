import 'dart:async';
import 'dart:convert';

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
  StreamSubscription<DhtValueChange>? _valueChangeSubscription;

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

    // Listen for inbound DHT value changes (real-time sync from peers)
    _valueChangeSubscription = _node.onValueChange.listen(_handleValueChange);

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
    await _valueChangeSubscription?.cancel();
    _valueChangeSubscription = null;

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

      // After processing outgoing, poll for new events from peers
      unawaited(_discoverInBackground());
    }
  }

  /// Runs discovery in the background without blocking the sync loop.
  Future<void> _discoverInBackground() async {
    try {
      final imported = await discoverNewEvents();
      if (imported > 0) {
        // ignore: avoid_print
        print('[Sync] 🔍 Discovered $imported new event(s) from peers');
      }
    } catch (_) {
      // Discovery errors are non-fatal
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

            // Watch the record for future remote changes
            await _node.watchRecord(result.dhtKey!);

            // Announce for peer discovery
            await _node.announceRecord(
              result.dhtKey!,
              row.recordType,
            );
          }
          return result.success;

        case 'delete':
          if (row.dhtKey == null) return true; // Nothing to delete remotely
          // Stop watching before delete
          await _node.unwatchRecord(row.dhtKey!);
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

  // ---------------------------------------------------------------------------
  // Inbound sync — handle remote DHT value changes
  // ---------------------------------------------------------------------------

  /// Called when a watched DHT record is modified by a remote peer.
  ///
  /// Updates the local SQLite cache with the new data.
  Future<void> _handleValueChange(DhtValueChange change) async {
    try {
      // Parse the incoming JSON payload
      final decoded = jsonDecode(change.payload);
      // Skip non-map payloads (e.g. the registry record is a JSON list)
      if (decoded is! Map<String, dynamic>) return;
      final json = decoded;
      final recordType = json[r'$type'] as String?;

      if (recordType != null && recordType.startsWith('ev.event')) {
        // Update or insert the event in local cache
        await _upsertEventFromDht(change.dhtKey, json);

        _emitEvent(
          dhtKey: change.dhtKey,
          status: EvSyncStatus.synced,
        );
      }
      // Extend with other record types (rsvp, group, etc.) as needed
    } catch (e) {
      // ignore: avoid_print
      print('[Sync] Failed to process value change for ${change.dhtKey}: $e');
    }
  }

  /// Upserts an event from a DHT value change into the local cache.
  Future<void> _upsertEventFromDht(
    String dhtKey,
    Map<String, dynamic> json,
  ) async {
    final name = json['name'] as String? ?? 'Unknown';
    final description = json['description'] as String?;
    final category = json['category'] as String?;
    final tagsValue =
        (json['tags'] as List<dynamic>?)?.cast<String>().join(',') ?? '';
    final startAt = json['startAt'] != null
        ? DateTime.tryParse(json['startAt'] as String)
        : null;
    final endAt = json['endAt'] != null
        ? DateTime.tryParse(json['endAt'] as String)
        : null;
    final creatorPubkey =
        json['creatorPubkey'] as String? ?? json['ownerPubkey'] as String? ?? 'unknown';

    // Check if event exists
    final existing = await (_db.select(_db.cachedEvents)
          ..where((t) => t.dhtKey.equals(dhtKey))
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      // Update existing
      await (_db.update(_db.cachedEvents)
            ..where((t) => t.dhtKey.equals(dhtKey)))
          .write(CachedEventsCompanion(
        name: Value(name),
        description: Value(description),
        category: Value(category),
        tags: Value(tagsValue),
        startAt: startAt != null ? Value(startAt) : const Value.absent(),
        endAt: Value(endAt),
        isDirty: const Value(false),
        lastSyncedAt: Value(DateTime.now()),
      ));
    } else {
      // Insert new
      await _db.into(_db.cachedEvents).insert(
            CachedEventsCompanion.insert(
              dhtKey: dhtKey,
              creatorPubkey: creatorPubkey,
              name: name,
              description: Value(description),
              category: Value(category),
              tags: Value(tagsValue),
              startAt: startAt ?? DateTime.now(),
              endAt: Value(endAt),
              isDirty: const Value(false),
              lastSyncedAt: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          );
    }
  }

  // ---------------------------------------------------------------------------
  // Discovery — pull new events from the network
  // ---------------------------------------------------------------------------

  /// Discovers new events from the DHT network and caches them locally.
  ///
  /// Called by pull-to-refresh in the UI.
  Future<int> discoverNewEvents() async {
    try {
      final dhtKeys = await _node.discoverRecords('event');
      var imported = 0;

      for (final dhtKey in dhtKeys) {
        // Skip if we already have this event
        final existing = await (_db.select(_db.cachedEvents)
              ..where((t) => t.dhtKey.equals(dhtKey))
              ..limit(1))
            .getSingleOrNull();
        if (existing != null) continue;

        // Fetch the record from DHT
        final payload = await _node.getRecord(dhtKey);
        if (payload == null) continue;

        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          await _upsertEventFromDht(dhtKey, json);

          // Start watching this record for future changes
          await _node.watchRecord(dhtKey);

          imported++;
        } catch (_) {
          // Skip malformed records
        }
      }

      return imported;
    } catch (e) {
      return 0;
    }
  }

  /// Disposes resources. Call when the service is no longer needed.
  Future<void> dispose() async {
    await stopSync();
    await _eventController.close();
  }
}
