# Option C — AT Protocol Implementation Plan

> A spike-first, lessons-applied plan for replacing Veilid transport with AT Protocol.
> Every phase has a kill criterion. No aspirational interfaces. No multi-month roadmaps for unvalidated tech.
>
> *Created: 2026-04-08*

---

## Lessons Applied

This plan was written with the [post-mortem](./lessons-learned-why-claude-over-prommised-and-under-evaluated.md) open. Each section references the specific failure mode it avoids.

| Lesson | How It's Applied Here |
|--------|-----------------------|
| **Spike before you spec** | Phase 0 is a 2-day spike with real `atproto.dart` code. No interfaces written until the spike passes. |
| **RSVP test first** | The spike's pass/fail gate IS the RSVP test. If it fails, Option C is dead. |
| **1 page per decision** | This entire plan is one document. No companion research docs. |
| **Score on buildability** | Every phase ends with running code, not diagrams. |
| **Kill the darlings** | Phase 1 deletes the 9 dead service interfaces before writing a single line of AT code. |
| **No breadth exploration** | We use ONE SDK (`atproto.dart`), ONE PDS (`bsky.social`). Two Lexicon namespaces: Smoke Signal (events/RSVPs) + Sailor-owned (positions/photos). No alternatives evaluated. |
| **Competitive awareness** | Sailor targets Layer 3 (day-to-day coordination) for sailing clubs. Yacht tracking + photo exchange are the differentiators Spond can't match. AT Protocol is chosen for ecosystem interop AND because its blob storage + custom Lexicons natively support these features. |

---

## The RSVP Test (Kill Criterion for Phase 0)

```
Alice creates an event on Device A.
Bob discovers the event on Device B.
Bob RSVPs "going."
Alice sees Bob's RSVP on her event.

Pass criteria:
  - No manual key exchange
  - < 10 seconds end-to-end
  - Uses real PDS (bsky.social), not mocks
  - Uses Smoke Signal Lexicon schemas
```

If this test fails with `atproto.dart` + `bsky.social` PDS, **stop. Re-evaluate Option B.**

---

## What We Keep, What We Kill, What We Build

### ✅ Keep (works today, transport-agnostic)

| Component | Path | Why |
|-----------|------|-----|
| Sailor UI pages | `apps/sailor/lib/features/events/presentation/` | 3 working pages: list, detail, create |
| Sailor UI shell | `apps/sailor/lib/features/shell/` | Bottom nav, routing, theme |
| Drift SQLite DB | `packages/ev_protocol_veilid/lib/src/db/` | 4 tables, working migrations — reuse as offline cache |
| Domain repo interface | `apps/sailor/lib/features/events/domain/repositories/event_repository.dart` | Clean abstract contract (83 lines) |
| Riverpod providers | `apps/sailor/lib/features/events/presentation/providers/` | State management wiring |
| GoRouter config | `apps/sailor/lib/core/router/` | Navigation |
| Theme system | `apps/sailor/lib/core/theme/` | Dark mode, design tokens |
| Core models (EvEvent, EvRsvp) | `packages/ev_protocol/lib/src/event/` | Data shape ~80% reusable — adapt to Smoke Signal Lexicon |
| Core types (EvTimestamp, EvResult) | `packages/ev_protocol/lib/src/core/` | Generic utilities |

### 🗑️ Kill (zero implementations, zero consumers)

| Component | Lines | Reason |
|-----------|:-----:|--------|
| `EvChatService` + models | ~200 | No implementation, no consumer. Veilid can't do multi-writer channels. AT Protocol DMs are a future concern. |
| `EvGroupService` + models | ~200 | Not used by Sailor. Build later IF needed. |
| `EvMediaService` + model | ~100 | Not used. AT Protocol has blob storage built in. |
| `EvPaymentService` + models | ~280 | Not used. Stripe integration is a product decision, not a protocol one. |
| `EvModerationService` + models | ~180 | Not used. AT Protocol has labelers. |
| `EvSearchService` + model | ~150 | Not used. Smoke Signal AppView handles search. |
| `EvSchemaValidator` | ~80 | Not used. PDS validates against Lexicon natively. |
| `EvLexiconRegistry` | ~160 | Not used. Lexicons are defined by Smoke Signal, not by us. |
| `EvSailingService` + models | ~300 | Not used. Build sailing features in the app, not in an abstract protocol layer. |
| `EvIdentityService` | ~100 | Replaced by AT Protocol DID + OAuth. |
| `EvIdentityBridge` | ~50 | Replaced by AT Protocol session. |
| `VeilidSyncService` | ~500 | Replaced by AT Protocol PDS XRPC calls. |
| `RealVeilidNode` / `MockVeilidNode` | ~400 | Veilid transport is dead. |
| `VeilidCryptoService` | ~200 | AT Protocol handles signing. |
| **Total deleted** | **~2,900** | This is the "aspirational API surface" the post-mortem identified. |

### 🔨 Build (new, AT Protocol-specific)

