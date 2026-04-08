import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/router/app_router.dart';
import 'package:sailor/core/theme/app_theme.dart';

/// Enables mouse/trackpad scrolling on desktop platforms.
class _DesktopScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// Root widget for the Sailor app.
class SailorApp extends ConsumerWidget {
  const SailorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Sailor',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      scrollBehavior: _DesktopScrollBehavior(),
      routerConfig: router,
    );
  }
}
