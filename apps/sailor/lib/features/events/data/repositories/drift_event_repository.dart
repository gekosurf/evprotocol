import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:ev_protocol/ev_protocol.dart';
import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:sailor/features/events/domain/repositories/event_repository.dart';

class DriftEventRepository implements EventRepository {
  final AppDatabase _db;
  final EvPubkey _currentUserPubkey;

  DriftEventRepository(this._db, this._currentUserPubkey);

  @override
  Future<EventPage> getEvents({String? cursor, int limit = 20}) async {
    final offset = cursor != null ? int.tryParse(cursor) ?? 0 : 0;

    final rows = await (_db.select(_db.cachedEvents)
          ..orderBy([
            (t) => OrderingTerm(expression: t.startAt, mode: OrderingMode.asc)
          ])
          ..limit(limit + 1, offset: offset))
        .get();

    final hasMore = rows.length > limit;
    final eventsToReturn = hasMore ? rows.take(limit).toList() : rows;

    final events = eventsToReturn.map(_mapRowToEvent).toList();

    return EventPage(
      events: events,
      nextCursor: hasMore ? (offset + limit).toString() : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<EvEvent?> getEvent(EvDhtKey dhtKey) async {
    final row = await (_db.select(_db.cachedEvents)
          ..where((t) => t.dhtKey.equals(dhtKey.value))
          ..limit(1))
        .getSingleOrNull();

    if (row == null) return null;
    return _mapRowToEvent(row);
  }

  @override
  Future<EvEvent> createEvent({
    required String name,
    String? description,
    required DateTime startAt,
    DateTime? endAt,
    EvEventLocation? location,
    List<String> tags = const [],
  }) async {
    final event = EvEvent(
      dhtKey: EvDhtKey('local-${DateTime.now().millisecondsSinceEpoch}'), // Temp key until Veilid publish
      creatorPubkey: _currentUserPubkey,
      name: name,
      description: description,
      startAt: EvTimestamp.parse(startAt.toUtc().toIso8601String()),
      endAt: endAt != null ? EvTimestamp.parse(endAt.toUtc().toIso8601String()) : null,
      location: location,
      tags: tags,
      createdAt: EvTimestamp.now(),
      visibility: EvEventVisibility.public_,
    );

    await _db.transaction(() async {
      final localId = await _db.into(_db.cachedEvents).insert(
        CachedEventsCompanion.insert(
          dhtKey: event.dhtKey!.value,
          creatorPubkey: event.creatorPubkey.value,
          name: event.name,
          description: Value(event.description),
          startAt: DateTime.parse(event.startAt.toIso8601()),
          endAt: Value(event.endAt != null ? DateTime.parse(event.endAt!.toIso8601()) : null),
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
          groupDhtKey: Value(event.groupDhtKey?.value),
          ticketingJson: Value(event.ticketing != null ? jsonEncode(event.ticketing!.toJson()) : null),
          createdAt: DateTime.parse(event.createdAt.toIso8601()),
          updatedAt: Value(event.updatedAt != null ? DateTime.parse(event.updatedAt!.toIso8601()) : null),
          lastSyncedAt: DateTime.now(),
          isDirty: const Value(true),
          evVersion: Value(event.evVersion),
        ),
      );

      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          operation: 'create',
          recordType: 'event',
          localRecordId: localId,
          payload: jsonEncode(event.toJson()),
          queuedAt: DateTime.now(),
        ),
      );
    });

    return event;
  }

