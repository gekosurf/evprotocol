import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/router/app_router.dart';
import 'package:sailor/core/sync/sync_provider.dart';
import 'package:sailor/core/theme/app_theme.dart';

/// Root widget for the Sailor app.
class SailorApp extends ConsumerStatefulWidget {
  const SailorApp({super.key});

  @override
  ConsumerState<SailorApp> createState() => _SailorAppState();
}

class _SailorAppState extends ConsumerState<SailorApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final node = ref.read(veilidNodeProvider);
    if (node is! RealVeilidNode) return;

    switch (state) {
      case AppLifecycleState.resumed:
        node.attach(); // Reconnect to Veilid routing table
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        node.detach(); // Disconnect to save battery/network
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Sailor',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
