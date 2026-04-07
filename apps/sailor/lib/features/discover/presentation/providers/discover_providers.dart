import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/db/database_provider.dart';
import 'package:sailor/features/events/domain/repositories/event_repository.dart';
import 'package:sailor/features/events/presentation/providers/event_providers.dart';

// === SEED DATA ===

/// Runs seed data insertion on first read. Safe to call multiple times.
final seedDataProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final service = SeedDataService(db);
  return service.seedIfEmpty();
});

// === DISCOVER EVENTS ===

/// All events in the local cache (seed + user-created + future DHT-synced).
/// Refreshes after seeding completes.
final discoverEventsProvider =
    AsyncNotifierProvider<DiscoverEventsNotifier, EventPage>(
  DiscoverEventsNotifier.new,
);

class DiscoverEventsNotifier extends AsyncNotifier<EventPage> {
  @override
  Future<EventPage> build() async {
    // Ensure seed data is loaded before querying
    await ref.watch(seedDataProvider.future);

    final repo = ref.read(eventRepositoryProvider);
    return repo.getEvents();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Re-seed check (no-op if already seeded)
      await ref.read(seedDataProvider.future);
      final repo = ref.read(eventRepositoryProvider);
      return repo.getEvents();
    });
  }
}
