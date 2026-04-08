import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/at/at_providers.dart';
import 'package:sailor/core/db/database_provider.dart';
import 'package:sailor/features/discover/data/smoke_signal_api.dart';
import 'package:sailor/features/discover/presentation/providers/search_providers.dart';
import 'package:sailor/features/events/domain/repositories/event_repository.dart';
import 'package:sailor/features/events/presentation/providers/event_providers.dart';

// === SMOKE SIGNAL API ===

/// API client for querying AT Protocol PDS repos.
final smokeSignalApiProvider = Provider<SmokeSignalApi>((ref) {
  final auth = ref.watch(atAuthServiceProvider);
  return SmokeSignalApi(auth);
});

// === SEED DATA ===

/// Runs seed data insertion on first read. Safe to call multiple times.
final seedDataProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final service = SeedDataService(db);
  return service.seedIfEmpty();
});

// === DISCOVER EVENTS ===

/// All events in the local cache, filtered by search query and category.
/// Pull-to-refresh triggers a PDS sync to bring in remote events.
final discoverEventsProvider =
    AsyncNotifierProvider<DiscoverEventsNotifier, EventPage>(
  DiscoverEventsNotifier.new,
);

class DiscoverEventsNotifier extends AsyncNotifier<EventPage> {
  @override
  Future<EventPage> build() async {
    // Ensure seed data is loaded before querying
    await ref.watch(seedDataProvider.future);

    // Watch search state — rebuild when it changes
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);

    final repo = ref.read(eventRepositoryProvider);

    // Use search if filters are active, otherwise get all
    if (query.isNotEmpty || category != null) {
      return repo.searchEvents(query: query, category: category);
    }
    return repo.getEvents();
  }

  /// Refresh — pulls from PDS then reloads from local cache.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Step 1: Sync from PDS (if authenticated)
      final atRepo = ref.read(atEventRepositoryProvider);
      await atRepo.refreshFromPds();

      // Step 2: Reload from local cache
      await ref.read(seedDataProvider.future);
      final query = ref.read(searchQueryProvider);
      final category = ref.read(selectedCategoryProvider);
      final repo = ref.read(eventRepositoryProvider);

      if (query.isNotEmpty || category != null) {
        return repo.searchEvents(query: query, category: category);
      }
      return repo.getEvents();
    });
  }
}

// === CATEGORIES ===

/// All distinct categories auto-derived from cached events.
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  // Ensure seed data exists before querying categories
  await ref.watch(seedDataProvider.future);
  final repo = ref.read(eventRepositoryProvider);
  return repo.getCategories();
});
