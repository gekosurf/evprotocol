import 'package:test/test.dart';
import 'package:ev_protocol/ev_protocol.dart';

void main() {
  final _now = EvTimestamp.now();
  final _pubkey = EvPubkey.fromRawKey('sender-key');

  group('EvChatChannel', () {
    test('JSON roundtrip', () {
      final channel = EvChatChannel(
        dhtKey: const EvDhtKey('chan-1'),
        eventDhtKey: const EvDhtKey('event-1'),
        name: 'Race Day Chat',
        type: EvChatChannelType.discussion,
        maxParticipants: 200,
        creatorPubkey: _pubkey,
        participantPubkeys: [_pubkey, EvPubkey.fromRawKey('other')],
        createdAt: _now,
      );

      final json = channel.toJson();
      expect(json[r'$type'], 'ev.chat.channel');
      expect(json['type'], 'discussion');
      expect(json['maxParticipants'], 200);
      expect(json['participantPubkeys'], hasLength(2));

      final restored = EvChatChannel.fromJson(json);
      expect(restored.name, 'Race Day Chat');
      expect(restored.type, EvChatChannelType.discussion);
      expect(restored.participantPubkeys.length, 2);
    });

    test('all channel types', () {
      for (final type in EvChatChannelType.values) {
        final channel = EvChatChannel(
          eventDhtKey: const EvDhtKey('e1'),
          name: 'Test',
          type: type,
          creatorPubkey: _pubkey,
          createdAt: _now,
        );
        final json = channel.toJson();
        final restored = EvChatChannel.fromJson(json);
        expect(restored.type, type);
      }
    });
  });

  group('EvChatMessage', () {
    test('JSON roundtrip', () {
      final message = EvChatMessage(
        id: 'msg-001',
        channelDhtKey: const EvDhtKey('chan-1'),
        senderPubkey: _pubkey,
        senderName: 'Alice',
        text: 'Wind is picking up! 15 knots from the SW.',
        sentAt: _now,
        replyToId: 'msg-000',
        reactions: {'🔥': 5, '⛵': 3},
        edited: true,
        editedAt: _now,
      );

      final json = message.toJson();
      expect(json[r'$type'], 'ev.chat.message');
      expect(json['id'], 'msg-001');
      expect(json['text'], contains('15 knots'));
      expect(json['replyToId'], 'msg-000');
      expect(json['reactions'], {'🔥': 5, '⛵': 3});
      expect(json['edited'], true);

      final restored = EvChatMessage.fromJson(json);
      expect(restored.senderName, 'Alice');
      expect(restored.replyToId, 'msg-000');
      expect(restored.reactions['🔥'], 5);
      expect(restored.edited, true);
    });

    test('copyWith', () {
      final message = EvChatMessage(
        id: 'msg-1',
        channelDhtKey: const EvDhtKey('c1'),
        senderPubkey: _pubkey,
        text: 'Original text',
        sentAt: _now,
      );
      final edited = message.copyWith(
        text: 'Edited text',
        edited: true,
        editedAt: _now,
      );
      expect(edited.text, 'Edited text');
      expect(edited.edited, true);
      expect(edited.id, 'msg-1');
    });

    test('minimal message', () {
      final message = EvChatMessage(
        id: 'msg-2',
        channelDhtKey: const EvDhtKey('c1'),
        senderPubkey: _pubkey,
        text: 'Hello',
        sentAt: _now,
      );
      final json = message.toJson();
      expect(json.containsKey('replyToId'), isFalse);
      expect(json.containsKey('media'), isFalse);
      expect(json.containsKey('reactions'), isFalse);
      expect(json.containsKey('editedAt'), isFalse);
    });
  });
}
