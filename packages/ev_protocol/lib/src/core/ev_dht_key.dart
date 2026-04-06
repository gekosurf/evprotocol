/// A typed wrapper around a Veilid DHT record key.
///
/// DHT keys are deterministic hashes generated from schema + owner + unique ID.
/// This wrapper provides type safety and consistent formatting.
class EvDhtKey {
  /// The raw key bytes as a base64url-encoded string.
  final String value;

  const EvDhtKey(this.value);

  /// Creates a DHT key from raw bytes (base64url-encoded).
  factory EvDhtKey.fromBase64(String base64Value) {
    return EvDhtKey(base64Value);
  }

  /// Whether this key is non-empty and appears valid.
  bool get isValid => value.isNotEmpty && value.length >= 8;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EvDhtKey && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;

  Map<String, dynamic> toJson() => {'value': value};

  factory EvDhtKey.fromJson(Map<String, dynamic> json) {
    return EvDhtKey(json['value'] as String);
  }
}
