import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailor/core/router/app_router.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/features/discover/presentation/pages/discover_page.dart';
import 'package:sailor/features/events/presentation/pages/event_list_page.dart';

/// Main shell with bottom tab navigation.
///
/// Two tabs:
/// - **Discover** — all cached events (seed + user + DHT)
/// - **My Events** — events created by the current user
///
/// The FAB floats above both tabs for creating new events.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sailor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DiscoverPage(),
          EventListPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: AppColors.surfaceBg,
        indicatorColor: AppColors.highlightMuted,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.highlight),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.sailing_outlined),
            selectedIcon: Icon(Icons.sailing, color: AppColors.highlight),
            label: 'My Events',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.highlight,
        foregroundColor: AppColors.textOnHighlight,
        onPressed: () => context.push(AppRoutes.createEvent),
        child: const Icon(Icons.add),
      ),
    );
  }
}
