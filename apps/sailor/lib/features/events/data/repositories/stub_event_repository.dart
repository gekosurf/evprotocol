import 'package:ev_protocol/ev_protocol.dart';
import 'package:sailor/features/events/domain/repositories/event_repository.dart';

/// Stub implementation of [EventRepository] with mock sailing events.
///
/// Will be replaced by a real implementation backed by SQLite + Veilid DHT.
class StubEventRepository implements EventRepository {
  late final List<EvEvent> _events;
  final EvPubkey _currentUserPubkey;

  StubEventRepository({required EvPubkey currentUserPubkey})
      : _currentUserPubkey = currentUserPubkey {
    _events = _generateMockEvents();
  }

  @override
  Future<EventPage> getEvents({String? cursor, int limit = 20}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final startIndex = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    final endIndex = (startIndex + limit).clamp(0, _events.length);
    final page = _events.sublist(startIndex, endIndex);
    final hasMore = endIndex < _events.length;

    return EventPage(
      events: page,
      nextCursor: hasMore ? endIndex.toString() : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<EvEvent?> getEvent(EvDhtKey dhtKey) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    try {
      return _events.firstWhere(
        (e) => e.name.hashCode.toString() == dhtKey.value,
      );
    } catch (_) {
      return null;
    }
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
    await Future.delayed(const Duration(milliseconds: 500));
    final newEvent = EvEvent(
      dhtKey: EvDhtKey('mock_${DateTime.now().millisecondsSinceEpoch}'),
      creatorPubkey: EvPubkey('stub_user'),
      name: name,
      description: description,
      startAt: EvTimestamp.parse(startAt.toIso8601String()),
      endAt: endAt != null ? EvTimestamp.parse(endAt.toIso8601String()) : null,
      location: location,
      category: category,
      tags: tags,
      createdAt: EvTimestamp.parse(DateTime.now().toIso8601String()),
      visibility: EvEventVisibility.public_,
    );
    _events.insert(0, newEvent);
    return newEvent;
  }

  @override
  Future<EvRsvp> rsvpToEvent({
    required EvDhtKey eventDhtKey,
    required EvRsvpStatus status,
    int guestCount = 0,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return EvRsvp(
      eventDhtKey: eventDhtKey,
      attendeePubkey: _currentUserPubkey,
      status: status,
      guestCount: guestCount,
      createdAt: EvTimestamp.now(),
    );
  }

  @override
  Future<List<EvRsvp>> getEventRsvps(EvDhtKey eventDhtKey) async {
    return [];
  }

  @override
  Future<void> deleteEvent(EvDhtKey dhtKey) async {
    _events.removeWhere(
      (e) => e.name.hashCode.toString() == dhtKey.value,
    );
  }

  @override
  Future<EventPage> getMyEvents({String? cursor, int limit = 20}) async {
    final myEvents = _events
        .where((e) => e.creatorPubkey == _currentUserPubkey)
        .toList();
    return EventPage(events: myEvents);
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
    var results = List<EvEvent>.from(_events);
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((e) =>
          e.name.toLowerCase().contains(q) ||
          (e.description?.toLowerCase().contains(q) ?? false)).toList();
    }
    if (category != null) {
      results = results.where((e) => e.category == category).toList();
    }
    return EventPage(events: results);
  }

  @override
  Future<EventPage> searchMyEvents({
    String? query,
    String? category,
    String? cursor,
    int limit = 20,
  }) async {
    var results = _events
        .where((e) => e.creatorPubkey == _currentUserPubkey)
        .toList();
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((e) =>
          e.name.toLowerCase().contains(q) ||
          (e.description?.toLowerCase().contains(q) ?? false)).toList();
    }
    if (category != null) {
      results = results.where((e) => e.category == category).toList();
    }
    return EventPage(events: results);
  }

  @override
  Future<List<String>> getCategories() async {
    return _events
        .where((e) => e.category != null)
        .map((e) => e.category!)
        .toSet()
        .toList()
      ..sort();
  }

