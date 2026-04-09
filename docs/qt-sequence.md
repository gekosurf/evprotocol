# QT Sequence Diagrams — AT Protocol Multi-Client Flows

> **Two clients, two handles, one PDS.**
> Alice (`alice.bsky.social`) and Bob (`bob.bsky.social`) each run Sailor on separate devices.
> Both authenticate via `AtAuthService.login()` and maintain independent SQLite caches.

---

## 1. New Event — Create & Sync

Alice creates an event. Bob sees it on the next PDS refresh.

```mermaid
sequenceDiagram
    participant Alice_UI as CreateEventPage<br/>(Alice)
    participant Alice_Not as MyEventsNotifier<br/>(Alice)
    participant Alice_UC as CreateEventUseCase
    participant Alice_Adapt as AtEventRepositoryAdapter
    participant Alice_Repo as AtEventRepository
    participant Alice_DB as AppDatabase<br/>(SQLite)
    participant Alice_Sync as AtSyncService
    participant Alice_Map as EventMapper
    participant PDS_A as Alice's PDS<br/>(at://alice)
    participant PDS_B as Bob's PDS<br/>(at://bob)
    participant Bob_Sync as AtSyncService<br/>(Bob)
    participant Bob_Repo as AtEventRepository<br/>(Bob)
    participant Bob_Map as EventMapper<br/>(Bob)
    participant Bob_DB as AppDatabase<br/>(Bob SQLite)
    participant Bob_UI as DiscoverEventsNotifier<br/>(Bob)

    Note over Alice_UI: Alice fills form & taps "Create Event"

    Alice_UI->>Alice_Not: createEvent(name, startAt, category, ...)
    Alice_Not->>Alice_UC: call(name, startAt, category, ...)
    Alice_UC->>Alice_UC: validate(name.length ≤ 128, endAt > startAt)
    Alice_UC->>Alice_Adapt: createEvent(...)
    Alice_Adapt->>Alice_Repo: createEvent(...)

    Note over Alice_Repo: Step 1 — Write to SQLite (offline-first)
    Alice_Repo->>Alice_Repo: localKey = "local-${timestamp}"
    Alice_Repo->>Alice_DB: into(cachedEvents).insert(<br/>CachedEventsCompanion(dhtKey: localKey, ...))
    Alice_DB-->>Alice_Repo: localId (int)

    Note over Alice_Repo: Step 2 — Queue for sync
    Alice_Repo->>Alice_DB: into(syncQueue).insert(<br/>SyncQueueCompanion(op: "create",<br/>type: "event", payload: jsonEncode(event)))
    Alice_DB-->>Alice_Repo: queued

    Alice_Repo-->>Alice_Not: EvEvent(dhtKey: "local-xxx")

    Note over Alice_Not: Step 3 — Immediate PDS push
    Alice_Not->>Alice_Sync: processQueue()
    Alice_Sync->>Alice_DB: select(syncQueue)<br/>.where(status == "pending")
    Alice_DB-->>Alice_Sync: [SyncQueueData item]

    Alice_Sync->>Alice_Sync: _pushEvent(item)
    Alice_Sync->>Alice_Map: EventMapper.toSmokeSignal(event)
    Alice_Map-->>Alice_Sync: SmokeSignalEvent
    Alice_Sync->>PDS_A: client.atproto.repo.createRecord(<br/>collection: "events.smokesignal.calendar.event",<br/>record: smokeSignal.toRecord())
    PDS_A-->>Alice_Sync: atUri = "at://alice/...event/3miz..."

    Note over Alice_Sync: Step 4 — Update local key → at:// URI
    Alice_Sync->>Alice_DB: update(cachedEvents)<br/>.where(id == localId)<br/>.write(dhtKey: atUri, isDirty: false)

    Alice_Sync->>Alice_DB: UPDATE cached_rsvps<br/>SET event_dht_key = atUri<br/>WHERE event_dht_key = "local-xxx"

    Alice_Sync->>Alice_DB: update(syncQueue)<br/>.write(status: "completed")

    Note over Alice_Not: Step 5 — Refresh UI
    Alice_Not->>Alice_Repo: refreshFromPds()
    Alice_Repo->>PDS_A: listRecords(collection: event)
    PDS_A-->>Alice_Repo: [records]
    Alice_Repo->>Alice_DB: _insertOrUpdateEventInDb (upsert)
    Alice_Not->>Alice_Not: ref.invalidate(categoriesProvider)

    Note over Bob_Sync: ══ 30s timer tick on Bob's device ══
    Bob_Sync->>Bob_Sync: processQueue()

    Note over Bob_UI: Bob pulls to refresh
    Bob_UI->>Bob_Repo: refreshFromPds()
    Bob_Repo->>PDS_B: listRecords(repo: bob, collection: event)
    PDS_B-->>Bob_Repo: [bob's own events only]

    Note over Bob_Repo: Bob won't see Alice's event<br/>unless Bob follows Alice or<br/>an AppView aggregates feeds

    Note right of Bob_Repo: ⚠ Cross-user discovery requires<br/>scanning other users' PDS repos<br/>or a relay/AppView service
```

