import 'package:test/test.dart';
import 'package:ev_protocol/ev_protocol.dart';

void main() {
  final _now = EvTimestamp.now();
  final _pubkey = EvPubkey.fromRawKey('uploader-key');

  group('EvMediaReference', () {
    test('JSON roundtrip', () {
      final media = EvMediaReference(
        dhtKey: const EvDhtKey('media-1'),
        uploaderPubkey: _pubkey,
        url: 'https://r2.example.com/photo.jpg',
        sha256Hash: 'abc123hash',
        sizeBytes: 1048576,
        mimeType: 'image/jpeg',
        widthPx: 1920,
        heightPx: 1080,
        altText: 'Start line at regatta',
        thumbnailUrl: 'https://r2.example.com/photo_thumb.jpg',
        createdAt: _now,
      );

      final json = media.toJson();
      expect(json[r'$type'], 'ev.media.reference');
      expect(json['url'], 'https://r2.example.com/photo.jpg');
      expect(json['sha256Hash'], 'abc123hash');
      expect(json['sizeBytes'], 1048576);
      expect(json['mimeType'], 'image/jpeg');

      final restored = EvMediaReference.fromJson(json);
      expect(restored.url, media.url);
      expect(restored.sha256Hash, media.sha256Hash);
      expect(restored.widthPx, 1920);
      expect(restored.heightPx, 1080);
      expect(restored.altText, 'Start line at regatta');
      expect(restored.thumbnailUrl, media.thumbnailUrl);
    });

    test('minimal fields', () {
      final media = EvMediaReference(
        uploaderPubkey: _pubkey,
        url: 'https://example.com/file.pdf',
        sha256Hash: 'hash',
        sizeBytes: 500,
        mimeType: 'application/pdf',
        createdAt: _now,
      );
      final json = media.toJson();
      expect(json.containsKey('widthPx'), isFalse);
      expect(json.containsKey('heightPx'), isFalse);
      expect(json.containsKey('durationSeconds'), isFalse);
      expect(json.containsKey('altText'), isFalse);
    });

    test('video with duration', () {
      final media = EvMediaReference(
        uploaderPubkey: _pubkey,
        url: 'https://example.com/race.mp4',
        sha256Hash: 'videohash',
        sizeBytes: 50000000,
        mimeType: 'video/mp4',
        durationSeconds: 180,
        createdAt: _now,
      );
      final json = media.toJson();
      expect(json['durationSeconds'], 180);
      final restored = EvMediaReference.fromJson(json);
      expect(restored.durationSeconds, 180);
    });
  });
}
