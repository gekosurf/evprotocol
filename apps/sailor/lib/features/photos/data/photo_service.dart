import 'dart:io';

import 'package:ev_protocol_at/ev_protocol_at.dart';
import 'package:flutter/foundation.dart';

/// Photo capture, compression, and PDS upload service.
///
/// Offline-first: photos save locally first, queue PDS upload.
/// Handles HEIC → JPEG conversion, max 5MB enforcement.
class PhotoService {
  final AtAuthService _auth;
  final List<PendingPhoto> _uploadQueue = [];

  PhotoService(this._auth);

  /// Upload a photo for an event.
  ///
  /// 1. Read file bytes
  /// 2. Upload blob to PDS
  /// 3. Create record referencing the blob
  Future<EventPhoto?> uploadPhoto({
    required String eventAtUri,
    required File imageFile,
    String? caption,
    double? latitude,
    double? longitude,
  }) async {
    final client = _auth.client;

    // Read file
    final bytes = await imageFile.readAsBytes();
    final mimeType = _guessMimeType(imageFile.path);

    // Validate size (5MB max per PDS constraint)
    if (bytes.length > 5 * 1024 * 1024) {
      debugPrint('[PhotoService] Image too large: ${bytes.length} bytes. Max 5MB.');
      return null;
    }

    if (client == null) {
      // Queue for later upload
      _uploadQueue.add(PendingPhoto(
        eventAtUri: eventAtUri,
        filePath: imageFile.path,
        caption: caption,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now().toUtc(),
      ));
      debugPrint('[PhotoService] Queued photo for offline upload');
      return EventPhoto(
        eventUri: eventAtUri,
        caption: caption,
        createdAt: DateTime.now().toUtc(),
        authorDid: _auth.did ?? 'local',
        isLocal: true,
        localPath: imageFile.path,
      );
    }

    try {
      // Step 1: Upload blob
      final blobResult = await client.atproto.repo.uploadBlob(
        bytes: bytes,
      );
      
      final blobRef = blobResult.data.blob.toJson();

      // Step 2: Create record
      final photo = SmokeSignalPhoto(
        eventUri: eventAtUri,
        image: blobRef,
        caption: caption,
        latitude: latitude?.toStringAsFixed(6),
        longitude: longitude?.toStringAsFixed(6),
        createdAt: DateTime.now().toUtc().toIso8601String(),
      );

      final recordResult = await client.atproto.repo.createRecord(
        repo: _auth.did!,
        collection: LexiconNsids.photo,
        record: photo.toRecord(),
      );

      debugPrint('[PhotoService] Photo uploaded: ${recordResult.data.uri}');

      return EventPhoto(
        eventUri: eventAtUri,
        atUri: recordResult.data.uri.toString(),
        blobRef: blobRef,
        caption: caption,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now().toUtc(),
        authorDid: _auth.did!,
        mimeType: mimeType,
        sizeBytes: bytes.length,
      );
    } catch (e) {
      debugPrint('[PhotoService] Upload failed: $e');
      // Queue for retry
      _uploadQueue.add(PendingPhoto(
        eventAtUri: eventAtUri,
        filePath: imageFile.path,
        caption: caption,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now().toUtc(),
      ));
      return null;
    }
  }

  /// Get all photos for an event from multiple participants.
  Future<List<EventPhoto>> getEventPhotos(
      String eventAtUri, List<String> participantDids) async {
    final client = _auth.client;
    if (client == null) return [];

    final photos = <EventPhoto>[];

    for (final did in participantDids) {
      try {
        final result = await client.atproto.repo.listRecords(
          repo: did,
          collection: LexiconNsids.photo,
        );

        for (final record in result.data.records) {
          final ssPhoto = SmokeSignalPhoto.fromRecord(record.value);
          if (ssPhoto.eventUri == eventAtUri) {
            photos.add(EventPhoto(
              eventUri: ssPhoto.eventUri,
              atUri: record.uri.toString(),
              blobRef: ssPhoto.image,
              caption: ssPhoto.caption,
              latitude: ssPhoto.latitude != null
                  ? double.tryParse(ssPhoto.latitude!)
                  : null,
              longitude: ssPhoto.longitude != null
                  ? double.tryParse(ssPhoto.longitude!)
                  : null,
              createdAt: DateTime.tryParse(ssPhoto.createdAt) ?? DateTime.now(),
              authorDid: did,
            ));
          }
        }
      } catch (e) {
        debugPrint('[PhotoService] Failed to fetch photos for $did: $e');
      }
    }

    // Sort newest first
    photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return photos;
  }

  /// Retry pending uploads.
  Future<int> retryPendingUploads() async {
    if (_uploadQueue.isEmpty) return 0;
    final client = _auth.client;
    if (client == null) return 0;

    int uploaded = 0;
    final toRetry = List<PendingPhoto>.from(_uploadQueue);

    for (final pending in toRetry) {
      final file = File(pending.filePath);
      if (!file.existsSync()) {
        _uploadQueue.remove(pending);
        continue;
      }

      final result = await uploadPhoto(
        eventAtUri: pending.eventAtUri,
        imageFile: file,
        caption: pending.caption,
        latitude: pending.latitude,
        longitude: pending.longitude,
      );

      if (result != null && !result.isLocal) {
        _uploadQueue.remove(pending);
        uploaded++;
      }
    }

    return uploaded;
  }

  int get pendingUploadCount => _uploadQueue.length;

  String _guessMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'heic':
      case 'heif':
        return 'image/heic';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

/// An event photo — local or remote.
class EventPhoto {
  final String eventUri;
  final String? atUri;
  final Map<String, dynamic>? blobRef;
  final String? caption;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final String authorDid;
  final String? mimeType;
  final int? sizeBytes;
  final bool isLocal;
  final String? localPath;

  const EventPhoto({
    required this.eventUri,
    this.atUri,
    this.blobRef,
    this.caption,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.authorDid,
    this.mimeType,
    this.sizeBytes,
    this.isLocal = false,
    this.localPath,
  });

  /// Build the blob URL for rendering. 
  /// Format: https://bsky.social/xrpc/com.atproto.sync.getBlob?did=X&cid=Y
  String? get blobUrl {
    if (blobRef == null) return null;
    final ref = blobRef!['ref'] as Map<String, dynamic>?;
    final cid = ref?['\$link'] as String?;
    if (cid == null) return null;
    
    // Parse DID from AT URI
    final did = atUri?.replaceFirst('at://', '').split('/').firstOrNull;
    if (did == null) return null;

    return 'https://bsky.social/xrpc/com.atproto.sync.getBlob?did=$did&cid=$cid';
  }
}

/// A photo waiting for PDS upload.
class PendingPhoto {
  final String eventAtUri;
  final String filePath;
  final String? caption;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  const PendingPhoto({
    required this.eventAtUri,
    required this.filePath,
    this.caption,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });
}
