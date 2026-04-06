import 'package:test/test.dart';
import 'package:ev_protocol/ev_protocol.dart';

void main() {
  group('EvResult', () {
    test('EvSuccess holds value', () {
      const result = EvSuccess(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrThrow, 42);
      expect(result.valueOrNull, 42);
    });

    test('EvFailure holds error', () {
      const result = EvFailure<int>(
        EvError(code: EvErrorCode.notFound, message: 'Not found'),
      );
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(() => result.valueOrThrow, throwsA(isA<EvProtocolException>()));
    });

    test('EvSuccess.map transforms value', () {
      const result = EvSuccess(10);
      final mapped = result.map((v) => v * 2);
      expect(mapped, isA<EvSuccess<int>>());
      expect((mapped as EvSuccess<int>).value, 20);
    });

    test('EvFailure.map preserves error', () {
      const result = EvFailure<int>(
        EvError(code: EvErrorCode.notFound, message: 'x'),
      );
      final mapped = result.map((v) => v * 2);
      expect(mapped, isA<EvFailure<int>>());
    });

    test('EvSuccess.flatMap chains operations', () {
      const result = EvSuccess(5);
      final chained = result.flatMap((v) => EvSuccess(v.toString()));
      expect(chained, isA<EvSuccess<String>>());
      expect((chained as EvSuccess<String>).value, '5');
    });

    test('EvFailure.flatMap short-circuits', () {
      const result = EvFailure<int>(
        EvError(code: EvErrorCode.timeout, message: 'timeout'),
      );
      final chained = result.flatMap((v) => EvSuccess(v.toString()));
      expect(chained, isA<EvFailure<String>>());
    });

    test('EvError toString', () {
      const error = EvError(code: EvErrorCode.notFound, message: 'Missing');
      expect(error.toString(), contains('notFound'));
      expect(error.toString(), contains('Missing'));
    });

    test('EvProtocolException toString', () {
      const error = EvError(code: EvErrorCode.offline, message: 'No net');
      final ex = EvProtocolException(error);
      expect(ex.toString(), contains('offline'));
      expect(ex.toString(), contains('No net'));
    });
  });

  group('EvDhtKey', () {
    test('equality', () {
      const a = EvDhtKey('abc123');
      const b = EvDhtKey('abc123');
      const c = EvDhtKey('xyz789');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });

    test('isValid', () {
      expect(const EvDhtKey('abcdefgh').isValid, isTrue);
      expect(const EvDhtKey('short').isValid, isFalse);
      expect(const EvDhtKey('').isValid, isFalse);
    });

    test('toString', () {
      const key = EvDhtKey('mykey');
      expect(key.toString(), 'mykey');
    });

    test('JSON roundtrip', () {
      const key = EvDhtKey('test-key-123');
      final json = key.toJson();
      final restored = EvDhtKey.fromJson(json);
      expect(restored, equals(key));
    });

    test('fromBase64 factory', () {
      final key = EvDhtKey.fromBase64('dGVzdA==');
      expect(key.value, 'dGVzdA==');
    });
  });

  group('EvPubkey', () {
    test('fromRawKey adds prefix', () {
      final key = EvPubkey.fromRawKey('rawbytes');
      expect(key.value, 'VLD0:rawbytes');
      expect(key.rawKey, 'rawbytes');
    });

    test('isValid checks prefix', () {
      expect(EvPubkey.fromRawKey('abc').isValid, isTrue);
      expect(const EvPubkey('VLD0:').isValid, isFalse);
      expect(const EvPubkey('invalid').isValid, isFalse);
    });

    test('equality', () {
      final a = EvPubkey.fromRawKey('key1');
      final b = EvPubkey.fromRawKey('key1');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('JSON roundtrip', () {
      final key = EvPubkey.fromRawKey('testkey');
      final json = key.toJson();
      final restored = EvPubkey.fromJson(json);
      expect(restored, equals(key));
    });

    test('toString', () {
      final key = EvPubkey.fromRawKey('abc');
      expect(key.toString(), 'VLD0:abc');
    });
  });

  group('EvTimestamp', () {
    test('now creates UTC', () {
      final ts = EvTimestamp.now();
      expect(ts.dateTime.isUtc, isTrue);
    });

    test('parse roundtrip', () {
      final ts = EvTimestamp.parse('2026-04-06T08:00:00.000Z');
      expect(ts.toIso8601(), '2026-04-06T08:00:00.000Z');
    });

    test('comparison', () {
      final a = EvTimestamp.parse('2026-01-01T00:00:00.000Z');
      final b = EvTimestamp.parse('2026-06-01T00:00:00.000Z');
      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect(a.compareTo(b), lessThan(0));
    });

    test('equality', () {
      final a = EvTimestamp.parse('2026-04-06T08:00:00.000Z');
      final b = EvTimestamp.parse('2026-04-06T08:00:00.000Z');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('JSON roundtrip', () {
      final ts = EvTimestamp.now();
      final json = ts.toJson();
      final restored = EvTimestamp.fromJson(json);
      expect(restored.millisecondsSinceEpoch, ts.millisecondsSinceEpoch);
    });

    test('millisecondsSinceEpoch', () {
      final ts = EvTimestamp.parse('2026-01-01T00:00:00.000Z');
      expect(ts.millisecondsSinceEpoch, greaterThan(0));
    });
  });

  group('EvProtocolConfig', () {
    test('defaults', () {
      const config = EvProtocolConfig();
      expect(config.protocolVersion, '0.1.0');
      expect(config.bootstrapNodes, isEmpty);
      expect(config.enableAtBridge, isFalse);
      expect(config.maxSearchTier, 1);
      expect(config.syncIntervalSeconds, 30);
      expect(config.enableDeviceModeration, isTrue);
      expect(config.lowPowerMode, isTrue);
    });

    test('copyWith', () {
      const config = EvProtocolConfig();
      final updated = config.copyWith(
        maxSearchTier: 3,
        enableAtBridge: true,
        bootstrapNodes: ['node1.example.com'],
      );
      expect(updated.maxSearchTier, 3);
      expect(updated.enableAtBridge, isTrue);
      expect(updated.bootstrapNodes, ['node1.example.com']);
      expect(updated.protocolVersion, '0.1.0'); // unchanged
    });
  });
}
