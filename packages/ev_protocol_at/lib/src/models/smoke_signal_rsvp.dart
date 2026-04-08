/// Smoke Signal RSVP record — maps 1:1 to the
/// `events.smokesignal.calendar.rsvp` Lexicon.
class SmokeSignalRsvp {
  /// AT URI of the event being RSVP'd to (required).
  /// Format: `at://did:plc:xxx/events.smokesignal.calendar.event/rkey`
  final String eventUri;

  /// RSVP status: going | interested | notgoing.
  final String status;

  /// ISO 8601 creation timestamp (required).
  final String createdAt;

  const SmokeSignalRsvp({
    required this.eventUri,
    required this.status,
    required this.createdAt,
  });

  /// Serialize to PDS record map.
  Map<String, dynamic> toRecord() => {
        r'$type': 'events.smokesignal.calendar.rsvp',
        'eventUri': eventUri,
        'status': status,
        'createdAt': createdAt,
      };

  /// Parse from PDS record value map.
  factory SmokeSignalRsvp.fromRecord(Map<String, dynamic> json) {
    return SmokeSignalRsvp(
      eventUri: json['eventUri'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
