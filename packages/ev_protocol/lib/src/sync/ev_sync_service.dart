import '../core/ev_dht_key.dart';
import '../core/ev_result.dart';

/// Abstract interface for offline-first sync in the EV Protocol.
///
/// ```mermaid
/// sequenceDiagram
///     participant App as Flutter App
///     participant Svc as EvSyncService
///     participant SQLite as Local SQLite
///     participant DHT as Veilid DHT
///
///     Note over App,DHT: WRITE (offline-first)
///     App->>Svc: Record created/updated
///     Svc->>SQLite: Write immediately (status: pending_sync)
///     Svc-->>App: EvSuccess (instant, no network wait)
///
///     Note over App,DHT: SYNC LOOP (background)
///     loop Every 30 seconds (configurable)
///         Svc->>SQLite: Query pending_sync records
///         SQLite-->>Svc: [record1, record2, ...]
///         Svc->>DHT: Publish record1
///         DHT-->>Svc: Published ✓
///         Svc->>SQLite: Update status → synced
///         Svc->>DHT: Publish record2
///         DHT-->>Svc: Failed (timeout)
///         Svc->>SQLite: Keep status → pending_sync (retry later)
///     end
///
///     Note over App,DHT: READ (cache-first)
///     App->>Svc: Request record
///     Svc->>SQLite: Check local cache
///     alt Cache hit (fresh)
///         SQLite-->>Svc: Cached record
///         Svc-->>App: EvSuccess (instant)
///     else Cache miss or stale
///         Svc->>DHT: Fetch from DHT
///         DHT-->>Svc: Record
///         Svc->>SQLite: Update cache
///         Svc-->>App: EvSuccess
///     end
/// ```
abstract class EvSyncService {
  /// Starts the background sync loop.
  Future<EvResult<void>> startSync();

  /// Stops the background sync loop.
  Future<EvResult<void>> stopSync();

  /// Forces an immediate sync of all pending records.
  Future<EvResult<int>> syncNow();

  /// Gets the number of records pending sync.
  Future<int> pendingSyncCount();

  /// Gets the sync status of a specific record.
  Future<EvSyncStatus> getSyncStatus(EvDhtKey dhtKey);

  /// Checks if the network is currently reachable.
  Future<bool> isOnline();

  /// Watches sync status changes.
  Stream<EvSyncEvent> watchSyncEvents();
}

/// Sync status for a record.
enum EvSyncStatus {
  /// Record has been synced to DHT.
  synced,

  /// Record is waiting to be synced.
  pendingSync,

  /// Sync failed, will retry.
  syncFailed,

  /// Record only exists locally (not yet published).
  localOnly,
}

/// An event emitted by the sync service.
class EvSyncEvent {
  final EvDhtKey dhtKey;
  final EvSyncStatus status;
  final String? errorMessage;
  final DateTime timestamp;

  const EvSyncEvent({
    required this.dhtKey,
    required this.status,
    this.errorMessage,
    required this.timestamp,
  });
}
