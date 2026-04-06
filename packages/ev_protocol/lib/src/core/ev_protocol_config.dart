/// Protocol-level configuration for an EV Protocol node.
///
/// ```mermaid
/// sequenceDiagram
///     participant App as Flutter App
///     participant Config as EvProtocolConfig
///     participant Services as Protocol Services
///
///     App->>Config: Create config
///     Note over Config: bootstrap nodes, version,<br/>search tier, sync interval
///     App->>Services: Initialize with config
///     Services->>Services: Connect to bootstrap
///     Services->>Services: Start sync loop
///     Services-->>App: Ready ✓
/// ```
class EvProtocolConfig {
  /// Protocol version (semantic versioning).
  final String protocolVersion;

  /// Bootstrap node addresses for initial DHT connection.
  final List<String> bootstrapNodes;

  /// Whether to enable AT Protocol identity bridging.
  final bool enableAtBridge;

  /// Maximum search tier to use (1 = DHT only, 2 = distributed, 3 = vector).
  final int maxSearchTier;

  /// Sync interval in seconds for offline queue processing.
  final int syncIntervalSeconds;

  /// Whether to enable on-device content moderation AI.
  final bool enableDeviceModeration;

  /// Maximum DHT record size in bytes.
  final int maxRecordSizeBytes;

  /// Low power mode for mobile (reduces DHT participation).
  final bool lowPowerMode;

  const EvProtocolConfig({
    this.protocolVersion = '0.1.0',
    this.bootstrapNodes = const [],
    this.enableAtBridge = false,
    this.maxSearchTier = 1,
    this.syncIntervalSeconds = 30,
    this.enableDeviceModeration = true,
    this.maxRecordSizeBytes = 32768,
    this.lowPowerMode = true,
  });

  EvProtocolConfig copyWith({
    String? protocolVersion,
    List<String>? bootstrapNodes,
    bool? enableAtBridge,
    int? maxSearchTier,
    int? syncIntervalSeconds,
    bool? enableDeviceModeration,
    int? maxRecordSizeBytes,
    bool? lowPowerMode,
  }) {
    return EvProtocolConfig(
      protocolVersion: protocolVersion ?? this.protocolVersion,
      bootstrapNodes: bootstrapNodes ?? this.bootstrapNodes,
      enableAtBridge: enableAtBridge ?? this.enableAtBridge,
      maxSearchTier: maxSearchTier ?? this.maxSearchTier,
      syncIntervalSeconds: syncIntervalSeconds ?? this.syncIntervalSeconds,
      enableDeviceModeration:
          enableDeviceModeration ?? this.enableDeviceModeration,
      maxRecordSizeBytes: maxRecordSizeBytes ?? this.maxRecordSizeBytes,
      lowPowerMode: lowPowerMode ?? this.lowPowerMode,
    );
  }
}
