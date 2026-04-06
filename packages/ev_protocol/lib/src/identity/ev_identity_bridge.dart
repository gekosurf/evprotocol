import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';

/// Bidirectional proof linking a Veilid identity to an AT Protocol DID.
///
/// Schema: `ev.identity.bridge`
///
/// This is optional — users without an AT Protocol identity skip this entirely.
class EvIdentityBridge {
  /// The user's Veilid public key.
  final EvPubkey veilidPubkey;

  /// The user's AT Protocol DID (e.g., `did:plc:abc123`).
  final String atDid;

  /// The user's AT Protocol handle (e.g., `@alice.bsky.social`).
  final String? atHandle;

  /// Veilid key's signature over the AT DID (proves Veilid key holder claims this DID).
  final String veilidSignature;

  /// AT key's signature over the Veilid pubkey (proves AT key holder claims this pubkey).
  final String atSignature;

  /// When the bridge was established.
  final EvTimestamp linkedAt;

  const EvIdentityBridge({
    required this.veilidPubkey,
    required this.atDid,
    this.atHandle,
    required this.veilidSignature,
    required this.atSignature,
    required this.linkedAt,
  });

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.identity.bridge',
        'veilidPubkey': veilidPubkey.toString(),
        'atDid': atDid,
        if (atHandle != null) 'atHandle': atHandle,
        'veilidSignature': veilidSignature,
        'atSignature': atSignature,
        'linkedAt': linkedAt.toIso8601(),
      };

  factory EvIdentityBridge.fromJson(Map<String, dynamic> json) {
    return EvIdentityBridge(
      veilidPubkey: EvPubkey(json['veilidPubkey'] as String),
      atDid: json['atDid'] as String,
      atHandle: json['atHandle'] as String?,
      veilidSignature: json['veilidSignature'] as String,
      atSignature: json['atSignature'] as String,
      linkedAt: EvTimestamp.parse(json['linkedAt'] as String),
    );
  }
}