| Component | Purpose | Estimated Lines |
|-----------|---------|:---------------:|
| `ev_protocol_at` package | New transport package — AT Protocol XRPC client wrapper | ~400 |
| `AtAuthService` | OAuth 2.0 DPoP session management via `atproto.dart` | ~150 |
| `AtEventRepository` | `EventRepository` impl that reads/writes to PDS + Smoke Signal AppView | ~300 |
| `AtSyncService` | Offline-first: local SQLite writes → background PDS push | ~250 |
| Smoke Signal Lexicon models | Dart classes matching `events.smokesignal.calendar.event` / `.rsvp` schemas | ~200 |
| Sailor Lexicon models | `au.sailor.yacht.position` + `au.sailor.photo` records (see schemas below) | ~250 |
| `PositionService` | GPS capture → batch buffer → PDS upload, offline queue | ~300 |
| `PhotoService` | Camera/gallery → PDS blob upload → photo record creation | ~250 |
| Auth UI (login page) | AT Protocol handle + app password or OAuth flow | ~200 |
| Discover page (network events) | Query Smoke Signal AppView for nearby/recent events | ~200 |
| Yacht tracking UI | Map view with live positions for event participants | ~350 |
| Photo gallery UI | Grid/carousel of event photos, upload FAB | ~300 |
| **Total new code** | | **~3,150** |

---

## Architecture After Migration

```
┌────────────────────────────────────────────────────────────────┐
│                         Sailor App                             │
│                                                                │
│  ┌──────────┐ ┌────────┐ ┌───────────┐ ┌─────────┐ ┌────────┐│
│  │ Event UI │ │RSVP UI │ │Discover UI│ │Track UI │ │Photo UI││
│  └────┬─────┘ └───┬────┘ └─────┬─────┘ └────┬────┘ └───┬────┘│
│       │           │            │             │          │     │
│  ┌────▼───────────▼────────────▼─────────────▼──────────▼───┐ │
│  │                  Riverpod Providers                      │ │
│  └────┬────────────────────────┬────────────────────────────┘ │
│       │                        │                              │
│  ┌────▼───────────────┐  ┌─────▼───────────────────────────┐  │
│  │ EventRepository    │  │ PositionService / PhotoService  │  │
│  │ (abstract)         │  │ (concrete — Sailor Lexicon)     │  │
│  └────┬───────────────┘  └─────┬───────────────────────────┘  │
│       │                        │                              │
│  ┌────▼───────────────┐  ┌─────▼───────────────────────────┐  │
│  │ AtEventRepository  │  │ GPS buffer → PDS batch upload   │  │
│  │ (Smoke Signal)     │  │ Camera → PDS blob + record      │  │
│  └────┬──────┬────────┘  └─────┬───────────────────────────┘  │
│       │      │                 │                              │
│  ┌────▼──┐ ┌─▼─────────────────▼──────────────┐               │
│  │ Drift │ │ atproto.dart SDK                  │               │
│  │SQLite │ │ ├── PDS XRPC (records + blobs)    │               │
│  │(cache)│ │ ├── OAuth / AppPwd                │               │
│  └───────┘ │ └── Smoke Signal AppView API      │               │
│            └──────────────────────────────────┘               │
└────────────────────────────────────────────────────────────────┘

External:
  ┌────────────┐     ┌──────────────────┐
  │  User PDS  │────▶│ Relay (firehose)  │
  │ bsky.social│     └───────┬──────────┘
  └────────────┘             │
                    ┌────────▼──────────┐
                    │ Smoke Signal      │
                    │ AppView           │
                    │ (event index,     │
                    │  RSVP aggregation,│
                    │  search)          │
                    └───────────────────┘

Lexicon Namespaces:
  events.smokesignal.calendar.*  → Events + RSVPs (interop with Smoke Signal ecosystem)
  au.sailor.yacht.*              → Position tracking (Sailor-owned, sailing-specific)
  au.sailor.photo                → Event photos    (Sailor-owned, sailing-specific)
```

### Data Flow: The RSVP Test, Solved

```
1. Alice logs in → AT Protocol OAuth → session stored locally
2. Alice creates event → write to local SQLite → XRPC createRecord to PDS
   Collection: events.smokesignal.calendar.event
   Result: at://did:plc:alice/events.smokesignal.calendar.event/3kt5abc

3. PDS → Relay → Smoke Signal AppView indexes event

4. Bob opens Discover tab → queries Smoke Signal AppView → sees Alice's event

5. Bob RSVPs → write to local SQLite → XRPC createRecord to Bob's PDS
   Collection: events.smokesignal.calendar.rsvp
   Record: { eventUri: "at://did:plc:alice/.../3kt5abc", status: "going" }

6. Bob's PDS → Relay → Smoke Signal AppView → increments RSVP count

7. Alice views her event → AppView returns RSVP list including Bob → DONE ✅
```

**Why this works and Veilid didn't**: The Smoke Signal AppView acts as the index. It consumes the firehose, sees Bob's RSVP record referencing Alice's event URI, and builds the reverse lookup. No manual key exchange. No polling. Standard HTTP queries.

