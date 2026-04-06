import 'package:ev_protocol/ev_protocol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/db/database_provider.dart';
import 'package:sailor/features/auth/presentation/providers/auth_providers.dart';
import 'package:sailor/features/events/data/repositories/drift_event_repository.dart';
import 'package:sailor/features/events/domain/repositories/event_repository.dart';
import 'package:sailor/features/events/domain/usecases/event_usecases.dart';

// === REPOSITORY ===
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final identity = ref.watch(authStateProvider).value;
  final pubkey = identity?.pubkey ?? EvPubkey.fromRawKey('anonymous');
  return DriftEventRepository(db, pubkey);
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
