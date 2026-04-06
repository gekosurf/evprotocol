import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';
import '../media/ev_media_reference.dart';

/// A chat message in the EV Protocol.
///
/// Schema: `ev.chat.message`
///
/// Messages are stored in multi-writer DHT records. Each participant
/// writes to their own subkey — no write contention, no conflicts.
class EvChatMessage {
  /// Unique message ID (TID format).
  final String id;

  /// DHT key of the channel this message belongs to.
  final EvDhtKey channelDhtKey;

  /// Sender's public key.
  final EvPubkey senderPubkey;

  /// Sender's display name (snapshot at send time).
  final String? senderName;

  /// Message text content.
  final String text;

  /// When the message was sent.
  final EvTimestamp sentAt;

  /// ID of the message being replied to (threaded replies).
  final String? replyToId;

  /// Attached media reference.
  final EvMediaReference? media;

  /// Aggregated emoji reactions: {'🔥': 5, '❤️': 3}.
  final Map<String, int> reactions;

  /// Whether this message has been edited.
  final bool edited;

  /// When the message was last edited.
  final EvTimestamp? editedAt;

  const EvChatMessage({
    required this.id,
    required this.channelDhtKey,
    required this.senderPubkey,
    this.senderName,
    required this.text,
    required this.sentAt,
    this.replyToId,
    this.media,
    this.reactions = const {},
    this.edited = false,
    this.editedAt,
  });

  EvChatMessage copyWith({
    String? text,
    Map<String, int>? reactions,
    bool? edited,
    EvTimestamp? editedAt,
  }) {
    return EvChatMessage(
      id: id,
      channelDhtKey: channelDhtKey,
      senderPubkey: senderPubkey,
      senderName: senderName,
      text: text ?? this.text,
      sentAt: sentAt,
      replyToId: replyToId,
      media: media,
      reactions: reactions ?? this.reactions,
      edited: edited ?? this.edited,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.chat.message',
        'id': id,
        'channelDhtKey': channelDhtKey.toString(),
        'senderPubkey': senderPubkey.toString(),
        if (senderName != null) 'senderName': senderName,
        'text': text,
        'sentAt': sentAt.toIso8601(),
        if (replyToId != null) 'replyToId': replyToId,
        if (media != null) 'media': media!.toJson(),
        if (reactions.isNotEmpty) 'reactions': reactions,
        'edited': edited,
        if (editedAt != null) 'editedAt': editedAt!.toIso8601(),
      };

  factory EvChatMessage.fromJson(Map<String, dynamic> json) {
    return EvChatMessage(
      id: json['id'] as String,
      channelDhtKey: EvDhtKey(json['channelDhtKey'] as String),
      senderPubkey: EvPubkey(json['senderPubkey'] as String),
      senderName: json['senderName'] as String?,
      text: json['text'] as String,
      sentAt: EvTimestamp.parse(json['sentAt'] as String),
      replyToId: json['replyToId'] as String?,
      media: json['media'] != null
          ? EvMediaReference.fromJson(json['media'] as Map<String, dynamic>)
          : null,
      reactions: (json['reactions'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          const {},
      edited: json['edited'] as bool? ?? false,
      editedAt: json['editedAt'] != null
          ? EvTimestamp.parse(json['editedAt'] as String)
          : null,
    );
  }
}