### Sailing-Specific Data Schemas (Sailor Lexicon)

These use Sailor's own namespace (`au.sailor.*`), not Smoke Signal's. We own these schemas. They're stored in each user's PDS alongside Smoke Signal event/RSVP records.

#### `au.sailor.yacht.position` — GPS Position Record

```json
{
  "lexicon": 1,
  "id": "au.sailor.yacht.position",
  "defs": {
    "main": {
      "type": "record",
      "description": "A batch of yacht GPS positions during a sailing event.",
      "key": "tid",
      "record": {
        "type": "object",
        "required": ["eventUri", "positions", "createdAt"],
        "properties": {
          "eventUri": {
            "type": "string",
            "format": "at-uri",
            "description": "The AT URI of the event this position data belongs to."
          },
          "boatName": {
            "type": "string",
            "maxLength": 100,
            "description": "Display name of the yacht (e.g. sail number or boat name)."
          },
          "positions": {
            "type": "array",
            "maxLength": 100,
            "items": { "type": "ref", "ref": "#positionPoint" },
            "description": "Batch of GPS points. Buffered on-device, uploaded in chunks."
          },
          "createdAt": {
            "type": "string",
            "format": "datetime"
          }
        }
      }
    },
    "positionPoint": {
      "type": "object",
      "required": ["latitude", "longitude", "timestamp"],
      "properties": {
        "latitude": { "type": "number" },
        "longitude": { "type": "number" },
        "timestamp": {
          "type": "string",
          "format": "datetime",
          "description": "When this GPS fix was captured."
        },
        "speedKnots": {
          "type": "number",
          "description": "Speed over ground in knots."
        },
        "headingDeg": {
          "type": "number",
          "description": "Heading in degrees true north (0-360)."
        },
        "accuracy": {
          "type": "number",
          "description": "Horizontal accuracy in metres."
        }
      }
    }
  }
}
```

**Design decisions**:
- **Batched, not real-time**: GPS points are buffered on-device (every 5–10s) and uploaded as a batch record (every 60s or when connectivity allows). This is offshore-friendly — works with intermittent signal.
- **100 points per record**: At 10s intervals, one record covers ~16 minutes. A 3-hour race produces ~11 records per yacht. Well within PDS storage and the 1MB record size limit.
- **eventUri links to Smoke Signal event**: Position data is anchored to an event, so any client can aggregate positions per-event by querying PDS repos for `au.sailor.yacht.position` records referencing a given event URI.
- **No tracking without event context**: Positions only exist tied to an event. No ambient surveillance.

#### `au.sailor.photo` — Event Photo Record

```json
{
  "lexicon": 1,
  "id": "au.sailor.photo",
  "defs": {
    "main": {
      "type": "record",
      "description": "A photo taken during a sailing event.",
      "key": "tid",
      "record": {
        "type": "object",
        "required": ["eventUri", "image", "createdAt"],
        "properties": {
          "eventUri": {
            "type": "string",
            "format": "at-uri",
            "description": "The AT URI of the event this photo belongs to."
          },
          "image": {
            "type": "blob",
            "accept": ["image/jpeg", "image/png", "image/webp", "image/heic"],
            "maxSize": 5000000,
            "description": "The photo blob (max 5MB). PDS blob limit is 50MB — 5MB gives headroom for full-res iPhone photos while keeping uploads feasible on marina Wi-Fi."
          },
          "caption": {
            "type": "string",
            "maxLength": 500
          },
          "location": {
            "type": "ref",
            "ref": "#geoTag"
          },
          "createdAt": {
            "type": "string",
            "format": "datetime"
          }
        }
      }
    },
    "geoTag": {
      "type": "object",
      "properties": {
        "latitude": { "type": "number" },
        "longitude": { "type": "number" }
      }
    }
  }
}
```

**Design decisions**:
- **PDS blob storage**: AT Protocol PDS has native blob upload (`com.atproto.repo.uploadBlob`). The per-blob limit is **50MB** on standard PDS instances. Photos are uploaded as blobs, then the CID is referenced in the record. No separate media server needed.
- **5MB max**: iPhone photos are typically 3–8MB (HEIC) or 2–5MB (JPEG). A 5MB cap allows full-resolution uploads without aggressive compression. This is well within the 50MB PDS blob limit and reasonable for marina Wi-Fi (~30s upload at 1.5 Mbps).
- **eventUri anchor**: Every photo is linked to an event. Query all participants' PDS repos for `au.sailor.photo` records referencing a given event → full event photo gallery from all attendees.
- **Offline capture**: Photos are taken and cached locally with SQLite + file system. Uploaded when connectivity returns. Same pattern as position batches.
- **Blob re-upload on retry**: If the app uploads a blob but the record creation fails (network drop), the PDS garbage-collects the unreferenced blob after ~1 hour. The offline queue must re-upload the blob when retrying, not assume it persists.

### Data Flow: Yacht Tracking During a Race

