import 'package:test/test.dart';
import 'package:ev_protocol/ev_protocol.dart';

void main() {
  group('EvLexiconRegistry', () {
    late EvLexiconRegistry registry;

    setUp(() {
      registry = EvLexiconRegistry();
    });

    test('register and retrieve', () {
      registry.registerLexicon({'lexicon': 1, 'id': 'ev.test.schema', 'revision': 1});
      expect(registry.hasLexicon('ev.test.schema'), isTrue);
      expect(registry.getLexicon('ev.test.schema'), isNotNull);
      expect(registry.getLexicon('ev.test.schema')!['id'], 'ev.test.schema');
    });

    test('missing schema returns null', () {
      expect(registry.getLexicon('ev.nonexistent'), isNull);
      expect(registry.hasLexicon('ev.nonexistent'), isFalse);
    });

    test('registerAll', () {
      registry.registerAll([
        {'lexicon': 1, 'id': 'ev.a', 'revision': 1},
        {'lexicon': 1, 'id': 'ev.b', 'revision': 1},
        {'lexicon': 1, 'id': 'ev.c', 'revision': 1},
      ]);
      expect(registry.count, 3);
      expect(registry.registeredIds, containsAll(['ev.a', 'ev.b', 'ev.c']));
    });

    test('listByNamespace', () {
      registry.registerAll([
        {'lexicon': 1, 'id': 'ev.sailing.race', 'revision': 1},
        {'lexicon': 1, 'id': 'ev.sailing.track', 'revision': 1},
        {'lexicon': 1, 'id': 'ev.event.record', 'revision': 1},
      ]);
      final sailing = registry.listByNamespace('ev.sailing');
      expect(sailing, hasLength(2));
      expect(sailing, contains('ev.sailing.race'));
      expect(sailing, contains('ev.sailing.track'));
    });

    test('unregister', () {
      registry.registerLexicon({'lexicon': 1, 'id': 'ev.temp', 'revision': 1});
      expect(registry.hasLexicon('ev.temp'), isTrue);
      registry.unregisterLexicon('ev.temp');
      expect(registry.hasLexicon('ev.temp'), isFalse);
    });

    test('throws on missing id', () {
      expect(
        () => registry.registerLexicon({'lexicon': 1}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on empty id', () {
      expect(
        () => registry.registerLexicon({'lexicon': 1, 'id': ''}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on missing lexicon version', () {
      expect(
        () => registry.registerLexicon({'id': 'ev.test'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on invalid lexicon version', () {
      expect(
        () => registry.registerLexicon({'lexicon': 0, 'id': 'ev.test'}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('EvLexicons constants', () {
    test('allCore has expected count', () {
      expect(EvLexicons.allCore.length, 16);
    });

    test('allSailing has expected count', () {
      expect(EvLexicons.allSailing.length, 4);
    });

    test('allV01 is superset', () {
      expect(EvLexicons.allV01.length, 20);
      for (final id in EvLexicons.allCore) {
        expect(EvLexicons.allV01, contains(id));
      }
      for (final id in EvLexicons.allSailing) {
        expect(EvLexicons.allV01, contains(id));
      }
    });

    test('all IDs follow ev.* convention', () {
      for (final id in EvLexicons.allV01) {
        expect(id, startsWith('ev.'));
      }
    });
  });

  group('EvSchemaValidator', () {
    test('extractSchemaId', () {
      final data = {r'$type': 'ev.event.record', 'name': 'Test'};
      expect(EvSchemaValidator.extractSchemaId(data), 'ev.event.record');
    });

    test('extractSchemaId returns null for missing', () {
      expect(EvSchemaValidator.extractSchemaId({'name': 'Test'}), isNull);
    });

    test('extractVersion', () {
      final data = {r'$ev_version': '0.1.0'};
      expect(EvSchemaValidator.extractVersion(data), '0.1.0');
    });
  });

  group('EvSyncEvent', () {
    test('construction', () {
      final event = EvSyncEvent(
        dhtKey: const EvDhtKey('key-1'),
        status: EvSyncStatus.synced,
        timestamp: DateTime.now(),
      );
      expect(event.status, EvSyncStatus.synced);
      expect(event.errorMessage, isNull);
    });

    test('with error', () {
      final event = EvSyncEvent(
        dhtKey: const EvDhtKey('key-2'),
        status: EvSyncStatus.syncFailed,
        errorMessage: 'DHT timeout',
        timestamp: DateTime.now(),
      );
      expect(event.status, EvSyncStatus.syncFailed);
      expect(event.errorMessage, 'DHT timeout');
    });
  });
}
