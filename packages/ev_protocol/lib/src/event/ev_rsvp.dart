import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';

/// An RSVP / registration record for an event.
///
/// Schema: `ev.event.rsvp`
///
/// Single-writer DHT record — only the attendee can modify their RSVP.
class EvRsvp {
  /// DHT key for this RSVP record.
  final EvDhtKey? dhtKey;

  /// DHT key of the event being RSVP'd to.
  final EvDhtKey eventDhtKey;

  /// Public key of the attendee.
  final EvPubkey attendeePubkey;

  /// RSVP status.
  final EvRsvpStatus status;

  /// Ticket tier name (if paid event).
  final String? tierName;

  /// DHT key of the payment receipt (if paid).
  final EvDhtKey? receiptDhtKey;

  /// DHT key of the ticket token (for QR verification).
  final EvDhtKey? ticketDhtKey;

  /// Whether the RSVP should be visible to other attendees.
  final bool isPublic;

  /// Optional message to the organiser.
  final String? message;

  /// Number of additional guests.
  final int guestCount;

  /// When the RSVP was created.
  final EvTimestamp createdAt;

  /// When the RSVP was last updated.
  final EvTimestamp? updatedAt;

  const EvRsvp({
    this.dhtKey,
    required this.eventDhtKey,
    required this.attendeePubkey,
    required this.status,
    this.tierName,
    this.receiptDhtKey,
    this.ticketDhtKey,
    this.isPublic = true,
    this.message,
    this.guestCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  EvRsvp copyWith({
    EvDhtKey? dhtKey,
    EvDhtKey? eventDhtKey,
    EvPubkey? attendeePubkey,
    EvRsvpStatus? status,
    String? tierName,
    EvDhtKey? receiptDhtKey,
    EvDhtKey? ticketDhtKey,
    bool? isPublic,
    String? message,
    int? guestCount,
    EvTimestamp? createdAt,
    EvTimestamp? updatedAt,
  }) {
    return EvRsvp(
      dhtKey: dhtKey ?? this.dhtKey,
      eventDhtKey: eventDhtKey ?? this.eventDhtKey,
      attendeePubkey: attendeePubkey ?? this.attendeePubkey,
      status: status ?? this.status,
      tierName: tierName ?? this.tierName,
      receiptDhtKey: receiptDhtKey ?? this.receiptDhtKey,
      ticketDhtKey: ticketDhtKey ?? this.ticketDhtKey,
      isPublic: isPublic ?? this.isPublic,
      message: message ?? this.message,
      guestCount: guestCount ?? this.guestCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.event.rsvp',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'eventDhtKey': eventDhtKey.toString(),
        'attendeePubkey': attendeePubkey.toString(),
        'status': status.name,
        if (tierName != null) 'tierName': tierName,
        if (receiptDhtKey != null) 'receiptDhtKey': receiptDhtKey.toString(),
        if (ticketDhtKey != null) 'ticketDhtKey': ticketDhtKey.toString(),
        'isPublic': isPublic,
        if (message != null) 'message': message,
        'guestCount': guestCount,
        'createdAt': createdAt.toIso8601(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601(),
      };

  factory EvRsvp.fromJson(Map<String, dynamic> json) {
    return EvRsvp(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      eventDhtKey: EvDhtKey(json['eventDhtKey'] as String),
      attendeePubkey: EvPubkey(json['attendeePubkey'] as String),
      status: EvRsvpStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => EvRsvpStatus.pending,
      ),
      tierName: json['tierName'] as String?,
      receiptDhtKey: json['receiptDhtKey'] != null
          ? EvDhtKey(json['receiptDhtKey'] as String)
          : null,
      ticketDhtKey: json['ticketDhtKey'] != null
          ? EvDhtKey(json['ticketDhtKey'] as String)
          : null,
      isPublic: json['isPublic'] as bool? ?? true,
      message: json['message'] as String?,
      guestCount: json['guestCount'] as int? ?? 0,
      createdAt: EvTimestamp.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? EvTimestamp.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// RSVP status values.
enum EvRsvpStatus {
  /// RSVP submitted, awaiting confirmation.
  pending,

  /// RSVP confirmed (payment verified or free event).
  confirmed,

  /// Attendee is on the waitlist.
  waitlisted,

  /// RSVP was cancelled by the attendee.
  cancelled,

  /// RSVP was declined by the organiser.
  declined,
}
