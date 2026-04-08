import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';

/// A user's local profile.
///
/// Post-cleanup: removed EvMediaReference (avatar) dependency.
/// Phase 2 will replace this with AT Protocol DID-based identities.
class EvIdentity {
  /// The user's public key (local identity).
  final EvPubkey pubkey;

  /// Display name shown to other users.
  final String displayName;

  /// Optional bio / description.
  final String? bio;

  /// When this profile was first created.
  final EvTimestamp createdAt;

  /// When this profile was last updated.
  final EvTimestamp? updatedAt;

  const EvIdentity({
    required this.pubkey,
    required this.displayName,
    this.bio,
    required this.createdAt,
    this.updatedAt,
  });

  EvIdentity copyWith({
    EvPubkey? pubkey,
    String? displayName,
    String? bio,
    EvTimestamp? createdAt,
    EvTimestamp? updatedAt,
  }) {
    return EvIdentity(
      pubkey: pubkey ?? this.pubkey,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.identity.profile',
        'pubkey': pubkey.toString(),
        'displayName': displayName,
        if (bio != null) 'bio': bio,
        'createdAt': createdAt.toIso8601(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601(),
      };

  factory EvIdentity.fromJson(Map<String, dynamic> json) {
    return EvIdentity(
      pubkey: EvPubkey(json['pubkey'] as String),
      displayName: json['displayName'] as String,
      bio: json['bio'] as String?,
      createdAt: EvTimestamp.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? EvTimestamp.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
