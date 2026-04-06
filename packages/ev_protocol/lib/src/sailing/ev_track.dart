import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';
import '../media/ev_media_reference.dart';

/// A GPS track recording from a race or sail.
///
/// Schema: `ev.sailing.track`
///
/// The actual GPS data (GeoJSON/GPX) is stored as a blob reference.
/// The DHT record contains metadata and a summary.
class EvTrack {
  final EvDhtKey? dhtKey;
  final EvDhtKey raceDhtKey;
  final EvPubkey sailorPubkey;
  final EvDhtKey vesselDhtKey;
  final EvTimestamp startedAt;
  final EvTimestamp? finishedAt;
  final int? elapsedSeconds;
  final int? correctedSeconds;
  final double? distanceNm;
  final EvMediaReference? trackRef;
  final EvTrackSummary? summary;

  const EvTrack({
    this.dhtKey,
    required this.raceDhtKey,
    required this.sailorPubkey,
    required this.vesselDhtKey,
    required this.startedAt,
    this.finishedAt,
    this.elapsedSeconds,
    this.correctedSeconds,
    this.distanceNm,
    this.trackRef,
    this.summary,
  });

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.sailing.track',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'raceDhtKey': raceDhtKey.toString(),
        'sailorPubkey': sailorPubkey.toString(),
        'vesselDhtKey': vesselDhtKey.toString(),
        'startedAt': startedAt.toIso8601(),
        if (finishedAt != null) 'finishedAt': finishedAt!.toIso8601(),
        if (elapsedSeconds != null) 'elapsedSeconds': elapsedSeconds,
        if (correctedSeconds != null) 'correctedSeconds': correctedSeconds,
        if (distanceNm != null) 'distanceNm': distanceNm,
        if (trackRef != null) 'trackRef': trackRef!.toJson(),
        if (summary != null) 'summary': summary!.toJson(),
      };

  factory EvTrack.fromJson(Map<String, dynamic> json) {
    return EvTrack(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      raceDhtKey: EvDhtKey(json['raceDhtKey'] as String),
      sailorPubkey: EvPubkey(json['sailorPubkey'] as String),
      vesselDhtKey: EvDhtKey(json['vesselDhtKey'] as String),
      startedAt: EvTimestamp.parse(json['startedAt'] as String),
      finishedAt: json['finishedAt'] != null
          ? EvTimestamp.parse(json['finishedAt'] as String)
          : null,
      elapsedSeconds: json['elapsedSeconds'] as int?,
      correctedSeconds: json['correctedSeconds'] as int?,
      distanceNm: (json['distanceNm'] as num?)?.toDouble(),
      trackRef: json['trackRef'] != null
          ? EvMediaReference.fromJson(
              json['trackRef'] as Map<String, dynamic>)
          : null,
      summary: json['summary'] != null
          ? EvTrackSummary.fromJson(
              json['summary'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Summary statistics for a GPS track.
class EvTrackSummary {
  final double? maxSpeedKnots;
  final double? avgSpeedKnots;
  final int? pointCount;
  final EvBoundingBox? boundingBox;

  const EvTrackSummary({
    this.maxSpeedKnots,
    this.avgSpeedKnots,
    this.pointCount,
    this.boundingBox,
  });

  Map<String, dynamic> toJson() => {
        if (maxSpeedKnots != null) 'maxSpeedKnots': maxSpeedKnots,
        if (avgSpeedKnots != null) 'avgSpeedKnots': avgSpeedKnots,
        if (pointCount != null) 'pointCount': pointCount,
        if (boundingBox != null) 'boundingBox': boundingBox!.toJson(),
      };

  factory EvTrackSummary.fromJson(Map<String, dynamic> json) {
    return EvTrackSummary(
      maxSpeedKnots: (json['maxSpeedKnots'] as num?)?.toDouble(),
      avgSpeedKnots: (json['avgSpeedKnots'] as num?)?.toDouble(),
      pointCount: json['pointCount'] as int?,
      boundingBox: json['boundingBox'] != null
          ? EvBoundingBox.fromJson(
              json['boundingBox'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Geographic bounding box for a track.
class EvBoundingBox {
  final double north;
  final double south;
  final double east;
  final double west;

  const EvBoundingBox({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  Map<String, dynamic> toJson() => {
        'north': north,
        'south': south,
        'east': east,
        'west': west,
      };

  factory EvBoundingBox.fromJson(Map<String, dynamic> json) {
    return EvBoundingBox(
      north: (json['north'] as num).toDouble(),
      south: (json['south'] as num).toDouble(),
      east: (json['east'] as num).toDouble(),
      west: (json['west'] as num).toDouble(),
    );
  }
}