  @override
  Future<EvRsvp> rsvpToEvent({
    required EvDhtKey eventDhtKey,
    required EvRsvpStatus status,
    int guestCount = 0,
  }) async {
    final rsvp = EvRsvp(
      dhtKey: EvDhtKey('local-rsvp-${DateTime.now().millisecondsSinceEpoch}'),
      eventDhtKey: eventDhtKey,
      attendeePubkey: _currentUserPubkey,
      status: status,
      guestCount: guestCount,
      createdAt: EvTimestamp.now(),
    );

    await _db.transaction(() async {
      await _db.into(_db.cachedRsvps).insert(
        CachedRsvpsCompanion.insert(
          eventDhtKey: rsvp.eventDhtKey.value,
          attendeePubkey: rsvp.attendeePubkey.value,
          status: rsvp.status.name,
          guestCount: Value(rsvp.guestCount),
          createdAt: DateTime.parse(rsvp.createdAt.toIso8601()),
          lastSyncedAt: DateTime.now(),
          isDirty: const Value(true),
        ),
        onConflict: DoUpdate(
          (old) => CachedRsvpsCompanion(
            status: Value(rsvp.status.name),
            guestCount: Value(rsvp.guestCount),
            lastSyncedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ),
          target: [_db.cachedRsvps.eventDhtKey, _db.cachedRsvps.attendeePubkey],
        ),
      );

      final row = await (_db.select(_db.cachedRsvps)
            ..where((t) => t.eventDhtKey.equals(rsvp.eventDhtKey.value))
            ..where((t) => t.attendeePubkey.equals(rsvp.attendeePubkey.value))
            ..limit(1))
          .getSingle();

      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          operation: 'create',
          recordType: 'rsvp',
          localRecordId: row.id,
          payload: jsonEncode(rsvp.toJson()),
          queuedAt: DateTime.now(),
        ),
      );
    });

    return rsvp;
  }

  @override
  Future<List<EvRsvp>> getEventRsvps(EvDhtKey eventDhtKey) async {
    final rows = await (_db.select(_db.cachedRsvps)
          ..where((t) => t.eventDhtKey.equals(eventDhtKey.value)))
        .get();

    return rows.map((row) {
      return EvRsvp(
        eventDhtKey: EvDhtKey(row.eventDhtKey),
        attendeePubkey: EvPubkey(row.attendeePubkey),
        status: EvRsvpStatus.values.firstWhere(
          (e) => e.name == row.status,
          orElse: () => EvRsvpStatus.pending,
        ),
        guestCount: row.guestCount,
        createdAt: EvTimestamp.parse(row.createdAt.toIso8601String()),
      );
    }).toList();
  }

  @override
  Future<void> deleteEvent(EvDhtKey dhtKey) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.cachedEvents)
            ..where((t) => t.dhtKey.equals(dhtKey.value))
            ..limit(1))
          .getSingleOrNull();

      if (row != null) {
        await _db.into(_db.syncQueue).insert(
          SyncQueueCompanion.insert(
            operation: 'delete',
            recordType: 'event',
            localRecordId: row.id,
            dhtKey: Value(dhtKey.value),
            payload: '{}', 
            queuedAt: DateTime.now(),
          ),
        );

        await (_db.delete(_db.cachedEvents)..where((t) => t.dhtKey.equals(dhtKey.value))).go();
      }
    });
  }

  @override
  Future<EventPage> getMyEvents({String? cursor, int limit = 20}) async {
    final offset = cursor != null ? int.tryParse(cursor) ?? 0 : 0;

    // Diagnostic: count all events in the table
    final allCount = await _db.select(_db.cachedEvents).get();
    // ignore: avoid_print
    print('[DB] 📊 Total events in cachedEvents table: ${allCount.length}');
    for (final e in allCount) {
      // ignore: avoid_print
      print('[DB]   → id=${e.id} name="${e.name}" dhtKey=${e.dhtKey} creator=${e.creatorPubkey}');
    }

    final rows = await (_db.select(_db.cachedEvents)
          ..orderBy([
            (t) => OrderingTerm(expression: t.startAt, mode: OrderingMode.asc)
          ])
          ..limit(limit + 1, offset: offset))
        .get();

    // ignore: avoid_print
    print('[DB] 📋 getMyEvents returning ${rows.length} rows');

    final hasMore = rows.length > limit;
    final eventsToReturn = hasMore ? rows.take(limit).toList() : rows;
    final events = eventsToReturn.map(_mapRowToEvent).toList();

    return EventPage(
      events: events,
      nextCursor: hasMore ? (offset + limit).toString() : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<EventPage> searchEvents({
    String? query,
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
    String? cursor,
    int limit = 20,
  }) async {
    final offset = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    final q = _db.select(_db.cachedEvents);

    if (query != null && query.trim().isNotEmpty) {
      final pattern = '%${query.trim().toLowerCase()}%';
      q.where((t) =>
          t.name.lower().like(pattern) |
          t.description.lower().like(pattern) |
          t.locationName.lower().like(pattern) |
          t.tags.lower().like(pattern));
    }
    if (category != null && category.isNotEmpty) {
      q.where((t) => t.category.equals(category));
    }
    if (fromDate != null) {
      q.where((t) => t.startAt.isBiggerOrEqualValue(fromDate));
    }
    if (toDate != null) {
      q.where((t) => t.startAt.isSmallerOrEqualValue(toDate));
    }

    q.orderBy([
      (t) => OrderingTerm(expression: t.startAt, mode: OrderingMode.asc),
    ]);
    q.limit(limit + 1, offset: offset);

    final rows = await q.get();
    final hasMore = rows.length > limit;
    final eventsToReturn = hasMore ? rows.take(limit).toList() : rows;

    return EventPage(
      events: eventsToReturn.map(_mapRowToEvent).toList(),
      nextCursor: hasMore ? (offset + limit).toString() : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<EventPage> searchMyEvents({
    String? query,
    String? category,
    String? cursor,
    int limit = 20,
  }) async {
    final offset = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    final q = _db.select(_db.cachedEvents);

    if (query != null && query.trim().isNotEmpty) {
      final pattern = '%${query.trim().toLowerCase()}%';
      q.where((t) =>
          t.name.lower().like(pattern) |
          t.description.lower().like(pattern) |
          t.locationName.lower().like(pattern) |
          t.tags.lower().like(pattern));
    }
    if (category != null && category.isNotEmpty) {
      q.where((t) => t.category.equals(category));
    }

    q.orderBy([
      (t) => OrderingTerm(expression: t.startAt, mode: OrderingMode.asc),
    ]);
    q.limit(limit + 1, offset: offset);

    final rows = await q.get();
    final hasMore = rows.length > limit;
    final eventsToReturn = hasMore ? rows.take(limit).toList() : rows;

    return EventPage(
      events: eventsToReturn.map(_mapRowToEvent).toList(),
      nextCursor: hasMore ? (offset + limit).toString() : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<List<String>> getCategories() async {
    final rows = await _db.customSelect(
      'SELECT DISTINCT category FROM cached_events WHERE category IS NOT NULL ORDER BY category',
    ).get();
    return rows.map((r) => r.read<String>('category')).toList();
  }

  EvEvent _mapRowToEvent(CachedEvent row) {
    EvEventLocation? location;
    if (row.locationName != null || row.locationAddress != null || row.latitude != null || row.longitude != null) {
      location = EvEventLocation(
        name: row.locationName,
        address: row.locationAddress,
        latitude: row.latitude,
        longitude: row.longitude,
        geohash: row.geohash,
      );
    }

    EvTicketing? ticketing;
    if (row.ticketingJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(row.ticketingJson!);
        ticketing = EvTicketing.fromJson(json);
      } catch (_) {}
    }

    return EvEvent(
      dhtKey: EvDhtKey(row.dhtKey),
      creatorPubkey: EvPubkey(row.creatorPubkey),
      name: row.name,
      description: row.description,
      startAt: EvTimestamp.parse(row.startAt.toUtc().toIso8601String()),
      endAt: row.endAt != null ? EvTimestamp.parse(row.endAt!.toUtc().toIso8601String()) : null,
      location: location,
      category: row.category,
      tags: row.tags.isNotEmpty ? row.tags.split(',') : const [],
      ticketing: ticketing,
      visibility: EvEventVisibility.values.firstWhere(
        (e) => e.name == row.visibility,
        orElse: () => EvEventVisibility.public_,
      ),
      maxCapacity: row.maxCapacity,
      rsvpCount: row.rsvpCount,
      groupDhtKey: row.groupDhtKey != null ? EvDhtKey(row.groupDhtKey!) : null,
      createdAt: EvTimestamp.parse(row.createdAt.toUtc().toIso8601String()),
      updatedAt: row.updatedAt != null ? EvTimestamp.parse(row.updatedAt!.toUtc().toIso8601String()) : null,
      evVersion: row.evVersion,
    );
  }
}
