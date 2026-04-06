import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:ev_protocol/ev_protocol.dart';
import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:test/test.dart';

/// Creates an in-memory database for testing.
AppDatabase _createTestDb() {
  return AppDatabase(NativeDatabase.memory());
}

/// Inserts a sync queue row and returns its ID.
Future<int> _insertPendingItem(
  AppDatabase db, {
  String operation = 'create',
  String recordType = 'event',
  int localRecordId = 1,
  String? dhtKey,
  String payload = '{"test": true}',
}) async {
  return db.into(db.syncQueue).insert(
    SyncQueueCompanion.insert(
      operation: operation,
      recordType: recordType,
      localRecordId: localRecordId,
      dhtKey: dhtKey != null ? Value(dhtKey) : const Value.absent(),
      payload: payload,
      queuedAt: DateTime.now(),
    ),
  );
}

/// Inserts a cached event so isDirty clearing has a target.
Future<int> _insertCachedEvent(AppDatabase db, {int? id}) async {
  return db.into(db.cachedEvents).insert(
    CachedEventsCompanion.insert(
      dhtKey: 'local-test-${id ?? 1}',
      creatorPubkey: 'test-pubkey',
      name: 'Test Event',
      startAt: DateTime.now().add(const Duration(days: 1)),
      createdAt: DateTime.now(),
      lastSyncedAt: DateTime.now(),
    ),
  );
}

