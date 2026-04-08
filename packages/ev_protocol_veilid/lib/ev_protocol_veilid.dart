/// EV Database — Drift (SQLite) persistence layer.
///
/// Provides:
/// - AppDatabase with cached events, RSVPs, identities, sync queue
/// - Seed data for development
///
/// Post-cleanup: removed Veilid sync, crypto, and node management.
/// This package is now a pure Drift database layer with no network deps.
library;

// Database
export 'src/db/app_database.dart';
export 'src/db/tables/cached_events.dart';
export 'src/db/tables/cached_rsvps.dart';
export 'src/db/tables/local_identities.dart';
export 'src/db/tables/sync_queue.dart';

// Seed data
export 'src/data/seed_events.dart';
export 'src/data/seed_data_service.dart';
