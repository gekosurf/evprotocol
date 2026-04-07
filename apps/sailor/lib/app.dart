import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/router/app_router.dart';
import 'package:sailor/core/theme/app_theme.dart';

/// Root widget for the Sailor app.
///
/// When the veilid FFI is enabled, this should be upgraded to a
/// ConsumerStatefulWidget with WidgetsBindingObserver to manage
/// Veilid lifecycle (attach on resume, detach on pause).
class SailorApp extends ConsumerWidget {
  const SailorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Sailor',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
