import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// A known Bluesky connection — someone whose PDS we scan for events.
class Connection {
  final String handle;
  final String did;
  final DateTime addedAt;

  const Connection({
    required this.handle,
    required this.did,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'handle': handle,
        'did': did,
        'addedAt': addedAt.toIso8601String(),
      };

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      handle: json['handle'] as String,
      did: json['did'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}

/// Persists the user's connection list to a local JSON file.
///
/// File location: `~/.sailor_connections.json`
/// This is a simple, platform-agnostic store — no Keychain or Drift dependency.
class ConnectionsStore {
  static const _fileName = '.sailor_connections.json';

  File get _file {
    final home = Platform.environment['HOME'] ?? '.';
    return File('$home/$_fileName');
  }

  /// Load all stored connections.
  Future<List<Connection>> loadAll() async {
    try {
      if (!await _file.exists()) return [];
      final content = await _file.readAsString();
      final list = jsonDecode(content) as List<dynamic>;
      return list
          .map((e) => Connection.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[Connections] Failed to load: $e');
      return [];
    }
  }

  /// Add a connection. Deduplicates by DID.
  Future<void> add(Connection connection) async {
    final existing = await loadAll();
    if (existing.any((c) => c.did == connection.did)) {
      debugPrint('[Connections] Already connected to ${connection.handle}');
      return;
    }
    existing.add(connection);
    await _persist(existing);
    debugPrint('[Connections] Added ${connection.handle} (${connection.did})');
  }

  /// Remove a connection by DID.
  Future<void> remove(String did) async {
    final existing = await loadAll();
    existing.removeWhere((c) => c.did == did);
    await _persist(existing);
    debugPrint('[Connections] Removed $did');
  }

  /// Get just the DIDs for scanning.
  Future<List<String>> getDids() async {
    final connections = await loadAll();
    return connections.map((c) => c.did).toList();
  }

  Future<void> _persist(List<Connection> connections) async {
    final json = jsonEncode(connections.map((c) => c.toJson()).toList());
    await _file.writeAsString(json, flush: true);
  }
}
