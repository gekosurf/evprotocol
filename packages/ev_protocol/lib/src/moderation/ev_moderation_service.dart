import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_result.dart';
import 'ev_moderation_action.dart';
import 'ev_moderation_report.dart';

/// Abstract interface for content moderation in the EV Protocol.
///
/// ```mermaid
/// sequenceDiagram
///     participant User as Attendee
///     participant Svc as EvModerationService
///     participant AI as On-Device AI
///     participant DHT as Veilid DHT
///     participant Org as Organiser
///
///     Note over User,Org: TIER 1 — ON-DEVICE AI (pre-upload)
///     User->>Svc: moderateContent(imageBytes)
///     Svc->>AI: NSFW classifier (MobileNet v2)
///     AI-->>Svc: Score: 0.92 (UNSAFE)
///     Svc-->>User: EvFailure(NSFW content blocked)
///     Note over User: Image never leaves device
///
///     Note over User,Org: TIER 3 — COMMUNITY REPORT
///     User->>Svc: reportContent(targetId, reason)
///     Svc->>DHT: Write ev.moderation.report
///     Svc->>Svc: Check report threshold (3 reports)
///     Svc->>DHT: Auto-hide if threshold reached
///     Svc-->>User: EvSuccess(EvModerationReport)
///
///     Note over User,Org: TIER 2 — ORGANISER ACTION
///     Org->>Svc: takeAction(targetId, action: remove)
///     Svc->>DHT: Write ev.moderation.action
///     Svc-->>Org: EvSuccess(EvModerationAction)
/// ```
abstract class EvModerationService {
  /// Checks content against on-device AI moderation (Tier 1).
  ///
  /// Returns true if the content is safe, false if it should be blocked.
  /// The content never leaves the device.
  Future<EvResult<bool>> moderateContent(List<int> imageBytes);

  /// Submits a community report (Tier 3).
  Future<EvResult<EvModerationReport>> reportContent({
    required EvDhtKey eventDhtKey,
    required EvReportTargetType targetType,
    required String targetId,
    required EvReportReason reason,
    String? description,
  });

  /// Takes a moderation action (Tier 2, organiser/admin only).
  Future<EvResult<EvModerationAction>> takeAction({
    required EvDhtKey eventDhtKey,
    required EvModerationActionType actionType,
    required String targetId,
    EvPubkey? targetUserPubkey,
    String? reason,
    Duration? duration,
  });

  /// Reverses a previous moderation action.
  Future<EvResult<EvModerationAction>> reverseAction({
    required EvDhtKey actionDhtKey,
    String? reason,
  });

  /// Lists all reports for an event (organiser only).
  Future<EvResult<List<EvModerationReport>>> listReports(
      EvDhtKey eventDhtKey);

  /// Lists all moderation actions for an event.
  Future<EvResult<List<EvModerationAction>>> listActions(
      EvDhtKey eventDhtKey);

  /// Checks if content/user is currently hidden or banned.
  Future<EvResult<bool>> isHidden({
    required EvDhtKey eventDhtKey,
    required String targetId,
  });

  /// Gets the current user's block list.
  Future<EvResult<List<EvPubkey>>> getBlockList();

  /// Blocks a user (client-side, affects only the current user's view).
  Future<EvResult<void>> blockUser(EvPubkey pubkey);

  /// Unblocks a user.
  Future<EvResult<void>> unblockUser(EvPubkey pubkey);
}
