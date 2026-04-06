import 'package:test/test.dart';
import 'package:ev_protocol/ev_protocol.dart';

void main() {
  final _now = EvTimestamp.now();
  final _pubkey = EvPubkey.fromRawKey('organiser-key');

  group('EvRace', () {
    test('JSON roundtrip', () {
      final race = EvRace(
        dhtKey: const EvDhtKey('race-1'),
        eventDhtKey: const EvDhtKey('event-1'),
        name: 'Race 1',
        raceNumber: 1,
        scheduledStart: _now,
        status: EvRaceStatus.started,
        handicapSystem: EvHandicapSystem.irc,
        conditions: const EvRaceConditions(
          windSpeedKnots: 15.5,
          windDirectionDeg: 225,
          seaState: EvSeaState.choppy,
          visibility: EvVisibility.good,
        ),
      );
      final json = race.toJson();
      expect(json[r'$type'], 'ev.sailing.race');
      final restored = EvRace.fromJson(json);
      expect(restored.status, EvRaceStatus.started);
      expect(restored.conditions!.windSpeedKnots, 15.5);
      expect(restored.conditions!.seaState, EvSeaState.choppy);
    });

    test('all race statuses', () {
      for (final s in EvRaceStatus.values) {
        final r = EvRace(eventDhtKey: const EvDhtKey('e'), name: 'R', scheduledStart: _now, status: s);
        expect(EvRace.fromJson(r.toJson()).status, s);
      }
    });

    test('copyWith', () {
      final race = EvRace(eventDhtKey: const EvDhtKey('e'), name: 'R', scheduledStart: _now);
      final u = race.copyWith(status: EvRaceStatus.finished);
      expect(u.status, EvRaceStatus.finished);
      expect(u.name, 'R');
    });
  });

  group('EvCourse', () {
    test('JSON roundtrip', () {
      final course = EvCourse(
        eventDhtKey: const EvDhtKey('e1'),
        name: 'WL',
        courseType: EvCourseType.windwardLeeward,
        distanceNm: 3.5,
        marks: [
          const EvCourseMark(name: 'WM', latitude: -32.05, longitude: 115.74, rounding: EvRounding.port, order: 1),
        ],
        startLine: const EvLineDefinition(
          pin: EvCourseMark(name: 'Pin', latitude: -32.04, longitude: 115.74),
          boat: EvCourseMark(name: 'RC', latitude: -32.04, longitude: 115.75),
        ),
      );
      final json = course.toJson();
      final restored = EvCourse.fromJson(json);
      expect(restored.marks[0].rounding, EvRounding.port);
      expect(restored.startLine!.pin.name, 'Pin');
      expect(restored.distanceNm, 3.5);
    });

    test('all course types', () {
      for (final t in EvCourseType.values) {
        final c = EvCourse(eventDhtKey: const EvDhtKey('e'), name: 'C', courseType: t, marks: const []);
        expect(EvCourse.fromJson(c.toJson()).courseType, t);
      }
    });
  });

  group('EvTrack', () {
    test('JSON roundtrip', () {
      final track = EvTrack(
        raceDhtKey: const EvDhtKey('r1'),
        sailorPubkey: _pubkey,
        vesselDhtKey: const EvDhtKey('v1'),
        startedAt: _now,
        elapsedSeconds: 3600,
        distanceNm: 12.5,
        summary: const EvTrackSummary(
          maxSpeedKnots: 8.5,
          avgSpeedKnots: 5.2,
          pointCount: 1800,
          boundingBox: EvBoundingBox(north: -31.9, south: -32.1, east: 115.8, west: 115.7),
        ),
      );
      final restored = EvTrack.fromJson(track.toJson());
      expect(restored.elapsedSeconds, 3600);
      expect(restored.summary!.maxSpeedKnots, 8.5);
      expect(restored.summary!.boundingBox!.north, -31.9);
    });
  });

  group('EvRaceResult', () {
    test('JSON roundtrip', () {
      final result = EvRaceResult(
        raceDhtKey: const EvDhtKey('r1'),
        eventDhtKey: const EvDhtKey('e1'),
        publishedAt: _now,
        protestsOpen: true,
        results: [
          const EvFinisherResult(vesselDhtKey: EvDhtKey('v1'), position: 1, status: EvFinishStatus.finished, points: 1.0),
          const EvFinisherResult(vesselDhtKey: EvDhtKey('v2'), position: 2, status: EvFinishStatus.dnf, points: 5.0),
        ],
      );
      final restored = EvRaceResult.fromJson(result.toJson());
      expect(restored.results.length, 2);
      expect(restored.results[1].status, EvFinishStatus.dnf);
      expect(restored.protestsOpen, true);
    });

    test('all finish statuses', () {
      for (final s in EvFinishStatus.values) {
        final r = EvFinisherResult(vesselDhtKey: const EvDhtKey('v'), position: 1, status: s);
        expect(EvFinisherResult.fromJson(r.toJson()).status, s);
      }
    });
  });
}
