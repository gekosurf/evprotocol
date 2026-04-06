import '../core/ev_dht_key.dart';
import '../core/ev_result.dart';
import '../core/ev_timestamp.dart';
import 'ev_search_result.dart';

/// Abstract interface for event search in the EV Protocol.
///
/// ```mermaid
/// sequenceDiagram
///     participant App as Flutter App
///     participant Svc as EvSearchService
///     participant T1 as Tier 1 (DHT keys)
///     participant T2 as Tier 2 (Index Node)
///     participant T3 as Tier 3 (Vector Node)
///
///     Note over App,T3: SEARCH BY LOCATION
///     App->>Svc: searchNearby(lat, lng, radiusKm)
///
///     Svc->>T1: Geohash key lookup (ev:geo:<hash>:*)
///     T1-->>Svc: [result1, result2] (2-5 sec)
///
///     alt Tier 2 available
///         Svc->>T2: Query index node (location + radius)
///         T2-->>Svc: [result3, result4] (500ms-2s)
///     end
///
///     alt Tier 3 available
///         Svc->>T3: Semantic search (location + ranking)
///         T3-->>Svc: [result5, result6] (100-500ms)
///     end
///
///     Svc->>Svc: Merge, deduplicate, rank
///     Svc-->>App: EvSuccess(List<EvSearchResult>)
/// ```
abstract class EvSearchService {
  /// Searches for events near a geographic location.
  Future<EvResult<List<EvSearchResult>>> searchNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    int limit = 20,
  });

  /// Searches for events by text query.
  Future<EvResult<List<EvSearchResult>>> searchByText({
    required String query,
    int limit = 20,
  });

  /// Searches for events within a date range.
  Future<EvResult<List<EvSearchResult>>> searchByDateRange({
    required EvTimestamp from,
    required EvTimestamp to,
    String? category,
    int limit = 20,
  });

  /// Searches for events within a group.
  Future<EvResult<List<EvSearchResult>>> searchByGroup({
    required EvDhtKey groupDhtKey,
    int limit = 20,
  });

  /// Gets a single event by its DHT key (Tier 1, always available).
  Future<EvResult<EvSearchResult?>> lookupByKey(EvDhtKey eventDhtKey);

  /// Registers an event in the search index (called on event creation).
  Future<EvResult<void>> registerEvent(EvDhtKey eventDhtKey);

  /// Removes an event from the search index (called on event deletion).
  Future<EvResult<void>> deregisterEvent(EvDhtKey eventDhtKey);

  /// Returns the highest available search tier (1, 2, or 3).
  Future<int> availableSearchTier();
}
