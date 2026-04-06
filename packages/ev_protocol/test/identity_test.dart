import 'package:test/test.dart';
import 'package:ev_protocol/ev_protocol.dart';

void main() {
  final _now = EvTimestamp.now();
  final _pubkey = EvPubkey.fromRawKey('test-user-key');

  group('EvIdentity', () {
    test('JSON roundtrip', () {
      final identity = EvIdentity(
        pubkey: _pubkey,
        displayName: 'Alice',
        bio: 'Sailor from Perth',
        createdAt: _now,
        updatedAt: _now,
      );
      final json = identity.toJson();
      expect(json[r'$type'], 'ev.identity.profile');
      final restored = EvIdentity.fromJson(json);
      expect(restored.pubkey, identity.pubkey);
      expect(restored.displayName, 'Alice');
      expect(restored.bio, 'Sailor from Perth');
    });

    test('copyWith', () {
      final identity = EvIdentity(
        pubkey: _pubkey,
        displayName: 'Alice',
        createdAt: _now,
      );
      final updated = identity.copyWith(displayName: 'Bob');
      expect(updated.displayName, 'Bob');
      expect(updated.pubkey, identity.pubkey);
    });

    test('optional fields are nullable', () {
      final identity = EvIdentity(
        pubkey: _pubkey,
        displayName: 'Alice',
        createdAt: _now,
      );
      final json = identity.toJson();
      expect(json.containsKey('bio'), isFalse);
      expect(json.containsKey('avatarRef'), isFalse);
      expect(json.containsKey('updatedAt'), isFalse);
    });
  });

  group('EvIdentityBridge', () {
    test('JSON roundtrip', () {
      final bridge = EvIdentityBridge(
        veilidPubkey: _pubkey,
        atDid: 'did:plc:abc123',
        atHandle: '@alice.bsky.social',
        veilidSignature: 'sig1',
        atSignature: 'sig2',
        linkedAt: _now,
      );
      final json = bridge.toJson();
      expect(json[r'$type'], 'ev.identity.bridge');
      expect(json['atDid'], 'did:plc:abc123');
      final restored = EvIdentityBridge.fromJson(json);
      expect(restored.atDid, 'did:plc:abc123');
      expect(restored.atHandle, '@alice.bsky.social');
      expect(restored.veilidSignature, 'sig1');
      expect(restored.atSignature, 'sig2');
    });
  });
}
