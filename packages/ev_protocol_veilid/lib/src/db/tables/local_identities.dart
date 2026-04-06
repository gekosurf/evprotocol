import 'package:drift/drift.dart';

/// Local identities table — stores the user's own identity.
class LocalIdentities extends Table {
  /// Auto-incremented primary key.
  IntColumn get id => integer().autoIncrement()();

  /// The public key (hex-encoded).
  TextColumn get pubkey => text().withLength(min: 1)();

  /// Display name.
  TextColumn get displayName => text().withLength(min: 1, max: 64)();

  /// Optional bio.
  TextColumn get bio => text().nullable()();

  /// Avatar file path or URL.
  TextColumn get avatarUrl => text().nullable()();

  /// The encrypted private key material (for backup/restore).
  TextColumn get encryptedPrivateKey => text().nullable()();

  /// DHT key if published.
  TextColumn get dhtKey => text().nullable()();

  /// When the identity was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When last updated.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Whether this is the currently active identity.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
