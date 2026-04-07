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

  // Initialize real Veilid node
  final veilidNode = RealVeilidNode();
  try {
    await veilidNode.initialize();
    // ignore: avoid_print
    print('[Sailor] Veilid core initialized');
  } catch (e) {
    // If Veilid fails to init (e.g. no network), fall back gracefully.
    // The app still works offline with local SQLite — sync will retry
    // when the node comes online.
    // ignore: avoid_print
    print('[Sailor] Veilid init failed (offline mode): $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        veilidNodeProvider.overrideWithValue(veilidNode),
      ],
      child: const SailorApp(),
    ),
  );
}
