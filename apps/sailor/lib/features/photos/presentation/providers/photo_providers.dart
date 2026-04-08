import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/at/at_providers.dart';
import 'package:sailor/features/photos/data/photo_service.dart';

/// Photo service provider.
final photoServiceProvider = Provider<PhotoService>((ref) {
  final auth = ref.watch(atAuthServiceProvider);
  return PhotoService(auth);
});

/// Photos for an event — fetched from participant PDS repos.
final eventPhotosProvider = FutureProvider.family<List<EventPhoto>,
    ({String eventAtUri, List<String> participantDids})>((ref, params) async {
  final service = ref.read(photoServiceProvider);
  return service.getEventPhotos(params.eventAtUri, params.participantDids);
});

/// Number of photos pending upload.
final pendingPhotoUploadsProvider = Provider<int>((ref) {
  final service = ref.watch(photoServiceProvider);
  return service.pendingUploadCount;
});
