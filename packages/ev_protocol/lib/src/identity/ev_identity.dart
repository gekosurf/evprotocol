import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';
import '../media/ev_media_reference.dart';

/// A user's public profile in the EV Protocol.
///
/// Schema: `ev.identity.profile`
///
/// Every user has exactly one profile, keyed by their public key.
/// The profile is a single-writer DHT record — only the owner can modify it.
class EvIdentity {
  /// The user's Veilid public key (their unique identity).
  final EvPubkey pubkey;

  /// Display name shown to other users.
  final String displayName;

  /// Optional bio / description.
  final String? bio;

  /// Optional avatar image reference.
  final EvMediaReference? avatarRef;

  /// When this profile was first created.
  final EvTimestamp createdAt;

  /// When this profile was last updated.
  final EvTimestamp? updatedAt;

  const EvIdentity({
    required this.pubkey,
    required this.displayName,
    this.bio,
    this.avatarRef,
    required this.createdAt,
    this.updatedAt,
  });

  EvIdentity copyWith({
    EvPubkey? pubkey,
    String? displayName,
    String? bio,
    EvMediaReference? avatarRef,
    EvTimestamp? createdAt,
    EvTimestamp? updatedAt,
  }) {
    return EvIdentity(
      pubkey: pubkey ?? this.pubkey,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarRef: avatarRef ?? this.avatarRef,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.identity.profile',
        'pubkey': pubkey.toString(),
        'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (avatarRef != null) 'avatarRef': avatarRef!.toJson(),
        'createdAt': createdAt.toIso8601(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601(),
      };

  factory EvIdentity.fromJson(Map<String, dynamic> json) {
    return EvIdentity(
      pubkey: EvPubkey(json['pubkey'] as String),
      displayName: json['displayName'] as String,
      bio: json['bio'] as String?,
      avatarRef: json['avatarRef'] != null
          ? EvMediaReference.fromJson(
              json['avatarRef'] as Map<String, dynamic>)
          : null,
      createdAt: EvTimestamp.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? EvTimestamp.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