---

## 2. RSVP — Respond & Cross-Sync

Bob RSVPs to an event. Alice sees the RSVP on next PDS refresh.

```mermaid
sequenceDiagram
    participant Bob_UI as EventDetailPage<br/>(Bob)
    participant Bob_Sheet as RsvpBottomSheet
    participant Bob_UC as RsvpToEventUseCase
    participant Bob_Adapt as AtEventRepositoryAdapter
    participant Bob_Repo as AtEventRepository<br/>(Bob)
    participant Bob_DB as AppDatabase<br/>(Bob SQLite)
    participant Bob_Sync as AtSyncService<br/>(Bob)
    participant Bob_RMap as RsvpMapper
    participant PDS_B as Bob's PDS<br/>(at://bob)
    participant PDS_A as Alice's PDS<br/>(at://alice)
    participant Alice_Repo as AtEventRepository<br/>(Alice)
    participant Alice_DB as AppDatabase<br/>(Alice SQLite)
    participant Alice_UI as DiscoverEventsNotifier<br/>(Alice)

    Note over Bob_UI: Bob opens event detail, taps "RSVP"

    Bob_UI->>Bob_Sheet: show RsvpBottomSheet(event)
    Bob_Sheet->>Bob_UI: onRsvp(EvRsvpStatus.confirmed)

    Bob_UI->>Bob_UC: call(eventDhtKey, status: confirmed)
    Bob_UC->>Bob_Adapt: rsvpToEvent(eventDhtKey, status)
    Bob_Adapt->>Bob_Repo: rsvpToEvent(<br/>eventKey: "at://alice/...event/3miz...",<br/>status: confirmed)

    Note over Bob_Repo: Step 1 — Upsert RSVP to SQLite
    Bob_Repo->>Bob_DB: into(cachedRsvps).insert(<br/>CachedRsvpsCompanion(<br/>eventDhtKey: "at://alice/...",<br/>attendeePubkey: bob_did,<br/>status: "confirmed"),<br/>onConflict: DoUpdate(<br/>target: [eventDhtKey, attendeePubkey]))
    Bob_DB-->>Bob_Repo: row inserted/updated

    Note over Bob_Repo: Step 2 — Increment local rsvpCount
    Bob_Repo->>Bob_DB: UPDATE cached_events<br/>SET rsvp_count = rsvp_count + 1<br/>WHERE dht_key = eventKey<br/>AND status == "confirmed"

    Note over Bob_Repo: Step 3 — Queue RSVP sync
    Bob_Repo->>Bob_DB: into(syncQueue).insert(<br/>SyncQueueCompanion(op: "create",<br/>type: "rsvp",<br/>payload: jsonEncode(rsvp)))
    Bob_DB-->>Bob_Repo: queued

    Bob_Repo-->>Bob_UI: EvRsvp(status: confirmed)

    Note over Bob_UI: Step 4 — Immediate PDS push
    Bob_UI->>Bob_Sync: processQueue()
    Bob_Sync->>Bob_DB: select(syncQueue).where(pending)
    Bob_DB-->>Bob_Sync: [SyncQueueData rsvpItem]

    Bob_Sync->>Bob_Sync: _pushRsvp(item)

    Note over Bob_Sync: Resolve local key → at:// URI
    Bob_Sync->>Bob_DB: select(cachedEvents)<br/>.where(dhtKey == eventKey)
    Bob_DB-->>Bob_Sync: row with dhtKey: "at://alice/..."

    Bob_Sync->>Bob_RMap: RsvpMapper.toSmokeSignal(<br/>rsvp, eventAtUri: "at://alice/...")
    Bob_RMap-->>Bob_Sync: SmokeSignalRsvp(<br/>eventUri: "at://alice/...",<br/>status: "going")

    Bob_Sync->>PDS_B: client.atproto.repo.createRecord(<br/>repo: bob_did,<br/>collection: "events.smokesignal.calendar.rsvp",<br/>record: rsvp.toRecord())
    PDS_B-->>Bob_Sync: atUri = "at://bob/...rsvp/3miz..."

    Bob_Sync->>Bob_DB: update(syncQueue).write(status: "completed")

    Note over Bob_UI: Step 5 — Refresh UI
    Bob_UI->>Bob_UI: ref.invalidate(discoverEventsProvider)
    Bob_UI->>Bob_UI: ref.invalidate(eventRsvpsProvider(dhtKey))

    Note over Alice_UI: ══ Alice pulls to refresh ══
    Alice_UI->>Alice_Repo: refreshFromPds()

    Note over Alice_Repo: Step 1 — Refresh events
    Alice_Repo->>PDS_A: listRecords(collection: event)
    PDS_A-->>Alice_Repo: [alice's events]
    Alice_Repo->>Alice_DB: _insertOrUpdateEventInDb (upsert each)

    Note over Alice_Repo: Step 2 — Refresh RSVPs
    Alice_Repo->>PDS_A: listRecords(collection: rsvp)
    PDS_A-->>Alice_Repo: [alice's own RSVPs]

    Note right of Alice_Repo: ⚠ Alice sees only HER OWN RSVPs<br/>from her PDS. Bob's RSVP is in<br/>BOB's PDS (at://bob/...rsvp/...).<br/>Cross-user RSVP discovery needs<br/>scanning participant PDS repos.

    Note over Alice_Repo: Step 3 — Recompute rsvpCount
    Alice_Repo->>Alice_DB: UPDATE cached_events<br/>SET rsvp_count = (<br/>SELECT COUNT(*) FROM cached_rsvps<br/>WHERE status = "confirmed")
```

