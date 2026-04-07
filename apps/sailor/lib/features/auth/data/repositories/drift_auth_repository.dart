import 'dart:math';

import 'package:drift/drift.dart';
import 'package:ev_protocol/ev_protocol.dart';
import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:sailor/features/auth/domain/repositories/auth_repository.dart';

/// Drift-backed implementation of [AuthRepository].
///
/// Uses stub key generation for simulator builds. When the veilid FFI is
/// enabled, swap to [VeilidCryptoService] for real ed25519 keypairs.
class DriftAuthRepository implements AuthRepository {
  final AppDatabase _db;
  String? _lastBackupKey;

  DriftAuthRepository(this._db);

  @override
  Future<EvIdentity> createIdentity({
    required String displayName,
    String? bio,
  }) async {
    // TODO: Replace with VeilidCryptoService.generateKeypair() when FFI enabled
    final publicKey = _generateStubKey();
    final secretKey = _generateStubKey();
    _lastBackupKey = '$publicKey:$secretKey';

    await _db.into(_db.localIdentities).insert(
          LocalIdentitiesCompanion.insert(
            pubkey: publicKey,
            displayName: displayName,
            bio: Value(bio),
            encryptedPrivateKey: Value(_lastBackupKey),
            createdAt: DateTime.now(),
            isActive: const Value(true),
          ),
        );

    return EvIdentity(
      pubkey: EvPubkey.fromRawKey(publicKey),
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
    // Parse pubkey from backup format "pubkey:secret"
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

  /// Generates a 64-char hex key stub for simulator development.
  ///
  /// TODO: Replace with real Veilid ed25519 keypair generation when FFI available.
  String _generateStubKey() {
    final rng = Random.secure();
    return List.generate(64, (_) => rng.nextInt(16).toRadixString(16)).join();
  }
}
