import 'dart:math';
import 'package:ev_protocol/ev_protocol.dart';
import 'package:sailor/features/auth/domain/repositories/auth_repository.dart';

/// Stub implementation of [AuthRepository] for scaffolding.
///
/// Generates a fake keypair and stores identity in memory.
/// Will be replaced by [VeilidAuthRepository] backed by SQLite + Veilid DHT.
class StubAuthRepository implements AuthRepository {
  EvIdentity? _identity;
  String? _backupKey;

  @override
  Future<EvIdentity> createIdentity({
    required String displayName,
    String? bio,
  }) async {
    // Simulate keypair generation delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final pubkey = EvPubkey.fromRawKey(_generateFakeKey());
    _backupKey = _generateBackupPhrase();

    _identity = EvIdentity(
      pubkey: pubkey,
      displayName: displayName,
      bio: bio,
      createdAt: EvTimestamp.now(),
    );

    return _identity!;
  }

  @override
  Future<EvIdentity?> getCurrentIdentity() async {
    return _identity;
  }

  @override
  Future<String> getBackupKey() async {
    return _backupKey ?? 'no-key-generated';
  }

  @override
  Future<EvIdentity> restoreFromBackup(String backupKey) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final pubkey = EvPubkey.fromRawKey(_generateFakeKey());
    _backupKey = backupKey;

    _identity = EvIdentity(
      pubkey: pubkey,
      displayName: 'Restored Sailor',
      createdAt: EvTimestamp.now(),
    );

    return _identity!;
  }

  @override
  Future<void> deleteIdentity() async {
    _identity = null;
    _backupKey = null;
  }

  @override
  Future<bool> hasIdentity() async {
    return _identity != null;
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
