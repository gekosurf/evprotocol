import 'dart:typed_data';

import '../core/ev_dht_key.dart';
import '../core/ev_result.dart';
import 'ev_media_reference.dart';

/// Abstract interface for media management in the EV Protocol.
///
/// ```mermaid
/// sequenceDiagram
///     participant App as Flutter App
///     participant Svc as EvMediaService
///     participant AI as On-Device AI
///     participant Store as Blob Store (R2/S3)
///     participant DHT as Veilid DHT
///
///     Note over App,DHT: UPLOAD MEDIA
///     App->>Svc: uploadMedia(bytes, mimeType, eventKey)
///     Svc->>AI: Moderate content (NSFW check)
///     AI-->>Svc: SAFE ✓
///     Svc->>Svc: Compute SHA256 hash
///     Svc->>Store: Upload bytes → get URL
///     Store-->>Svc: https://r2.example.com/abc.jpg
///     Svc->>DHT: Write ev.media.reference
///     DHT-->>Svc: Published ✓
///     Svc-->>App: EvSuccess(EvMediaReference)
///
///     Note over App,DHT: DOWNLOAD MEDIA
///     App->>Svc: downloadMedia(mediaRef)
///     Svc->>Store: Fetch URL
///     Svc->>Svc: Verify SHA256 hash
///     Store-->>Svc: bytes
///     Svc-->>App: EvSuccess(Uint8List)
/// ```
abstract class EvMediaService {
  /// Uploads media and creates a reference record in the DHT.
  ///
  /// The bytes are uploaded to blob storage, and a reference
  /// (URL + hash) is written to the DHT.
  Future<EvResult<EvMediaReference>> uploadMedia({
    required Uint8List bytes,
    required String mimeType,
    required EvDhtKey eventDhtKey,
    String? altText,
    bool moderateOnDevice = true,
  });

  /// Downloads media bytes from the referenced URL.
  ///
  /// Verifies the SHA256 hash after download to ensure integrity.
  Future<EvResult<Uint8List>> downloadMedia(EvMediaReference reference);

  /// Gets a media reference by its DHT key.
  Future<EvResult<EvMediaReference>> getMediaReference(EvDhtKey dhtKey);

  /// Lists all media references for an event.
  Future<EvResult<List<EvMediaReference>>> listEventMedia(
      EvDhtKey eventDhtKey);

  /// Deletes a media reference and optionally the blob.
  Future<EvResult<void>> deleteMedia(EvDhtKey dhtKey);
}
