/// Persistent session storage for AT Protocol credentials.
///
/// Phase 2: Simple in-memory + callback approach.
/// Phase 4: Replace with flutter_secure_storage for iOS Keychain.
class AtSessionStore {
  SavedSession? _cached;
  final Future<void> Function(SavedSession)? _onSave;
  final Future<SavedSession?> Function()? _onLoad;
  final Future<void> Function()? _onClear;

  /// Create a session store.
  ///
  /// For testing, pass no callbacks — sessions stay in-memory only.
  /// For production, wire up secure storage callbacks.
  AtSessionStore({
    Future<void> Function(SavedSession)? onSave,
    Future<SavedSession?> Function()? onLoad,
    Future<void> Function()? onClear,
  })  : _onSave = onSave,
        _onLoad = onLoad,
        _onClear = onClear;

  /// Save a session.
  Future<void> save({
    required String handle,
    required String did,
    required String accessJwt,
    required String refreshJwt,
  }) async {
    _cached = SavedSession(
      handle: handle,
      did: did,
      accessJwt: accessJwt,
      refreshJwt: refreshJwt,
    );
    await _onSave?.call(_cached!);
  }

  /// Load a previously saved session.
  Future<SavedSession?> load() async {
    if (_cached != null) return _cached;
    _cached = await _onLoad?.call();
    return _cached;
  }

  /// Clear the stored session.
  Future<void> clear() async {
    _cached = null;
    await _onClear?.call();
  }
}

/// A saved AT Protocol session.
class SavedSession {
  final String handle;
  final String did;
  final String accessJwt;
  final String refreshJwt;

  const SavedSession({
    required this.handle,
    required this.did,
    required this.accessJwt,
    required this.refreshJwt,
  });
}