```
1. Race event exists: at://did:plc:alice/events.smokesignal.calendar.event/3kt5abc

2. Bob joins race → enables tracking in Sailor app
   - App starts iOS location updates (background mode)
   - GPS points buffered in local SQLite: [{lat, lng, timestamp, speed, heading}, ...]

3. Every 60 seconds (or when signal available):
   - Batch of buffered points → XRPC createRecord to Bob's PDS
   Collection: au.sailor.yacht.position
   Record: { eventUri: "at://...alice.../3kt5abc", boatName: "AU 5432", positions: [...], createdAt: "..." }

4. Alice (race officer) opens tracking view:
   - Queries known participants' PDS repos for au.sailor.yacht.position records with matching eventUri
   - Renders positions on a map as yacht tracks
   - Refreshes periodically (pull or timer)

5. Race ends → Bob stops tracking → no more position records created
```

### Data Flow: Photo Exchange at an Event

```
1. Event exists: at://did:plc:alice/events.smokesignal.calendar.event/3kt5abc

2. Carol takes a photo on the water:
   - Saved to local cache (SQLite row + compressed image file)
   - If online: upload blob → get CID → createRecord(au.sailor.photo)
   - If offline: queued for upload when connectivity returns

3. Later at the clubhouse:
   - Alice opens event → Photo tab
   - App queries known event participants' PDS repos for au.sailor.photo with matching eventUri
   - All photos from all participants appear in a shared gallery
   - Anyone can save/share any photo from the event
```

---

## Phases

### Phase 0: Spike (2 days) — VALIDATE BEFORE BUILDING

> *Lesson: "A 2-hour spike with `atproto.dart` creating and reading an event record would have been worth more than the entire 691-line comparison doc."*

**Goal**: Run the RSVP test against real infrastructure. Throwaway code only.

**Day 1: Auth + Event Write**
```
□ Create 2 test accounts on bsky.social (alice-test, bob-test)
□ Generate app passwords for both
□ Write a Dart CLI script (NOT in Sailor app) that:
    1. Authenticates as alice-test via atproto.dart
    2. Creates an event record in alice's PDS repo:
       Collection: events.smokesignal.calendar.event
       Payload: { name: "Spike Test", startsAt: "...", createdAt: "..." }
    3. Prints the resulting at:// URI
□ Verify the record exists:
    GET /xrpc/com.atproto.repo.getRecord?repo=alice-test&collection=events.smokesignal.calendar.event&rkey=...
```

**Day 2: RSVP + Discovery**
```
□ Authenticate as bob-test
□ Create an RSVP record in bob's PDS repo:
   Collection: events.smokesignal.calendar.rsvp
   Payload: { eventUri: "at://did:plc:alice/.../3kt5abc", status: "going", createdAt: "..." }
□ Verify RSVP record is readable from bob's PDS
□ Check if Smoke Signal AppView indexes the event:
   - Visit smokesignal.events and search for "Spike Test"
   - OR query their API if documented
□ If AppView doesn't index: can we query bob's PDS directly for RSVP?
   - Yes → RSVP aggregation will be app-side initially (acceptable)
   - No → investigate further before proceeding
```

**Kill criteria**:
- ❌ `atproto.dart` can't authenticate → STOP, evaluate alternatives or raw HTTP
- ❌ Can't create records with Smoke Signal Lexicon collection names → STOP, check PDS Lexicon validation rules
- ❌ Created records aren't readable → STOP, fundamental issue
- ✅ Both records created and readable → PROCEED to Phase 1

**Output**: A single `spike_results.md` file (max 1 page) with: works/doesn't work, actual latency numbers, any surprises.

---

### Phase 1: Clean House (1 day)

> *Lesson: "Kill the darlings. Delete the 9 unimplemented interfaces. They're not a roadmap, they're dead weight."*

**Goal**: Remove all dead code before writing any new code.

```
□ Delete from ev_protocol/lib/src/:
    chat/, group/, media/, payment/, moderation/,
    search/, schema/, sailing/, identity/
□ Delete from ev_protocol/lib/ev_protocol.dart:
    All exports for deleted modules
□ Delete ev_protocol_veilid package entirely
    (or gut it to just the Drift DB tables if reusing the schema)
□ Remove veilid dependency from sailor/pubspec.yaml
□ Remove all veilid imports from sailor/lib/
□ Update sailor/lib/main.dart:
    Remove VeilidNode initialization
    Remove veilidNodeProvider override
□ Update sailor/lib/core/sync/sync_provider.dart:
    Remove VeilidSyncService references (stub for now)
□ Run: flutter analyze — zero errors
□ Run: flutter build ios — compiles
□ Commit: "chore: delete dead protocol code (9 services, veilid transport)"
```

**What remains after cleanup**:
- `ev_protocol`: EvEvent, EvRsvp, core types (~600 lines)
- `sailor`: UI, domain interfaces, Drift DB, providers (~4,000 lines)
- No transport layer (will be built in Phase 2)

---

