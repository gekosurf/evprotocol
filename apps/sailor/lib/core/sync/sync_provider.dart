import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder providers for the sync layer.
///
/// Phase 2 will replace these with AT Protocol sync:
/// - AtSyncService (background PDS sync)
/// - Offline queue retry
///
/// For now, the app works fully offline via Drift SQLite.

/// Live pending sync count — always 0 until AT Protocol sync is implemented.
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  return Stream.value(0);
});
