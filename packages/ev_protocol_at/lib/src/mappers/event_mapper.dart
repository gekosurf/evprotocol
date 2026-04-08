import 'package:ev_protocol/ev_protocol.dart';

import '../models/smoke_signal_event.dart';

/// Maps between the app's [EvEvent] domain model and the
/// AT Protocol [SmokeSignalEvent] Lexicon record.
///
/// The Smoke Signal Lexicon is a subset of EvEvent:
/// - No ticketing, no groups, no capacity, no visibility enum
/// - Locations use a different structure (name+address only, no lat/lng)
/// - Uses `startsAt`/`endsAt` instead of `startAt`/`endAt`
class EventMapper {
  EventMapper._();

  /// Convert an [EvEvent] to a [SmokeSignalEvent] for PDS write.
  static SmokeSignalEvent toSmokeSignal(EvEvent event) {
    return SmokeSignalEvent(
      name: event.name,
      description: event.description,
      startsAt: event.startAt.toIso8601(),
      endsAt: event.endAt?.toIso8601(),
      status: 'scheduled',
      locations: event.location != null
          ? [
              SmokeSignalLocation(
                name: event.location!.name,
                address: event.location!.address,
              ),
            ]
          : null,
      createdAt: event.createdAt.toIso8601(),
    );
  }

  /// Convert a [SmokeSignalEvent] from PDS read to an [EvEvent].
  ///
  /// The `atUri` parameter is the `at://` URI returned by the PDS,
  /// which we store as the event's dhtKey (repurposed field — Phase 2).
  static EvEvent fromSmokeSignal(
    SmokeSignalEvent record, {
    required String atUri,
    required String creatorDid,
  }) {
    EvEventLocation? location;
    if (record.locations != null && record.locations!.isNotEmpty) {
      final loc = record.locations!.first;
      location = EvEventLocation(
        name: loc.name,
        address: loc.address,
      );
    }

    return EvEvent(
      dhtKey: EvDhtKey(atUri), // Store AT URI in dhtKey field for now
      creatorPubkey: EvPubkey(creatorDid),
      name: record.name,
      description: record.description,
      startAt: EvTimestamp.parse(record.startsAt),
      endAt: record.endsAt != null
          ? EvTimestamp.parse(record.endsAt!)
          : null,
      location: location,
      createdAt: EvTimestamp.parse(record.createdAt),
    );
  }
}