### Phase 2: AT Protocol Transport (1 week)

> *Lesson: "Make it work, then make it right, then make it fast."*

**Goal**: Sailor app authenticates and creates/reads events via AT Protocol. Local-only RSVPs. No discovery yet.

#### New package: `packages/ev_protocol_at/`

```
ev_protocol_at/
├── pubspec.yaml          (depends on: atproto, ev_protocol, drift)
├── lib/
│   ├── ev_protocol_at.dart
│   └── src/
│       ├── auth/
│       │   └── at_auth_service.dart       # Session management
│       ├── models/
│       │   ├── smoke_signal_event.dart     # Lexicon-aligned model
│       │   └── smoke_signal_rsvp.dart      # Lexicon-aligned model
│       ├── mappers/
│       │   ├── event_mapper.dart           # EvEvent ↔ Smoke Signal record
│       │   └── rsvp_mapper.dart            # EvRsvp ↔ Smoke Signal record
│       └── repositories/
│           └── at_event_repository.dart    # EventRepository impl
```

#### Key implementation details

**`AtAuthService`** — Keep it simple.
```dart
// Phase 2: App passwords only. OAuth is Phase 4 polish.
// Lesson: don't build the auth cathedral when a shed works.
class AtAuthService {
  Future<Session> login(String handle, String appPassword);
  Future<void> logout();
  Session? get currentSession;
  String? get did;
}
```

**`SmokeSignalEvent`** — Match the Lexicon exactly.
```dart
// Map 1:1 to events.smokesignal.calendar.event Lexicon
// Do NOT invent extra fields. Do NOT add ticketing/payments/groups.
// Those aren't in Smoke Signal's schema.
class SmokeSignalEvent {
  final String name;          // required
  final String? description;
  final String startsAt;      // ISO 8601, required
  final String? endsAt;
  final String? status;       // scheduled | cancelled | postponed
  final List<SmokeSignalLocation>? locations;
  final String createdAt;     // ISO 8601, required
}
```

**`AtEventRepository`** — Offline-first, AT Protocol sync.
```dart
class AtEventRepository implements EventRepository {
  // WRITE PATH: local-first
  // 1. Write to Drift SQLite immediately (instant UI update)
  // 2. Background: push to PDS via XRPC createRecord
  // 3. Store resulting at:// URI back in SQLite

  // READ PATH: local + remote
  // - getMyEvents() → SQLite only (fast, offline-safe)
  // - getEvents() → SQLite cache, refresh from AppView in background

  // RSVP PATH:
  // - rsvpToEvent() → SQLite + PDS createRecord
  // - getEventRsvps() → SQLite (local RSVPs) + AppView (network RSVPs)
}
```

**Milestone check**: Alice creates event in Sailor → appears in her PDS repo → readable via XRPC GET.

---

### Phase 3: Discovery + RSVP Visibility (1 week)

> *Lesson: "Can a user search for events near them?" and "Can the event creator see RSVPs?" — these are the questions that kill or validate.*

**Goal**: The full RSVP test passes inside the Sailor app. Network event discovery works.

#### Discover Tab

```
□ New feature: apps/sailor/lib/features/discover/
    ├── presentation/
    │   ├── pages/discover_page.dart
    │   └── providers/discover_providers.dart
    └── data/
        └── smoke_signal_api.dart    # HTTP client for Smoke Signal AppView
```

**`SmokeSignalApi`** — Query the AppView for events.
```dart
class SmokeSignalApi {
  // If Smoke Signal has a public API:
  Future<List<SmokeSignalEvent>> searchEvents({
    String? query,
    String? location,
    DateTime? fromDate,
  });

  // If no public API yet:
  // Fallback: query PDS repos directly by known DIDs
  // This is ugly but validates the data flow
  Future<SmokeSignalEvent?> getEventByUri(String atUri);
  Future<List<SmokeSignalRsvp>> getRsvpsForEvent(String eventAtUri);
}
```

#### RSVP Aggregation

Two sub-strategies depending on Smoke Signal AppView availability:

**If Smoke Signal AppView has an RSVP endpoint** (ideal):
```
GET smokesignal.events/api/rsvps?eventUri=at://did:plc:alice/.../3kt5abc
→ [{ did: "did:plc:bob", status: "going", createdAt: "..." }]
```

**If no AppView RSVP endpoint** (fallback):
```
- Subscribe to Jetstream filtered by collection=events.smokesignal.calendar.rsvp
- Build a lightweight local aggregator that watches for RSVPs referencing our events
- Cache in SQLite
- This is more work but still AT Protocol-native
```

**Milestone check**: The RSVP test passes end-to-end in the Sailor app.

---

### Phase 3b: Yacht Tracking + Photo Exchange (1 week)

> *Lesson from competitive analysis: "Build the sailing team app that works offshore. That's a niche Spond doesn't serve."*
>
> These features are NOT aspirational — they are the core differentiators that justify Sailor's existence. Spond can't do position tracking. WhatsApp doesn't aggregate event photos across participants. This is what makes Sailor a sailing app, not a generic event tool.

