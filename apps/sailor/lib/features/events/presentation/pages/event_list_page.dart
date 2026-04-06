import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailor/core/router/app_router.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/events/presentation/providers/event_providers.dart';
import 'package:sailor/features/events/presentation/widgets/event_card.dart';

/// Event list page — replaces the placeholder home page.
class EventListPage extends ConsumerWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sailor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Profile page
            },
          ),
        ],
      ),
      body: eventState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              const Text(
                'Failed to load events',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(eventListProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (page) => RefreshIndicator(
          color: AppColors.highlight,
          backgroundColor: AppColors.surfaceBg,
          onRefresh: () =>
              ref.read(eventListProvider.notifier).refresh(),
          child: page.events.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.sailing_outlined,
                              size: 64,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events yet',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Create your first event below',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: page.events.length,
                  itemBuilder: (context, index) {
                    final event = page.events[index];
                    return EventCard(
                      event: event,
                      onTap: () => context.push(
                        '${AppRoutes.eventDetail}/${event.name.hashCode}',
                        extra: event,
                      ),
                    );
                  },
                ),
        ),
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
