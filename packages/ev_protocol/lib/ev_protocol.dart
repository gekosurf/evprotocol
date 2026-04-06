/// EV Protocol v0.1
///
/// Abstract interfaces and data models for the Event Vector
/// decentralised event protocol.
///
/// This package contains ONLY interfaces (abstract classes) and immutable
/// data models. It has ZERO external dependencies.
///
/// ## Usage
///
/// ```dart
/// import 'package:ev_protocol/ev_protocol.dart';
///
/// // Implement the abstract interfaces with your chosen backend:
/// class VeilidEventService implements EvEventService {
///   // ... Veilid-specific implementation
/// }
/// ```
library ev_protocol;

// Core types
export 'src/core/ev_protocol_config.dart';
export 'src/core/ev_result.dart';
export 'src/core/ev_dht_key.dart';
export 'src/core/ev_pubkey.dart';
export 'src/core/ev_timestamp.dart';

// Identity
export 'src/identity/ev_identity.dart';
export 'src/identity/ev_identity_bridge.dart';
export 'src/identity/ev_identity_service.dart';

// Events
export 'src/event/ev_event.dart';
export 'src/event/ev_rsvp.dart';
export 'src/event/ev_event_service.dart';

// Groups & Vessels
export 'src/group/ev_group.dart';
export 'src/group/ev_vessel.dart';
export 'src/group/ev_group_service.dart';

// Media
export 'src/media/ev_media_reference.dart';
export 'src/media/ev_media_service.dart';

// Payments
export 'src/payment/ev_payment_intent.dart';
export 'src/payment/ev_payment_receipt.dart';
export 'src/payment/ev_ticket.dart';
export 'src/payment/ev_payment_service.dart';

// Chat
export 'src/chat/ev_chat_channel.dart';
export 'src/chat/ev_chat_message.dart';
export 'src/chat/ev_chat_service.dart';

// Search
export 'src/search/ev_search_result.dart';
export 'src/search/ev_search_service.dart';

// Moderation
export 'src/moderation/ev_moderation_report.dart';
export 'src/moderation/ev_moderation_action.dart';
export 'src/moderation/ev_moderation_service.dart';

// Sync
export 'src/sync/ev_sync_service.dart';

// Schema
export 'src/schema/ev_lexicon.dart';
export 'src/schema/ev_schema_validator.dart';

// Sailing extension
export 'src/sailing/ev_race.dart';
export 'src/sailing/ev_course.dart';
export 'src/sailing/ev_track.dart';
export 'src/sailing/ev_race_result.dart';
export 'src/sailing/ev_sailing_service.dart';
