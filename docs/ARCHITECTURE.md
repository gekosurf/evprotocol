# Sailor App — Architecture & Handover Document

> **Last Updated:** 2026-04-07  
> **GitHub:** [gekosurf/evprotocol](https://github.com/gekosurf/evprotocol)  
> **Flutter:** 3.41.6 / Dart 3.11.4  
> **Target:** iOS (Flutter)

---

## 1. Monorepo Structure

```
evprotocol/
├── docs/
│   ├── ev-protocol-spec-v0.1.md    ← Full protocol spec (Lexicon schemas, DHT layout)
│   ├── p2p-notes.md                ← Research notes on P2P approaches
│   └── ARCHITECTURE.md             ← THIS FILE
├── packages/
│   ├── ev_protocol/                ← Pure Dart protocol interfaces (ZERO deps)
│   │   ├── lib/src/
│   │   │   ├── core/               ← EvDhtKey, EvPubkey, EvTimestamp, EvResult
│   │   │   ├── identity/           ← EvIdentity, EvIdentityService
│   │   │   ├── event/              ← EvEvent, EvRsvp, EvEventService
│   │   │   ├── group/              ← EvGroup, EvVessel, EvGroupService
│   │   │   ├── chat/               ← EvChatChannel, EvChatMessage
│   │   │   ├── payment/            ← EvPaymentIntent, EvTicket, EvPaymentReceipt
│   │   │   ├── media/              ← EvMediaReference, EvMediaService
│   │   │   ├── search/             ← EvSearchResult, EvSearchService
│   │   │   ├── moderation/         ← EvModerationReport, EvModerationAction
│   │   │   ├── sync/               ← EvSyncService (abstract)
│   │   │   ├── schema/             ← EvLexicon, EvSchemaValidator
│   │   │   └── sailing/            ← EvRace, EvCourse, EvTrack (extension)
│   │   └── test/                   ← 119 tests, 100% pass
│   │
│   └── ev_protocol_veilid/         ← Implementation layer (Drift + Veilid)
│       ├── lib/src/
│       │   ├── db/
│       │   │   ├── app_database.dart       ← Drift DB with 4 tables
│       │   │   ├── app_database.g.dart     ← Generated (build_runner)
│       │   │   └── tables/
│       │   │       ├── local_identities.dart
│       │   │       ├── cached_events.dart
│       │   │       ├── cached_rsvps.dart
│       │   │       └── sync_queue.dart
│       │   ├── sync/
│       │   │   ├── veilid_node_interface.dart  ← Abstract DHT operations
│       │   │   ├── mock_veilid_node.dart       ← Dev mock (configurable failures)
│       │   │   └── veilid_sync_service.dart    ← EvSyncService implementation
│       │   └── ev_protocol_veilid_base.dart
│       └── test/                   ← 22 tests, 100% pass
│
└── apps/
    └── sailor/                     ← Flutter iOS app
        ├── lib/
        │   ├── main.dart           ← Entry point (ProviderScope)
        │   ├── app.dart            ← MaterialApp.router with theme
        │   ├── core/
        │   │   ├── db/
        │   │   │   └── database_provider.dart  ← Riverpod Provider<AppDatabase>
        │   │   ├── sync/
        │   │   │   └── sync_provider.dart      ← VeilidSyncService + pending count
        │   │   ├── router/
        │   │   │   └── app_router.dart         ← GoRouter + auth redirect
        │   │   └── theme/
        │   │       ├── app_colors.dart          ← Black/Yellow palette
        │   │       ├── app_text_styles.dart      ← Inter typography
        │   │       └── app_theme.dart            ← ThemeData composition
        │   ├── shared/widgets/
        │   │   └── ev_overlays.dart              ← showEvDialog, showEvBottomSheet
        │   └── features/
        │       ├── auth/
        │       │   ├── domain/
        │       │   │   ├── repositories/auth_repository.dart  ← Abstract
        │       │   │   └── usecases/auth_usecases.dart
        │       │   ├── data/
        │       │   │   └── repositories/
        │       │   │       ├── stub_auth_repository.dart      ← In-memory (deprecated)
        │       │   │       └── drift_auth_repository.dart     ← SQLite-backed (ACTIVE)
        │       │   └── presentation/
        │       │       ├── providers/auth_providers.dart
        │       │       └── pages/
        │       │           ├── welcome_page.dart
        │       │           ├── create_identity_page.dart
        │       │           └── backup_key_page.dart
        │       ├── events/
        │       │   ├── domain/
        │       │   │   ├── repositories/event_repository.dart ← Abstract + EventPage
        │       │   │   └── usecases/event_usecases.dart
        │       │   ├── data/
        │       │   │   └── repositories/
        │       │   │       ├── stub_event_repository.dart     ← Mock data (deprecated)
        │       │   │       └── drift_event_repository.dart    ← SQLite-backed (ACTIVE)
        │       │   └── presentation/
        │       │       ├── providers/event_providers.dart
        │       │       ├── widgets/
        │       │       │   ├── event_card.dart
        │       │       │   └── rsvp_bottom_sheet.dart
        │       │       └── pages/
        │       │           ├── event_list_page.dart
        │       │           ├── event_detail_page.dart
        │       │           └── create_event_page.dart
        │       ├── profile/
        │       │   └── presentation/pages/profile_page.dart
        │       └── home/
        │           └── presentation/pages/home_page.dart     ← Legacy, unused
        └── analysis_options.yaml   ← 33 clean_architecture_linter rules

```

---

## 2. Architecture Pattern

### Clean Architecture (Strictly Enforced)

```
┌──────────────────────────────────────────────────────┐
│  PRESENTATION (Pages, Widgets, Riverpod Providers)   │
│  • NO business logic — lint enforced                 │
│  • GoRouter with auth redirect guard                 │
│  • AsyncNotifierProvider for list/create state        │
├──────────────────────────────────────────────────────┤
│  DOMAIN (UseCases, Repository Interfaces, Entities)  │
│  • Pure Dart — NO Flutter or framework imports       │
│  • Abstract repository interfaces only               │
│  • Validation lives here (name length, date order)   │
├──────────────────────────────────────────────────────┤
│  DATA (Repository Implementations, Datasources)      │
│  • Drift repos → write to SQLite + queue to SyncQueue│
│  • Maps Drift row types ↔ ev_protocol domain models  │
│  • Zero protocol knowledge — just persistence logic  │
└──────────────────────────────────────────────────────┘
```

**33 automated lint rules** via `clean_architecture_linter` package enforce these boundaries at compile time.

### Offline-First Write Pattern

Every mutation follows this flow:

```
User Action → Repository → SQLite (immediate) → SyncQueue row → [Background] → Veilid DHT
```

The `DriftEventRepository.createEvent()` does this in a single Drift transaction:
1. INSERT into `CachedEvents`
2. INSERT into `SyncQueue` with `operation: 'create'`, `status: 'pending'`
3. Return the `EvEvent` immediately (no network wait)

---

## 3. Database Schema (Drift / SQLite)

Defined in `packages/ev_protocol_veilid/lib/src/db/tables/`:

### LocalIdentities
| Column | Type | Notes |
|--------|------|-------|
| id | int | autoIncrement PK |
| pubkey | text | unique, hex-encoded |
| displayName | text | |
| bio | text? | nullable |
| avatarUrl | text? | nullable |
| encryptedPrivateKey | text? | backup phrase |
| createdAt | dateTime | |
| isActive | bool | default true |

### CachedEvents
| Column | Type | Notes |
|--------|------|-------|
| id | int | autoIncrement PK |
| dhtKey | text | unique |
| creatorPubkey | text | |
| name | text | |
| description | text? | |
| startAt | dateTime | |
| endAt | dateTime? | |
| locationName, locationAddress, latitude, longitude, geohash | mixed | nullable location fields |
| category | text? | |
| tags | text | comma-separated |
| visibility | text | enum name |
| rsvpCount | int | default 0 |
| maxCapacity | int? | |
| groupDhtKey | text? | |
| ticketingJson | text? | full EvTicketing as JSON |
| createdAt | dateTime | |
| updatedAt | dateTime? | |
| lastSyncedAt | dateTime | |
| isDirty | bool | default false |
| evVersion | text? | |

### CachedRsvps
| Column | Type | Notes |
|--------|------|-------|
| id | int | autoIncrement PK |
| eventDhtKey | text | |
| attendeePubkey | text | |
| status | text | EvRsvpStatus name |
| guestCount | int | default 0 |
| createdAt | dateTime | |
| lastSyncedAt | dateTime | |
| isDirty | bool | default false |

### SyncQueue
| Column | Type | Notes |
|--------|------|-------|
| id | int | autoIncrement PK |
| operation | text | 'create', 'update', 'delete' |
| recordType | text | 'identity', 'event, 'rsvp', etc. |
| localRecordId | int | FK to source table |
| dhtKey | text? | null for creates |
| payload | text | JSON blob |
| retryCount | int | default 0 |
| lastError | text? | |
| queuedAt | dateTime | |
| lastAttemptAt | dateTime? | |
| completedAt | dateTime? | when successfully synced |
| status | text | 'pending', 'processing', 'failed', 'completed' |

---

## 4. Theme / Design System

| Token | Value |
|-------|-------|
| Scaffold BG | `#000000` (pure black) |
| Card BG | `#0D0D0D` |
| Surface BG | `#1A1A1A` |
| Overlay | `#000000` @ 50% opacity |
| Highlight | `#FFD600` (yellow) |
| Highlight Dim | `#FBC02D` |
| Text Primary | `#FFFFFF` |
| Text Secondary | `#B0B0B0` |
| Text Tertiary | `#707070` |
| Text on Highlight | `#000000` |
| Success | `#4CAF50` |
| Error | `#EF5350` |
| Warning | `#FFA726` |
| Typography | Inter font family |

---

## 5. Dependency Graph

```
sailor (Flutter app)
  ├─ ev_protocol          (pure Dart — interfaces & models)
  ├─ ev_protocol_veilid   (Drift DB + future Veilid DHT)
  ├─ flutter_riverpod     (state management)
  ├─ go_router            (routing)
  ├─ drift                (SQLite ORM)
  ├─ sqlite3_flutter_libs (native SQLite binaries)
  ├─ path_provider        (app documents directory)
  └─ clean_architecture_linter (33 lint rules)

ev_protocol_veilid
  ├─ ev_protocol          (depends on core package)
  ├─ drift                (code generation)
  └─ sqlite3_flutter_libs

ev_protocol
  └─ (no dependencies — pure Dart)
```

---

## 6. Routes

| Path | Page | Auth Required |
|------|------|--------------|
| `/welcome` | WelcomePage | No |
| `/create-identity` | CreateIdentityPage | No |
| `/backup-key` | BackupKeyPage | No |
| `/` | EventListPage (home) | Yes |
| `/event/:id` | EventDetailPage | Yes |
| `/create-event` | CreateEventPage | Yes |
| `/profile` | ProfilePage | Yes |

GoRouter redirect guard: unauthenticated users → `/welcome`.

---

## 7. Key Protocol Types (ev_protocol)

| Type | Description |
|------|-------------|
| `EvEvent` | Event with name, datetime, location, tags, ticketing, visibility |
| `EvRsvp` | RSVP with status enum: `pending`, `confirmed`, `waitlisted`, `cancelled`, `declined` |
| `EvIdentity` | User identity with pubkey, displayName, bio |
| `EvDhtKey` | Wrapper for DHT record keys |
| `EvPubkey` | Wrapper for public keys |
| `EvTimestamp` | ISO 8601 timestamp wrapper |
| `EvResult<T>` | Result type (`EvSuccess<T>` / `EvFailure`) |
| `EvSyncService` | Abstract sync interface (startSync, stopSync, syncNow, pendingSyncCount) |
| `EvTicketing` | Ticketing model with EvTicketModel (`free`, `fixed`, `donation`, `external`) |

---

## 8. Current State & What Works

### ✅ Fully Working
- Auth onboarding flow (Welcome → Create Identity → Backup Key → Home)
- Identity persists in SQLite across hot restarts
- Event list with 0 events (empty state) — user can create events
- Event creation with date/time pickers → writes to SQLite + SyncQueue
- Event detail view with RSVP bottom sheet (Going/Maybe/Not Going)
- Profile page with pubkey copy, backup key view, delete identity
- **Background sync service** — processes SyncQueue every 5s via MockVeilidNode
- **Live sync status** on Profile page (Synced / Syncing / Offline)
- GoRouter auth redirect (no identity → welcome page)
- All 141 tests pass (119 ev_protocol + 22 ev_protocol_veilid)
- Drift codegen is generated and committed

### ⚠️ Known Issues
- **No seed data**: The old 6 stub events are gone now that DriftEventRepository is active. The event list starts empty — user must create events manually.
- **Fake keypair**: `DriftAuthRepository` generates random hex strings, not real Veilid keypairs.
- **`home_page.dart`** is a legacy placeholder — unused, can be deleted.

---

## 9. Completed: Phase 8 — Background Sync Service

### Architecture

```
User Action → Repository → SQLite + SyncQueue → [5s Timer] → VeilidNodeInterface → DHT
                                                     ↑                    ↑
                                              VeilidSyncService     MockVeilidNode (dev)
                                                                    RealVeilidNode (future)
```

### Implementation

| File | Role |
|------|------|
| `veilid_node_interface.dart` | Abstract DHT operations: `publishRecord`, `getRecord`, `deleteRecord`, `isOnline` |
| `mock_veilid_node.dart` | Dev mock — configurable `failureRate`, deterministic `seed`, console logging |
| `veilid_sync_service.dart` | Implements `EvSyncService` — 5s periodic sync, exponential backoff (5 retries), 24h completed retention |
| `sync_provider.dart` | Riverpod providers: `syncServiceProvider`, `pendingSyncCountProvider`, `syncEventsProvider` |
| `profile_page.dart` | Live sync status indicator (🟢 Synced / 🟡 Syncing / 🔴 Offline) |

### Key Design Decision
> The `VeilidNodeInterface` abstraction means the entire queue-processing, retry, and status-tracking logic works without compiling Veilid's Rust FFI. When ready, swap `MockVeilidNode` for `RealVeilidNode` — one line change in `sync_provider.dart`.

---

## 10. Future Features (Not Started)

| Feature | Notes |
|---------|-------|
| Group/Club management | `EvGroup`, `EvVessel` models exist in protocol |
| Chat | `EvChatChannel`, `EvChatMessage` models exist |
| Sailing race tracking | `EvRace`, `EvCourse`, `EvTrack` extension models exist |
| Media uploads | `EvMediaReference` for event photos |
| Event search | `EvSearchService` interface defined |
| Payment/ticketing | `EvPaymentIntent`, `EvTicket`, `EvPaymentReceipt` exist |
| Moderation | Content reporting and actions |
| Real Veilid integration | Replace mock with `veilid_flutter` package |

---

## 11. Commands Reference

```bash
# Run the app
cd apps/sailor && flutter run

# Run ev_protocol tests
cd packages/ev_protocol && dart test

# Run ev_protocol_veilid tests
cd packages/ev_protocol_veilid && dart test

# Regenerate Drift code (after changing table definitions)
cd packages/ev_protocol_veilid && dart run build_runner build --delete-conflicting-outputs

# Analyze all packages
cd apps/sailor && dart analyze
cd packages/ev_protocol && dart analyze
cd packages/ev_protocol_veilid && dart analyze

# Auto-fix lint issues
cd apps/sailor && dart fix --apply
```

---

## 12. Git History

```
44f8101 update
dad622f feat: complete Drift integration and UI wiring
f9d8a1d fix: restore EvProtocolVeilid export + codegen output
566eb43 feat: add Drift database schema for offline-first SSOT
1d71e83 feat: add Events feature with list, detail, and create pages
ef322bb chore: add all platform targets from flutter create
b515a7e feat: scaffold Sailor app + ev_protocol_veilid package
3ddbdff test: 119 tests with ~100% coverage of all testable code
25ea2f7 feat: EV Protocol v0.1 — spec, docs, and Dart interfaces
```
