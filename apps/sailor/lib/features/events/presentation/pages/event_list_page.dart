import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailor/core/router/app_router.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/discover/presentation/providers/search_providers.dart';
import 'package:sailor/features/discover/presentation/widgets/category_chips.dart';
import 'package:sailor/features/discover/presentation/widgets/search_bar_widget.dart';
import 'package:sailor/features/events/presentation/providers/event_providers.dart';
import 'package:sailor/features/events/presentation/widgets/event_card.dart';

/// My Events page — shows events created by the current user, with search.
class EventListPage extends ConsumerWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(myEventsProvider);
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);
    final hasFilters = query.isNotEmpty || category != null;

    return Column(
      children: [
        const EventSearchBar(),
        const CategoryChips(),
        const SizedBox(height: 4),
        Expanded(
          child: eventState.when(
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
                        ref.read(myEventsProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (page) => RefreshIndicator(
              color: AppColors.highlight,
              backgroundColor: AppColors.surfaceBg,
              onRefresh: () =>
                  ref.read(myEventsProvider.notifier).refresh(),
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
                                      : Icons.sailing_outlined,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  hasFilters
                                      ? 'No events match your search'
                                      : 'No events yet',
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hasFilters
                                      ? 'Try a different search or category'
                                      : 'Create your first event below',
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
