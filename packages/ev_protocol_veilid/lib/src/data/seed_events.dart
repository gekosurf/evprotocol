import 'package:ev_protocol/ev_protocol.dart';

/// Curated seed events for the Discover feed.
///
/// These are inserted into SQLite on first launch to make the app feel alive.
/// All locations are real Perth, Western Australia sailing venues.
List<EvEvent> generateSeedEvents() {
  final now = DateTime.now();

  return [
    EvEvent(
      dhtKey: EvDhtKey('seed-event-twilight-series'),
      creatorPubkey: EvPubkey.fromRawKey('ev:seed:community'),
      name: 'Wednesday Twilight Series',
      description:
          'Weekly twilight racing on the Swan River. All keelboat classes '
          'welcome. Skipper briefing at 16:30, first start at 17:00. '
          'BBQ and drinks at the clubhouse after racing.\n\n'
          'New crew members always welcome — no experience required.',
      startAt: EvTimestamp.parse(
        now
            .add(Duration(days: _daysUntilWeekday(now, DateTime.wednesday)))
            .copyWith(hour: 17, minute: 0, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      endAt: EvTimestamp.parse(
        now
            .add(Duration(days: _daysUntilWeekday(now, DateTime.wednesday)))
            .copyWith(hour: 20, minute: 0, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      location: const EvEventLocation(
        name: 'Royal Perth Yacht Club',
        address: 'Hackett Dr, Crawley WA 6009',
        latitude: -31.9668,
        longitude: 115.8375,
        geohash: 'qd66hr',
      ),
      category: 'sailing',
      tags: ['racing', 'twilight', 'keelboats'],
      visibility: EvEventVisibility.public_,
      rsvpCount: 42,
      createdAt: EvTimestamp.parse(
        now.subtract(const Duration(days: 14)).toUtc().toIso8601String(),
      ),
    ),
    EvEvent(
      dhtKey: EvDhtKey('seed-event-freo-sunset'),
      creatorPubkey: EvPubkey.fromRawKey('ev:seed:community'),
      name: 'Fremantle Harbour Sunset Sail',
      description:
          'A relaxed social sail departing from Fremantle Sailing Club. '
          'Cruise past the harbour wall, watch the sunset over the Indian '
          'Ocean, and return for fish & chips on the balcony.\n\n'
          'BYO drinks. Life jackets provided. Suitable for all ages.',
      startAt: EvTimestamp.parse(
        now
            .add(Duration(days: _daysUntilWeekday(now, DateTime.saturday) + 3))
            .copyWith(hour: 16, minute: 30, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      endAt: EvTimestamp.parse(
        now
            .add(Duration(days: _daysUntilWeekday(now, DateTime.saturday) + 3))
            .copyWith(hour: 19, minute: 30, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      location: const EvEventLocation(
        name: 'Fremantle Sailing Club',
        address: '151 Marine Terrace, Fremantle WA 6160',
        latitude: -32.0569,
        longitude: 115.7416,
        geohash: 'qd66h2',
      ),
      category: 'social',
      tags: ['sunset', 'social', 'family-friendly'],
      visibility: EvEventVisibility.public_,
      rsvpCount: 28,
      maxCapacity: 40,
      createdAt: EvTimestamp.parse(
        now.subtract(const Duration(days: 7)).toUtc().toIso8601String(),
      ),
    ),
    EvEvent(
      dhtKey: EvDhtKey('seed-event-safety-bay-sup'),
      creatorPubkey: EvPubkey.fromRawKey('ev:seed:community'),
      name: 'Safety Bay SUP & Sail Mashup',
      description:
          'Stand-up paddleboard and dinghy sailing social at Safety Bay. '
          'SUP boards available for hire (\$20/session). Bring your own '
          'dinghy or crew with someone else.\n\n'
          'Meet at the boat ramp at 09:00. Coffee van on site.',
      startAt: EvTimestamp.parse(
        now
            .add(Duration(days: _daysUntilWeekday(now, DateTime.sunday) + 7))
            .copyWith(hour: 9, minute: 0, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      endAt: EvTimestamp.parse(
        now
            .add(Duration(days: _daysUntilWeekday(now, DateTime.sunday) + 7))
            .copyWith(hour: 13, minute: 0, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      location: const EvEventLocation(
        name: 'Safety Bay Yacht Club',
        address: 'Arcadia Dr, Safety Bay WA 6169',
        latitude: -32.3157,
        longitude: 115.7373,
        geohash: 'qd65mp',
      ),
      category: 'watersports',
      tags: ['SUP', 'dinghy', 'social'],
      visibility: EvEventVisibility.public_,
      rsvpCount: 15,
      createdAt: EvTimestamp.parse(
        now.subtract(const Duration(days: 3)).toUtc().toIso8601String(),
      ),
    ),
    EvEvent(
      dhtKey: EvDhtKey('seed-event-rotto-briefing'),
      creatorPubkey: EvPubkey.fromRawKey('ev:seed:community'),
      name: 'Rottnest Channel Crossing — Skipper Briefing',
      description:
          'Mandatory skipper briefing for the upcoming Rottnest Island '
          'Channel Crossing. Covers safety procedures, weather contingencies, '
          'start sequences, and course layout.\n\n'
          'All competing skippers must attend. Non-skippers welcome to '
          'observe. Pizza provided.',
      startAt: EvTimestamp.parse(
        now
            .add(Duration(days: _daysUntilWeekday(now, DateTime.thursday) + 14))
            .copyWith(hour: 18, minute: 30, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      endAt: EvTimestamp.parse(
        now
            .add(Duration(days: _daysUntilWeekday(now, DateTime.thursday) + 14))
            .copyWith(hour: 20, minute: 30, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      location: const EvEventLocation(
        name: 'Royal Freshwater Bay Yacht Club',
        address: 'Keane St, Peppermint Grove WA 6011',
        latitude: -31.9807,
        longitude: 115.7622,
        geohash: 'qd66h8',
      ),
      category: 'racing',
      tags: ['rottnest', 'offshore', 'briefing'],
      visibility: EvEventVisibility.public_,
      rsvpCount: 67,
      createdAt: EvTimestamp.parse(
        now.subtract(const Duration(days: 21)).toUtc().toIso8601String(),
      ),
    ),
    EvEvent(
      dhtKey: EvDhtKey('seed-event-full-moon-paddle'),
      creatorPubkey: EvPubkey.fromRawKey('ev:seed:community'),
      name: 'Swan River Full Moon Paddle',
      description:
          'Join us for a magical full moon paddle on the Swan River. '
          'Kayaks, canoes, and SUPs all welcome. We launch from Elizabeth '
          'Quay foreshore and paddle upstream to the Narrows Bridge, then '
          'return under the moonlight.\n\n'
          'Bring a headlamp and warm layers. Watercraft not provided.',
      startAt: EvTimestamp.parse(
        now
            .add(Duration(days: _daysUntilWeekday(now, DateTime.friday) + 21))
            .copyWith(hour: 19, minute: 0, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      endAt: EvTimestamp.parse(
        now
            .add(Duration(days: _daysUntilWeekday(now, DateTime.friday) + 21))
            .copyWith(hour: 22, minute: 0, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      location: const EvEventLocation(
        name: 'Elizabeth Quay',
        address: 'Elizabeth Quay, Perth WA 6000',
        latitude: -31.9590,
        longitude: 115.8580,
        geohash: 'qd66hs',
      ),
      category: 'social',
      tags: ['paddle', 'moonlight', 'adventure'],
      visibility: EvEventVisibility.public_,
      rsvpCount: 34,
      maxCapacity: 50,
      createdAt: EvTimestamp.parse(
        now.subtract(const Duration(days: 5)).toUtc().toIso8601String(),
      ),
    ),
    EvEvent(
      dhtKey: EvDhtKey('seed-event-sopyc-agm'),
      creatorPubkey: EvPubkey.fromRawKey('ev:seed:community'),
      name: 'South of Perth Yacht Club — AGM',
      description:
          'Annual General Meeting of the South of Perth Yacht Club. '
          'Agenda includes commodore\'s report, treasurer\'s report, '
          'election of office bearers, and discussion of the upcoming '
          'season calendar.\n\n'
          'Members only. Proxy forms available at the office.',
      startAt: EvTimestamp.parse(
        now
            .add(Duration(
                days: _daysUntilWeekday(now, DateTime.tuesday) + 28))
            .copyWith(hour: 19, minute: 0, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      endAt: EvTimestamp.parse(
        now
            .add(Duration(
                days: _daysUntilWeekday(now, DateTime.tuesday) + 28))
            .copyWith(hour: 21, minute: 0, second: 0)
            .toUtc()
            .toIso8601String(),
      ),
      location: const EvEventLocation(
        name: 'South of Perth Yacht Club',
        address: 'The Esplanade, South Perth WA 6151',
        latitude: -31.9696,
        longitude: 115.8651,
        geohash: 'qd66ht',
      ),
      category: 'club',
      tags: ['AGM', 'members', 'governance'],
      visibility: EvEventVisibility.groupOnly,
      rsvpCount: 23,
      createdAt: EvTimestamp.parse(
        now.subtract(const Duration(days: 10)).toUtc().toIso8601String(),
      ),
    ),
  ];
}

/// Returns the number of days from [from] until the next [weekday] (1=Mon..7=Sun).
/// If [from] is already the target weekday, returns 7 (next week).
int _daysUntilWeekday(DateTime from, int weekday) {
  final diff = (weekday - from.weekday) % 7;
  return diff == 0 ? 7 : diff;
}