---

## 3. Add Photo — Upload & Cross-Read

Alice uploads a photo for an event. Bob views it by scanning Alice's PDS.

```mermaid
sequenceDiagram
    participant Alice_UI as EventPhotosPage<br/>(Alice)
    participant Alice_Prov as photoServiceProvider
    participant Alice_Svc as PhotoService<br/>(Alice)
    participant Alice_Auth as AtAuthService<br/>(Alice)
    participant PDS_A as Alice's PDS<br/>(at://alice)
    participant Bob_UI as EventPhotosPage<br/>(Bob)
    participant Bob_Prov as eventPhotosProvider
    participant Bob_Svc as PhotoService<br/>(Bob)
    participant PDS_B as Alice's PDS<br/>(read by Bob)

    Note over Alice_UI: Alice taps "+" camera FAB, picks image

    Alice_UI->>Alice_Prov: ref.read(photoServiceProvider)
    Alice_Prov-->>Alice_UI: PhotoService instance

    Alice_UI->>Alice_Svc: uploadPhoto(<br/>eventAtUri: "at://alice/...event/3miz...",<br/>imageFile: File("/path/to/photo.jpg"),<br/>caption: "Spinnaker set!")

    Note over Alice_Svc: Step 1 — Read & validate file
    Alice_Svc->>Alice_Svc: imageFile.readAsBytes()
    Alice_Svc->>Alice_Svc: _guessMimeType("photo.jpg") → "image/jpeg"
    Alice_Svc->>Alice_Svc: validate bytes.length ≤ 5MB

    Note over Alice_Svc: Step 2 — Check auth
    Alice_Svc->>Alice_Auth: client (getter)
    Alice_Auth-->>Alice_Svc: XRPCClient (authenticated)

    Note over Alice_Svc: Step 3 — Upload blob to PDS
    Alice_Svc->>PDS_A: client.atproto.repo.uploadBlob(<br/>bytes: imageBytes)
    PDS_A-->>Alice_Svc: BlobResult(blob: {ref, mimeType, size})

    Note over Alice_Svc: Step 4 — Create photo record
    Alice_Svc->>Alice_Svc: SmokeSignalPhoto(<br/>eventUri: "at://alice/...event/...",<br/>image: blobRef,<br/>caption: "Spinnaker set!",<br/>createdAt: now.toIso8601())

    Alice_Svc->>PDS_A: client.atproto.repo.createRecord(<br/>repo: alice_did,<br/>collection: "au.sailor.photo",<br/>record: photo.toRecord())
    PDS_A-->>Alice_Svc: RecordResult(uri: "at://alice/...photo/3miz...")

    Alice_Svc-->>Alice_UI: EventPhoto(<br/>atUri: "at://alice/...photo/...",<br/>blobRef: {...},<br/>authorDid: alice_did)

    Note over Alice_UI: UI refreshes grid via<br/>ref.invalidate(eventPhotosProvider)

    Note over Alice_Svc: ── OFFLINE PATH (client == null) ──
    Note over Alice_Svc: _uploadQueue.add(PendingPhoto(...))<br/>Returns EventPhoto(isLocal: true)<br/>retryPendingUploads() called later

    Note over Bob_UI: ══ Bob opens same event's photo page ══

    Bob_UI->>Bob_Prov: ref.watch(eventPhotosProvider(<br/>eventAtUri: "at://alice/...event/...",<br/>participantDids: [alice_did, bob_did]))
    Bob_Prov->>Bob_Svc: getEventPhotos(<br/>eventAtUri, [alice_did, bob_did])

    Note over Bob_Svc: Step 1 — Scan Alice's PDS
    Bob_Svc->>PDS_B: client.atproto.repo.listRecords(<br/>repo: alice_did,<br/>collection: "au.sailor.photo")
    PDS_B-->>Bob_Svc: [records]

    Bob_Svc->>Bob_Svc: for each record:<br/>SmokeSignalPhoto.fromRecord(record.value)<br/>filter: ssPhoto.eventUri == eventAtUri

    Note over Bob_Svc: Step 2 — Scan Bob's own PDS
    Bob_Svc->>PDS_B: client.atproto.repo.listRecords(<br/>repo: bob_did,<br/>collection: "au.sailor.photo")
    PDS_B-->>Bob_Svc: [records]
    Bob_Svc->>Bob_Svc: filter by eventUri, build EventPhoto list

    Note over Bob_Svc: Step 3 — Sort & return
    Bob_Svc->>Bob_Svc: photos.sort((a,b) => b.createdAt.compareTo(...))
    Bob_Svc-->>Bob_UI: List<EventPhoto>

    Note over Bob_UI: Grid renders photos via<br/>EventPhoto.blobUrl →<br/>"https://bsky.social/xrpc/<br/>com.atproto.sync.getBlob<br/>?did=alice_did&cid=..."
```

