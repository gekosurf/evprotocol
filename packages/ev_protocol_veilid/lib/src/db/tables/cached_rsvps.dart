import 'package:drift/drift.dart';

/// Cached RSVPs table — local SSOT for RSVP records.
class CachedRsvps extends Table {
  /// Auto-incremented primary key.
  IntColumn get id => integer().autoIncrement()();

  /// DHT key of the event.
  TextColumn get eventDhtKey => text().withLength(min: 1)();

  /// Public key of the attendee.
  TextColumn get attendeePubkey => text().withLength(min: 1)();

  /// RSVP status enum name (going, maybe, notGoing, waitlisted).
  TextColumn get status => text()();

  /// Number of additional guests.
  IntColumn get guestCount => integer().withDefault(const Constant(0))();

  /// Optional note.
  TextColumn get note => text().nullable()();

  /// When the RSVP was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When last synced from DHT.
  DateTimeColumn get lastSyncedAt => dateTime()();

  /// Pending DHT push.
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {eventDhtKey, attendeePubkey},
      ];
}