**Goal**: During a sailing event, participants can share live position data and photos. All data tied to events via `eventUri`. All offline-first.

#### Yacht Position Tracking

```
□ New feature: apps/sailor/lib/features/tracking/
    ├── data/
    │   └── position_service.dart       # GPS → buffer → PDS upload
    ├── domain/
    │   └── position_repository.dart    # Abstract interface
    └── presentation/
        ├── pages/tracking_page.dart     # Map view with yacht positions
        ├── providers/tracking_providers.dart
        └── widgets/
            ├── yacht_marker.dart        # Map pin with boat name + heading
            └── track_polyline.dart      # Historical trail on map
```

**`PositionService`** — GPS buffering + PDS upload.
```dart
class PositionService {
  // Start/stop tracking for a specific event
  Future<void> startTracking(String eventAtUri, {String? boatName});
  Future<void> stopTracking();
  bool get isTracking;

  // Internal: iOS location updates → buffer in SQLite
  // Every 60s: flush buffer → createRecord(au.sailor.yacht.position)
  // Offline: buffer grows, flushes when connectivity returns

  // Read other participants' positions for a given event
  Future<List<YachtTrack>> getEventTracks(String eventAtUri, List<String> participantDids);
}
```

**Key implementation notes**:
- Uses `geolocator` or `location` package for iOS GPS with background mode
- GPS interval: 10 seconds (configurable per event — race vs. cruise)
- Batch upload: every 60s OR when buffer hits 50 points OR on `stopTracking()`
- Map rendering: `flutter_map` with OpenStreetMap tiles (no Google Maps API key needed)
- Battery warning: show estimated battery impact before enabling tracking
- **Privacy**: tracking only activates with explicit user tap per-event. No ambient tracking.

#### Photo Exchange

```
□ New feature: apps/sailor/lib/features/photos/
    ├── data/
    │   └── photo_service.dart           # Camera → compress → PDS blob + record
    ├── domain/
    │   └── photo_repository.dart        # Abstract interface
    └── presentation/
        ├── pages/event_photos_page.dart  # Grid gallery for an event
        ├── providers/photo_providers.dart
        └── widgets/
            ├── photo_card.dart           # Thumbnail with caption + author
            └── photo_upload_fab.dart     # Camera/gallery picker FAB
```

**`PhotoService`** — Capture, compress, upload.
```dart
class PhotoService {
  // Upload a photo for an event
  Future<void> uploadPhoto({
    required String eventAtUri,
    required File imageFile,
    String? caption,
    double? latitude,
    double? longitude,
  });
  // Internal:
  // 1. Convert HEIC → JPEG if needed. Light compress to ≤5MB (quality 90)
  // 2. Save to local cache (SQLite row + temp file)
  // 3. Upload blob: POST /xrpc/com.atproto.repo.uploadBlob → get CID
  // 4. Create record: POST /xrpc/com.atproto.repo.createRecord
  //    Collection: au.sailor.photo
  //    Record: { eventUri, image: {$type: "blob", ref: CID, ...}, caption, createdAt }
  // 5. If offline: step 3-4 queued for retry

  // Fetch all photos for an event (from multiple participants)
  Future<List<EventPhoto>> getEventPhotos(String eventAtUri, List<String> participantDids);
}
```

**Key implementation notes**:
- Uses `image_picker` for camera/gallery access
- Conversion: HEIC → JPEG if needed, resize to max 4032px wide (iPhone native), quality 90 → typically 3–5MB
- If over 5MB after conversion: step down to quality 80, then 70. Resize to 3024px as last resort.
- PDS blob upload: `com.atproto.repo.uploadBlob` returns a blob ref (CID + mime + size)
- Gallery aggregation: query each known participant's PDS for `au.sailor.photo` records matching the event URI
- Pagination: `com.atproto.repo.listRecords` with collection filter
- **Offline**: photos saved locally, queued for upload. Gallery shows local + remote photos.
- **Blob re-upload**: PDS garbage-collects unreferenced blobs after ~1hr. If record creation fails after blob upload, the retry must re-upload the blob first.

**Milestone check**: Three users on separate devices at a sailing event — all can see each other's position tracks on a map AND browse a shared photo gallery for the event.

---

### Phase 4: Polish & Ship (1 week)

> *Lesson: "Spond uses Java, Spring Boot, and AWS. Nothing exotic. Purely product-driven value, not protocol-driven."*

**Goal**: The app is a credible product, not a protocol demo. Focus on UX, not architecture.

