import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Resolves a DID to its PDS (Personal Data Server) URL and queries records
/// across PDS boundaries.
///
/// The AT Protocol stores each user's data on their specific PDS. To read
/// another user's records, you must resolve their PDS URL from the PLC
/// directory and query THAT PDS directly.
class CrossPdsResolver {
  /// Cache of DID → PDS URL mappings to avoid repeated PLC lookups.
  static final Map<String, String> _pdsCache = {};

  /// Resolve a DID to its PDS URL via the PLC directory.
  ///
  /// Returns the PDS service endpoint URL (e.g., "https://puffin.us-east.host.bsky.network").
  static Future<String?> resolvePdsUrl(String did) async {
    // Check cache first
    if (_pdsCache.containsKey(did)) return _pdsCache[did];

    try {
      final url = Uri.parse('https://plc.directory/$did');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        debugPrint('[CrossPDS] PLC lookup failed for $did: ${response.statusCode}');
        return null;
      }

      final doc = jsonDecode(response.body) as Map<String, dynamic>;
      final services = doc['service'] as List<dynamic>?;
      if (services == null) return null;

      for (final svc in services) {
        final s = svc as Map<String, dynamic>;
        if (s['type'] == 'AtprotoPersonalDataServer') {
          final endpoint = s['serviceEndpoint'] as String;
          _pdsCache[did] = endpoint;
          debugPrint('[CrossPDS] Resolved $did → $endpoint');
          return endpoint;
        }
      }

      return null;
    } catch (e) {
      debugPrint('[CrossPDS] PDS resolution failed for $did: $e');
      return null;
    }
  }

  /// List records from ANY user's PDS, regardless of which PDS the current
  /// session is connected to.
  ///
  /// Resolves the DID's PDS URL, then makes a direct HTTP GET to that PDS.
  static Future<List<Map<String, dynamic>>> listRecords({
    required String did,
    required String collection,
    int limit = 100,
  }) async {
    final pdsUrl = await resolvePdsUrl(did);
    if (pdsUrl == null) return [];

    try {
      final uri = Uri.parse(
        '$pdsUrl/xrpc/com.atproto.repo.listRecords'
        '?repo=${Uri.encodeComponent(did)}'
        '&collection=${Uri.encodeComponent(collection)}'
        '&limit=$limit',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        debugPrint('[CrossPDS] listRecords failed for $did/$collection: ${response.statusCode}');
        return [];
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final records = body['records'] as List<dynamic>? ?? [];

      return records.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[CrossPDS] listRecords error for $did/$collection: $e');
      return [];
    }
  }

  /// Clear the PDS URL cache (useful on logout).
  static void clearCache() => _pdsCache.clear();
}
