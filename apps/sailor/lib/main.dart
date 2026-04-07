import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/app.dart';
import 'package:sailor/core/sync/sync_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  // Lock to portrait on iPhone
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Attempt to initialize real Veilid node.
  // Falls back to MockVeilidNode if FFI fails.
  VeilidNodeInterface node;
  try {
    final realNode = RealVeilidNode();
    await realNode.initialize();
    node = realNode;
    // ignore: avoid_print
    print('[Sailor] ✅ Veilid core initialized — real DHT active');
  } catch (e) {
    // If Veilid fails to init (e.g., no native libs, etc.)
    // fall back to MockVeilidNode — the app still works offline.
    node = MockVeilidNode();
    // ignore: avoid_print
    print('[Sailor] ⚠️ Veilid init failed, using MockVeilidNode: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        veilidNodeProvider.overrideWithValue(node),
      ],
      child: const SailorApp(),
    ),
  );
}
