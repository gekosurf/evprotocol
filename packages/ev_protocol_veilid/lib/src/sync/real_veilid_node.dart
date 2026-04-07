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
  VeilidRoutingContext? _routingContext;
  StreamSubscription<VeilidUpdate>? _updateSubscription;

  /// Current attachment state.
  AttachmentState _attachmentState = AttachmentState.detached;

  /// Stream controller for DHT value change notifications.
  final StreamController<DhtValueChange> _valueChangeController =
      StreamController<DhtValueChange>.broadcast();

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
    // In Veilid, records are discoverable by their key once published.
    // The DHT routing table inherently handles discovery — any peer
    // that knows the key can resolve it. No separate announce step needed.
    //
    // For structured discovery (e.g. "find all events"), we use a
    // well-known DHT record as an index/registry that lists known keys.
    _log('📢 Record announced: $dhtKey (type: $recordType)');
  }

  @override
  Future<List<String>> discoverRecords(String recordType) async {
    // Discovery in Veilid works by reading from well-known DHT records
    // that serve as indexes. For now, return empty — the seed data and
    // locally cached events provide the initial dataset.
    //
    // Future: implement a shared DHT record that acts as an event registry.
    _log('🔍 Discover records (type: $recordType) — local cache only for now');
    return [];
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
