import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';

/// A moderation action taken by an organiser or admin.
///
/// Schema: `ev.moderation.action`
class EvModerationAction {
  final EvDhtKey? dhtKey;
  final EvPubkey moderatorPubkey;
  final EvDhtKey eventDhtKey;
  final EvModerationActionType actionType;
  final String targetId;
  final EvPubkey? targetUserPubkey;
  final String? reason;
  final Duration? duration;
  final EvTimestamp createdAt;
  final EvTimestamp? expiresAt;

  const EvModerationAction({
    this.dhtKey,
    required this.moderatorPubkey,
    required this.eventDhtKey,
    required this.actionType,
    required this.targetId,
    this.targetUserPubkey,
    this.reason,
    this.duration,
    required this.createdAt,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.moderation.action',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'moderatorPubkey': moderatorPubkey.toString(),
        'eventDhtKey': eventDhtKey.toString(),
        'actionType': actionType.name,
        'targetId': targetId,
        if (targetUserPubkey != null)
          'targetUserPubkey': targetUserPubkey.toString(),
        if (reason != null) 'reason': reason,
        if (duration != null) 'durationMs': duration!.inMilliseconds,
        'createdAt': createdAt.toIso8601(),
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601(),
      };

  factory EvModerationAction.fromJson(Map<String, dynamic> json) {
    return EvModerationAction(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      moderatorPubkey: EvPubkey(json['moderatorPubkey'] as String),
      eventDhtKey: EvDhtKey(json['eventDhtKey'] as String),
      actionType: EvModerationActionType.values.firstWhere(
        (t) => t.name == json['actionType'],
        orElse: () => EvModerationActionType.hide,
      ),
      targetId: json['targetId'] as String,
      targetUserPubkey: json['targetUserPubkey'] != null
          ? EvPubkey(json['targetUserPubkey'] as String)
          : null,
      reason: json['reason'] as String?,
      duration: json['durationMs'] != null
          ? Duration(milliseconds: json['durationMs'] as int)
          : null,
      createdAt: EvTimestamp.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? EvTimestamp.parse(json['expiresAt'] as String)
          : null,
    );
  }
}

enum EvModerationActionType {
  /// Content hidden from public view.
  hide,

  /// Content permanently removed.
  remove,

  /// User temporarily muted in event channels.
  mute,

  /// User banned from event.
  ban,

  /// Warning issued to user.
  warn,

  /// Previous action reversed.
  reverse,
}
