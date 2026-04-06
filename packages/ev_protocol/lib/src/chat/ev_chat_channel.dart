import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';

/// A chat channel within an event.
///
/// Schema: `ev.chat.channel`
class EvChatChannel {
  final EvDhtKey? dhtKey;
  final EvDhtKey eventDhtKey;
  final String name;
  final EvChatChannelType type;
  final int? maxParticipants;
  final EvPubkey creatorPubkey;
  final List<EvPubkey> participantPubkeys;
  final EvTimestamp createdAt;

  const EvChatChannel({
    this.dhtKey,
    required this.eventDhtKey,
    required this.name,
    required this.type,
    this.maxParticipants,
    required this.creatorPubkey,
    this.participantPubkeys = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.chat.channel',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'eventDhtKey': eventDhtKey.toString(),
        'name': name,
        'type': type.name,
        if (maxParticipants != null) 'maxParticipants': maxParticipants,
        'creatorPubkey': creatorPubkey.toString(),
        'participantPubkeys':
            participantPubkeys.map((p) => p.toString()).toList(),
        'createdAt': createdAt.toIso8601(),
      };

  factory EvChatChannel.fromJson(Map<String, dynamic> json) {
    return EvChatChannel(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      eventDhtKey: EvDhtKey(json['eventDhtKey'] as String),
      name: json['name'] as String,
      type: EvChatChannelType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => EvChatChannelType.discussion,
      ),
      maxParticipants: json['maxParticipants'] as int?,
      creatorPubkey: EvPubkey(json['creatorPubkey'] as String),
      participantPubkeys: (json['participantPubkeys'] as List<dynamic>?)
              ?.map((p) => EvPubkey(p as String))
              .toList() ??
          const [],
      createdAt: EvTimestamp.parse(json['createdAt'] as String),
    );
  }
}

/// Channel type determines write access and persistence.
enum EvChatChannelType {
  /// One-to-many, organiser-only writes.
  announcements,

  /// Many-to-many, capped at ~200 participants.
  discussion,

  /// One-to-one, fully E2E encrypted.
  dm,

  /// Ephemeral emoji reactions, not persisted.
  reactions,
}
