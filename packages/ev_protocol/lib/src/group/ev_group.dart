import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';
import '../media/ev_media_reference.dart';

/// A group of users (e.g., a sailing club, a meetup community).
///
/// Schema: `ev.group.roster`
///
/// Multi-writer DHT record — admin manages membership, members can
/// update their own subkey data.
class EvGroup {
  final EvDhtKey? dhtKey;
  final String name;
  final String? description;
  final EvPubkey adminPubkey;
  final EvMediaReference? avatarRef;
  final List<EvGroupMember> members;
  final List<EvDhtKey> vesselDhtKeys;
  final EvGroupVisibility visibility;
  final EvTimestamp createdAt;
  final EvTimestamp? updatedAt;

  const EvGroup({
    this.dhtKey,
    required this.name,
    this.description,
    required this.adminPubkey,
    this.avatarRef,
    this.members = const [],
    this.vesselDhtKeys = const [],
    this.visibility = EvGroupVisibility.public_,
    required this.createdAt,
    this.updatedAt,
  });

  EvGroup copyWith({
    EvDhtKey? dhtKey,
    String? name,
    String? description,
    EvPubkey? adminPubkey,
    EvMediaReference? avatarRef,
    List<EvGroupMember>? members,
    List<EvDhtKey>? vesselDhtKeys,
    EvGroupVisibility? visibility,
    EvTimestamp? createdAt,
    EvTimestamp? updatedAt,
  }) {
    return EvGroup(
      dhtKey: dhtKey ?? this.dhtKey,
      name: name ?? this.name,
      description: description ?? this.description,
      adminPubkey: adminPubkey ?? this.adminPubkey,
      avatarRef: avatarRef ?? this.avatarRef,
      members: members ?? this.members,
      vesselDhtKeys: vesselDhtKeys ?? this.vesselDhtKeys,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.group.roster',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'name': name,
        if (description != null) 'description': description,
        'adminPubkey': adminPubkey.toString(),
        if (avatarRef != null) 'avatarRef': avatarRef!.toJson(),
        'members': members.map((m) => m.toJson()).toList(),
        'vesselDhtKeys': vesselDhtKeys.map((k) => k.toString()).toList(),
        'visibility': visibility.name,
        'createdAt': createdAt.toIso8601(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601(),
      };

  factory EvGroup.fromJson(Map<String, dynamic> json) {
    return EvGroup(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      name: json['name'] as String,
      description: json['description'] as String?,
      adminPubkey: EvPubkey(json['adminPubkey'] as String),
      avatarRef: json['avatarRef'] != null
          ? EvMediaReference.fromJson(
              json['avatarRef'] as Map<String, dynamic>)
          : null,
      members: (json['members'] as List<dynamic>?)
              ?.map(
                  (m) => EvGroupMember.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
      vesselDhtKeys: (json['vesselDhtKeys'] as List<dynamic>?)
              ?.map((k) => EvDhtKey(k as String))
              .toList() ??
          const [],
      visibility: EvGroupVisibility.values.firstWhere(
        (v) => v.name == json['visibility'],
        orElse: () => EvGroupVisibility.public_,
      ),
      createdAt: EvTimestamp.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? EvTimestamp.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// A member of a group.
class EvGroupMember {
  final EvPubkey pubkey;
  final String? displayName;
  final EvGroupRole role;
  final EvTimestamp joinedAt;

  const EvGroupMember({
    required this.pubkey,
    this.displayName,
    required this.role,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
        'pubkey': pubkey.toString(),
        if (displayName != null) 'displayName': displayName,
        'role': role.name,
        'joinedAt': joinedAt.toIso8601(),
      };

  factory EvGroupMember.fromJson(Map<String, dynamic> json) {
    return EvGroupMember(
      pubkey: EvPubkey(json['pubkey'] as String),
      displayName: json['displayName'] as String?,
      role: EvGroupRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => EvGroupRole.member,
      ),
      joinedAt: EvTimestamp.parse(json['joinedAt'] as String),
    );
  }
}

enum EvGroupRole { admin, organiser, member, guest }

enum EvGroupVisibility { public_, private_, inviteOnly }
