/// Smoke Signal event record — maps 1:1 to the
/// `events.smokesignal.calendar.event` Lexicon.
///
/// Rule: Do NOT invent extra fields. Do NOT add ticketing/payments/groups.
/// Those aren't in Smoke Signal's schema.
class SmokeSignalEvent {
  /// Event name (required).
  final String name;

  /// Optional description / details.
  final String? description;

  /// ISO 8601 start time (required).
  final String startsAt;

  /// ISO 8601 end time.
  final String? endsAt;

  /// Event status: scheduled | cancelled | postponed.
  final String? status;

  /// Location(s) for this event.
  final List<SmokeSignalLocation>? locations;

  /// ISO 8601 creation timestamp (required).
  final String createdAt;

  const SmokeSignalEvent({
    required this.name,
    this.description,
    required this.startsAt,
    this.endsAt,
    this.status,
    this.locations,
    required this.createdAt,
  });

  /// Serialize to PDS record map.
  ///
  /// Includes `$type` field required by the AT Protocol.
  Map<String, dynamic> toRecord() => {
        r'$type': 'events.smokesignal.calendar.event',
        'name': name,
        if (description != null) 'description': description,
        'startsAt': startsAt,
        if (endsAt != null) 'endsAt': endsAt,
        if (status != null) 'status': status,
        if (locations != null && locations!.isNotEmpty)
          'locations': locations!.map((l) => l.toJson()).toList(),
        'createdAt': createdAt,
      };

  /// Parse from PDS record value map.
  factory SmokeSignalEvent.fromRecord(Map<String, dynamic> json) {
    return SmokeSignalEvent(
      name: json['name'] as String,
      description: json['description'] as String?,
      startsAt: json['startsAt'] as String,
      endsAt: json['endsAt'] as String?,
      status: json['status'] as String?,
      locations: (json['locations'] as List<dynamic>?)
          ?.map((l) =>
              SmokeSignalLocation.fromJson(l as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String,
    );
  }
}

/// A location within a Smoke Signal event.
class SmokeSignalLocation {
  final String? name;
  final String? address;

  const SmokeSignalLocation({this.name, this.address});

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (address != null) 'address': address,
      };

  factory SmokeSignalLocation.fromJson(Map<String, dynamic> json) {
    return SmokeSignalLocation(
      name: json['name'] as String?,
      address: json['address'] as String?,
    );
  }
}
