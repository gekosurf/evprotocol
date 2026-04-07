import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:veilid/veilid.dart';

import 'veilid_node_interface.dart';

/// Real Veilid node using the veilid_flutter FFI bindings.
///
/// Implements [VeilidNodeInterface] with actual DHT operations, watchers,
/// and network state tracking.
///
/// ## Lifecycle
/// ```
/// node.initialize()  → starts Veilid core, attaches to network
/// node.shutdown()    → detaches and shuts down core
/// ```
class RealVeilidNode implements VeilidNodeInterface {
  /// Optional pre-shared registry key for cross-device sync.
  /// Both devices must use the same key to discover each other's events.
  RealVeilidNode({String? registryKey}) : _registryKeyStr = registryKey;

  VeilidRoutingContext? _routingContext;
  StreamSubscription<VeilidUpdate>? _updateSubscription;

  /// Current attachment state.
  AttachmentState _attachmentState = AttachmentState.detached;

  /// Stream controller for DHT value change notifications.
  final StreamController<DhtValueChange> _valueChangeController =
      StreamController<DhtValueChange>.broadcast();

  /// Cached registry record key — lazily created on first announce.
  String? _registryKeyStr;

  /// The current registry key (null until first announce or set via constructor).
  String? get registryKey => _registryKeyStr;

  /// Whether the node has been initialized.
  bool get isInitialized => _routingContext != null;

  /// Initialize Veilid core and attach to the network.
  ///
  /// Must be called once before any DHT operations.
  Future<void> initialize() async {
    // Get platform-appropriate config
    Veilid.instance.initializeVeilidCore(getDefaultVeilidPlatformConfig());

    final config = await getDefaultVeilidConfig(
      isWeb: false,
      programName: 'sailor',
    );

    // Start the core — returns a stream of updates
    final updateStream = await Veilid.instance.startupVeilidCore(config);

    // Listen for updates (attachment state, value changes)
    _updateSubscription = updateStream.listen(_handleUpdate);

    // Attach to the network
    await Veilid.instance.attach();

    // Wait for attachment (up to 30 seconds)
    await _waitForAttachment(timeout: const Duration(seconds: 30));

    // Get a routing context for DHT operations
    _routingContext = await Veilid.instance.routingContext();
  }

  /// Shut down Veilid core. Call when the app is being disposed.
  Future<void> shutdown() async {
    await _updateSubscription?.cancel();
    _updateSubscription = null;
    _routingContext?.close();
    _routingContext = null;
    await _valueChangeController.close();

    try {
      await Veilid.instance.detach();
      await Veilid.instance.shutdownVeilidCore();
    } catch (_) {
      // May already be shut down
    }

    _attachmentState = AttachmentState.detached;
  }

  /// Detach from the network (e.g., when app goes to background).
  Future<void> detach() async {
    try {
      await Veilid.instance.detach();
    } catch (_) {}
  }

