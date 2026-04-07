/// Abstract interface for Veilid DHT node operations.
///
/// This is the single seam between the sync service and Veilid's FFI layer.
/// Swap [MockVeilidNode] for [RealVeilidNode] when Veilid Rust bindings
/// are compiled.
abstract class VeilidNodeInterface {
  /// Publishes a record to the DHT.
  ///
  /// For creates, the returned [VeilidPublishResult.dhtKey] may differ from
  /// the input (the DHT assigns the real key).
  Future<VeilidPublishResult> publishRecord(String dhtKey, String payload);

  /// Fetches a record from the DHT by key.
  ///
  /// Returns the JSON payload as a string, or null if not found.
  Future<String?> getRecord(String dhtKey);

  /// Deletes a record from the DHT by key.
  ///
  /// Returns true if the record was deleted (or didn't exist).
  Future<bool> deleteRecord(String dhtKey);

  /// Checks whether the Veilid network is currently reachable.
  Future<bool> isOnline();

  // ---------------------------------------------------------------------------
  // DHT Watchers — real-time inbound sync
  // ---------------------------------------------------------------------------

  /// Begin watching a DHT record for remote changes.
  ///
  /// When a remote peer modifies the record, a [DhtValueChange] is emitted
  /// on the [onValueChange] stream.
  Future<void> watchRecord(String dhtKey);

  /// Stop watching a DHT record.
  Future<void> unwatchRecord(String dhtKey);

  /// Stream of inbound DHT value changes from watched records.
  Stream<DhtValueChange> get onValueChange;

  // ---------------------------------------------------------------------------
  // Peer Discovery
  // ---------------------------------------------------------------------------

  /// Announce a published record for peer discovery.
  Future<void> announceRecord(String dhtKey, String recordType);

  /// Discover records of a given type from the DHT network.
  ///
  /// Returns a list of DHT keys found.
  Future<List<String>> discoverRecords(String recordType);
}

/// Result of a DHT publish operation.
class VeilidPublishResult {
  /// Whether the publish succeeded.
  final bool success;

  /// The DHT key assigned to the record.
  /// For creates this may be a newly-assigned key; for updates it echoes
  /// the input key.
  final String? dhtKey;

  /// Human-readable error message on failure.
  final String? error;

  const VeilidPublishResult({
    required this.success,
    this.dhtKey,
    this.error,
  });

  /// Convenience constructor for a successful publish.
  const VeilidPublishResult.ok(String key)
      : success = true,
        dhtKey = key,
        error = null;

  /// Convenience constructor for a failed publish.
  const VeilidPublishResult.fail(String message)
      : success = false,
        dhtKey = null,
        error = message;
}

/// A change notification from a watched DHT record.
class DhtValueChange {
  /// The DHT key of the changed record.
  final String dhtKey;

  /// The updated JSON payload.
  final String payload;

  /// When the change was received locally.
  final DateTime receivedAt;

  const DhtValueChange({
    required this.dhtKey,
    required this.payload,
    required this.receivedAt,
  });
}
