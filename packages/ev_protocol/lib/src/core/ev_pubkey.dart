/// A typed wrapper around a Veilid Ed25519 public key.
///
/// Public keys serve as user identities in the EV Protocol.
/// Format: `VLD0:<base64url-encoded-key-bytes>`
class EvPubkey {
  /// The full public key string including prefix.
  final String value;

  /// Protocol prefix for Veilid public keys.
  static const String prefix = 'VLD0:';

  const EvPubkey(this.value);

  /// Creates a pubkey from a raw base64url-encoded key.
  factory EvPubkey.fromRawKey(String rawBase64) {
    return EvPubkey('$prefix$rawBase64');
  }

  /// The raw key bytes (without the VLD0: prefix).
  String get rawKey {
    if (value.startsWith(prefix)) {
      return value.substring(prefix.length);
    }
    return value;
  }

  /// Whether this pubkey has the expected format.
  bool get isValid => value.startsWith(prefix) && rawKey.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EvPubkey && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;

  Map<String, dynamic> toJson() => {'value': value};

  factory EvPubkey.fromJson(Map<String, dynamic> json) {
    return EvPubkey(json['value'] as String);
  }
}
