import 'package:drift/drift.dart';

/// Sync queue table — tracks pending DHT operations.
///
/// Each row represents a write that needs to be pushed to the Veilid DHT.
/// The sync service processes this queue in order.
class SyncQueue extends Table {
  /// Auto-incremented primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Operation type: 'create', 'update', 'delete'.
  TextColumn get operation => text()();

  /// Record type: 'identity', 'event', 'rsvp', 'group', 'message'.
  TextColumn get recordType => text()();

  /// Local record ID in the source table.
  IntColumn get localRecordId => integer()();

  /// DHT key (null for creates, populated for updates/deletes).
  TextColumn get dhtKey => text().nullable()();

  /// JSON payload of the record to push.
  TextColumn get payload => text()();

  /// Number of retry attempts.
  IntColumn get retryCount =>
      integer().withDefault(const Constant(0))();

  /// Last error message if failed.
  TextColumn get lastError => text().nullable()();

  /// When the operation was queued.
  DateTimeColumn get queuedAt => dateTime()();

  /// When it was last attempted.
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  /// When the operation was completed successfully.
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Status: 'pending', 'processing', 'failed', 'completed'.
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();
}
