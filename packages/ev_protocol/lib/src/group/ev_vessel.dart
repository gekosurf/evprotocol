import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../media/ev_media_reference.dart';

/// A yacht or vessel profile.
///
/// Schema: `ev.group.vessel`
///
/// Single-writer DHT record — owned by the vessel's registered owner.
class EvVessel {
  final EvDhtKey? dhtKey;
  final String name;
  final EvPubkey ownerPubkey;
  final String? sailNumber;
  final String? vesselClass;
  final double? handicap;
  final double? lengthMetres;
  final EvMediaReference? photoRef;
  final String? homePort;
  final EvDhtKey? groupDhtKey;
  final List<EvCrewMember> crew;

  const EvVessel({
    this.dhtKey,
    required this.name,
    required this.ownerPubkey,
    this.sailNumber,
    this.vesselClass,
    this.handicap,
    this.lengthMetres,
    this.photoRef,
    this.homePort,
    this.groupDhtKey,
    this.crew = const [],
  });

  EvVessel copyWith({
    EvDhtKey? dhtKey,
    String? name,
    EvPubkey? ownerPubkey,
    String? sailNumber,
    String? vesselClass,
    double? handicap,
    double? lengthMetres,
    EvMediaReference? photoRef,
    String? homePort,
    EvDhtKey? groupDhtKey,
    List<EvCrewMember>? crew,
  }) {
    return EvVessel(
      dhtKey: dhtKey ?? this.dhtKey,
      name: name ?? this.name,
      ownerPubkey: ownerPubkey ?? this.ownerPubkey,
      sailNumber: sailNumber ?? this.sailNumber,
      vesselClass: vesselClass ?? this.vesselClass,
      handicap: handicap ?? this.handicap,
      lengthMetres: lengthMetres ?? this.lengthMetres,
      photoRef: photoRef ?? this.photoRef,
      homePort: homePort ?? this.homePort,
      groupDhtKey: groupDhtKey ?? this.groupDhtKey,
      crew: crew ?? this.crew,
    );
  }

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.group.vessel',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'name': name,
        'ownerPubkey': ownerPubkey.toString(),
        if (sailNumber != null) 'sailNumber': sailNumber,
        if (vesselClass != null) 'class': vesselClass,
        if (handicap != null) 'handicap': handicap,
        if (lengthMetres != null) 'length': lengthMetres,
        if (photoRef != null) 'photoRef': photoRef!.toJson(),
        if (homePort != null) 'homePort': homePort,
        if (groupDhtKey != null) 'groupDhtKey': groupDhtKey.toString(),
        'crew': crew.map((c) => c.toJson()).toList(),
      };

  factory EvVessel.fromJson(Map<String, dynamic> json) {
    return EvVessel(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      name: json['name'] as String,
      ownerPubkey: EvPubkey(json['ownerPubkey'] as String),
      sailNumber: json['sailNumber'] as String?,
      vesselClass: json['class'] as String?,
      handicap: (json['handicap'] as num?)?.toDouble(),
      lengthMetres: (json['length'] as num?)?.toDouble(),
      photoRef: json['photoRef'] != null
          ? EvMediaReference.fromJson(
              json['photoRef'] as Map<String, dynamic>)
          : null,
      homePort: json['homePort'] as String?,
      groupDhtKey: json['groupDhtKey'] != null
          ? EvDhtKey(json['groupDhtKey'] as String)
          : null,
      crew: (json['crew'] as List<dynamic>?)
              ?.map((c) => EvCrewMember.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

/// A crew member on a vessel.
class EvCrewMember {
  final EvPubkey? pubkey;
  final String? displayName;
  final EvCrewRole role;

  const EvCrewMember({
    this.pubkey,
    this.displayName,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        if (pubkey != null) 'pubkey': pubkey.toString(),
        if (displayName != null) 'displayName': displayName,
        'role': role.name,
      };

  factory EvCrewMember.fromJson(Map<String, dynamic> json) {
    return EvCrewMember(
      pubkey:
          json['pubkey'] != null ? EvPubkey(json['pubkey'] as String) : null,
      displayName: json['displayName'] as String?,
      role: EvCrewRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => EvCrewRole.crew,
      ),
    );
  }
}

enum EvCrewRole { skipper, helm, tactician, trimmer, bowperson, crew }
