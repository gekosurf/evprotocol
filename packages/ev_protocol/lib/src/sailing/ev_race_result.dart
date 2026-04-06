import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';

/// Race results and standings.
///
/// Schema: `ev.sailing.result`
class EvRaceResult {
  final EvDhtKey? dhtKey;
  final EvDhtKey raceDhtKey;
  final EvDhtKey eventDhtKey;
  final EvTimestamp publishedAt;
  final List<EvFinisherResult> results;
  final bool protestsOpen;

  const EvRaceResult({
    this.dhtKey,
    required this.raceDhtKey,
    required this.eventDhtKey,
    required this.publishedAt,
    required this.results,
    this.protestsOpen = false,
  });

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.sailing.result',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'raceDhtKey': raceDhtKey.toString(),
        'eventDhtKey': eventDhtKey.toString(),
        'publishedAt': publishedAt.toIso8601(),
        'results': results.map((r) => r.toJson()).toList(),
        'protestsOpen': protestsOpen,
      };

  factory EvRaceResult.fromJson(Map<String, dynamic> json) {
    return EvRaceResult(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      raceDhtKey: EvDhtKey(json['raceDhtKey'] as String),
      eventDhtKey: EvDhtKey(json['eventDhtKey'] as String),
      publishedAt: EvTimestamp.parse(json['publishedAt'] as String),
      results: (json['results'] as List<dynamic>)
          .map((r) => EvFinisherResult.fromJson(r as Map<String, dynamic>))
          .toList(),
      protestsOpen: json['protestsOpen'] as bool? ?? false,
    );
  }
}

/// An individual vessel's result in a race.
class EvFinisherResult {
  final EvDhtKey vesselDhtKey;
  final EvPubkey? skipperPubkey;
  final int position;
  final int? elapsedSeconds;
  final int? correctedSeconds;
  final double? points;
  final EvFinishStatus status;
  final EvDhtKey? trackDhtKey;

  const EvFinisherResult({
    required this.vesselDhtKey,
    this.skipperPubkey,
    required this.position,
    this.elapsedSeconds,
    this.correctedSeconds,
    this.points,
    this.status = EvFinishStatus.finished,
    this.trackDhtKey,
  });

  Map<String, dynamic> toJson() => {
        'vesselDhtKey': vesselDhtKey.toString(),
        if (skipperPubkey != null) 'skipperPubkey': skipperPubkey.toString(),
        'position': position,
        if (elapsedSeconds != null) 'elapsedSeconds': elapsedSeconds,
        if (correctedSeconds != null) 'correctedSeconds': correctedSeconds,
        if (points != null) 'points': points,
        'status': status.name,
        if (trackDhtKey != null) 'trackDhtKey': trackDhtKey.toString(),
      };

  factory EvFinisherResult.fromJson(Map<String, dynamic> json) {
    return EvFinisherResult(
      vesselDhtKey: EvDhtKey(json['vesselDhtKey'] as String),
      skipperPubkey: json['skipperPubkey'] != null
          ? EvPubkey(json['skipperPubkey'] as String)
          : null,
      position: json['position'] as int,
      elapsedSeconds: json['elapsedSeconds'] as int?,
      correctedSeconds: json['correctedSeconds'] as int?,
      points: (json['points'] as num?)?.toDouble(),
      status: EvFinishStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => EvFinishStatus.finished,
      ),
      trackDhtKey: json['trackDhtKey'] != null
          ? EvDhtKey(json['trackDhtKey'] as String)
          : null,
    );
  }
}

/// Finish status codes (standard sailing race results).
enum EvFinishStatus {
  finished,
  dnf,  // Did not finish
  dns,  // Did not start
  dsq,  // Disqualified
  ocs,  // On course side (premature start)
  ret,  // Retired
  raf,  // Retired after finishing
}
