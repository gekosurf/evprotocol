import 'dart:async';

import 'package:ev_protocol_at/ev_protocol_at.dart';
import 'package:flutter/foundation.dart';

/// GPS position buffering + PDS upload service.
///
/// Offline-first: positions buffer in memory, flush to PDS every [flushInterval].
/// If PDS is unreachable, buffer grows and flushes when connectivity returns.
class PositionService {
  final AtAuthService _auth;
  final List<SmokeSignalPosition> _buffer = [];
  Timer? _flushTimer;
  String? _activeEventUri;
  String? _boatName;
  bool _isTracking = false;

  /// How often to flush buffered positions to PDS.
  final Duration flushInterval;

  /// Callback to get current GPS position — injected by platform layer.
  /// Returns (latitude, longitude, speed, heading, altitude).
  final Future<({double lat, double lng, double? speed, double? heading, double? altitude})>
      Function()? onGetPosition;

  /// Stream controller for tracking state changes.
  final _trackingStateController = StreamController<bool>.broadcast();

  /// Stream of tracking state changes.
  Stream<bool> get trackingState => _trackingStateController.stream;

  bool get isTracking => _isTracking;
  String? get activeEventUri => _activeEventUri;

  PositionService(
    this._auth, {
    this.flushInterval = const Duration(seconds: 60),
    this.onGetPosition,
  });

  /// Start tracking for a specific event.
  Future<void> startTracking(String eventAtUri, {String? boatName}) async {
    if (_isTracking) return;

    _activeEventUri = eventAtUri;
    _boatName = boatName ?? 'Unknown';
    _isTracking = true;
    _trackingStateController.add(true);

    // Start periodic flush
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(flushInterval, (_) => flushBuffer());

    debugPrint('[PositionService] Tracking started for event: $eventAtUri');
  }

  /// Record a position point. Call this from GPS location listener.
  void recordPosition({
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? altitude,
  }) {
    if (!_isTracking || _activeEventUri == null) return;

    _buffer.add(SmokeSignalPosition(
      eventUri: _activeEventUri!,
      boatName: _boatName ?? 'Unknown',
      latitude: latitude.toStringAsFixed(6),
      longitude: longitude.toStringAsFixed(6),
      speed: speed?.toStringAsFixed(1),
      heading: heading?.toStringAsFixed(1),
      altitude: altitude?.toStringAsFixed(1),
      timestamp: DateTime.now().toUtc().toIso8601String(),
    ));

    debugPrint('[PositionService] Buffered position: ${_buffer.length} points');
  }

  /// Stop tracking. Flushes remaining buffer.
  Future<void> stopTracking() async {
    _isTracking = false;
    _trackingStateController.add(false);
    _flushTimer?.cancel();
    _flushTimer = null;

    // Flush remaining buffer
    await flushBuffer();

    _activeEventUri = null;
    _boatName = null;
    debugPrint('[PositionService] Tracking stopped');
  }

  /// Flush buffered positions to PDS.
  Future<int> flushBuffer() async {
    if (_buffer.isEmpty) return 0;

    final client = _auth.client;
    if (client == null) {
      debugPrint('[PositionService] Not authenticated — keeping ${_buffer.length} in buffer');
      return 0;
    }

    final toFlush = List<SmokeSignalPosition>.from(_buffer);
    int pushed = 0;

    for (final position in toFlush) {
      try {
        await client.atproto.repo.createRecord(
          repo: _auth.did!,
          collection: LexiconNsids.yachtPosition,
          record: position.toRecord(),
        );
        _buffer.remove(position);
        pushed++;
      } catch (e) {
        debugPrint('[PositionService] PDS push failed: $e');
        break; // Stop on first failure, retry next flush
      }
    }

    debugPrint('[PositionService] Flushed $pushed/${toFlush.length} positions');
    return pushed;
  }

  /// Get tracks for participants in an event by querying their PDS repos.
  Future<List<YachtTrack>> getEventTracks(
      String eventAtUri, List<String> participantDids) async {
    final client = _auth.client;
    if (client == null) return [];

    final tracks = <YachtTrack>[];

    for (final did in participantDids) {
      try {
        final result = await client.atproto.repo.listRecords(
          repo: did,
          collection: LexiconNsids.yachtPosition,
        );

        final positions = result.data.records
            .map((r) => SmokeSignalPosition.fromRecord(r.value))
            .where((p) => p.eventUri == eventAtUri)
            .toList();

        if (positions.isNotEmpty) {
          tracks.add(YachtTrack(
            did: did,
            boatName: positions.first.boatName,
            positions: positions,
          ));
        }
      } catch (e) {
        debugPrint('[PositionService] Failed to fetch tracks for $did: $e');
      }
    }

    return tracks;
  }

  /// Number of buffered positions waiting to flush.
  int get pendingCount => _buffer.length;

  void dispose() {
    _flushTimer?.cancel();
    _trackingStateController.close();
  }
}

/// A yacht's track — a sequence of position points.
class YachtTrack {
  final String did;
  final String boatName;
  final List<SmokeSignalPosition> positions;

  const YachtTrack({
    required this.did,
    required this.boatName,
    required this.positions,
  });

  /// Latest position in the track.
  SmokeSignalPosition? get latest =>
      positions.isNotEmpty ? positions.last : null;
}
