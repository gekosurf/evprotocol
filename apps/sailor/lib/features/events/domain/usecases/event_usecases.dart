import 'package:ev_protocol/ev_protocol.dart';
import 'package:sailor/features/events/domain/repositories/event_repository.dart';

/// Use case: List events with pagination.
class ListEventsUseCase {
  final EventRepository _repository;

  const ListEventsUseCase(this._repository);

  Future<EventPage> call({String? cursor, int limit = 20}) {
    return _repository.getEvents(cursor: cursor, limit: limit);
  }
}

/// Use case: Get a single event by DHT key.
class GetEventUseCase {
  final EventRepository _repository;

  const GetEventUseCase(this._repository);

  Future<EvEvent?> call(EvDhtKey dhtKey) {
    return _repository.getEvent(dhtKey);
  }
}

/// Use case: Create a new event.
class CreateEventUseCase {
  final EventRepository _repository;

  const CreateEventUseCase(this._repository);

  Future<EvEvent> call({
    required String name,
    String? description,
    required DateTime startAt,
    DateTime? endAt,
    EvEventLocation? location,
    String? category,
    List<String> tags = const [],
  }) {
    if (name.trim().isEmpty) {
      throw const EventException('Event name cannot be empty');
    }
    if (name.trim().length > 128) {
      throw const EventException('Event name must be 128 characters or less');
    }
    if (endAt != null && endAt.isBefore(startAt)) {
      throw const EventException('End time must be after start time');
    }
    return _repository.createEvent(
      name: name.trim(),
      description: description?.trim(),
      startAt: startAt,
      endAt: endAt,
      location: location,
      category: category,
      tags: tags,
    );
  }
}

/// Use case: RSVP to an event.
class RsvpToEventUseCase {
  final EventRepository _repository;

  const RsvpToEventUseCase(this._repository);

  Future<EvRsvp> call({
    required EvDhtKey eventDhtKey,
    required EvRsvpStatus status,
    int guestCount = 0,
  }) {
    return _repository.rsvpToEvent(
      eventDhtKey: eventDhtKey,
      status: status,
      guestCount: guestCount,
    );
  }
}

/// Domain exception for event operations.
class EventException implements Exception {
  final String message;
  const EventException(this.message);

  @override
  String toString() => 'EventException: $message';
}
