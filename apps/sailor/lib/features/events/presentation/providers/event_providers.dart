import 'package:ev_protocol/ev_protocol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/at/at_providers.dart';
import 'package:sailor/features/discover/presentation/providers/search_providers.dart';
import 'package:sailor/features/events/data/repositories/at_event_repository_adapter.dart';
import 'package:sailor/features/events/domain/repositories/event_repository.dart';
import 'package:sailor/features/events/domain/usecases/event_usecases.dart';

// === REPOSITORY (AT Protocol + SQLite offline-first) ===
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  // AtEventRepository handles both local SQLite and PDS sync.
  // For now, wrap it in an adapter that implements the EventRepository interface.
  final atRepo = ref.watch(atEventRepositoryProvider);
  return AtEventRepositoryAdapter(atRepo);
});

// === USE CASES ===
final listEventsUseCaseProvider = Provider<ListEventsUseCase>((ref) {
  return ListEventsUseCase(ref.watch(eventRepositoryProvider));
});

final getEventUseCaseProvider = Provider<GetEventUseCase>((ref) {
  return GetEventUseCase(ref.watch(eventRepositoryProvider));
});

final createEventUseCaseProvider = Provider<CreateEventUseCase>((ref) {
  return CreateEventUseCase(ref.watch(eventRepositoryProvider));
});

final rsvpToEventUseCaseProvider = Provider<RsvpToEventUseCase>((ref) {
  return RsvpToEventUseCase(ref.watch(eventRepositoryProvider));
});

// === EVENT LIST STATE ===
final eventListProvider =
    AsyncNotifierProvider<EventListNotifier, EventPage>(
  EventListNotifier.new,
);

class EventListNotifier extends AsyncNotifier<EventPage> {
  @override
  Future<EventPage> build() async {
    final useCase = ref.read(listEventsUseCaseProvider);
    return useCase();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final useCase = ref.read(listEventsUseCaseProvider);
      return useCase();
    });
  }

  Future<void> createEvent({
    required String name,
    String? description,
    required DateTime startAt,
    DateTime? endAt,
    EvEventLocation? location,
    List<String> tags = const [],
  }) async {
    final useCase = ref.read(createEventUseCaseProvider);
    await useCase(
      name: name,
      description: description,
      startAt: startAt,
      endAt: endAt,
      location: location,
      tags: tags,
    );
    // Refresh the list
    await refresh();
  }
}

// === MY EVENTS (filtered by current user + search) ===
final myEventsProvider =
    AsyncNotifierProvider<MyEventsNotifier, EventPage>(
  MyEventsNotifier.new,
);

class MyEventsNotifier extends AsyncNotifier<EventPage> {
  @override
  Future<EventPage> build() async {
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);
    final repo = ref.read(eventRepositoryProvider);

    if (query.isNotEmpty || category != null) {
      return repo.searchMyEvents(query: query, category: category);
    }
    return repo.getMyEvents();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final query = ref.read(searchQueryProvider);
      final category = ref.read(selectedCategoryProvider);
      final repo = ref.read(eventRepositoryProvider);

      if (query.isNotEmpty || category != null) {
        return repo.searchMyEvents(query: query, category: category);
      }
      return repo.getMyEvents();
    });
  }

  Future<void> createEvent({
    required String name,
    String? description,
    required DateTime startAt,
    DateTime? endAt,
    EvEventLocation? location,
    List<String> tags = const [],
  }) async {
    final useCase = ref.read(createEventUseCaseProvider);
    await useCase(
      name: name,
      description: description,
      startAt: startAt,
      endAt: endAt,
      location: location,
      tags: tags,
    );
    await refresh();
  }
}
