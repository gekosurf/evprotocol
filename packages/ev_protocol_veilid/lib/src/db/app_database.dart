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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here
      },
    );
  }
}
