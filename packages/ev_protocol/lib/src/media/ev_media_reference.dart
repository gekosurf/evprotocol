import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';

/// A reference to a media blob stored externally.
///
/// Schema: `ev.media.reference`
///
/// The DHT stores only the reference (URL + hash + metadata).
/// The actual binary is stored in R2, S3, IPFS, or on-device.
class EvMediaReference {
  final EvDhtKey? dhtKey;
  final EvPubkey uploaderPubkey;
  final String url;
  final String sha256Hash;
  final int sizeBytes;
  final String mimeType;
  final int? widthPx;
  final int? heightPx;
  final int? durationSeconds;
  final String? altText;
  final String? thumbnailUrl;
  final EvTimestamp createdAt;

  const EvMediaReference({
    this.dhtKey,
    required this.uploaderPubkey,
    required this.url,
    required this.sha256Hash,
    required this.sizeBytes,
    required this.mimeType,
    this.widthPx,
    this.heightPx,
    this.durationSeconds,
    this.altText,
    this.thumbnailUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.media.reference',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'uploaderPubkey': uploaderPubkey.toString(),
        'url': url,
        'sha256Hash': sha256Hash,
        'sizeBytes': sizeBytes,
        'mimeType': mimeType,
        if (widthPx != null) 'widthPx': widthPx,
        if (heightPx != null) 'heightPx': heightPx,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (altText != null) 'altText': altText,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        'createdAt': createdAt.toIso8601(),
      };

  factory EvMediaReference.fromJson(Map<String, dynamic> json) {
    return EvMediaReference(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      uploaderPubkey: EvPubkey(json['uploaderPubkey'] as String),
      url: json['url'] as String,
      sha256Hash: json['sha256Hash'] as String,
      sizeBytes: json['sizeBytes'] as int,
      mimeType: json['mimeType'] as String,
      widthPx: json['widthPx'] as int?,
      heightPx: json['heightPx'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      altText: json['altText'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: EvTimestamp.parse(json['createdAt'] as String),
    );
  }
}
