import 'package:drift/drift.dart';
import 'package:ev_protocol_veilid/src/db/tables/cached_events.dart';
import 'package:ev_protocol_veilid/src/db/tables/cached_rsvps.dart';
import 'package:ev_protocol_veilid/src/db/tables/local_identities.dart';
import 'package:ev_protocol_veilid/src/db/tables/sync_queue.dart';

part 'app_database.g.dart';

/// The local SQLite database — single source of truth for offline-first data.
///
/// Tables:
/// - [LocalIdentities] — user's own identity keypair + profile
/// - [CachedEvents] — events synced from DHT
/// - [CachedRsvps] — RSVP records synced from DHT
/// - [SyncQueue] — pending DHT write operations
///
/// The offline-first pattern:
/// 1. All writes go to SQLite first → immediate UI response
/// 2. Writes are queued in [SyncQueue] for background DHT push
/// 3. Reads always come from SQLite (never block on network)
/// 4. Background sync pulls remote changes into SQLite
@DriftDatabase(tables: [
  LocalIdentities,
  CachedEvents,
  CachedRsvps,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Phase 8 added completed_at and status to sync_queue.
          // If the columns already exist (e.g. fresh install at v1 with
          // manually patched .g.dart), ignore the ALTER TABLE error.
          try {
            await m.addColumn(syncQueue, syncQueue.completedAt);
          } catch (_) {}
          try {
            await m.addColumn(syncQueue, syncQueue.status);
          } catch (_) {}
        }
      },
      beforeOpen: (details) async {
        // In development, if schema hash has drifted (e.g. from manual .g.dart
        // edits), validate the critical tables exist. If they don't, wipe and
        // recreate — data loss is acceptable in dev.
        if (details.wasCreated) return;
        try {
          // Quick smoke test — try selecting from all tables
          await customSelect('SELECT 1 FROM local_identities LIMIT 0').get();
          await customSelect('SELECT 1 FROM cached_events LIMIT 0').get();
          await customSelect('SELECT 1 FROM sync_queue LIMIT 0').get();
        } catch (_) {
          // Schema is broken — nuke and recreate
          final m = createMigrator();
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
        }
      },
    );
  }
}

