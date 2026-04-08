import 'package:ev_protocol_at/ev_protocol_at.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sailor/core/db/database_provider.dart';

import 'dart:io';

/// AT Protocol session store — uses flutter_secure_storage for iOS Keychain/Android Keystore.
/// On macOS, uses an in-memory store to avoid Keychain entitlement requirements during local development.
final atSessionStoreProvider = Provider<AtSessionStore>((ref) {
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    return AtSessionStore();
  }

  const storage = FlutterSecureStorage();
  
  return AtSessionStore(
    onSave: (session) async {
      try {
        await storage.write(key: 'at_handle', value: session.handle);
        await storage.write(key: 'at_did', value: session.did);
        await storage.write(key: 'at_access_jwt', value: session.accessJwt);
        await storage.write(key: 'at_refresh_jwt', value: session.refreshJwt);
      } catch (e) {
        // Ignore keychain errors on unsigned local macOS builds
      }
    },
    onLoad: () async {
      try {
        final handle = await storage.read(key: 'at_handle');
        final did = await storage.read(key: 'at_did');
        final access = await storage.read(key: 'at_access_jwt');
        final refresh = await storage.read(key: 'at_refresh_jwt');
        
        if (handle != null && did != null && access != null && refresh != null) {
          return SavedSession(
            handle: handle,
            did: did,
            accessJwt: access,
            refreshJwt: refresh,
          );
        }
      } catch (e) {
        // Ignore keychain errors on unsigned local macOS builds
      }
      return null;
    },
    onClear: () async {
      try {
        await storage.delete(key: 'at_handle');
        await storage.delete(key: 'at_did');
        await storage.delete(key: 'at_access_jwt');
        await storage.delete(key: 'at_refresh_jwt');
      } catch (e) {
        // Ignore keychain errors on unsigned local macOS builds
      }
    },
  );
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
