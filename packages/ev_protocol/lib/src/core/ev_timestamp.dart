/// Protocol-level timestamp with ISO 8601 formatting.
///
/// All timestamps in the EV Protocol MUST be UTC ISO 8601 strings.
/// This wrapper provides consistent formatting and comparison.
class EvTimestamp implements Comparable<EvTimestamp> {
  /// The underlying DateTime (always UTC).
  final DateTime dateTime;

  EvTimestamp(this.dateTime);

  /// Creates a timestamp for the current moment.
  factory EvTimestamp.now() => EvTimestamp(DateTime.now().toUtc());

  /// Parses an ISO 8601 string.
  factory EvTimestamp.parse(String iso8601) {
    return EvTimestamp(DateTime.parse(iso8601).toUtc());
  }

  /// Returns the ISO 8601 string representation (always UTC).
  String toIso8601() => dateTime.toUtc().toIso8601String();

  /// Milliseconds since epoch.
  int get millisecondsSinceEpoch => dateTime.millisecondsSinceEpoch;

  /// Whether this timestamp is before [other].
  bool isBefore(EvTimestamp other) => dateTime.isBefore(other.dateTime);

  /// Whether this timestamp is after [other].
  bool isAfter(EvTimestamp other) => dateTime.isAfter(other.dateTime);

  @override
  int compareTo(EvTimestamp other) => dateTime.compareTo(other.dateTime);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvTimestamp &&
          dateTime.millisecondsSinceEpoch ==
              other.dateTime.millisecondsSinceEpoch;

  @override
  int get hashCode => dateTime.millisecondsSinceEpoch.hashCode;

  @override
  String toString() => toIso8601();

  Map<String, dynamic> toJson() => {'iso8601': toIso8601()};

  factory EvTimestamp.fromJson(Map<String, dynamic> json) {
    return EvTimestamp.parse(json['iso8601'] as String);
  }
}