  List<EvEvent> _generateMockEvents() {
    final now = DateTime.now().toUtc();
    final organiser = EvPubkey.fromRawKey('rpyc-organiser-key');

    return [
      EvEvent(
        creatorPubkey: organiser,
        name: 'RPYC Wednesday Twilight Series',
        description:
            'Weekly twilight race around the cans off Fremantle. All classes welcome. Skipper\'s briefing at 1630, first gun at 1700.',
        startAt: EvTimestamp.parse(
          now.add(const Duration(days: 2)).toIso8601String(),
        ),
        endAt: EvTimestamp.parse(
          now.add(const Duration(days: 2, hours: 3)).toIso8601String(),
        ),
        location: const EvEventLocation(
          name: 'Royal Perth Yacht Club',
          latitude: -31.9655,
          longitude: 115.8405,
          address: 'Australia II Drive, Crawley WA 6009',
        ),
        tags: ['racing', 'twilight', 'rpyc'],
        rsvpCount: 34,
        createdAt: EvTimestamp.parse(
          now.subtract(const Duration(days: 5)).toIso8601String(),
        ),
        visibility: EvEventVisibility.public_,
      ),
      EvEvent(
        creatorPubkey: organiser,
        name: 'Fremantle to Rottnest Island Race',
        description:
            'Annual offshore classic. 12nm dash from Fremantle to Rottnest. IRC and PHS handicap divisions. Entry fee includes post-race BBQ on the island.',
        startAt: EvTimestamp.parse(
          now.add(const Duration(days: 14)).toIso8601String(),
        ),
        endAt: EvTimestamp.parse(
          now.add(const Duration(days: 14, hours: 6)).toIso8601String(),
        ),
        location: const EvEventLocation(
          name: 'Fremantle Sailing Club',
          latitude: -32.0569,
          longitude: 115.7426,
          address: 'Marine Terrace, Fremantle WA 6160',
        ),
        tags: ['offshore', 'rottnest', 'annual'],
        rsvpCount: 67,
        createdAt: EvTimestamp.parse(
          now.subtract(const Duration(days: 30)).toIso8601String(),
        ),
        visibility: EvEventVisibility.public_,
        ticketing: const EvTicketing(
          model: EvTicketModel.fixed,
          currency: 'AUD',
          acceptedMethods: [],
          tiers: [
            EvTicketTier(
              name: 'Entry',
              priceMinor: 8500,
              quantity: 120,
            ),
          ],
        ),
      ),
      EvEvent(
        creatorPubkey: EvPubkey.fromRawKey('fsc-organiser'),
        name: 'Laser Dinghy Open Day',
        description:
            'Free open day for new sailors. Try a Laser dinghy on the river. All equipment provided. Perfect for beginners aged 12+.',
        startAt: EvTimestamp.parse(
          now.add(const Duration(days: 7)).toIso8601String(),
        ),
        endAt: EvTimestamp.parse(
          now.add(const Duration(days: 7, hours: 4)).toIso8601String(),
        ),
        location: const EvEventLocation(
          name: 'South of Perth Yacht Club',
          latitude: -32.0210,
          longitude: 115.8490,
          address: 'The Esplanade, Como WA 6152',
        ),
        tags: ['dinghy', 'beginner', 'free'],
        rsvpCount: 12,
        createdAt: EvTimestamp.parse(
          now.subtract(const Duration(days: 3)).toIso8601String(),
        ),
        visibility: EvEventVisibility.public_,
      ),
      EvEvent(
        creatorPubkey: EvPubkey.fromRawKey('claremont-yc'),
        name: 'Cruising Division Raft-Up',
        description:
            'Social raft-up at Matilda Bay. BYO sundowners. All cruising boats welcome — motor or sail.',
        startAt: EvTimestamp.parse(
          now.add(const Duration(days: 5)).toIso8601String(),
        ),
        location: const EvEventLocation(
          name: 'Matilda Bay',
          latitude: -31.9750,
          longitude: 115.8380,
        ),
        tags: ['cruising', 'social', 'raft-up'],
        rsvpCount: 18,
        createdAt: EvTimestamp.parse(
          now.subtract(const Duration(days: 2)).toIso8601String(),
        ),
        visibility: EvEventVisibility.public_,
      ),
      EvEvent(
        creatorPubkey: EvPubkey.fromRawKey('safety-officer'),
        name: 'Sea Safety & EPIRB Workshop',
        description:
            'Mandatory safety briefing for all offshore racers. Covers EPIRB registration, flare protocols, MOB drills, and life raft deployment. BYO PFD.',
        startAt: EvTimestamp.parse(
          now.add(const Duration(days: 10)).toIso8601String(),
        ),
        endAt: EvTimestamp.parse(
          now.add(const Duration(days: 10, hours: 2)).toIso8601String(),
        ),
        location: const EvEventLocation(
          name: 'Royal Perth Yacht Club — Wardroom',
          latitude: -31.9655,
          longitude: 115.8405,
        ),
        tags: ['safety', 'offshore', 'workshop'],
        rsvpCount: 24,
        createdAt: EvTimestamp.parse(
          now.subtract(const Duration(days: 7)).toIso8601String(),
        ),
        visibility: EvEventVisibility.public_,
      ),
      EvEvent(
        creatorPubkey: _currentUserPubkey,
        name: 'Swan River Sunset Cruise',
        description:
            'Casual sunset sail with friends. Departing from RPYC marina at 1700. Bring snacks and good vibes.',
        startAt: EvTimestamp.parse(
          now.add(const Duration(days: 3)).toIso8601String(),
        ),
        location: const EvEventLocation(
          name: 'RPYC Marina',
          latitude: -31.9657,
          longitude: 115.8410,
        ),
        tags: ['social', 'sunset', 'casual'],
        rsvpCount: 6,
        createdAt: EvTimestamp.parse(
          now.subtract(const Duration(hours: 12)).toIso8601String(),
        ),
        visibility: EvEventVisibility.private_,
      ),
    ];
  }
}
