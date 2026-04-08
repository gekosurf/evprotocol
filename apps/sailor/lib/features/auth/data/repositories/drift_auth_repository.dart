import 'package:drift/drift.dart';
import 'package:ev_protocol/ev_protocol.dart';
import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:sailor/features/auth/domain/repositories/auth_repository.dart';

/// Drift-backed implementation of [AuthRepository].
///
/// Post-cleanup: removed VeilidCryptoService dependency.
/// Identity is now a simple local profile stored in SQLite.
/// Phase 2 will replace this with AT Protocol DID-based auth.
class DriftAuthRepository implements AuthRepository {
  final AppDatabase _db;
  String? _lastBackupKey;

  DriftAuthRepository(this._db);

  @override
  Future<EvIdentity> createIdentity({
    required String displayName,
    String? bio,
  }) async {
    // Generate a simple local identity (no crypto needed until AT Protocol auth)
    final pubkey = 'local-${DateTime.now().millisecondsSinceEpoch}';

    await _db.into(_db.localIdentities).insert(
          LocalIdentitiesCompanion.insert(
            pubkey: pubkey,
            displayName: displayName,
            bio: Value(bio),
            encryptedPrivateKey: const Value('pending-at-protocol'),
            createdAt: DateTime.now(),
            isActive: const Value(true),
          ),
        );

    return EvIdentity(
      pubkey: EvPubkey.fromRawKey(pubkey),
      displayName: displayName,
      bio: bio,
      createdAt: EvTimestamp.now(),
    );
  }

  @override
  Future<EvIdentity?> getCurrentIdentity() async {
    final row = await (_db.select(_db.localIdentities)
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();

    if (row == null) return null;

    return EvIdentity(
      pubkey: EvPubkey.fromRawKey(row.pubkey),
      displayName: row.displayName,
      bio: row.bio,
      createdAt: EvTimestamp.parse(row.createdAt.toUtc().toIso8601String()),
    );
  }

  @override
  Future<String> getBackupKey() async {
    if (_lastBackupKey != null) return _lastBackupKey!;

    final row = await (_db.select(_db.localIdentities)
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();

    return row?.encryptedPrivateKey ?? 'no-key-found';
  }

  @override
  Future<EvIdentity> restoreFromBackup(String backupKey) async {
    final publicKey = backupKey.contains(':')
        ? backupKey.split(':').first
        : backupKey;
    _lastBackupKey = backupKey;

    await _db.into(_db.localIdentities).insert(
          LocalIdentitiesCompanion.insert(
            pubkey: publicKey,
            displayName: 'Restored Sailor',
            encryptedPrivateKey: Value(backupKey),
            createdAt: DateTime.now(),
            isActive: const Value(true),
          ),
        );

    return EvIdentity(
      pubkey: EvPubkey.fromRawKey(publicKey),
      displayName: 'Restored Sailor',
      createdAt: EvTimestamp.now(),
    );
  }

  @override
  Future<void> deleteIdentity() async {
    await _db.delete(_db.localIdentities).go();
    _lastBackupKey = null;
  }

  @override
  Future<bool> hasIdentity() async {
    final count = await (_db.select(_db.localIdentities)
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
    return count != null;
  }
}
