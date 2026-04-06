import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_result.dart';
import 'ev_chat_channel.dart';
import 'ev_chat_message.dart';

/// Abstract interface for event-scoped chat in the EV Protocol.
///
/// ```mermaid
/// sequenceDiagram
///     participant A as User A (sender)
///     participant Svc as EvChatService
///     participant DHT as Veilid DHT
///     participant B as User B (online)
///     participant C as User C (offline)
///     participant Push as APNS/FCM
///
///     Note over A,Push: SEND MESSAGE
///     A->>Svc: sendMessage(channelKey, text)
///     Svc->>DHT: Write to sender's subkey (persistent)
///     Svc->>B: AppMessage (instant P2P, ~100ms)
///     Svc->>C: AppMessage (fails — offline)
///     Svc->>Push: Wake-up notification (no content)
///     Svc-->>A: EvSuccess(EvChatMessage)
///
///     B->>B: Display message instantly
///
///     Note over A,Push: OFFLINE USER CATCHES UP
///     C->>Svc: loadMessages(channelKey)
///     Svc->>DHT: Read all subkeys
///     Svc->>Svc: Merge by timestamp
///     Svc-->>C: EvSuccess(List<EvChatMessage>)
/// ```
abstract class EvChatService {
  /// Creates a chat channel for an event.
  Future<EvResult<EvChatChannel>> createChannel({
    required EvDhtKey eventDhtKey,
    required String name,
    required EvChatChannelType type,
    int? maxParticipants,
  });

  /// Gets a channel by DHT key.
  Future<EvResult<EvChatChannel>> getChannel(EvDhtKey dhtKey);

  /// Lists all channels for an event.
  Future<EvResult<List<EvChatChannel>>> listEventChannels(
      EvDhtKey eventDhtKey);

  /// Sends a message to a channel.
  ///
  /// The message is written to the sender's subkey on the multi-writer
  /// DHT record, then delivered via AppMessage to online participants.
  Future<EvResult<EvChatMessage>> sendMessage({
    required EvDhtKey channelDhtKey,
    required String text,
    String? replyToId,
    EvDhtKey? mediaDhtKey,
  });

  /// Loads all messages from a channel (merges all subkeys by timestamp).
  Future<EvResult<List<EvChatMessage>>> loadMessages(
    EvDhtKey channelDhtKey, {
    int? limit,
    String? beforeMessageId,
  });

  /// Edits an existing message (sender only).
  Future<EvResult<EvChatMessage>> editMessage({
    required EvDhtKey channelDhtKey,
    required String messageId,
    required String newText,
  });

  /// Deletes a message (sender or channel admin).
  Future<EvResult<void>> deleteMessage({
    required EvDhtKey channelDhtKey,
    required String messageId,
  });

  /// Reacts to a message with an emoji.
  Future<EvResult<void>> reactToMessage({
    required EvDhtKey channelDhtKey,
    required String messageId,
    required String emoji,
  });

  /// Watches a channel for new messages in real-time.
  ///
  /// Returns a stream of new messages as they arrive
  /// (via AppMessage for instant delivery, DHT polling for catch-up).
  Stream<EvChatMessage> watchChannel(EvDhtKey channelDhtKey);

  /// Creates or gets the DM channel between the current user and another.
  ///
  /// DM keys are deterministic: sha256("ev:dm:<sorted-pubkeys>:v1").
  Future<EvResult<EvChatChannel>> getOrCreateDm(EvPubkey otherPubkey);

  /// Sends an announcement to an event (organiser only).
  Future<EvResult<EvChatMessage>> sendAnnouncement({
    required EvDhtKey eventDhtKey,
    required String text,
    String? priority,
    EvDhtKey? mediaDhtKey,
  });

  /// Sends an ephemeral live reaction (not persisted).
  Future<EvResult<void>> sendReaction({
    required EvDhtKey eventDhtKey,
    required String emoji,
  });

  /// Watches live reactions for an event.
  Stream<Map<String, int>> watchReactions(EvDhtKey eventDhtKey);
}
