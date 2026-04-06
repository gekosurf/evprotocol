import 'dart:math';

import 'package:ev_protocol_veilid/src/sync/veilid_node_interface.dart';

/// Mock Veilid node for development and testing.
///
/// Simulates DHT operations by logging to console. Use [failureRate] to
/// test retry/backoff logic without a real network.
///
/// ```dart
/// // Always succeeds (default)
/// final node = MockVeilidNode();
///
/// // 30% random failure rate for testing retries
/// final flakyNode = MockVeilidNode(failureRate: 0.3);
///
/// // Always fails (test max-retry / failed state)
/// final deadNode = MockVeilidNode(failureRate: 1.0);
/// ```
class MockVeilidNode implements VeilidNodeInterface {
  /// Probability of a simulated failure (0.0–1.0).
  final double failureRate;

  /// Whether the mock node reports itself as online.
  bool _online;

  final Random _random;

  /// Creates a mock Veilid node.
  ///
  /// [failureRate] controls the probability of a simulated failure (0.0–1.0).
  /// [online] sets the initial online status (default true).
  /// [seed] optional random seed for deterministic test behaviour.
  MockVeilidNode({
    this.failureRate = 0.0,
    bool online = true,
    int? seed,
  })  : _online = online,
        _random = Random(seed);

  /// Sets the online status for testing.
  set online(bool value) => _online = value;

  @override
  Future<VeilidPublishResult> publishRecord(
    String dhtKey,
    String payload,
  ) async {
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 50));

    if (_shouldFail()) {
      final msg = 'MockVeilidNode: simulated publish failure for $dhtKey';
      _log('❌ PUBLISH FAILED: $dhtKey');
      return VeilidPublishResult.fail(msg);
    }

    // For local- keys, simulate DHT assigning a "real" key
    final resolvedKey = dhtKey.startsWith('local-')
        ? 'dht-${dhtKey.substring(6)}'
        : dhtKey;

    _log('✅ PUBLISHED: $resolvedKey (${payload.length} bytes)');
    return VeilidPublishResult.ok(resolvedKey);
  }

  @override
  Future<String?> getRecord(String dhtKey) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));

    if (_shouldFail()) {
      _log('❌ GET FAILED: $dhtKey');
      return null;
    }

    _log('📖 GET: $dhtKey (mock — no data stored)');
    return null; // Mock has no persistent store
  }

  @override
  Future<bool> deleteRecord(String dhtKey) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));

    if (_shouldFail()) {
      _log('❌ DELETE FAILED: $dhtKey');
      return false;
    }

    _log('🗑️ DELETED: $dhtKey');
    return true;
  }

  @override
  Future<bool> isOnline() async => _online;

  bool _shouldFail() {
    if (failureRate <= 0.0) return false;
    if (failureRate >= 1.0) return true;
    return _random.nextDouble() < failureRate;
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[VeilidMock ${DateTime.now().toIso8601String()}] $message');
  }
}
