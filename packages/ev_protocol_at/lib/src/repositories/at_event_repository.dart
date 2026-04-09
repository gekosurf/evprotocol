import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ev_protocol/ev_protocol.dart';
import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:flutter/foundation.dart';

import '../auth/at_auth_service.dart';
import '../auth/cross_pds_resolver.dart';
import '../lexicon_nsids.dart';
import '../mappers/event_mapper.dart';
import '../mappers/rsvp_mapper.dart';
import '../models/smoke_signal_event.dart';
import '../models/smoke_signal_rsvp.dart';

/// AT Protocol-backed event repository.
///
/// Offline-first pattern:
/// - WRITE: SQLite first (instant UI) → queue PDS push
/// - READ: SQLite cache → optional background refresh from PDS
/// - All PDS failures are non-fatal — data is safe in SQLite
class AtEventRepository {
  final AppDatabase _db;
  final AtAuthService _auth;

  AtEventRepository(this._db, this._auth);

  // ═══════════════════════════════════════════════════════════════════
  // READ OPERATIONS
  // ═══════════════════════════════════════════════════════════════════

  /// Get paginated events from local cache.
  Future<AtEventPage> getEvents({String? cursor, int limit = 20}) async {
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

    return AtEventPage(
      events: events,
      nextCursor: hasMore ? (offset + limit).toString() : null,
      hasMore: hasMore,
    );
  }

  /// Get a single event by its key (AT URI or local key).
  Future<EvEvent?> getEvent(String key) async {
    final row = await (_db.select(_db.cachedEvents)
          ..where((t) => t.dhtKey.equals(key))
          ..limit(1))
        .getSingleOrNull();

    if (row == null) return null;
    return _mapRowToEvent(row);
  }

  /// Get events created by the current user.
  Future<AtEventPage> getMyEvents({String? cursor, int limit = 20}) async {
    final did = _auth.did;
    if (did == null) return const AtEventPage(events: []);

    final offset = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    final rows = await (_db.select(_db.cachedEvents)
          ..where((t) => t.creatorPubkey.equals(did))
          ..orderBy([
            (t) => OrderingTerm(expression: t.startAt, mode: OrderingMode.desc)
          ])
          ..limit(limit + 1, offset: offset))
        .get();

    final hasMore = rows.length > limit;
    final eventsToReturn = hasMore ? rows.take(limit).toList() : rows;
    final events = eventsToReturn.map(_mapRowToEvent).toList();

    return AtEventPage(
      events: events,
      nextCursor: hasMore ? (offset + limit).toString() : null,
      hasMore: hasMore,
    );
  }

