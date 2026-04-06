/// Abstract interface for Veilid DHT node operations.
///
/// This is the single seam between the sync service and Veilid's FFI layer.
/// Swap [MockVeilidNode] for a real implementation when Veilid Rust bindings
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