```
□ Auth UX
   - Login page with handle + app password input
   - Persist session securely (flutter_secure_storage)
   - Auto-reconnect on app resume
   - Show logged-in identity in profile tab

□ Event UX
   - Pull-to-refresh on event list (re-fetch from PDS)
   - Loading states and error handling (no unhandled exceptions)
   - Offline indicator when PDS unreachable
   - Sync status badge (pending uploads count)

□ RSVP UX
   - 1-tap RSVP button on event detail (going / not going)
   - RSVP count displayed on event cards
   - List of RSVPs on event detail page
   - My RSVP status shown if already responded

□ Discovery UX
   - Discover tab with search/filter
   - Pull-to-refresh
   - Empty states ("No events found near you")

□ Offline resilience
   - Queue failed PDS writes for retry
   - Show locally-created events immediately (optimistic UI)
   - Merge remote state on reconnect without duplicates

□ iOS release prep
   - App icon, splash screen
   - TestFlight build
```

---

## Timeline Summary

| Phase | Duration | Gate | Output |
|-------|:--------:|------|--------|
| **0: Spike** | 2 days | RSVP test passes with real PDS | 1-page spike_results.md |
| **1: Clean** | 1 day | `flutter analyze` clean, `flutter build ios` compiles | Commit deleting ~2,900 lines |
| **2: Transport** | 1 week | Event created in app → readable in PDS | `ev_protocol_at` package |
| **3: Discovery** | 1 week | Full RSVP test in-app, Discover tab works | Network integration |
| **3b: Sailing** | 1 week | Position tracks visible on map, photos in shared gallery | Yacht tracking + photos |
| **4: Polish** | 1 week | TestFlight-ready build | Shippable product |
| **Total** | **~5 weeks** | | |

### Why 5 weeks, not the 8–10 from protocol-killer.md

The original estimate assumed building everything from scratch with full OAuth, a custom AppView, and all Lexicon schemas. This plan:
1. Uses app passwords instead of full OAuth (saves 1–2 weeks)
2. Leverages Smoke Signal's existing AppView for discovery/RSVP aggregation instead of building our own (saves 2–3 weeks)
3. Keeps the existing Drift DB + offline-first pattern instead of designing a new data layer (saves 1 week)
4. Doesn't build chat, payments, groups, or moderation (saves 4+ weeks of scope that was never needed)
5. Adds yacht tracking + photo exchange (+1 week) — but these are concrete differentiators with defined schemas, not aspirational interfaces

---

## Rate Limits ([source](https://docs.bsky.app/docs/advanced-guides/rate-limits))

Bluesky PDS instances enforce rate limits at multiple levels. These are **Bluesky's hosted PDS limits** — self-hosted PDS operators can set their own.

### Content Write Operations (per account)

| Limit | Value | Notes |
|-------|:-----:|-------|
| **Points per hour** | 5,000 | Shared budget across all record writes |
| **Points per day** | 35,000 | |
| **Create record** | 3 points | Events, RSVPs, position batches, photos |
| **Update record** | 2 points | Editing an event |
| **Delete record** | 1 point | |
| **Max creates/hour** | ~1,666 | 5,000 ÷ 3 |
| **Max creates/day** | ~11,666 | 35,000 ÷ 3 |

### API Request Limits

| Endpoint | Limit | Scope |
|----------|:-----:|:-----:|
| **All API requests** | 3,000 / 5 min | Per IP |
| `createSession` | 30 / 5 min, 300 / day | Per account |
| **Blob upload** | 50 MB max per blob | Per request |

### Relay Limits (affects how fast data propagates to AppView/Jetstream)

| Limit | Value |
|-------|:-----:|
| Repository stream events | 50/sec, 1,500/hr, 10,000/day |
| New account creation | 5/sec |

### Sailor Usage Projections vs Limits

| Sailor Activity | Records/hr | Records/day | Limit | Headroom |
|-----------------|:----------:|:-----------:|:-----:|:--------:|
| **Casual user** (browse events, 2 RSVPs) | ~5 | ~20 | 1,666/hr | ✅ 333x |
| **Event organiser** (create event, check RSVPs) | ~10 | ~30 | 1,666/hr | ✅ 166x |
| **Active race day** (1 event + 5 photos + tracking) | ~25 | ~50 | 1,666/hr | ✅ 66x |
| **Position tracking** (10s GPS, 60s batch upload) | ~60 batches/hr | ~180/race (3hr) | 1,666/hr | ✅ 27x |
| **Photo burst** (20 photos after a race) | ~20 | ~20 | 1,666/hr | ✅ 83x |
| **Worst case** (organiser + tracking + 20 photos) | ~85 | ~250 | 1,666/hr | ✅ 19x |

> **Verdict**: Sailor's usage is nowhere near the rate limits. Even the worst-case scenario (race officer running GPS tracking, uploading 20 photos, creating events, and checking RSVPs) uses ~5% of the hourly budget. The limits are designed to stop bots that like every post on the network, not sailing apps.

### One Constraint Worth Noting

**API requests**: 3,000 per 5 minutes per IP. This is relevant if querying **multiple PDS repos** to aggregate position data or photos for an event. If 20 participants are in a race and we query each of their PDS repos for position records + photos = ~40 requests. At a 30-second refresh: ~480 requests per 5 min. Fine. But at 10-second refresh with 50 participants: ~1,500 requests per 5 min. Approaching the limit.

