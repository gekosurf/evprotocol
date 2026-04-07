// =============================================================================
// Veilid DHT Integration Test
//
// DISABLED: Requires `veilid` FFI package which crashes on iOS simulator.
// To enable: uncomment veilid dep in pubspec.yaml and uncomment tests below.
// Run on a real iOS device only.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Veilid DHT Integration (placeholder)', () {
    testWidgets('requires real device with veilid FFI', (tester) async {
      // This test is a placeholder. When veilid FFI is enabled:
      //
      // 1. Uncomment the `veilid` dependency in both pubspec.yaml files
      // 2. Re-export real_veilid_node.dart from ev_protocol_veilid.dart
      // 3. Replace this test with:
      //
      //   final node = RealVeilidNode();
      //   await node.initialize();
      //   final result = await node.publishRecord('local-test', '{"test":true}');
      //   expect(result.success, isTrue);
      //   await node.shutdown();
      //
      expect(true, isTrue);
    });
  });
}
