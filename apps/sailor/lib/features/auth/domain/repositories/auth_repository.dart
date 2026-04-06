import 'package:ev_protocol/ev_protocol.dart';

/// Abstract repository for authentication/identity operations.
///
/// Implementations handle keypair generation, local storage, and DHT publishing.
abstract class AuthRepository {
  /// Creates a new identity with a generated keypair.
  ///
  /// Stores locally in SQLite first (offline-first), then queues DHT publish.
  Future<EvIdentity> createIdentity({
    required String displayName,
    String? bio,
  });

  /// Gets the current authenticated identity from local storage.
  ///
  /// Returns null if no identity exists (user needs to onboard).
  Future<EvIdentity?> getCurrentIdentity();

  /// Gets the backup key (seed phrase or raw key) for the current identity.
  ///
  /// This is shown to the user once during onboarding.
  Future<String> getBackupKey();

  /// Restores an identity from a backup key.
  Future<EvIdentity> restoreFromBackup(String backupKey);

  /// Deletes the current identity from local storage.
  Future<void> deleteIdentity();

  /// Checks if an identity exists locally.
  Future<bool> hasIdentity();
}
