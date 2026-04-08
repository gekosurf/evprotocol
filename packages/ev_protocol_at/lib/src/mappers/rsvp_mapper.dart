import 'package:ev_protocol/ev_protocol.dart';

import '../models/smoke_signal_rsvp.dart';

/// Maps between the app's [EvRsvp] domain model and the
/// AT Protocol [SmokeSignalRsvp] Lexicon record.
///
/// The Smoke Signal RSVP is much simpler than EvRsvp:
/// - No tickets, no payments, no guest count
/// - Uses `going | interested | notgoing` instead of pending/confirmed/etc.
class RsvpMapper {
  RsvpMapper._();

  /// Map EvRsvpStatus → Smoke Signal RSVP status string.
  static String _toSmokeSignalStatus(EvRsvpStatus status) {
    switch (status) {
      case EvRsvpStatus.confirmed:
        return 'going';
      case EvRsvpStatus.pending:
        return 'interested';
      case EvRsvpStatus.cancelled:
      case EvRsvpStatus.declined:
        return 'notgoing';
      case EvRsvpStatus.waitlisted:
        return 'interested';
    }
  }

  /// Map Smoke Signal status string → EvRsvpStatus.
  static EvRsvpStatus _fromSmokeSignalStatus(String status) {
    switch (status) {
      case 'going':
        return EvRsvpStatus.confirmed;
      case 'interested':
        return EvRsvpStatus.pending;
      case 'notgoing':
        return EvRsvpStatus.cancelled;
      default:
        return EvRsvpStatus.pending;
    }
  }

  /// Convert an [EvRsvp] to a [SmokeSignalRsvp] for PDS write.
  ///
  /// The `eventAtUri` is the `at://` URI of the event being RSVP'd to.
  static SmokeSignalRsvp toSmokeSignal(EvRsvp rsvp, {required String eventAtUri}) {
    return SmokeSignalRsvp(
      eventUri: eventAtUri,
      status: _toSmokeSignalStatus(rsvp.status),
      createdAt: rsvp.createdAt.toIso8601(),
    );
  }

  /// Convert a [SmokeSignalRsvp] from PDS read to an [EvRsvp].
  static EvRsvp fromSmokeSignal(
    SmokeSignalRsvp record, {
    required String atUri,
    required String attendeeDid,
  }) {
    return EvRsvp(
      dhtKey: EvDhtKey(atUri),
      eventDhtKey: EvDhtKey(record.eventUri),
      attendeePubkey: EvPubkey(attendeeDid),
      status: _fromSmokeSignalStatus(record.status),
      createdAt: EvTimestamp.parse(record.createdAt),
    );
  }
}
