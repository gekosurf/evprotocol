/// EV Protocol Veilid — Concrete implementations of ev_protocol interfaces.
///
/// This package provides:
/// - SQLite (Drift) persistence for offline-first SSOT
/// - Veilid DHT for decentralised sync
/// - Background sync service
library;

export 'src/ev_protocol_veilid_base.dart';
export 'src/db/app_database.dart';
export 'src/db/tables/cached_events.dart';
export 'src/db/tables/cached_rsvps.dart';
export 'src/db/tables/local_identities.dart';
export 'src/db/tables/sync_queue.dart';

// Sync layer
export 'src/sync/veilid_node_interface.dart';
export 'src/sync/mock_veilid_node.dart';
// real_veilid_node.dart — requires `veilid` FFI package (disabled for simulator)
export 'src/sync/veilid_sync_service.dart';

// Seed data
export 'src/data/seed_events.dart';
export 'src/data/seed_data_service.dart';

// Crypto
// veilid_crypto_service.dart — requires `veilid` FFI package (disabled for simulator)
