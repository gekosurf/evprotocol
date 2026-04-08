import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/at/at_providers.dart';

/// Live pending sync count — powered by AtSyncService.
///
/// Shows 0 until AT Protocol login, then reflects the real
/// offline queue depth from the sync service.
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(atSyncServiceProvider);
  return syncService.pendingCount;
});
