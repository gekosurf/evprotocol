import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/at/at_providers.dart';
import 'package:sailor/features/tracking/data/position_service.dart';

/// Position tracking service provider.
final positionServiceProvider = Provider<PositionService>((ref) {
  final auth = ref.watch(atAuthServiceProvider);
  final service = PositionService(auth);
  ref.onDispose(service.dispose);
  return service;
});

/// Whether tracking is currently active.
final isTrackingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(positionServiceProvider);
  return service.trackingState;
});

/// Number of buffered positions waiting to flush.
final pendingPositionsProvider = Provider<int>((ref) {
  final service = ref.watch(positionServiceProvider);
  return service.pendingCount;
});

/// Tracks for an event — fetched from participant PDS repos.
final eventTracksProvider = FutureProvider.family<List<YachtTrack>,
    ({String eventAtUri, List<String> participantDids})>((ref, params) async {
  final service = ref.read(positionServiceProvider);
  return service.getEventTracks(params.eventAtUri, params.participantDids);
});
