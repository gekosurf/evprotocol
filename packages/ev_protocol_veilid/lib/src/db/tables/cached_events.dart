import 'package:drift/drift.dart';

/// Cached events table — local SSOT for events synced from DHT.
class CachedEvents extends Table {
  /// Auto-incremented primary key.
  IntColumn get id => integer().autoIncrement()();

  /// DHT key of the event record.
  TextColumn get dhtKey => text().withLength(min: 1)();

  /// Public key of the event creator.
  TextColumn get creatorPubkey => text().withLength(min: 1)();

  /// Event title.
  TextColumn get name => text().withLength(min: 1, max: 256)();

  /// Event description (markdown).
  TextColumn get description => text().nullable()();

  /// Start time (UTC).
  DateTimeColumn get startAt => dateTime()();

  /// End time (UTC).
  DateTimeColumn get endAt => dateTime().nullable()();

  /// Location name.
  TextColumn get locationName => text().nullable()();

  /// Location address.
  TextColumn get locationAddress => text().nullable()();

  /// Latitude.
  RealColumn get latitude => real().nullable()();

  /// Longitude.
  RealColumn get longitude => real().nullable()();

  /// Geohash (6 chars, for range queries).
  TextColumn get geohash => text().nullable()();

  /// Category.
  TextColumn get category => text().nullable()();

  /// Comma-separated tags.
  TextColumn get tags => text().withDefault(const Constant(''))();

  /// Visibility enum name.
  TextColumn get visibility =>
      text().withDefault(const Constant('public_'))();

  /// RSVP count (approximate).
  IntColumn get rsvpCount => integer().withDefault(const Constant(0))();

  /// Max capacity.
  IntColumn get maxCapacity => integer().nullable()();

  /// Group DHT key.
  TextColumn get groupDhtKey => text().nullable()();

  /// Ticketing JSON blob (nullable — free events have none).
  TextColumn get ticketingJson => text().nullable()();

  /// When the event was created (on the network).
  DateTimeColumn get createdAt => dateTime()();

  /// When the event was last updated (on the network).
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// When we last synced this record from DHT.
  DateTimeColumn get lastSyncedAt => dateTime()();

  /// Whether the record has local changes pending DHT push.
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))();

  /// EV protocol version.
  TextColumn get evVersion =>
      text().withDefault(const Constant('0.1.0'))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {dhtKey},
      ];
}
