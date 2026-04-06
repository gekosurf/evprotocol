import '../core/ev_dht_key.dart';
import '../core/ev_timestamp.dart';

/// A sailing race within an event.
///
/// Schema: `ev.sailing.race`
class EvRace {
  final EvDhtKey? dhtKey;
  final EvDhtKey eventDhtKey;
  final String name;
  final int? raceNumber;
  final EvTimestamp scheduledStart;
  final EvTimestamp? actualStart;
  final EvRaceStatus status;
  final EvDhtKey? courseDhtKey;
  final EvHandicapSystem handicapSystem;
  final EvRaceConditions? conditions;

  const EvRace({
    this.dhtKey,
    required this.eventDhtKey,
    required this.name,
    this.raceNumber,
    required this.scheduledStart,
    this.actualStart,
    this.status = EvRaceStatus.scheduled,
    this.courseDhtKey,
    this.handicapSystem = EvHandicapSystem.yardstick,
    this.conditions,
  });

  EvRace copyWith({
    EvDhtKey? dhtKey,
    EvTimestamp? actualStart,
    EvRaceStatus? status,
    EvDhtKey? courseDhtKey,
    EvRaceConditions? conditions,
  }) {
    return EvRace(
      dhtKey: dhtKey ?? this.dhtKey,
      eventDhtKey: eventDhtKey,
      name: name,
      raceNumber: raceNumber,
      scheduledStart: scheduledStart,
      actualStart: actualStart ?? this.actualStart,
      status: status ?? this.status,
      courseDhtKey: courseDhtKey ?? this.courseDhtKey,
      handicapSystem: handicapSystem,
      conditions: conditions ?? this.conditions,
    );
  }

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.sailing.race',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'eventDhtKey': eventDhtKey.toString(),
        'name': name,
        if (raceNumber != null) 'raceNumber': raceNumber,
        'scheduledStart': scheduledStart.toIso8601(),
        if (actualStart != null) 'actualStart': actualStart!.toIso8601(),
        'status': status.name,
        if (courseDhtKey != null) 'courseDhtKey': courseDhtKey.toString(),
        'handicapSystem': handicapSystem.name,
        if (conditions != null) 'conditions': conditions!.toJson(),
      };

  factory EvRace.fromJson(Map<String, dynamic> json) {
    return EvRace(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      eventDhtKey: EvDhtKey(json['eventDhtKey'] as String),
      name: json['name'] as String,
      raceNumber: json['raceNumber'] as int?,
      scheduledStart:
          EvTimestamp.parse(json['scheduledStart'] as String),
      actualStart: json['actualStart'] != null
          ? EvTimestamp.parse(json['actualStart'] as String)
          : null,
      status: EvRaceStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => EvRaceStatus.scheduled,
      ),
      courseDhtKey: json['courseDhtKey'] != null
          ? EvDhtKey(json['courseDhtKey'] as String)
          : null,
      handicapSystem: EvHandicapSystem.values.firstWhere(
        (h) => h.name == json['handicapSystem'],
        orElse: () => EvHandicapSystem.yardstick,
      ),
      conditions: json['conditions'] != null
          ? EvRaceConditions.fromJson(
              json['conditions'] as Map<String, dynamic>)
          : null,
    );
  }
}

enum EvRaceStatus {
  scheduled,
  preparatory,
  started,
  finished,
  abandoned,
  postponed
}

enum EvHandicapSystem { yardstick, irc, phrf, none }

/// Wind/sea conditions at race start.
class EvRaceConditions {
  final double? windSpeedKnots;
  final int? windDirectionDeg;
  final EvSeaState? seaState;
  final double? currentKnots;
  final int? currentDirectionDeg;
  final EvVisibility? visibility;

  const EvRaceConditions({
    this.windSpeedKnots,
    this.windDirectionDeg,
    this.seaState,
    this.currentKnots,
    this.currentDirectionDeg,
    this.visibility,
  });

  Map<String, dynamic> toJson() => {
        if (windSpeedKnots != null) 'windSpeedKnots': windSpeedKnots,
        if (windDirectionDeg != null) 'windDirectionDeg': windDirectionDeg,
        if (seaState != null) 'seaState': seaState!.name,
        if (currentKnots != null) 'currentKnots': currentKnots,
        if (currentDirectionDeg != null)
          'currentDirectionDeg': currentDirectionDeg,
        if (visibility != null) 'visibility': visibility!.name,
      };

  factory EvRaceConditions.fromJson(Map<String, dynamic> json) {
    return EvRaceConditions(
      windSpeedKnots: (json['windSpeedKnots'] as num?)?.toDouble(),
      windDirectionDeg: json['windDirectionDeg'] as int?,
      seaState: json['seaState'] != null
          ? EvSeaState.values.firstWhere(
              (s) => s.name == json['seaState'],
              orElse: () => EvSeaState.moderate,
            )
          : null,
      currentKnots: (json['currentKnots'] as num?)?.toDouble(),
      currentDirectionDeg: json['currentDirectionDeg'] as int?,
      visibility: json['visibility'] != null
          ? EvVisibility.values.firstWhere(
              (v) => v.name == json['visibility'],
              orElse: () => EvVisibility.good,
            )
          : null,
    );
  }
}

enum EvSeaState { flat, choppy, moderate, rough }

enum EvVisibility { good, moderate, poor }