  /// Get RSVPs for an event from local cache.
  Future<List<EvRsvp>> getEventRsvps(String eventKey) async {
    final rows = await (_db.select(_db.cachedRsvps)
          ..where((t) => t.eventDhtKey.equals(eventKey)))
        .get();

    return rows.map((row) {
      return EvRsvp(
        dhtKey: EvDhtKey(row.eventDhtKey),
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

  /// Get all unique DIDs seen in cached events and RSVPs.
  ///
  /// Used for RSVP auto-discovery: any new DID that appears here
  /// can be auto-added to the connections list.
  Future<Set<String>> getAllKnownDids() async {
    final eventDids = await _db.customSelect(
      'SELECT DISTINCT creator_pubkey FROM cached_events',
    ).get();

    final rsvpDids = await _db.customSelect(
      'SELECT DISTINCT attendee_pubkey FROM cached_rsvps',
    ).get();

    return {
      ...eventDids.map((r) => r.read<String>('creator_pubkey')),
      ...rsvpDids.map((r) => r.read<String>('attendee_pubkey')),
    };
  }

  // ═══════════════════════════════════════════════════════════════════
  // WRITE OPERATIONS (offline-first)
  // ═══════════════════════════════════════════════════════════════════

  /// Create an event.
  ///
  /// 1. Write to SQLite immediately (UI sees it instantly)
  /// 2. Push to PDS in background
  /// 3. Store resulting at:// URI back in SQLite
  Future<EvEvent> createEvent({
    required String name,
    String? description,
    required DateTime startAt,
    DateTime? endAt,
    EvEventLocation? location,
    String? category,
    List<String> tags = const [],
  }) async {
    final did = _auth.did ?? 'local';
    final now = DateTime.now().toUtc();

    // Generate a local key. Will be replaced with at:// URI after PDS push.
    final localKey = 'local-${now.millisecondsSinceEpoch}';

    final event = EvEvent(
      dhtKey: EvDhtKey(localKey),
      creatorPubkey: EvPubkey(did),
      name: name,
      description: description,
      startAt: EvTimestamp.parse(startAt.toUtc().toIso8601String()),
      endAt: endAt != null
          ? EvTimestamp.parse(endAt.toUtc().toIso8601String())
          : null,
      location: location,
      category: category,
      tags: tags,
      createdAt: EvTimestamp.parse(now.toIso8601String()),
      visibility: EvEventVisibility.public_,
    );

    // Step 1: Write to SQLite
    final localId = await _insertEventToDb(event);

    // Step 2: Queue sync
    await _db.into(_db.syncQueue).insert(
      SyncQueueCompanion.insert(
        operation: 'create',
        recordType: 'event',
        localRecordId: localId,
        payload: jsonEncode(event.toJson()),
        queuedAt: now,
      ),
    );

    return event;
  }

  /// RSVP to an event.
  ///
  /// 1. Write to SQLite immediately
  /// 2. Push to PDS in background
  Future<EvRsvp> rsvpToEvent({
    required String eventKey,
    required EvRsvpStatus status,
    int guestCount = 0,
  }) async {
    final did = _auth.did ?? 'local';
    final now = DateTime.now().toUtc();

    final rsvp = EvRsvp(
      dhtKey: EvDhtKey('local-rsvp-${now.millisecondsSinceEpoch}'),
      eventDhtKey: EvDhtKey(eventKey),
      attendeePubkey: EvPubkey(did),
      status: status,
      guestCount: guestCount,
      createdAt: EvTimestamp.parse(now.toIso8601String()),
    );

    // Step 1: Upsert to SQLite
    await _db.into(_db.cachedRsvps).insert(
      CachedRsvpsCompanion.insert(
        eventDhtKey: rsvp.eventDhtKey.value,
        attendeePubkey: rsvp.attendeePubkey.value,
        status: rsvp.status.name,
        guestCount: Value(rsvp.guestCount),
        createdAt: now,
        lastSyncedAt: now,
        isDirty: const Value(true),
      ),
      onConflict: DoUpdate(
        (old) => CachedRsvpsCompanion(
          status: Value(rsvp.status.name),
          guestCount: Value(rsvp.guestCount),
          lastSyncedAt: Value(now),
          isDirty: const Value(true),
        ),
        target: [_db.cachedRsvps.eventDhtKey, _db.cachedRsvps.attendeePubkey],
      ),
    );

    // Step 2: Queue sync
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
        queuedAt: now,
      ),
    );

    // Increment rsvpCount on the event for immediate UI feedback
    if (status == EvRsvpStatus.confirmed) {
      await _db.customUpdate(
        'UPDATE cached_events SET rsvp_count = rsvp_count + 1 WHERE dht_key = ?',
        variables: [Variable.withString(eventKey)],
        updates: {_db.cachedEvents},
      );
    }

    return rsvp;
  }

  /// Delete an event.
  Future<void> deleteEvent(String key) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.cachedEvents)
            ..where((t) => t.dhtKey.equals(key))
            ..limit(1))
          .getSingleOrNull();

