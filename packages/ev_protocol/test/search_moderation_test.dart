import 'package:test/test.dart';
import 'package:ev_protocol/ev_protocol.dart';

void main() {
  final _now = EvTimestamp.now();

  group('EvSearchResult', () {
    test('JSON roundtrip', () {
      final result = EvSearchResult(
        eventDhtKey: const EvDhtKey('event-1'),
        title: 'Perth Regatta',
        descriptionSnippet: 'Annual sailing event...',
        startAt: _now,
        category: 'sailing',
        locationName: 'Fremantle',
        latitude: -32.05,
        longitude: 115.74,
        distanceKm: 12.5,
        relevanceScore: 0.95,
        searchTier: 3,
        rsvpCount: 42,
        groupDhtKey: const EvDhtKey('group-1'),
        tags: ['sailing', 'regatta'],
      );

      final json = result.toJson();
      expect(json['title'], 'Perth Regatta');
      expect(json['searchTier'], 3);
      expect(json['relevanceScore'], 0.95);
      expect(json['distanceKm'], 12.5);

      final restored = EvSearchResult.fromJson(json);
      expect(restored.title, 'Perth Regatta');
      expect(restored.distanceKm, 12.5);
      expect(restored.relevanceScore, 0.95);
      expect(restored.searchTier, 3);
      expect(restored.tags, ['sailing', 'regatta']);
    });

    test('tier 1 result (minimal)', () {
      final result = EvSearchResult(
        eventDhtKey: const EvDhtKey('event-2'),
        title: 'Local Meetup',
        startAt: _now,
        searchTier: 1,
      );
      final json = result.toJson();
      expect(json.containsKey('relevanceScore'), isFalse);
      expect(json.containsKey('distanceKm'), isFalse);
    });
  });

  group('EvModerationReport', () {
    test('JSON roundtrip', () {
      final report = EvModerationReport(
        dhtKey: const EvDhtKey('report-1'),
        reporterPubkey: EvPubkey.fromRawKey('reporter'),
        eventDhtKey: const EvDhtKey('event-1'),
        targetType: EvReportTargetType.message,
        targetId: 'msg-bad-1',
        reason: EvReportReason.harassment,
        description: 'Offensive language in chat',
        createdAt: _now,
      );

      final json = report.toJson();
      expect(json[r'$type'], 'ev.moderation.report');
      expect(json['targetType'], 'message');
      expect(json['reason'], 'harassment');

      final restored = EvModerationReport.fromJson(json);
      expect(restored.targetType, EvReportTargetType.message);
      expect(restored.reason, EvReportReason.harassment);
      expect(restored.description, 'Offensive language in chat');
    });

    test('all report reasons', () {
      for (final reason in EvReportReason.values) {
        final report = EvModerationReport(
          reporterPubkey: EvPubkey.fromRawKey('r'),
          eventDhtKey: const EvDhtKey('e1'),
          targetType: EvReportTargetType.content,
          targetId: 'x',
          reason: reason,
          createdAt: _now,
        );
        final json = report.toJson();
        final restored = EvModerationReport.fromJson(json);
        expect(restored.reason, reason);
      }
    });

    test('all target types', () {
      for (final type in EvReportTargetType.values) {
        final report = EvModerationReport(
          reporterPubkey: EvPubkey.fromRawKey('r'),
          eventDhtKey: const EvDhtKey('e1'),
          targetType: type,
          targetId: 'x',
          reason: EvReportReason.spam,
          createdAt: _now,
        );
        final json = report.toJson();
        final restored = EvModerationReport.fromJson(json);
        expect(restored.targetType, type);
      }
    });
  });

  group('EvModerationAction', () {
    test('JSON roundtrip', () {
      final action = EvModerationAction(
        dhtKey: const EvDhtKey('action-1'),
        moderatorPubkey: EvPubkey.fromRawKey('mod'),
        eventDhtKey: const EvDhtKey('event-1'),
        actionType: EvModerationActionType.ban,
        targetId: 'user-bad-1',
        targetUserPubkey: EvPubkey.fromRawKey('bad-user'),
        reason: 'Repeated harassment',
        duration: const Duration(hours: 24),
        createdAt: _now,
        expiresAt: EvTimestamp.parse('2026-04-07T08:00:00.000Z'),
      );

      final json = action.toJson();
      expect(json[r'$type'], 'ev.moderation.action');
      expect(json['actionType'], 'ban');
      expect(json['durationMs'], 86400000);

      final restored = EvModerationAction.fromJson(json);
      expect(restored.actionType, EvModerationActionType.ban);
      expect(restored.reason, 'Repeated harassment');
      expect(restored.duration!.inHours, 24);
    });

    test('all action types', () {
      for (final type in EvModerationActionType.values) {
        final action = EvModerationAction(
          moderatorPubkey: EvPubkey.fromRawKey('mod'),
          eventDhtKey: const EvDhtKey('e1'),
          actionType: type,
          targetId: 'x',
          createdAt: _now,
        );
        final json = action.toJson();
        final restored = EvModerationAction.fromJson(json);
        expect(restored.actionType, type);
      }
    });
  });
}
