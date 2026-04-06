import 'package:test/test.dart';
import 'package:ev_protocol/ev_protocol.dart';

/// Tests specifically targeting the ~5% of code paths that were not
/// covered by the main test suite.
void main() {
  final _now = EvTimestamp.now();
  final _pubkey = EvPubkey.fromRawKey('test-key');

  group('EvError.cause', () {
    test('cause is preserved', () {
      final cause = Exception('underlying error');
      final error = EvError(
        code: EvErrorCode.networkError,
        message: 'Connection failed',
        cause: cause,
      );
      expect(error.cause, same(cause));
    });

    test('cause is null by default', () {
      const error = EvError(code: EvErrorCode.unknown, message: 'x');
      expect(error.cause, isNull);
    });
  });

  group('EvValidationError', () {
    test('toString', () {
      const err = EvValidationError(
        field: 'ticketing.tiers[0].priceMinor',
        message: 'Must be >= 0',
        type: EvValidationErrorType.belowMinimum,
      );
      expect(err.toString(), contains('ticketing.tiers[0].priceMinor'));
      expect(err.toString(), contains('Must be >= 0'));
    });

    test('all error types exist', () {
      // Ensures the enum is complete and accessible
      expect(EvValidationErrorType.values.length, 8);
      expect(EvValidationErrorType.values, contains(EvValidationErrorType.requiredFieldMissing));
      expect(EvValidationErrorType.values, contains(EvValidationErrorType.typeMismatch));
      expect(EvValidationErrorType.values, contains(EvValidationErrorType.maxLengthExceeded));
      expect(EvValidationErrorType.values, contains(EvValidationErrorType.belowMinimum));
      expect(EvValidationErrorType.values, contains(EvValidationErrorType.aboveMaximum));
      expect(EvValidationErrorType.values, contains(EvValidationErrorType.formatInvalid));
      expect(EvValidationErrorType.values, contains(EvValidationErrorType.unknownReference));
      expect(EvValidationErrorType.values, contains(EvValidationErrorType.unknownSchema));
    });
  });

  group('EvTicketTier with timestamps', () {
    test('salesStart and salesEnd roundtrip', () {
      final tier = EvTicketTier(
        name: 'Early Bird',
        priceMinor: 3000,
        maxPriceMinor: 5000,
        quantity: 50,
        description: 'Discounted early tickets',
        salesStart: _now,
        salesEnd: EvTimestamp.parse('2026-12-01T00:00:00.000Z'),
      );
      final json = tier.toJson();
      expect(json['salesStart'], isNotNull);
      expect(json['salesEnd'], isNotNull);
      expect(json['maxPriceMinor'], 5000);
      expect(json['description'], 'Discounted early tickets');

      final restored = EvTicketTier.fromJson(json);
      expect(restored.salesStart, isNotNull);
      expect(restored.salesEnd, isNotNull);
      expect(restored.maxPriceMinor, 5000);
      expect(restored.description, 'Discounted early tickets');
    });
  });

  group('EvRaceConditions full fields', () {
    test('currentKnots and currentDirectionDeg roundtrip', () {
      const conditions = EvRaceConditions(
        windSpeedKnots: 12.0,
        windDirectionDeg: 180,
        seaState: EvSeaState.flat,
        currentKnots: 2.5,
        currentDirectionDeg: 90,
        visibility: EvVisibility.moderate,
      );
      final json = conditions.toJson();
      expect(json['currentKnots'], 2.5);
      expect(json['currentDirectionDeg'], 90);
      expect(json['seaState'], 'flat');
      expect(json['visibility'], 'moderate');

      final restored = EvRaceConditions.fromJson(json);
      expect(restored.currentKnots, 2.5);
      expect(restored.currentDirectionDeg, 90);
      expect(restored.seaState, EvSeaState.flat);
      expect(restored.visibility, EvVisibility.moderate);
    });

    test('all sea states', () {
      for (final s in EvSeaState.values) {
        final c = EvRaceConditions(seaState: s);
        final restored = EvRaceConditions.fromJson(c.toJson());
        expect(restored.seaState, s);
      }
    });

    test('all visibility values', () {
      for (final v in EvVisibility.values) {
        final c = EvRaceConditions(visibility: v);
        final restored = EvRaceConditions.fromJson(c.toJson());
        expect(restored.visibility, v);
      }
    });

    test('empty conditions', () {
      const c = EvRaceConditions();
      final json = c.toJson();
      expect(json, isEmpty);
      final restored = EvRaceConditions.fromJson(json);
      expect(restored.windSpeedKnots, isNull);
    });
  });

  group('EvTrack with trackRef', () {
    test('trackRef media reference roundtrip', () {
      final track = EvTrack(
        raceDhtKey: const EvDhtKey('r1'),
        sailorPubkey: _pubkey,
        vesselDhtKey: const EvDhtKey('v1'),
        startedAt: _now,
        finishedAt: _now,
        correctedSeconds: 3100,
        trackRef: EvMediaReference(
          uploaderPubkey: _pubkey,
          url: 'https://r2.example.com/track.gpx',
          sha256Hash: 'gpxhash',
          sizeBytes: 50000,
          mimeType: 'application/gpx+xml',
          createdAt: _now,
        ),
      );
      final json = track.toJson();
      expect(json['trackRef'], isNotNull);
      expect(json['correctedSeconds'], 3100);
      expect(json['finishedAt'], isNotNull);

      final restored = EvTrack.fromJson(json);
      expect(restored.trackRef!.url, 'https://r2.example.com/track.gpx');
      expect(restored.trackRef!.mimeType, 'application/gpx+xml');
      expect(restored.correctedSeconds, 3100);
      expect(restored.finishedAt, isNotNull);
    });
  });

  group('EvChatMessage with media', () {
    test('media attachment roundtrip', () {
      final msg = EvChatMessage(
        id: 'msg-media',
        channelDhtKey: const EvDhtKey('c1'),
        senderPubkey: _pubkey,
        text: 'Check this photo!',
        sentAt: _now,
        media: EvMediaReference(
          uploaderPubkey: _pubkey,
          url: 'https://r2.example.com/photo.jpg',
          sha256Hash: 'photohash',
          sizeBytes: 2000000,
          mimeType: 'image/jpeg',
          createdAt: _now,
        ),
      );
      final json = msg.toJson();
      expect(json['media'], isNotNull);
      expect(json['media']['mimeType'], 'image/jpeg');

      final restored = EvChatMessage.fromJson(json);
      expect(restored.media, isNotNull);
      expect(restored.media!.url, 'https://r2.example.com/photo.jpg');
    });
  });

  group('EvBoundingBox', () {
    test('JSON roundtrip', () {
      const bb = EvBoundingBox(north: -31.9, south: -32.1, east: 115.8, west: 115.7);
      final json = bb.toJson();
      final restored = EvBoundingBox.fromJson(json);
      expect(restored.north, -31.9);
      expect(restored.south, -32.1);
      expect(restored.east, 115.8);
      expect(restored.west, 115.7);
    });
  });

  group('EvTrackSummary minimal', () {
    test('empty summary', () {
      const summary = EvTrackSummary();
      final json = summary.toJson();
      expect(json, isEmpty);
      final restored = EvTrackSummary.fromJson(json);
      expect(restored.maxSpeedKnots, isNull);
      expect(restored.boundingBox, isNull);
    });
  });

  group('EvFinisherResult with all fields', () {
    test('skipperPubkey and trackDhtKey roundtrip', () {
      final result = EvFinisherResult(
        vesselDhtKey: const EvDhtKey('v1'),
        skipperPubkey: _pubkey,
        position: 1,
        elapsedSeconds: 3200,
        correctedSeconds: 3000,
        points: 1.0,
        status: EvFinishStatus.finished,
        trackDhtKey: const EvDhtKey('track-1'),
      );
      final json = result.toJson();
      expect(json['skipperPubkey'], isNotNull);
      expect(json['trackDhtKey'], 'track-1');
      expect(json['elapsedSeconds'], 3200);

      final restored = EvFinisherResult.fromJson(json);
      expect(restored.skipperPubkey, _pubkey);
      expect(restored.trackDhtKey!.value, 'track-1');
    });
  });

  group('EvEvent defaults', () {
    test('unknown visibility defaults to public', () {
      final json = {
        'creatorPubkey': _pubkey.toString(),
        'name': 'Test',
        'startAt': _now.toIso8601(),
        'createdAt': _now.toIso8601(),
        'visibility': 'nonexistent_value',
      };
      final event = EvEvent.fromJson(json);
      expect(event.visibility, EvEventVisibility.public_);
    });

    test('missing rsvpCount defaults to 0', () {
      final json = {
        'creatorPubkey': _pubkey.toString(),
        'name': 'Test',
        'startAt': _now.toIso8601(),
        'createdAt': _now.toIso8601(),
      };
      final event = EvEvent.fromJson(json);
      expect(event.rsvpCount, 0);
    });

    test('missing tags defaults to empty', () {
      final json = {
        'creatorPubkey': _pubkey.toString(),
        'name': 'Test',
        'startAt': _now.toIso8601(),
        'createdAt': _now.toIso8601(),
      };
      final event = EvEvent.fromJson(json);
      expect(event.tags, isEmpty);
    });
  });

  group('EvGroup defaults', () {
    test('empty members and vessels from JSON', () {
      final json = {
        'name': 'Club',
        'adminPubkey': _pubkey.toString(),
        'createdAt': _now.toIso8601(),
        'visibility': 'public_',
      };
      final group = EvGroup.fromJson(json);
      expect(group.members, isEmpty);
      expect(group.vesselDhtKeys, isEmpty);
    });
  });

  group('EvChatChannel defaults', () {
    test('empty participants from JSON', () {
      final json = {
        'eventDhtKey': 'e1',
        'name': 'Chan',
        'type': 'discussion',
        'creatorPubkey': _pubkey.toString(),
        'createdAt': _now.toIso8601(),
      };
      final channel = EvChatChannel.fromJson(json);
      expect(channel.participantPubkeys, isEmpty);
    });
  });

  group('EvChatMessage defaults', () {
    test('missing reactions and edited defaults', () {
      final json = {
        'id': 'm1',
        'channelDhtKey': 'c1',
        'senderPubkey': _pubkey.toString(),
        'text': 'Hello',
        'sentAt': _now.toIso8601(),
      };
      final msg = EvChatMessage.fromJson(json);
      expect(msg.reactions, isEmpty);
      expect(msg.edited, isFalse);
    });
  });

  group('EvRsvp defaults', () {
    test('missing isPublic defaults to true', () {
      final json = {
        'eventDhtKey': 'e1',
        'attendeePubkey': _pubkey.toString(),
        'status': 'pending',
        'createdAt': _now.toIso8601(),
      };
      final rsvp = EvRsvp.fromJson(json);
      expect(rsvp.isPublic, isTrue);
      expect(rsvp.guestCount, 0);
    });
  });

  group('EvModerationAction without optional fields', () {
    test('no duration or expiry', () {
      final action = EvModerationAction(
        moderatorPubkey: _pubkey,
        eventDhtKey: const EvDhtKey('e1'),
        actionType: EvModerationActionType.warn,
        targetId: 'u1',
        createdAt: _now,
      );
      final json = action.toJson();
      expect(json.containsKey('durationMs'), isFalse);
      expect(json.containsKey('expiresAt'), isFalse);
      expect(json.containsKey('targetUserPubkey'), isFalse);
    });
  });

  group('EvVessel defaults', () {
    test('empty crew from JSON', () {
      final json = {
        'name': 'Boat',
        'ownerPubkey': _pubkey.toString(),
      };
      final vessel = EvVessel.fromJson(json);
      expect(vessel.crew, isEmpty);
    });
  });
}