      if (row != null) {
        await _db.into(_db.syncQueue).insert(
          SyncQueueCompanion.insert(
            operation: 'delete',
            recordType: 'event',
            localRecordId: row.id,
            payload: key,
            queuedAt: DateTime.now(),
          ),
        );

        await (_db.delete(_db.cachedEvents)
              ..where((t) => t.dhtKey.equals(key)))
            .go();
      }
    });

    // Try PDS delete in background
    _tryDeleteFromPds(key);
  }

  // ═══════════════════════════════════════════════════════════════════
  // PDS SYNC (background, non-blocking)
  // ═══════════════════════════════════════════════════════════════════



  /// Attempt to delete a record from the PDS.
  void _tryDeleteFromPds(String atUri) async {
    final client = _auth.client;
    if (client == null || !atUri.startsWith('at://')) return;

    try {
      // Parse the AT URI: at://did/collection/rkey
      final parts = atUri.replaceFirst('at://', '').split('/');
      if (parts.length < 3) return;

      await client.atproto.repo.deleteRecord(
        repo: parts[0],
        collection: parts[1],
        rkey: parts[2],
      );
      debugPrint('[AtSync] Record deleted from PDS: $atUri');
    } catch (e) {
      debugPrint('[AtSync] PDS delete failed: $e');
    }
  }

  /// Refresh local cache from PDS. Call on pull-to-refresh or app foreground.
  ///
  /// Scans the current user's PDS plus any [additionalDids] (connections).
  Future<int> refreshFromPds({List<String> additionalDids = const []}) async {
    final client = _auth.client;
    if (client == null) return 0;

    final selfDid = _auth.did!;
    // Deduplicated list: self first, then connections
    final didsToScan = <String>{selfDid, ...additionalDids}.toList();
    int totalCount = 0;

    for (final did in didsToScan) {
      final isSelf = did == selfDid;
      try {
        // Refresh events for this DID
        totalCount += await _refreshEventsForDid(client, did, isSelf);

        // Refresh RSVPs for this DID
        await _refreshRsvpsForDid(client, did, isSelf);

        debugPrint('[AtSync] Scanned $did${isSelf ? ' (self)' : ' (cross-PDS)'}');
      } catch (e) {
        debugPrint('[AtSync] PDS scan failed for $did: $e');
      }
    }

    // Recompute rsvpCount from actual RSVP records
    await _db.customUpdate(
      '''UPDATE cached_events SET rsvp_count = (
        SELECT COUNT(*) FROM cached_rsvps
        WHERE cached_rsvps.event_dht_key = cached_events.dht_key
        AND cached_rsvps.status = 'confirmed'
      )''',
      updates: {_db.cachedEvents},
    );

    debugPrint('[AtSync] Refreshed $totalCount events from ${didsToScan.length} PDS repos');
    return totalCount;
  }

  /// Refresh events for a single DID.
  /// Uses direct SDK call for self, CrossPdsResolver for others.
  Future<int> _refreshEventsForDid(dynamic client, String did, bool isSelf) async {
    int count = 0;

    if (isSelf) {
      // Self: use authenticated SDK client (same PDS)
      final result = await client.atproto.repo.listRecords(
        repo: did,
        collection: LexiconNsids.event,
      );
      for (final record in result.data.records) {
        final smokeSignal = SmokeSignalEvent.fromRecord(record.value);
        final event = EventMapper.fromSmokeSignal(
          smokeSignal,
          atUri: record.uri.toString(),
          creatorDid: did,
        );
        await _insertOrUpdateEventInDb(event);
        count++;
      }
    } else {
      // Cross-PDS: resolve their PDS and query directly
      final records = await CrossPdsResolver.listRecords(
        did: did,
        collection: LexiconNsids.event,
      );
      for (final record in records) {
        final uri = record['uri'] as String? ?? '';
        final value = record['value'] as Map<String, dynamic>? ?? {};
        final smokeSignal = SmokeSignalEvent.fromRecord(value);
        final event = EventMapper.fromSmokeSignal(
          smokeSignal,
          atUri: uri,
          creatorDid: did,
        );
        await _insertOrUpdateEventInDb(event);
        count++;
      }
    }

    return count;
  }

  /// Refresh RSVPs for a single DID.
  Future<void> _refreshRsvpsForDid(dynamic client, String did, bool isSelf) async {
    try {
      if (isSelf) {
        final result = await client.atproto.repo.listRecords(
          repo: did,
          collection: LexiconNsids.rsvp,
        );
        for (final record in result.data.records) {
          final smokeSignal = SmokeSignalRsvp.fromRecord(record.value);
          final rsvp = RsvpMapper.fromSmokeSignal(
            smokeSignal,
            atUri: record.uri.toString(),
            attendeeDid: did,
          );
          await _upsertRsvpToDb(rsvp);
        }
      } else {
        final records = await CrossPdsResolver.listRecords(
          did: did,
          collection: LexiconNsids.rsvp,
        );
        for (final record in records) {
          final uri = record['uri'] as String? ?? '';
          final value = record['value'] as Map<String, dynamic>? ?? {};
          final smokeSignal = SmokeSignalRsvp.fromRecord(value);

          // Skip orphaned RSVPs that reference local-* event keys
          if (smokeSignal.eventUri.startsWith('local-')) {
            continue;
          }

          final rsvp = RsvpMapper.fromSmokeSignal(
            smokeSignal,
            atUri: uri,
            attendeeDid: did,
          );
          await _upsertRsvpToDb(rsvp);
        }
      }
    } catch (e) {
      debugPrint('[AtSync] RSVP refresh failed for $did: $e');
    }
  }

  /// Upsert an RSVP record into the local cache.
  Future<void> _upsertRsvpToDb(EvRsvp rsvp) async {
    final now = DateTime.now();
    await _db.into(_db.cachedRsvps).insert(
      CachedRsvpsCompanion.insert(
        eventDhtKey: rsvp.eventDhtKey.value,
        attendeePubkey: rsvp.attendeePubkey.value,
        status: rsvp.status.name,
        guestCount: Value(rsvp.guestCount),
        createdAt: DateTime.parse(rsvp.createdAt.toIso8601()),
        lastSyncedAt: now,
        isDirty: const Value(false),
      ),
      onConflict: DoUpdate(
        (old) => CachedRsvpsCompanion(
          status: Value(rsvp.status.name),
          guestCount: Value(rsvp.guestCount),
          lastSyncedAt: Value(now),
          isDirty: const Value(false),
        ),
        target: [
          _db.cachedRsvps.eventDhtKey,
          _db.cachedRsvps.attendeePubkey,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SEARCH (local SQLite only for Phase 2)
  // ═══════════════════════════════════════════════════════════════════

  /// Search events in local cache.
  Future<AtEventPage> searchEvents({
    String? query,
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
    String? cursor,
    int limit = 20,
  }) async {
    final offset = cursor != null ? int.tryParse(cursor) ?? 0 : 0;

    var select = _db.select(_db.cachedEvents);
    if (query != null && query.isNotEmpty) {
      select = select..where((t) => t.name.like('%$query%'));
    }
    if (category != null) {
      select = select..where((t) => t.category.equals(category));
    }
    if (fromDate != null) {
      select = select..where((t) => t.startAt.isBiggerOrEqualValue(fromDate));
    }
    if (toDate != null) {
      select = select..where((t) => t.startAt.isSmallerOrEqualValue(toDate));
    }

    final rows = await (select
          ..orderBy([
            (t) => OrderingTerm(expression: t.startAt, mode: OrderingMode.asc)
          ])
          ..limit(limit + 1, offset: offset))
        .get();

    final hasMore = rows.length > limit;
    final eventsToReturn = hasMore ? rows.take(limit).toList() : rows;
    final events = eventsToReturn.map(_mapRowToEvent).toList();

    return AtEventPage(
      events: events,
      nextCursor: hasMore ? (offset + limit).toString() : null,
      hasMore: hasMore,
    );
  }

  /// Get all distinct categories.
  Future<List<String>> getCategories() async {
    final rows = await _db.customSelect(
      'SELECT DISTINCT category FROM cached_events WHERE category IS NOT NULL ORDER BY category',
    ).get();
    return rows.map((r) => r.read<String>('category')).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // INTERNAL HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Future<int> _insertEventToDb(EvEvent event) async {
    return await _db.into(_db.cachedEvents).insert(
      CachedEventsCompanion.insert(
        dhtKey: event.dhtKey!.value,
        creatorPubkey: event.creatorPubkey.value,
        name: event.name,
        description: Value(event.description),
        startAt: DateTime.parse(event.startAt.toIso8601()),
        endAt: Value(event.endAt != null
            ? DateTime.parse(event.endAt!.toIso8601())
            : null),
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
        ticketingJson: Value(event.ticketing != null
            ? jsonEncode(event.ticketing!.toJson())
            : null),
        createdAt: DateTime.parse(event.createdAt.toIso8601()),
        updatedAt: Value(event.updatedAt != null
            ? DateTime.parse(event.updatedAt!.toIso8601())
            : null),
        lastSyncedAt: DateTime.now(),
        isDirty: const Value(true),
        evVersion: Value(event.evVersion),
      ),
    );
  }

  Future<void> _insertOrUpdateEventInDb(EvEvent event) async {
    await _db.into(_db.cachedEvents).insert(
      CachedEventsCompanion.insert(
        dhtKey: event.dhtKey!.value,
        creatorPubkey: event.creatorPubkey.value,
        name: event.name,
        description: Value(event.description),
        startAt: DateTime.parse(event.startAt.toIso8601()),
        endAt: Value(event.endAt != null
            ? DateTime.parse(event.endAt!.toIso8601())
            : null),
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
        ticketingJson: Value(event.ticketing != null
            ? jsonEncode(event.ticketing!.toJson())
            : null),
        createdAt: DateTime.parse(event.createdAt.toIso8601()),
        updatedAt: Value(event.updatedAt != null
            ? DateTime.parse(event.updatedAt!.toIso8601())
            : null),
        lastSyncedAt: DateTime.now(),
        isDirty: const Value(false),
        evVersion: Value(event.evVersion),
      ),
      onConflict: DoUpdate(
        (old) => CachedEventsCompanion(
          creatorPubkey: Value(event.creatorPubkey.value),
          name: Value(event.name),
          description: Value(event.description),
          startAt: Value(DateTime.parse(event.startAt.toIso8601())),
          endAt: Value(event.endAt != null
              ? DateTime.parse(event.endAt!.toIso8601())
              : null),
          locationName: Value(event.location?.name),
          locationAddress: Value(event.location?.address),
          latitude: Value(event.location?.latitude),
          longitude: Value(event.location?.longitude),
          geohash: Value(event.location?.geohash),
          category: Value(event.category),
          tags: Value(event.tags.join(',')),
          visibility: Value(event.visibility.name),
          // Note: rsvpCount is NOT overwritten from PDS — Smoke Signal events
          // don't carry this field (always 0). It's computed from local RSVP records.
          groupDhtKey: Value(event.groupDhtKey?.value),
          ticketingJson: Value(event.ticketing != null
              ? jsonEncode(event.ticketing!.toJson())
              : null),
          updatedAt: Value(event.updatedAt != null
              ? DateTime.parse(event.updatedAt!.toIso8601())
              : null),
          lastSyncedAt: Value(DateTime.now()),
          isDirty: const Value(false),
          evVersion: Value(event.evVersion),
        ),
        target: [_db.cachedEvents.dhtKey],
      ),
    );
  }

  EvEvent _mapRowToEvent(CachedEvent row) {
    return EvEvent(
      dhtKey: EvDhtKey(row.dhtKey),
      creatorPubkey: EvPubkey(row.creatorPubkey),
      name: row.name,
      description: row.description,
      startAt: EvTimestamp.parse(row.startAt.toIso8601String()),
      endAt: row.endAt != null
          ? EvTimestamp.parse(row.endAt!.toIso8601String())
          : null,
      location: (row.locationName != null || row.locationAddress != null)
          ? EvEventLocation(
              name: row.locationName,
              address: row.locationAddress,
              latitude: row.latitude,
              longitude: row.longitude,
              geohash: row.geohash,
            )
          : null,
      category: row.category,
      tags: row.tags.split(',').where((t) => t.isNotEmpty).toList(),
      visibility: EvEventVisibility.values.firstWhere(
        (v) => v.name == row.visibility,
        orElse: () => EvEventVisibility.public_,
      ),
      rsvpCount: row.rsvpCount,
      maxCapacity: row.maxCapacity,
      groupDhtKey:
          row.groupDhtKey != null ? EvDhtKey(row.groupDhtKey!) : null,
      ticketing: row.ticketingJson != null
          ? EvTicketing.fromJson(
              jsonDecode(row.ticketingJson!) as Map<String, dynamic>)
          : null,
      createdAt: EvTimestamp.parse(row.createdAt.toIso8601String()),
      updatedAt: row.updatedAt != null
          ? EvTimestamp.parse(row.updatedAt!.toIso8601String())
          : null,
      evVersion: row.evVersion,
    );
  }
}

/// A page of events with pagination.
class AtEventPage {
  final List<EvEvent> events;
  final String? nextCursor;
  final bool hasMore;

  const AtEventPage({
    required this.events,
    this.nextCursor,
    this.hasMore = false,
  });
}
