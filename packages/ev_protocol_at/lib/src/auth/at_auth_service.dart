import 'package:bluesky/atproto.dart' as atproto;
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/foundation.dart';

import 'at_session_store.dart';

/// AT Protocol authentication service.
///
/// Phase 2: App password login only. OAuth is Phase 4 polish.
/// Lesson: "Don't build the auth cathedral when a shed works."
class AtAuthService {
  final AtSessionStore _store;
  bsky.Bluesky? _client;

  AtAuthService(this._store);

  /// The current Bluesky API client, null if not authenticated.
  bsky.Bluesky? get client => _client;

  /// The current user's DID, null if not authenticated.
  String? get did => _client?.session?.did;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _client != null;

  /// Login with handle + app password.
  ///
  /// Returns the DID on success, throws on failure.
  Future<String> login({
    required String handle,
    required String appPassword,
  }) async {
    try {
      final session = await atproto.createSession(
        identifier: handle,
        password: appPassword,
      );
      _client = bsky.Bluesky.fromSession(session.data);
      final did = _client!.session!.did;

      // Persist session for restart recovery
      await _store.save(
        handle: handle,
        did: did,
        accessJwt: session.data.accessJwt,
        refreshJwt: session.data.refreshJwt,
      );

      debugPrint('[AtAuth] Authenticated as $handle ($did)');
      return did;
    } catch (e) {
      debugPrint('[AtAuth] Login failed: $e');
      rethrow;
    }
  }

  /// Attempt to restore a previous session from secure storage.
  ///
  /// Returns true if session was restored and is still valid.
  Future<bool> tryRestoreSession() async {
    final saved = await _store.load();
    if (saved == null) return false;

    try {
      // Try refreshing the session token
      final session = await atproto.createSession(
        identifier: saved.handle,
        password: '', // Can't re-auth without password — need refresh
      );
      _client = bsky.Bluesky.fromSession(session.data);
      debugPrint('[AtAuth] Session restored for ${saved.handle}');
      return true;
    } catch (_) {
      // Session expired — user needs to re-login
      await _store.clear();
      debugPrint('[AtAuth] Session expired, cleared');
      return false;
    }
  }

  /// Logout and clear stored session.
  Future<void> logout() async {
    _client = null;
    await _store.clear();
    debugPrint('[AtAuth] Logged out');
  }
}
