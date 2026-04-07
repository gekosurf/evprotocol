import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailor/core/router/app_router.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/discover/presentation/providers/discover_providers.dart';
import 'package:sailor/features/discover/presentation/providers/search_providers.dart';
import 'package:sailor/features/discover/presentation/widgets/category_chips.dart';
import 'package:sailor/features/discover/presentation/widgets/search_bar_widget.dart';
import 'package:sailor/features/events/presentation/widgets/event_card.dart';

/// Discover page — shows all events with search and category filtering.
class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(discoverEventsProvider);
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);
    final hasFilters = query.isNotEmpty || category != null;

    return Column(
      children: [
        // Search bar (always visible)
        const EventSearchBar(),
        // Category chips
        const CategoryChips(),
        const SizedBox(height: 4),
        // Event list
        Expanded(
          child: eventsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  const Text('Failed to load events', style: AppTextStyles.body),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        ref.read(discoverEventsProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (page) => RefreshIndicator(
              color: AppColors.highlight,
              backgroundColor: AppColors.surfaceBg,
              onRefresh: () =>
                  ref.read(discoverEventsProvider.notifier).refresh(),
              child: page.events.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.4,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasFilters
                                      ? Icons.search_off
                                      : Icons.explore_outlined,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  hasFilters
                                      ? 'No events match your search'
                                      : 'No events nearby',
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hasFilters
                                      ? 'Try a different search or category'
                                      : 'Pull to refresh or create your own',
                                  style: AppTextStyles.bodySecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 100),
                      itemCount: page.events.length,
                      itemBuilder: (context, index) {
                        final event = page.events[index];
                        return EventCard(
                          event: event,
                          onTap: () => context.push(
                            '${AppRoutes.eventDetail}/${event.dhtKey?.value ?? index}',
                            extra: event,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
