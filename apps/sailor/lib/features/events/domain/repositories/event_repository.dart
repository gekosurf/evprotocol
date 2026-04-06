import 'package:ev_protocol/ev_protocol.dart';

/// Abstract repository for event operations.
///
/// Implementations handle local SQLite storage and background DHT sync.
abstract class EventRepository {
  /// Gets a paginated list of events.
  ///
  /// [cursor] is an opaque pagination token. Pass null for the first page.
  Future<EventPage> getEvents({
    String? cursor,
    int limit = 20,
  });

  /// Gets a single event by its DHT key.
  Future<EvEvent?> getEvent(EvDhtKey dhtKey);

  /// Creates a new event.
  ///
  /// Writes to local SQLite first, then queues DHT publish.
  Future<EvEvent> createEvent({
    required String name,
    String? description,
    required DateTime startAt,
    DateTime? endAt,
    EvEventLocation? location,
    List<String> tags,
  });

  /// RSVPs to an event.
  Future<EvRsvp> rsvpToEvent({
    required EvDhtKey eventDhtKey,
    required EvRsvpStatus status,
    int guestCount,
  });

  /// Gets RSVPs for an event.
  Future<List<EvRsvp>> getEventRsvps(EvDhtKey eventDhtKey);

  /// Deletes an event (only if creator).
  Future<void> deleteEvent(EvDhtKey dhtKey);
}

/// A page of events with optional cursor for pagination.
class EventPage {
  final List<EvEvent> events;
  final String? nextCursor;
  final bool hasMore;

  const EventPage({
    required this.events,
    this.nextCursor,
    this.hasMore = false,
  });
}