---

## 4. Yacht Position Tracking (Course)

Alice starts GPS tracking during a race. Bob views her track in real-time by reading her PDS positions.

```mermaid
sequenceDiagram
    participant Alice_UI as TrackingPage<br/>(Alice)
    participant Alice_Prov as trackingProviders
    participant Alice_Svc as PositionService<br/>(Alice)
    participant Alice_Auth as AtAuthService<br/>(Alice)
    participant GPS as GPS / Location<br/>(Alice device)
    participant PDS_A as Alice's PDS<br/>(at://alice)
    participant Bob_UI as TrackingPage<br/>(Bob)
    participant Bob_Svc as PositionService<br/>(Bob)
    participant Bob_Auth as AtAuthService<br/>(Bob)

    Note over Alice_UI: Alice taps "Start Tracking"

    Alice_UI->>Alice_Prov: ref.read(positionServiceProvider)
    Alice_UI->>Alice_Svc: startTracking(<br/>eventAtUri: "at://alice/...event/...",<br/>boatName: "S/V Nimbus")

    Note over Alice_Svc: Initialize tracking state
    Alice_Svc->>Alice_Svc: _activeEventUri = eventAtUri
    Alice_Svc->>Alice_Svc: _boatName = "S/V Nimbus"
    Alice_Svc->>Alice_Svc: _isTracking = true
    Alice_Svc->>Alice_Svc: _trackingStateController.add(true)

    Note over Alice_Svc: Start periodic flush timer
    Alice_Svc->>Alice_Svc: Timer.periodic(60s, flushBuffer)

    Note over GPS: ── GPS callback fires (every ~1s) ──

    GPS->>Alice_Svc: recordPosition(<br/>lat: -31.9505, lng: 115.8605,<br/>speed: 8.2, heading: 145.0)

    Alice_Svc->>Alice_Svc: _buffer.add(SmokeSignalPosition(<br/>eventUri: eventAtUri,<br/>boatName: "S/V Nimbus",<br/>latitude: "-31.950500",<br/>longitude: "115.860500",<br/>speed: "8.2",<br/>heading: "145.0",<br/>timestamp: now.toIso8601()))

    Note over GPS: ── More GPS callbacks ──
    GPS->>Alice_Svc: recordPosition(lat, lng, speed, heading)
    GPS->>Alice_Svc: recordPosition(lat, lng, speed, heading)
    Alice_Svc->>Alice_Svc: _buffer.length == 3

    Note over Alice_Svc: ── 60s flush timer fires ──

    Alice_Svc->>Alice_Svc: flushBuffer()
    Alice_Svc->>Alice_Auth: client (getter)
    Alice_Auth-->>Alice_Svc: XRPCClient

    loop For each buffered position
        Alice_Svc->>PDS_A: client.atproto.repo.createRecord(<br/>repo: alice_did,<br/>collection: "au.sailor.yacht.position",<br/>record: position.toRecord())
        PDS_A-->>Alice_Svc: RecordResult(uri)
        Alice_Svc->>Alice_Svc: _buffer.remove(position)
    end

    Note over Alice_UI: ── Alice taps "Stop Tracking" ──

    Alice_UI->>Alice_Svc: stopTracking()
    Alice_Svc->>Alice_Svc: _isTracking = false
    Alice_Svc->>Alice_Svc: _trackingStateController.add(false)
    Alice_Svc->>Alice_Svc: _flushTimer.cancel()
    Alice_Svc->>Alice_Svc: flushBuffer() — flush remaining

    Note over Bob_UI: ══ Bob views race tracks ══

    Bob_UI->>Bob_Svc: getEventTracks(<br/>eventAtUri: "at://alice/...event/...",<br/>participantDids: [alice_did, bob_did])

    Note over Bob_Svc: Scan each participant's PDS
    Bob_Svc->>Bob_Auth: client (getter)
    Bob_Auth-->>Bob_Svc: XRPCClient

    Note over Bob_Svc: Step 1 — Read Alice's positions
    Bob_Svc->>PDS_A: client.atproto.repo.listRecords(<br/>repo: alice_did,<br/>collection: "au.sailor.yacht.position")
    PDS_A-->>Bob_Svc: [position records]

    Bob_Svc->>Bob_Svc: records.map(SmokeSignalPosition.fromRecord)<br/>.where(p.eventUri == eventAtUri)
    Bob_Svc->>Bob_Svc: tracks.add(YachtTrack(<br/>did: alice_did,<br/>boatName: "S/V Nimbus",<br/>positions: [...]))

    Note over Bob_Svc: Step 2 — Read Bob's own positions
    Bob_Svc->>PDS_A: client.atproto.repo.listRecords(<br/>repo: bob_did,<br/>collection: "au.sailor.yacht.position")
    PDS_A-->>Bob_Svc: [position records]
    Bob_Svc->>Bob_Svc: filter & build YachtTrack for bob

    Bob_Svc-->>Bob_UI: List<YachtTrack>

    Note over Bob_UI: UI renders polylines on map<br/>from track.positions[].latitude/longitude
```

