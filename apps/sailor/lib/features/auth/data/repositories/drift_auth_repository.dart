import 'dart:math';
import 'package:drift/drift.dart';
import 'package:ev_protocol/ev_protocol.dart';
import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:sailor/features/auth/domain/repositories/auth_repository.dart';

/// Drift-backed implementation of [AuthRepository].
///
/// Stores identity in local SQLite. Keypair generation is still stubbed
/// (will be replaced by real Veilid crypto when integrated).
class DriftAuthRepository implements AuthRepository {
  final AppDatabase _db;
  String? _lastBackupKey;

  DriftAuthRepository(this._db);

  @override
  Future<EvIdentity> createIdentity({
    required String displayName,
    String? bio,
  }) async {
    final pubkey = _generateFakeKey();
    _lastBackupKey = _generateBackupPhrase();

    await _db.into(_db.localIdentities).insert(
          LocalIdentitiesCompanion.insert(
            pubkey: pubkey,
            displayName: displayName,
            bio: Value(bio),
            encryptedPrivateKey: Value(_lastBackupKey),
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
    final pubkey = _generateFakeKey();
    _lastBackupKey = backupKey;

    await _db.into(_db.localIdentities).insert(
          LocalIdentitiesCompanion.insert(
            pubkey: pubkey,
            displayName: 'Restored Sailor',
            encryptedPrivateKey: Value(backupKey),
            createdAt: DateTime.now(),
            isActive: const Value(true),
          ),
        );

    return EvIdentity(
      pubkey: EvPubkey.fromRawKey(pubkey),
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

  String _generateFakeKey() {
    final rng = Random.secure();
    final bytes = List.generate(32, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _generateBackupPhrase() {
    const words = [
      'anchor', 'breeze', 'compass', 'drift', 'easterly',
      'fleet', 'gust', 'harbour', 'island', 'jib',
      'keel', 'leeward', 'mooring', 'nautical', 'ocean',
      'port', 'quarter', 'rigging', 'starboard', 'tiller',
      'upwind', 'voyage', 'windward', 'yacht',
    ];
    final rng = Random.secure();
    return List.generate(12, (_) => words[rng.nextInt(words.length)]).join(' ');
  }
}
