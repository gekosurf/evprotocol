/// AT Protocol transport layer for the EV Protocol.
///
/// Provides authentication, event/RSVP CRUD against a user's PDS,
/// and offline-first sync via the existing Drift SQLite database.
library ev_protocol_at;

// Auth
export 'src/auth/at_auth_service.dart';
export 'src/auth/at_session_store.dart';
export 'src/auth/connections_store.dart';
export 'src/auth/cross_pds_resolver.dart';

// Lexicon-aligned models
export 'src/models/smoke_signal_event.dart';
export 'src/models/smoke_signal_rsvp.dart';
export 'src/models/smoke_signal_sailor.dart';

// Mappers
export 'src/mappers/event_mapper.dart';
export 'src/mappers/rsvp_mapper.dart';

// Repository
export 'src/repositories/at_event_repository.dart';

// Sync
export 'src/sync/at_sync_service.dart';

// Constants
export 'src/lexicon_nsids.dart';