  /// Re-attach to the network (e.g., when app comes to foreground).
  Future<void> attach() async {
    try {
      await Veilid.instance.attach();
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // VeilidNodeInterface implementation
  // ---------------------------------------------------------------------------

  @override
  Future<VeilidPublishResult> publishRecord(
    String dhtKey,
    String payload,
  ) async {
    if (!await isOnline()) {
      return VeilidPublishResult(dhtKey: dhtKey, success: false);
    }
    final rc = _requireContext();
    final data = Uint8List.fromList(utf8.encode(payload));

    try {
      if (dhtKey.startsWith('local-')) {
        // Create a new DHT record
        final descriptor = await rc.createDHTRecord(
          cryptoKindVLD0,
          const DHTSchema.dflt(oCnt: 1),
        );
        final recordKey = descriptor.key;

        // Write the payload to subkey 0
        await rc.setDHTValue(recordKey, 0, data);

        // Start watching for remote changes
        await watchRecord(recordKey.toString());

        return VeilidPublishResult.ok(recordKey.toString());
      } else {
        // Update an existing DHT record
        final recordKey = RecordKey.fromString(dhtKey);

        // Open the record (may already be open)
        await rc.openDHTRecord(recordKey);

        // Write the updated payload
        await rc.setDHTValue(recordKey, 0, data);

        return VeilidPublishResult.ok(dhtKey);
      }
    } on VeilidAPIException catch (e) {
      return VeilidPublishResult.fail('Veilid publish error: ${e.toDisplayError()}');
    } catch (e) {
      return VeilidPublishResult.fail('Publish error: $e');
    }
  }

  @override
  Future<String?> getRecord(String dhtKey) async {
    final rc = _requireContext();

    try {
      final recordKey = RecordKey.fromString(dhtKey);

      // Open the record for reading
      await rc.openDHTRecord(recordKey);

      // Read subkey 0
      final valueData = await rc.getDHTValue(recordKey, 0, forceRefresh: true);

      if (valueData == null) return null;

      return utf8.decode(valueData.data);
    } on VeilidAPIException {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> deleteRecord(String dhtKey) async {
    final rc = _requireContext();

    try {
      final recordKey = RecordKey.fromString(dhtKey);

      // Cancel any watch first
      await unwatchRecord(dhtKey);

      // Close and delete
      await rc.closeDHTRecord(recordKey);
      await rc.deleteDHTRecord(recordKey);

      return true;
    } on VeilidAPIException {
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isOnline() async {
    return _attachmentState == AttachmentState.attachedGood ||
        _attachmentState == AttachmentState.attachedStrong ||
        _attachmentState == AttachmentState.fullyAttached ||
        _attachmentState == AttachmentState.overAttached;
  }

  // ---------------------------------------------------------------------------
  // DHT Watchers
  // ---------------------------------------------------------------------------

  @override
  Future<void> watchRecord(String dhtKey) async {
    final rc = _requireContext();

    try {
      final recordKey = RecordKey.fromString(dhtKey);

      // Ensure the record is open
      try {
        await rc.openDHTRecord(recordKey);
      } on VeilidAPIException {
        // May already be open — that's fine
      }

      // Set up a watch on all subkeys
      await rc.watchDHTValues(recordKey);
    } catch (e) {
      _log('⚠️ Failed to watch $dhtKey: $e');
    }
  }

  @override
  Future<void> unwatchRecord(String dhtKey) async {
    final rc = _requireContext();

    try {
      final recordKey = RecordKey.fromString(dhtKey);
      await rc.cancelDHTWatch(recordKey);
    } catch (e) {
      // Record may not be watched or open — safe to ignore
    }
  }

  @override
  Stream<DhtValueChange> get onValueChange => _valueChangeController.stream;

  // ---------------------------------------------------------------------------
  // Peer Discovery
  // ---------------------------------------------------------------------------

  @override
  Future<void> announceRecord(String dhtKey, String recordType) async {
    if (recordType != 'event') return; // Only index events for now
    if (!await isOnline()) return; // Wait for network

    try {
      final rc = _requireContext();
      final registryKey = await _getOrCreateRegistryKey();

      // Read current registry contents
      final existing = await rc.getDHTValue(registryKey, 0, forceRefresh: true);
      final currentKeys = <String>{};

      if (existing != null) {
        final json = utf8.decode(existing.data);
        final list = jsonDecode(json) as List<dynamic>;
        currentKeys.addAll(list.cast<String>());
      }

      // Add the new key if not already present
      if (currentKeys.add(dhtKey)) {
        final updatedJson = jsonEncode(currentKeys.toList());
        final data = Uint8List.fromList(utf8.encode(updatedJson));
        await rc.setDHTValue(registryKey, 0, data);
        _log('📢 Announced $dhtKey to registry (${currentKeys.length} total)');
      }
    } catch (e) {
      _log('⚠️ Failed to announce $dhtKey: $e');
    }
  }

  @override
  Future<List<String>> discoverRecords(String recordType) async {
    if (recordType != 'event') return [];
    if (!await isOnline()) return []; // Wait for network

    try {
      final rc = _requireContext();
      final registryKey = await _getOrCreateRegistryKey();

      // Force refresh to get the latest from the network
      final valueData = await rc.getDHTValue(registryKey, 0, forceRefresh: true);

      if (valueData == null) return [];

      final json = utf8.decode(valueData.data);
      final list = jsonDecode(json) as List<dynamic>;
      _log('🔍 Discovered ${list.length} event keys from registry');
      return list.cast<String>();
    } catch (e) {
      _log('⚠️ Failed to discover records: $e');
      return [];
    }
  }

  /// Gets or creates the shared event registry DHT record.
  ///
  /// If a registry key was provided in the constructor, opens that record.
  /// Otherwise creates a new one (and logs the key so it can be shared).
  Future<RecordKey> _getOrCreateRegistryKey() async {
    final rc = _requireContext();

    if (_registryKeyStr != null) {
      // Re-open an existing registry
      final key = RecordKey.fromString(_registryKeyStr!);
      try {
        await rc.openDHTRecord(key);
      } on VeilidAPIException {
        // May already be open
      }
      return key;
    }

    // Create a brand new registry
    final descriptor = await rc.createDHTRecord(
      cryptoKindVLD0,
      const DHTSchema.dflt(oCnt: 1),
    );
    _registryKeyStr = descriptor.key.toString();

    // Initialize with empty list
    final emptyList = Uint8List.fromList(utf8.encode('[]'));
    await rc.setDHTValue(descriptor.key, 0, emptyList);

    _log('📋 Created event registry: $_registryKeyStr');
    _log('📋 ⭐ SHARE THIS KEY with other devices to discover events');
    return descriptor.key;
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  /// Handles incoming Veilid updates.
  void _handleUpdate(VeilidUpdate update) {
    switch (update) {
      case VeilidUpdateAttachment(:final state):
        _attachmentState = state;
        _log('🔗 Attachment: ${state.name}');

      case VeilidUpdateValueChange(:final key, :final value):
        if (value != null) {
          try {
            final payload = utf8.decode(value.data);
            if (!_valueChangeController.isClosed) {
              _valueChangeController.add(DhtValueChange(
                dhtKey: key.toString(),
                payload: payload,
                receivedAt: DateTime.now(),
              ));
            }
          } catch (e) {
            _log('⚠️ Failed to decode value change for $key: $e');
          }
        }

      case VeilidUpdateNetwork():
        // Network state changes — could log peer count etc
        break;

      default:
        break;
    }
  }

  VeilidRoutingContext _requireContext() {
    final rc = _routingContext;
    if (rc == null) {
      throw StateError('RealVeilidNode not initialized. Call initialize() first.');
    }
    return rc;
  }

  /// Waits for the node to attach to the network.
  Future<void> _waitForAttachment({
    required Duration timeout,
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      if (_attachmentState == AttachmentState.attachedGood ||
          _attachmentState == AttachmentState.attachedStrong ||
          _attachmentState == AttachmentState.fullyAttached ||
          _attachmentState == AttachmentState.overAttached) {
        _log('✅ Attached to Veilid network (${_attachmentState.name})');
        return;
      }

      if (_attachmentState == AttachmentState.attachedWeak) {
        _log('⚡ Weakly attached, proceeding...');
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    _log('⏳ Attachment timeout — proceeding with state: ${_attachmentState.name}');
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[VeilidNode ${DateTime.now().toIso8601String()}] $message');
  }
}

/// Returns the platform config JSON expected by `initializeVeilidCore`.
///
/// This must match the Rust `VeilidFFIConfig` struct exactly:
///   { logging: { terminal: {...}, api: {...}, otlp: {...}, flame: {...} } }
Map<String, dynamic> getDefaultVeilidPlatformConfig() {
  return <String, dynamic>{
    'logging': <String, dynamic>{
      'terminal': <String, dynamic>{
        'enabled': true,
        'level': 'Info',
        'ignoreLogTargets': <String>[],
        'directives': <String>[],
      },
      'api': <String, dynamic>{
        'enabled': true,
        'level': 'Info',
        'ignoreLogTargets': <String>[],
        'directives': <String>[],
      },
      'otlp': <String, dynamic>{
        'enabled': false,
        'level': 'Trace',
        'grpcEndpoint': 'localhost:4317',
        'serviceName': 'sailor',
        'ignoreLogTargets': <String>[],
        'directives': <String>[],
      },
      'flame': <String, dynamic>{
        'enabled': false,
        'path': '',
      },
    },
  };
}
