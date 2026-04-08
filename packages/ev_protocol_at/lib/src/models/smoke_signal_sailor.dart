/// Smoke Signal yacht position model — matches PDS Lexicon.
///
/// Collection: au.sailor.yacht.position
/// All numeric values stored as strings per CBOR constraint.
class SmokeSignalPosition {
  final String eventUri;
  final String boatName;
  final String latitude;
  final String longitude;
  final String? speed;
  final String? heading;
  final String? altitude;
  final String timestamp;

  const SmokeSignalPosition({
    required this.eventUri,
    required this.boatName,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
    this.altitude,
    required this.timestamp,
  });

  Map<String, dynamic> toRecord() => {
        '\$type': 'au.sailor.yacht.position',
        'eventUri': eventUri,
        'boatName': boatName,
        'coordinates': {
          'latitude': latitude,
          'longitude': longitude,
          if (altitude != null) 'altitude': altitude,
        },
        if (speed != null) 'speed': speed,
        if (heading != null) 'heading': heading,
        'timestamp': timestamp,
      };

  factory SmokeSignalPosition.fromRecord(Map<String, dynamic> record) {
    final coords = record['coordinates'] as Map<String, dynamic>? ?? {};
    return SmokeSignalPosition(
      eventUri: record['eventUri'] as String? ?? '',
      boatName: record['boatName'] as String? ?? 'Unknown',
      latitude: coords['latitude'] as String? ?? '0',
      longitude: coords['longitude'] as String? ?? '0',
      speed: record['speed'] as String?,
      heading: record['heading'] as String?,
      altitude: coords['altitude'] as String?,
      timestamp: record['timestamp'] as String? ?? '',
    );
  }
}

/// Smoke Signal photo model — matches PDS Lexicon.
///
/// Collection: au.sailor.photo
class SmokeSignalPhoto {
  final String eventUri;
  final Map<String, dynamic> image; // blob reference {$type, ref, mimeType, size}
  final String? caption;
  final String? latitude;
  final String? longitude;
  final String createdAt;

  const SmokeSignalPhoto({
    required this.eventUri,
    required this.image,
    this.caption,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  Map<String, dynamic> toRecord() => {
        '\$type': 'au.sailor.photo',
        'eventUri': eventUri,
        'image': image,
        if (caption != null) 'caption': caption,
        if (latitude != null || longitude != null)
          'location': {
            if (latitude != null) 'latitude': latitude,
            if (longitude != null) 'longitude': longitude,
          },
        'createdAt': createdAt,
      };

  factory SmokeSignalPhoto.fromRecord(Map<String, dynamic> record) {
    final loc = record['location'] as Map<String, dynamic>?;
    return SmokeSignalPhoto(
      eventUri: record['eventUri'] as String? ?? '',
      image: record['image'] as Map<String, dynamic>? ?? {},
      caption: record['caption'] as String?,
      latitude: loc?['latitude'] as String?,
      longitude: loc?['longitude'] as String?,
      createdAt: record['createdAt'] as String? ?? '',
    );
  }
}
