import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  // Lock to portrait on iPhone
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    const ProviderScope(
      child: SailorApp(),
    ),
  );
}
