import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ev_protocol_veilid/src/data/seed_events.dart';
import 'package:ev_protocol_veilid/src/db/app_database.dart';

/// Seeds the local database with community events on first launch.
///
/// Idempotent — only inserts if the `cachedEvents` table is empty.
/// Seed events are marked `isDirty: false` so they don't enter the SyncQueue.
class SeedDataService {
  final AppDatabase _db;

  SeedDataService(this._db);

  /// Seeds the database with community events if no events exist yet.
  ///
  /// Returns the number of events seeded (0 if the DB already had data).
  Future<int> seedIfEmpty() async {
    final count = await _db.cachedEvents.count().getSingle();
    if (count > 0) return 0;

    final events = generateSeedEvents();

    await _db.batch((batch) {
      for (final event in events) {
        batch.insert(
          _db.cachedEvents,
          CachedEventsCompanion.insert(
            dhtKey: event.dhtKey!.value,
            creatorPubkey: event.creatorPubkey.value,
            name: event.name,
            description: Value(event.description),
            startAt: DateTime.parse(event.startAt.toIso8601()),
            endAt: Value(
              event.endAt != null
                  ? DateTime.parse(event.endAt!.toIso8601())
                  : null,
            ),
            locationName: Value(event.location?.name),
            locationAddress: Value(event.location?.address),
            latitude: Value(event.location?.latitude),
            longitude: Value(event.location?.longitude),
            geohash: Value(event.location?.geohash),
            category: Value(event.category),
            tags: Value(event.tags.join(',')),
            visibility: Value(event.visibility.name),
            rsvpCount: Value(event.rsvpCount),
            maxCapacity: Value(event.maxCapacity),
            ticketingJson: Value(
              event.ticketing != null
                  ? jsonEncode(event.ticketing!.toJson())
                  : null,
            ),
            createdAt: DateTime.parse(event.createdAt.toIso8601()),
            lastSyncedAt: DateTime.now(),
            isDirty: const Value(false), // Already "synced" — no queue entry
          ),
        );
      }
    });

    return events.length;
  }
}
