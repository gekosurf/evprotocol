import 'package:ev_protocol/ev_protocol.dart';
import 'package:ev_protocol_at/ev_protocol_at.dart';
import 'package:sailor/features/events/domain/repositories/event_repository.dart';

/// Adapter that wraps [AtEventRepository] to satisfy the [EventRepository]
/// interface expected by usage across the app.
///
/// This bridges the gap between the AT Protocol layer's API and the
/// app's domain interface, which still uses EvDhtKey parameters.
class AtEventRepositoryAdapter implements EventRepository {
  final AtEventRepository _atRepo;

  AtEventRepositoryAdapter(this._atRepo);

  @override
  Future<EventPage> getEvents({String? cursor, int limit = 20}) async {
    final page = await _atRepo.getEvents(cursor: cursor, limit: limit);
    return EventPage(
      events: page.events,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  @override
  Future<EvEvent?> getEvent(EvDhtKey dhtKey) async {
    return _atRepo.getEvent(dhtKey.value);
  }

  @override
  Future<EvEvent> createEvent({
    required String name,
    String? description,
    required DateTime startAt,
    DateTime? endAt,
    EvEventLocation? location,
    String? category,
    List<String> tags = const [],
  }) async {
    return _atRepo.createEvent(
      name: name,
      description: description,
      startAt: startAt,
      endAt: endAt,
      location: location,
      category: category,
      tags: tags,
    );
  }

  @override
  Future<EvRsvp> rsvpToEvent({
    required EvDhtKey eventDhtKey,
    required EvRsvpStatus status,
    int guestCount = 0,
  }) async {
    return _atRepo.rsvpToEvent(
      eventKey: eventDhtKey.value,
      status: status,
      guestCount: guestCount,
    );
  }

  @override
  Future<List<EvRsvp>> getEventRsvps(EvDhtKey eventDhtKey) async {
    return _atRepo.getEventRsvps(eventDhtKey.value);
  }

  @override
  Future<void> deleteEvent(EvDhtKey dhtKey) async {
    return _atRepo.deleteEvent(dhtKey.value);
  }

  @override
  Future<EventPage> getMyEvents({String? cursor, int limit = 20}) async {
    final page = await _atRepo.getMyEvents(cursor: cursor, limit: limit);
    return EventPage(
      events: page.events,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
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
    final page = await _atRepo.searchEvents(
      query: query,
      category: category,
      fromDate: fromDate,
      toDate: toDate,
      cursor: cursor,
      limit: limit,
    );
    return EventPage(
      events: page.events,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  @override
  Future<EventPage> searchMyEvents({
    String? query,
    String? category,
    String? cursor,
    int limit = 20,
  }) async {
    // Use searchEvents filtered by current user — AtEventRepository
    // handles this via getMyEvents for now.
    final page = await _atRepo.getMyEvents(cursor: cursor, limit: limit);
    return EventPage(
      events: page.events,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  @override
  Future<List<String>> getCategories() async {
    return _atRepo.getCategories();
  }
}
