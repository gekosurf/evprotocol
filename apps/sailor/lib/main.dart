import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/app.dart';
import 'package:sailor/core/at/at_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  // Lock to portrait on iPhone
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final container = ProviderContainer();

  // Attempt to restore AT Protocol session from secure storage
  try {
    final authService = container.read(atAuthServiceProvider);
    final restored = await authService.tryRestoreSession();
    if (restored) {
      container.read(atAuthStateProvider.notifier).setAuthenticated(true);
      container.read(atSyncServiceProvider).start();
    }
  } catch (e) {
    debugPrint('Session restore failed: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SailorApp(),
    ),
  );
}
