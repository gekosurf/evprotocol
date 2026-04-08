import 'package:ev_protocol_at/ev_protocol_at.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/db/database_provider.dart';

/// AT Protocol session store — in-memory for Phase 2.
/// Phase 4: swap for flutter_secure_storage callbacks.
final atSessionStoreProvider = Provider<AtSessionStore>((ref) {
  return AtSessionStore();
});

/// AT Protocol authentication service.
final atAuthServiceProvider = Provider<AtAuthService>((ref) {
  final store = ref.watch(atSessionStoreProvider);
  return AtAuthService(store);
});

/// AT Protocol event repository — offline-first with PDS sync.
final atEventRepositoryProvider = Provider<AtEventRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final auth = ref.watch(atAuthServiceProvider);
  return AtEventRepository(db, auth);
});

/// AT Protocol background sync service.
final atSyncServiceProvider = Provider<AtSyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final auth = ref.watch(atAuthServiceProvider);
  final service = AtSyncService(db, auth);
  ref.onDispose(service.dispose);
  return service;
});

/// Whether the user is authenticated with AT Protocol.
final atAuthStateProvider =
    NotifierProvider<AtAuthStateNotifier, bool>(AtAuthStateNotifier.new);

class AtAuthStateNotifier extends Notifier<bool> {
  @override
  bool build() {
    final auth = ref.watch(atAuthServiceProvider);
    return auth.isAuthenticated;
  }

  void setAuthenticated(bool value) {
    state = value;
  }
}

/// AT Protocol login action.
final atLoginProvider =
    FutureProvider.family<String, ({String handle, String appPassword})>(
  (ref, creds) async {
    final auth = ref.read(atAuthServiceProvider);
    final did = await auth.login(
      handle: creds.handle,
      appPassword: creds.appPassword,
    );
    // Start sync service after login
    ref.read(atSyncServiceProvider).start();
    // Update auth state
    ref.read(atAuthStateProvider.notifier).setAuthenticated(true);
    return did;
  },
);
