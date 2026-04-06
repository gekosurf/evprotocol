import 'dart:async';

import 'package:ev_protocol/ev_protocol.dart';
import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/db/database_provider.dart';

/// Sync service provider — single instance, starts on first access.
///
/// Uses [MockVeilidNode] until real Veilid FFI bindings are compiled.
/// To swap: replace `MockVeilidNode()` with `RealVeilidNode()`.
final syncServiceProvider = Provider<VeilidSyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final node = MockVeilidNode(); // One-line swap for real Veilid later
  final service = VeilidSyncService(db: db, node: node);
  service.startSync();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Live pending sync count — refreshes every 2 seconds.
///
/// Displays how many queue items are still waiting to be synced.
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final service = ref.watch(syncServiceProvider);
  return Stream.periodic(
    const Duration(seconds: 2),
    (_) => service.pendingSyncCount(),
  ).asyncMap((future) => future);
});

/// Stream of sync events for UI feedback (toast, status indicators).
final syncEventsProvider = StreamProvider<EvSyncEvent>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.watchSyncEvents();
});

/// Whether the Veilid node reports itself as online.
final syncOnlineProvider = FutureProvider<bool>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.isOnline();
});
