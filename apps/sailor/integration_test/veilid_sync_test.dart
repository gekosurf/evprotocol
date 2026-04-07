import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Veilid DHT Integration', () {
    late RealVeilidNode node;

    setUpAll(() async {
      // Initialize a real veilid node connected to the live network
      node = RealVeilidNode();
      await node.initialize();
    });

    tearDownAll(() async {
      await node.shutdown();
    });

    testWidgets('publishRecord, getRecord, and deleteRecord', (tester) async {
      // We expect the online status to become true eventually.
      // Depending on connection speed, we may need to wait.
      var isOnline = await node.isOnline();
      int tries = 0;
      while (!isOnline && tries < 10) {
        await Future<void>.delayed(const Duration(seconds: 1));
        isOnline = await node.isOnline();
        tries++;
      }
      expect(isOnline, isTrue, reason: 'Node should attach to the network');

      final payload = '{"test": "data", "ts": ${DateTime.now().millisecondsSinceEpoch}}';
      
      // 1. Publish
      final publishResult = await node.publishRecord('local-test-key', payload);
      expect(publishResult.success, isTrue);
      expect(publishResult.dhtKey, isNotNull);
      expect(publishResult.dhtKey, isNot('local-test-key'));
      
      final dhtKey = publishResult.dhtKey!;
      
      // 2. Get
      final fetchedPayload = await node.getRecord(dhtKey);
      expect(fetchedPayload, equals(payload));
      
      // 3. Delete
      final deleteResult = await node.deleteRecord(dhtKey);
      expect(deleteResult, isTrue);
      
      // 4. Get after delete should return null
      final fetchAfterDelete = await node.getRecord(dhtKey);
      expect(fetchAfterDelete, isNull);
    });
  });
}
