import '../core/ev_dht_key.dart';

/// A sailing course with marks and start/finish lines.
///
/// Schema: `ev.sailing.course`
class EvCourse {
  final EvDhtKey? dhtKey;
  final EvDhtKey eventDhtKey;
  final String name;
  final EvCourseType courseType;
  final double? distanceNm;
  final List<EvCourseMark> marks;
  final EvLineDefinition? startLine;
  final EvLineDefinition? finishLine;

  const EvCourse({
    this.dhtKey,
    required this.eventDhtKey,
    required this.name,
    this.courseType = EvCourseType.windwardLeeward,
    this.distanceNm,
    required this.marks,
    this.startLine,
    this.finishLine,
  });

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.sailing.course',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'eventDhtKey': eventDhtKey.toString(),
        'name': name,
        'courseType': courseType.name,
        if (distanceNm != null) 'distanceNm': distanceNm,
        'marks': marks.map((m) => m.toJson()).toList(),
        if (startLine != null) 'startLine': startLine!.toJson(),
        if (finishLine != null) 'finishLine': finishLine!.toJson(),
      };

  factory EvCourse.fromJson(Map<String, dynamic> json) {
    return EvCourse(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      eventDhtKey: EvDhtKey(json['eventDhtKey'] as String),
      name: json['name'] as String,
      courseType: EvCourseType.values.firstWhere(
        (t) => t.name == json['courseType'],
        orElse: () => EvCourseType.windwardLeeward,
      ),
      distanceNm: (json['distanceNm'] as num?)?.toDouble(),
      marks: (json['marks'] as List<dynamic>)
          .map((m) => EvCourseMark.fromJson(m as Map<String, dynamic>))
          .toList(),
      startLine: json['startLine'] != null
          ? EvLineDefinition.fromJson(
              json['startLine'] as Map<String, dynamic>)
          : null,
      finishLine: json['finishLine'] != null
          ? EvLineDefinition.fromJson(
              json['finishLine'] as Map<String, dynamic>)
          : null,
    );
  }
}

enum EvCourseType { windwardLeeward, triangle, trapezoid, fixed, custom }

/// A mark on the course.
class EvCourseMark {
  final String name;
  final double latitude;
  final double longitude;
  final EvRounding? rounding;
  final int? order;

  const EvCourseMark({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.rounding,
    this.order,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        if (rounding != null) 'rounding': rounding!.name,
        if (order != null) 'order': order,
      };

  factory EvCourseMark.fromJson(Map<String, dynamic> json) {
    return EvCourseMark(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rounding: json['rounding'] != null
          ? EvRounding.values.firstWhere(
              (r) => r.name == json['rounding'],
              orElse: () => EvRounding.port,
            )
          : null,
      order: json['order'] as int?,
    );
  }
}

enum EvRounding { port, starboard }

/// Start or finish line defined by two marks.
class EvLineDefinition {
  final EvCourseMark pin;
  final EvCourseMark boat;

  const EvLineDefinition({required this.pin, required this.boat});

  Map<String, dynamic> toJson() => {
        'pin': pin.toJson(),
        'boat': boat.toJson(),
      };

  factory EvLineDefinition.fromJson(Map<String, dynamic> json) {
    return EvLineDefinition(
      pin: EvCourseMark.fromJson(json['pin'] as Map<String, dynamic>),
      boat: EvCourseMark.fromJson(json['boat'] as Map<String, dynamic>),
    );
  }
}
