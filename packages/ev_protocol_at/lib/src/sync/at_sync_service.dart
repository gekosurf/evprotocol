import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ev_protocol/ev_protocol.dart';
import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:flutter/foundation.dart';

import '../auth/at_auth_service.dart';
import '../lexicon_nsids.dart';
import '../mappers/event_mapper.dart';
import '../mappers/rsvp_mapper.dart';

/// Background sync service that processes the offline queue.
///
/// Reads dirty records from [SyncQueue] and pushes them to the user's PDS.
/// Runs on a periodic timer — no persistent connections needed.
class AtSyncService {
  final AppDatabase _db;
  final AtAuthService _auth;
  Timer? _timer;

  /// Stream controller for pending sync count (drives UI indicator).
  final _pendingCountController = StreamController<int>.broadcast();

  /// Stream of pending sync item count.
  Stream<int> get pendingCount => _pendingCountController.stream;

  AtSyncService(this._db, this._auth);

  /// Start the periodic sync timer.
  ///
  /// Processes the queue every [interval] (default: 30 seconds).
  void start({Duration interval = const Duration(seconds: 30)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => processQueue());
    // Also process immediately on start
    processQueue();
  }

  /// Stop the sync timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Process all pending items in the sync queue.
  ///
  /// Returns the number of successfully synced items.
  Future<int> processQueue() async {
    if (!_auth.isAuthenticated) {
      await _emitPendingCount();
      return 0;
    }

    final pendingItems = await (_db.select(_db.syncQueue)
          ..where((t) => t.status.isNull() | t.status.equals('pending'))
          ..orderBy([
            (t) => OrderingTerm(expression: t.queuedAt, mode: OrderingMode.asc)
          ])
          ..limit(10))
        .get();

    if (pendingItems.isEmpty) {
      _pendingCountController.add(0);
      return 0;
    }

    int synced = 0;

    for (final item in pendingItems) {
      try {
        final success = await _processItem(item);
        if (success) {
          // Mark as completed
          await (_db.update(_db.syncQueue)
                ..where((t) => t.id.equals(item.id)))
              .write(SyncQueueCompanion(
            status: const Value('completed'),
            completedAt: Value(DateTime.now()),
          ));
          synced++;
        }
      } catch (e) {
        debugPrint('[AtSync] Failed to process queue item ${item.id}: $e');
        // Mark as failed for retry
        await (_db.update(_db.syncQueue)
              ..where((t) => t.id.equals(item.id)))
            .write(const SyncQueueCompanion(
          status: Value('failed'),
        ));
      }
    }

    await _emitPendingCount();
    debugPrint('[AtSync] Processed $synced/${pendingItems.length} queue items');
    return synced;
  }

  Future<bool> _processItem(SyncQueueData item) async {
    final client = _auth.client;
    if (client == null) return false;

    switch ('${item.operation}:${item.recordType}') {
      case 'create:event':
        return _pushEvent(item);
      case 'create:rsvp':
        return _pushRsvp(item);
      case 'delete:event':
        return _deleteRecord(item);
      default:
        debugPrint('[AtSync] Unknown operation: ${item.operation}:${item.recordType}');
        return true; // Remove unknown items from queue
    }
  }

  Future<bool> _pushEvent(SyncQueueData item) async {
    final client = _auth.client!;
    final eventJson = jsonDecode(item.payload) as Map<String, dynamic>;
    final event = EvEvent.fromJson(eventJson);
    final smokeSignal = EventMapper.toSmokeSignal(event);

    final result = await client.atproto.repo.createRecord(
      repo: _auth.did!,
      collection: LexiconNsids.event,
      record: smokeSignal.toRecord(),
    );

    final atUri = result.data.uri.toString();

    // Update local record with real AT URI
    await (_db.update(_db.cachedEvents)
          ..where((t) => t.id.equals(item.localRecordId)))
        .write(CachedEventsCompanion(
      dhtKey: Value(atUri),
      isDirty: const Value(false),
      lastSyncedAt: Value(DateTime.now()),
    ));

    debugPrint('[AtSync] Event synced → $atUri');
    return true;
  }

  Future<bool> _pushRsvp(SyncQueueData item) async {
    final client = _auth.client!;
    final rsvpJson = jsonDecode(item.payload) as Map<String, dynamic>;
    final rsvp = EvRsvp.fromJson(rsvpJson);

    // Look up the event's current dhtKey — it may have been updated
    // from a local-xxx key to an at:// URI by the event sync.
    String eventAtUri = rsvp.eventDhtKey.value;

    if (!eventAtUri.startsWith('at://')) {
      // Try to find the event's current key in SQLite
      final eventRow = await _db.customSelect(
        'SELECT dht_key FROM cached_events WHERE dht_key = ? OR id = (SELECT local_record_id FROM sync_queue WHERE record_type = \'event\' AND status = \'completed\' LIMIT 1)',
        variables: [Variable.withString(eventAtUri)],
      ).getSingleOrNull();

      if (eventRow != null) {
        final resolvedKey = eventRow.read<String>('dht_key');
        if (resolvedKey.startsWith('at://')) {
          eventAtUri = resolvedKey;
        }
      }

      // If still not an at:// URI, defer to next cycle
      if (!eventAtUri.startsWith('at://')) {
        debugPrint('[AtSync] RSVP deferred — event not yet synced: $eventAtUri');
        return false;
      }
    }

    final smokeSignal = RsvpMapper.toSmokeSignal(rsvp, eventAtUri: eventAtUri);

    await client.atproto.repo.createRecord(
      repo: _auth.did!,
      collection: LexiconNsids.rsvp,
      record: smokeSignal.toRecord(),
    );

    // Mark as synced
    await (_db.update(_db.cachedRsvps)
          ..where((t) => t.id.equals(item.localRecordId)))
        .write(const CachedRsvpsCompanion(
      isDirty: Value(false),
    ));

    debugPrint('[AtSync] RSVP synced');
    return true;
  }

  Future<bool> _deleteRecord(SyncQueueData item) async {
    final client = _auth.client!;
    final atUri = item.payload;
    if (!atUri.startsWith('at://')) return true; // Local-only, skip

    final parts = atUri.replaceFirst('at://', '').split('/');
    if (parts.length < 3) return true;

    await client.atproto.repo.deleteRecord(
      repo: parts[0],
      collection: parts[1],
      rkey: parts[2],
    );

    debugPrint('[AtSync] Record deleted from PDS: $atUri');
    return true;
  }

  Future<void> _emitPendingCount() async {
    final count = await _db.customSelect(
      "SELECT COUNT(*) AS c FROM sync_queue WHERE status IS NULL OR status = 'pending'",
    ).getSingle();
    _pendingCountController.add(count.read<int>('c'));
  }

  /// Dispose of resources.
  void dispose() {
    stop();
    _pendingCountController.close();
  }
}