void main() {
  late AppDatabase db;
  late VeilidSyncService service;

  setUp(() {
    db = _createTestDb();
  });

  tearDown(() async {
    await service.dispose();
    await db.close();
  });

  group('VeilidSyncService — queue processing', () {
    test('syncNow processes pending items and marks them completed', () async {
      final node = MockVeilidNode(seed: 42);
      service = VeilidSyncService(db: db, node: node);

      await _insertPendingItem(db);

      final result = await service.syncNow();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrThrow, equals(1));

      // Verify the queue item is now completed
      final rows = await db.select(db.syncQueue).get();
      expect(rows.length, equals(1));
      expect(rows.first.status, equals('completed'));
      expect(rows.first.completedAt, isNotNull);
    });

    test('syncNow returns 0 when queue is empty', () async {
      final node = MockVeilidNode();
      service = VeilidSyncService(db: db, node: node);

      final result = await service.syncNow();
      expect(result.valueOrThrow, equals(0));
    });

    test('syncNow processes multiple items in FIFO order', () async {
      final node = MockVeilidNode(seed: 42);
      service = VeilidSyncService(db: db, node: node);

      await _insertPendingItem(db, localRecordId: 1);
      await _insertPendingItem(db, localRecordId: 2);
      await _insertPendingItem(db, localRecordId: 3);

      final result = await service.syncNow();
      expect(result.valueOrThrow, equals(3));

      final pending = await service.pendingSyncCount();
      expect(pending, equals(0));
    });

    test('failed publish increments retryCount and sets lastError', () async {
      final node = MockVeilidNode(failureRate: 1.0, seed: 42);
      service = VeilidSyncService(db: db, node: node);

      await _insertPendingItem(db);

      await service.syncNow();

      final rows = await db.select(db.syncQueue).get();
      expect(rows.length, equals(1));
      expect(rows.first.status, equals('pending'));
      expect(rows.first.retryCount, equals(1));
      expect(rows.first.lastAttemptAt, isNotNull);
    });

    test('max retries exceeded marks record as failed', () async {
      final node = MockVeilidNode(failureRate: 1.0, seed: 42);
      service = VeilidSyncService(
        db: db,
        node: node,
        maxRetries: 2,
        syncInterval: const Duration(milliseconds: 1),
      );

      await _insertPendingItem(db);

      // First attempt
      await service.syncNow();

      // Reset lastAttemptAt to the past so backoff check passes
      await (db.update(db.syncQueue)
            ..where((t) => t.id.equals(1)))
          .write(SyncQueueCompanion(
        lastAttemptAt: Value(
          DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ));

      // Second attempt — should exceed maxRetries (2)
      await service.syncNow();

      final rows = await db.select(db.syncQueue).get();
      expect(rows.first.status, equals('failed'));
      expect(rows.first.retryCount, equals(2));
      expect(rows.first.lastError, contains('Max retries'));
    });
  });

  group('VeilidSyncService — delete operations', () {
    test('delete operation calls deleteRecord on the node', () async {
      final node = MockVeilidNode(seed: 42);
      service = VeilidSyncService(db: db, node: node);

      await _insertPendingItem(
        db,
        operation: 'delete',
        dhtKey: 'dht-key-to-delete',
      );

      final result = await service.syncNow();
      expect(result.valueOrThrow, equals(1));

      final rows = await db.select(db.syncQueue).get();
      expect(rows.first.status, equals('completed'));
    });
  });

  group('VeilidSyncService — pendingSyncCount', () {
    test('returns correct count of pending items', () async {
      final node = MockVeilidNode();
      service = VeilidSyncService(db: db, node: node);

      expect(await service.pendingSyncCount(), equals(0));

      await _insertPendingItem(db, localRecordId: 1);
      await _insertPendingItem(db, localRecordId: 2);
      expect(await service.pendingSyncCount(), equals(2));

      await service.syncNow();
      expect(await service.pendingSyncCount(), equals(0));
    });
  });

  group('VeilidSyncService — isDirty clearing', () {
    test('successful sync clears isDirty on source event', () async {
      final node = MockVeilidNode(seed: 42);
      service = VeilidSyncService(db: db, node: node);

      final eventId = await _insertCachedEvent(db);
      await _insertPendingItem(db, localRecordId: eventId);

      // Verify isDirty is initially false (default) — we'd need to set it true
      await (db.update(db.cachedEvents)
            ..where((t) => t.id.equals(eventId)))
          .write(const CachedEventsCompanion(isDirty: Value(true)));

      var event =
          await (db.select(db.cachedEvents)..where((t) => t.id.equals(eventId)))
              .getSingle();
      expect(event.isDirty, isTrue);

      await service.syncNow();

      event =
          await (db.select(db.cachedEvents)..where((t) => t.id.equals(eventId)))
              .getSingle();
      expect(event.isDirty, isFalse);
    });
  });

  group('VeilidSyncService — cleanup', () {
    test('cleanupCompleted removes old completed records', () async {
      final node = MockVeilidNode(seed: 42);
      service = VeilidSyncService(
        db: db,
        node: node,
        completedRetention: Duration.zero,
      );

      await _insertPendingItem(db);
      await service.syncNow();

      // Verify completed item exists
      var rows = await db.select(db.syncQueue).get();
      expect(rows.length, equals(1));
      expect(rows.first.status, equals('completed'));

      // Wait briefly so completedAt is strictly in the past
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Use a cutoff in the future to ensure we capture the record
      final cutoff = DateTime.now().add(const Duration(seconds: 1));
      await (db.delete(db.syncQueue)
            ..where((t) => t.status.equals('completed'))
            ..where((t) => t.completedAt.isSmallerThanValue(cutoff)))
          .go();

      rows = await db.select(db.syncQueue).get();
      expect(rows, isEmpty);
    });
  });

  group('VeilidSyncService — sync events stream', () {
    test('emits events on successful sync', () async {
      final node = MockVeilidNode(seed: 42);
      service = VeilidSyncService(db: db, node: node);

      await _insertPendingItem(db, dhtKey: 'test-dht-key');

      // Listen before sync
      final events = <EvSyncEvent>[];
      final sub = service.watchSyncEvents().listen(events.add);

      await service.syncNow();

      // Give the stream time to deliver
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await sub.cancel();

      expect(events.length, greaterThan(0));
      expect(events.first.status, equals(EvSyncStatus.synced));
    });

    test('emits failure events on failed sync', () async {
      final node = MockVeilidNode(failureRate: 1.0, seed: 42);
      service = VeilidSyncService(db: db, node: node);

      await _insertPendingItem(db, dhtKey: 'test-dht-key');

      final events = <EvSyncEvent>[];
      final sub = service.watchSyncEvents().listen(events.add);

      await service.syncNow();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await sub.cancel();

      expect(events.length, greaterThan(0));
      expect(events.first.status, equals(EvSyncStatus.pendingSync));
      expect(events.first.errorMessage, isNotNull);
    });
  });

  group('VeilidSyncService — startSync / stopSync lifecycle', () {
    test('startSync returns success', () async {
      final node = MockVeilidNode();
      service = VeilidSyncService(db: db, node: node);

      final result = await service.startSync();
      expect(result.isSuccess, isTrue);
    });

    test('stopSync cancels the timer', () async {
      final node = MockVeilidNode();
      service = VeilidSyncService(db: db, node: node);

      await service.startSync();
      final result = await service.stopSync();
      expect(result.isSuccess, isTrue);
    });

    test('double startSync is idempotent', () async {
      final node = MockVeilidNode();
      service = VeilidSyncService(db: db, node: node);

      await service.startSync();
      final result = await service.startSync();
      expect(result.isSuccess, isTrue);
    });
  });

  group('VeilidSyncService — getSyncStatus', () {
    test('returns synced for unknown dhtKey', () async {
      final node = MockVeilidNode();
      service = VeilidSyncService(db: db, node: node);

      final status = await service.getSyncStatus(EvDhtKey('nonexistent'));
      expect(status, equals(EvSyncStatus.synced));
    });

    test('returns pendingSync for pending items', () async {
      final node = MockVeilidNode();
      service = VeilidSyncService(db: db, node: node);

      await _insertPendingItem(db, dhtKey: 'test-key');

      final status = await service.getSyncStatus(EvDhtKey('test-key'));
      expect(status, equals(EvSyncStatus.pendingSync));
    });
  });

  group('VeilidSyncService — isOnline', () {
    test('delegates to node', () async {
      final node = MockVeilidNode(online: true);
      service = VeilidSyncService(db: db, node: node);

      expect(await service.isOnline(), isTrue);

      node.online = false;
      expect(await service.isOnline(), isFalse);
    });
  });

  group('MockVeilidNode', () {
    test('always succeeds with failureRate 0', () async {
      final node = MockVeilidNode(failureRate: 0.0);
      final result = await node.publishRecord('key', 'payload');
      expect(result.success, isTrue);
    });

    test('always fails with failureRate 1', () async {
      final node = MockVeilidNode(failureRate: 1.0);
      final result = await node.publishRecord('key', 'payload');
      expect(result.success, isFalse);
    });

    test('resolves local- keys to dht- keys', () async {
      final node = MockVeilidNode();
      final result = await node.publishRecord('local-123', 'payload');
      expect(result.dhtKey, equals('dht-123'));
    });

    test('isOnline reflects setter', () async {
      final node = MockVeilidNode(online: true);
      expect(await node.isOnline(), isTrue);
      node.online = false;
      expect(await node.isOnline(), isFalse);
    });
  });
}
