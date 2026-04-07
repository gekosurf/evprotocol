import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  // Lock to portrait on iPhone
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // NOTE: When veilid native FFI is working on-device, uncomment this
  // to initialize RealVeilidNode and override veilidNodeProvider.
  // For now, MockVeilidNode is used via the default provider.

  runApp(
    const ProviderScope(
      child: SailorApp(),
    ),
  );
}
