import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';

/// A content or user report submitted by a community member.
///
/// Schema: `ev.moderation.report`
class EvModerationReport {
  final EvDhtKey? dhtKey;
  final EvPubkey reporterPubkey;
  final EvDhtKey eventDhtKey;
  final EvReportTargetType targetType;
  final String targetId;
  final EvReportReason reason;
  final String? description;
  final EvTimestamp createdAt;

  const EvModerationReport({
    this.dhtKey,
    required this.reporterPubkey,
    required this.eventDhtKey,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.moderation.report',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'reporterPubkey': reporterPubkey.toString(),
        'eventDhtKey': eventDhtKey.toString(),
        'targetType': targetType.name,
        'targetId': targetId,
        'reason': reason.name,
        if (description != null) 'description': description,
        'createdAt': createdAt.toIso8601(),
      };

  factory EvModerationReport.fromJson(Map<String, dynamic> json) {
    return EvModerationReport(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      reporterPubkey: EvPubkey(json['reporterPubkey'] as String),
      eventDhtKey: EvDhtKey(json['eventDhtKey'] as String),
      targetType: EvReportTargetType.values.firstWhere(
        (t) => t.name == json['targetType'],
        orElse: () => EvReportTargetType.content,
      ),
      targetId: json['targetId'] as String,
      reason: EvReportReason.values.firstWhere(
        (r) => r.name == json['reason'],
        orElse: () => EvReportReason.other,
      ),
      description: json['description'] as String?,
      createdAt: EvTimestamp.parse(json['createdAt'] as String),
    );
  }
}

enum EvReportTargetType { content, user, message, media }

enum EvReportReason { spam, harassment, nsfw, misinformation, violence, other }