**Mitigation**: Cache aggressively in SQLite. Use long polling intervals (30s) for position aggregation. Batch queries where possible (`com.atproto.repo.listRecords` returns multiple records per call).

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|:----------:|:------:|------------|
| `atproto.dart` SDK has breaking bugs | Medium | High | Spike catches this in Day 1. Fallback: raw HTTP + `dio`. |
| Smoke Signal AppView doesn't index our records | Medium | Medium | Fallback: direct PDS queries for known DIDs. Build own mini-aggregator later. |
| Smoke Signal AppView has no public API | Medium | Medium | Fallback: use Jetstream to build local index. More work but viable. |
| bsky.social PDS rejects Smoke Signal collection names | Low | High | Spike catches this in Day 1. PDS should accept any valid NSID. |
| AT Protocol breaking changes during build | Low | Medium | Pin `atproto.dart` version. Don't chase HEAD. |
| OAuth requirement enforced (app passwords deprecated) | Low | Low | Phase 4 stretch goal. OAuth flow in `atproto.dart` exists. |
| PDS blob upload size limit too small for photos | Very Low | Low | PDS blob limit is **50MB** ([confirmed](https://docs.bsky.app/docs/advanced-guides/rate-limits)). Our 5MB photo cap is 10x below the ceiling. |
| iOS background GPS kills battery | Medium | Medium | Show battery impact estimate. Default to 10s interval, allow 30s for cruising. Auto-stop after event end time. |
| Position data volume exceeds PDS storage | Low | Low | 11 records per 3hr race per yacht. Tiny. Could prune old position records after event ends. |
| Aggregating photos/positions from many PDS repos is slow | Medium | Medium | Query in parallel. Cache aggressively in SQLite. Paginate. Accept 2-5s load time for first gallery view. |
| Rate-limited when aggregating across many PDS repos | Low | Medium | 3,000 req / 5 min per IP. Worst case ~480 req / 5 min for 20-participant race at 30s refresh. Use `listRecords` batching and SQLite caching to stay well under. |

---

## What This Plan Deliberately Does NOT Include

> *Lesson: "9 of those 12 services had zero implementations and zero consumers. They were aspirational API surfaces for features that didn't exist, couldn't exist on the chosen transport, and weren't needed for an MVP."*

| Not Included | Why Not |
|--------------|---------|
| Chat / messaging | Build it when users ask for it (Spond-level feature, not MVP) |
| Group management | Build it when clubs onboard (requires real user feedback) |
| Payment collection | Stripe integration is a product decision after user validation |
| Custom Feed Generator | Optimisation for scale. Not needed at <1,000 users |
| Custom Relay | We use Bluesky's relay. Run our own only if costs justify it |
| Custom AppView | We use Smoke Signal's. Build our own only if their API is insufficient |
| Race scoring / series management | That's TopYacht/SailSys territory (Layer 2). Sailor is Layer 3. |
| Real-time WebSocket position streaming | PDS batch upload is good enough for sailing (60s intervals). Real-time tracking is a V2 optimisation. |
| Video uploads | AT Protocol supports video (100MB, 3 min, via `video.bsky.app` sidecar with transcoding). Dart SDK supports it. But marina Wi-Fi makes 100MB uploads impractical. Add as post-launch feature when core photo flow is validated. |
| E2E encryption for private events | AT Protocol doesn't support this yet. Ship public events first |
| Multi-phase roadmap beyond Phase 4 | *"Phase 1 hadn't been validated."* Ship Phase 4, then decide what's next based on real users |

---

## Success Criteria

The plan succeeds when a real person (not the developer) can:

### Core (Phases 0–3)
1. ✅ Open Sailor on their iPhone
2. ✅ Log in with a Bluesky/AT Protocol account
3. ✅ See events from the Smoke Signal network
4. ✅ Create an event that appears on Smoke Signal
5. ✅ RSVP to someone else's event
6. ✅ See RSVPs on their own events
7. ✅ Do all of the above in < 30 seconds per action
8. ✅ Do 1–4 while offline (sync when back online)

### Sailing-Specific (Phase 3b)
9. ✅ Enable GPS tracking for a sailing event and see their own position on a map
10. ✅ See other participants' yacht positions/tracks on the same map during the event
11. ✅ Take a photo during an event and have it appear in the shared event gallery
12. ✅ Browse photos taken by other participants at the same event
13. ✅ Position tracking + photo capture work offline (buffer locally, sync when signal returns)
14. ✅ Stop tracking — no position data recorded outside of active events

If criteria 1–8 are met, Sailor has a viable event product. If 9–14 are also met, Sailor has a **unique competitive position** — the only sailing coordination app that combines AT Protocol interoperability with offshore-capable yacht tracking and crowd-sourced event photos. This is the Layer 3 niche that Spond, WhatsApp, and Eventbrite cannot serve.

---

*Related: [protocol-killer.md](./protocol-killer.md) | [lessons-learned](./lessons-learned-why-claude-over-prommised-and-under-evaluated.md) | [at-protocol-overview.md](./at-protocol-overview.md)*
