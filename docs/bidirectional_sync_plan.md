# Bidirectional DHT Event Sync

## Problem Statement

Cross-device event sync is currently **one-directional**. The iPhone can announce events to the shared registry, and the macOS can read them. But the macOS **cannot** write its events back to the registry.

### Root Cause

The registry DHT record uses `DHTSchema.dflt(oCnt: 1)` — a single-owner schema. In Veilid, **only the key pair that created a DFLT record can write to it**. The macOS node has a different key pair, so `setDHTValue` returns `VeilidAPIException: Generic (message: value is not writable)`.

This is not a bug — it's a fundamental constraint of Veilid's DHT ownership model.

### What IS Working (Confirmed)

| Feature | Status |
|---------|--------|
| iPhone → DHT publish | ✅ Events published to DHT records |
| iPhone → Registry announce | ✅ Event keys appended to registry |
| macOS → Registry read | ✅ Discovers iPhone's event keys |
| macOS → DHT fetch | ✅ Fetches event payload from iPhone's DHT records |
| macOS → Local cache | ✅ Stores events in SQLite (`getMyEvents returning 13 rows`) |
| macOS → Registry write | ❌ **`value is not writable`** |
| UI shows all events | ✅ Fixed this session (removed `creatorPubkey` filter) |
| RSVP upsert | ✅ Fixed this session (correct conflict target) |
| macOS scrolling | ✅ Fixed this session (custom ScrollBehavior) |

---

## Proposed Solution: Per-Device Announcement Records

Replace the single shared registry with **per-device announcement records**. Each device creates and owns its own DHT record containing a list of its event keys. Devices discover peers by exchanging announcement keys.

### Architecture

```
┌──────────────┐                    ┌──────────────┐
│   iPhone     │                    │   macOS      │
│              │                    │              │
│ Announce Rec │◄── reads ──────────│              │
│ [evt1, evt2] │                    │              │
│              │                    │ Announce Rec │
│              │──────── reads ────►│ [evt3, evt4] │
│              │                    │              │
│ peers table: │                    │ peers table: │
│  macOS key   │                    │  iPhone key  │
└──────────────┘                    └──────────────┘
```

**Key insight**: Each device writes ONLY to its own announcement record (always writable). Discovery means reading ALL known peer announcement records.

---

## Proposed Changes

### 1. New SQLite Table: `known_peers`

#### [NEW] `packages/ev_protocol_veilid/lib/src/db/tables/known_peers.dart`

```dart
class KnownPeers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get announcementKey => text().withLength(min: 1)();
  TextColumn get label => text().nullable()();       // "iPhone", "macOS", etc.
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [{announcementKey}];
}
```

Register in `AppDatabase` tables list and regenerate drift code.

---

### 2. Refactor `RealVeilidNode`

#### [MODIFY] `real_veilid_node.dart`

**Remove**: `registryKey` constructor parameter, `_getOrCreateRegistryKey()`

**Add**:
- `_announcementKeyStr` — this device's own announcement record key (persisted locally)
- `_getOrCreateAnnouncementKey()` — creates this device's own DHT record (always writable)
- `_peerAnnouncementKeys` — list of peer announcement keys loaded from SQLite

**Change `announceRecord()`**:
- Write to **this device's own** announcement record (always succeeds)

**Change `discoverRecords()`**:
- Read from **all known peer** announcement records
- Merge the event key lists and return deduplicated results

---

### 3. Peer Management

#### [MODIFY] `VeilidSyncService`

Add methods:
- `addPeer(String announcementKey, {String? label})` — insert into `known_peers`
- `removePeer(String announcementKey)` — delete from `known_peers`
- `listPeers()` — query all known peers

Load peer keys on startup and pass them to the node for discovery.

---

### 4. Update `main.dart`

#### [MODIFY] `apps/sailor/lib/main.dart`

**Remove**: hardcoded `registryKey` string

**Add**: Load peer announcement keys from the database on startup, inject into `RealVeilidNode`. Log this device's own announcement key for manual sharing.

---

### 5. Cleanup: Remove diagnostic logging

Remove the `[DB] 📊` diagnostic prints from `drift_event_repository.dart` after testing.

---

## User Review Required

> [!IMPORTANT]
> **Peer key exchange**: For the initial version, devices will need to manually share announcement keys (copy from logs, paste into a settings screen). Future versions could use QR codes or a local network broadcast. Is this acceptable for now?

> [!IMPORTANT]
> **Seed events**: The 6 seed events with `dhtKey=seed-event-*` are local-only fixtures. They won't sync via DHT (they're not real DHT records). Should they remain as demo data?

---

## Open Questions

1. Should we add a simple "Add Peer" UI (settings page with a text field), or is log-copy-paste sufficient for now?
2. Should the announcement key be persisted in SQLite or in shared_preferences? (I recommend SQLite via the existing `local_identities` table.)

---

## Verification Plan

### Automated
- `dart analyze` passes on both packages
- Existing tests pass

### Manual Cross-Device Test
1. Start iPhone app → note announcement key from logs
2. Start macOS app → note announcement key from logs
3. Add iPhone's key to macOS via addPeer / Add macOS's key to iPhone
4. Create event on iPhone → verify it appears on macOS within 10s
5. Create event on macOS → verify it appears on iPhone within 10s
