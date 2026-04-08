/// EV Protocol v0.2
///
/// Core data models for the Sailor event app.
///
/// This package contains ONLY data models and abstract interfaces.
/// It has ZERO external dependencies.
///
/// Post-cleanup: removed 9 unused service modules (chat, group, media,
/// payment, moderation, search, schema, sailing, identity).
/// What remains: event models, RSVP, core types, sync interface.
library ev_protocol;

// Core types
export 'src/core/ev_protocol_config.dart';
export 'src/core/ev_result.dart';
export 'src/core/ev_dht_key.dart';
export 'src/core/ev_identity.dart';
export 'src/core/ev_pubkey.dart';
export 'src/core/ev_timestamp.dart';

// Events
export 'src/event/ev_event.dart';
export 'src/event/ev_rsvp.dart';
export 'src/event/ev_event_service.dart';

// Sync
export 'src/sync/ev_sync_service.dart';
