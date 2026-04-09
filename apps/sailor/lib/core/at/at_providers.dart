import 'dart:convert';
import 'dart:io';

import 'package:ev_protocol_at/ev_protocol_at.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sailor/core/db/database_provider.dart';

/// AT Protocol session store.
///
/// iOS: FlutterSecureStorage (Keychain works with proper provisioning).
/// macOS: File-based JSON in app support directory (Keychain requires
///        code signing entitlements that don't work in unsigned debug builds).
final atSessionStoreProvider = Provider<AtSessionStore>((ref) {
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    return _createFileBasedStore();
  }
  return _createSecureStore();
});

/// File-based session storage for desktop (avoids Keychain entitlement issues).
AtSessionStore _createFileBasedStore() {
  // Store in home directory as a hidden file
  final home = Platform.environment['HOME'] ?? '.';
  final sessionFile = File('$home/.sailor_session.json');

  return AtSessionStore(
    onSave: (session) async {
      try {
        final json = jsonEncode({
          'handle': session.handle,
          'did': session.did,
          'accessJwt': session.accessJwt,
          'refreshJwt': session.refreshJwt,
          'appPassword': session.appPassword,
        });
        await sessionFile.writeAsString(json);
      } catch (e) {
        debugPrint('[AtAuth] File storage write failed: $e');
      }
    },
    onLoad: () async {
      try {
        if (!await sessionFile.exists()) return null;
        final json = jsonDecode(await sessionFile.readAsString())
            as Map<String, dynamic>;
        return SavedSession(
          handle: json['handle'] as String,
          did: json['did'] as String,
          accessJwt: json['accessJwt'] as String,
          refreshJwt: json['refreshJwt'] as String,
          appPassword: json['appPassword'] as String?,
        );
      } catch (e) {
        debugPrint('[AtAuth] File storage read failed: $e');
      }
      return null;
    },
    onClear: () async {
      try {
        if (await sessionFile.exists()) {
          await sessionFile.delete();
        }
      } catch (e) {
        debugPrint('[AtAuth] File storage clear failed: $e');
      }
    },
  );
}

/// Secure storage for iOS (Keychain).
AtSessionStore _createSecureStore() {
  const storage = FlutterSecureStorage();

  return AtSessionStore(
    onSave: (session) async {
      try {
        await storage.write(key: 'at_handle', value: session.handle);
        await storage.write(key: 'at_did', value: session.did);
        await storage.write(key: 'at_access_jwt', value: session.accessJwt);
        await storage.write(key: 'at_refresh_jwt', value: session.refreshJwt);
        if (session.appPassword != null) {
          await storage.write(key: 'at_app_password', value: session.appPassword);
        }
      } catch (e) {
        debugPrint('[AtAuth] Secure storage write failed: $e');
      }
    },
    onLoad: () async {
      try {
        final handle = await storage.read(key: 'at_handle');
        final did = await storage.read(key: 'at_did');
        final access = await storage.read(key: 'at_access_jwt');
        final refresh = await storage.read(key: 'at_refresh_jwt');
        final appPassword = await storage.read(key: 'at_app_password');

        if (handle != null && did != null && access != null && refresh != null) {
          return SavedSession(
            handle: handle,
            did: did,
            accessJwt: access,
            refreshJwt: refresh,
            appPassword: appPassword,
          );
        }
      } catch (e) {
        debugPrint('[AtAuth] Secure storage read failed: $e');
      }
      return null;
    },
    onClear: () async {
      try {
        await storage.delete(key: 'at_handle');
        await storage.delete(key: 'at_did');
        await storage.delete(key: 'at_access_jwt');
        await storage.delete(key: 'at_refresh_jwt');
        await storage.delete(key: 'at_app_password');
      } catch (e) {
        debugPrint('[AtAuth] Secure storage clear failed: $e');
      }
    },
  );
}

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

// ═══════════════════════════════════════════════════════════════════════
// CONNECTIONS — known Bluesky users to scan for events/RSVPs
// ═══════════════════════════════════════════════════════════════════════

/// Connections store singleton — uses app documents directory for cross-platform support.
final connectionsStoreProvider = FutureProvider<ConnectionsStore>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return ConnectionsStore(dir.path);
});

/// All current connections (auto-refreshes when invalidated).
final connectionsProvider = FutureProvider<List<Connection>>((ref) async {
  final store = await ref.read(connectionsStoreProvider.future);
  return store.loadAll();
});

/// Just the DIDs for PDS scanning.
final connectionDidsProvider = FutureProvider<List<String>>((ref) async {
  final connections = await ref.watch(connectionsProvider.future);
  return connections.map((c) => c.did).toList();
});

/// Add a connection by Bluesky handle. Resolves handle → DID.
final addConnectionProvider =
    FutureProvider.family<void, String>((ref, handle) async {
  final auth = ref.read(atAuthServiceProvider);
  final client = auth.client;
  if (client == null) throw Exception('Not authenticated');

  // Resolve handle to DID
  final result = await client.atproto.identity.resolveHandle(handle: handle);
  final did = result.data.did;

  final store = await ref.read(connectionsStoreProvider.future);
  await store.add(Connection(
    handle: handle,
    did: did,
    addedAt: DateTime.now(),
  ));

  // Refresh the connections list
  ref.invalidate(connectionsProvider);
  debugPrint('[Connections] Added $handle → $did');
});

/// Import all Bluesky follows as connections in one tap.
///
/// Pulls the follow list once, deduplicates against existing connections,
/// and bulk-adds them. Returns the count of new connections added.
final importFollowsProvider = FutureProvider<int>((ref) async {
  final auth = ref.read(atAuthServiceProvider);
  final client = auth.client;
  if (client == null) throw Exception('Not authenticated');

  final store = await ref.read(connectionsStoreProvider.future);
  final existingDids = (await store.loadAll()).map((c) => c.did).toSet();
  final selfDid = auth.did!;

  int added = 0;
  String? cursor;

  // Paginate through all follows
  do {
    final result = await client.graph.getFollows(
      actor: selfDid,
      cursor: cursor,
    );

    for (final follow in result.data.follows) {
      final did = follow.did;
      final handle = follow.handle;

      if (did == selfDid || existingDids.contains(did)) continue;

      await store.add(Connection(
        handle: handle,
        did: did,
        addedAt: DateTime.now(),
      ));
      existingDids.add(did);
      added++;
    }

    cursor = result.data.cursor;
  } while (cursor != null);

  ref.invalidate(connectionsProvider);
  debugPrint('[Connections] Imported $added follows from Bluesky');
  return added;
});