---

## Architecture Summary

| Collection NSID | Stored In | Who Writes | Who Reads | Discovery |
|---|---|---|---|---|
| `events.smokesignal.calendar.event` | Creator's PDS | Event creator | Anyone with DID | Scan PDS repos |
| `events.smokesignal.calendar.rsvp` | Attendee's PDS | Attendee | Anyone with DID | Scan participant DIDs |
| `au.sailor.photo` | Photographer's PDS | Photo author | Anyone with DID | Scan participant DIDs |
| `au.sailor.yacht.position` | Tracker's PDS | Tracking device | Anyone with DID | Scan participant DIDs |

### Key Classes Per Layer

```
┌─────────────────────────────────────────────────────┐
│  UI Layer (apps/sailor/lib/features/...)            │
│  CreateEventPage → MyEventsNotifier                 │
│  EventDetailPage → RsvpBottomSheet                  │
│  EventPhotosPage → eventPhotosProvider              │
│  TrackingPage    → trackingProviders                │
├─────────────────────────────────────────────────────┤
│  Domain Layer                                       │
│  CreateEventUseCase · RsvpToEventUseCase             │
│  EventRepository (interface)                         │
├─────────────────────────────────────────────────────┤
│  Data Layer (AtEventRepositoryAdapter)              │
│  AtEventRepository → AppDatabase (Drift/SQLite)     │
│  PhotoService      → direct PDS (no local cache)    │
│  PositionService   → in-memory buffer → PDS         │
├─────────────────────────────────────────────────────┤
│  Protocol Layer (packages/ev_protocol_at/)          │
│  AtAuthService · AtSyncService                       │
│  EventMapper · RsvpMapper                            │
│  SmokeSignalEvent · SmokeSignalRsvp                  │
│  SmokeSignalPhoto · SmokeSignalPosition              │
│  LexiconNsids                                        │
├─────────────────────────────────────────────────────┤
│  AT Protocol PDS (remote)                           │
│  repo.createRecord · repo.listRecords               │
│  repo.uploadBlob · repo.deleteRecord                │
└─────────────────────────────────────────────────────┘
```
