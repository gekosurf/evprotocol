# Spike Results — AT Protocol Validation

> Phase 0 gate: **PASS** ✅  
> Date: 2026-04-08  
> Account: gekosurf.bsky.social (did:plc:cdnsgzolyvl5p4jirhc5utfg)  
> PDS: stropharia.us-west.host.bsky.network

## Results

| Test | Result | Latency |
|------|:------:|:-------:|
| Auth (app password) | ✅ | 1,070ms |
| Create event (`events.smokesignal.calendar.event`) | ✅ | 850ms |
| Read event back | ✅ | 799ms |
| Create RSVP (`events.smokesignal.calendar.rsvp`) | ✅ | 763ms |
| Read RSVP back (references event URI) | ✅ | 804ms |
| List records by collection | ✅ | 761ms |
| Create with **custom Lexicon** (`au.sailor.yacht.position`) | ✅ | 848ms |
| Delete all test records | ✅ | — |

## Key Finding: PDS Rejects Dart Doubles

The CBOR encoder rejects floating-point `double` values in record maps:

```
InvalidRequestException: 400 Expected one of null, boolean, integer, string, 
cid, bytes, array or object value type (got -31.9744) 
at $.record.locations[0].coordinates.latitude
```

**Fix**: Encode numeric values (lat/lng, speed, heading) as **strings** in AT Protocol records. Parse back to doubles in the app layer.

**Impact on plan**: The `au.sailor.yacht.position` Lexicon schema must use `"type": "string"` for latitude, longitude, speedKnots, headingDeg, accuracy — not `"type": "number"`. Already validated: string-encoded positions were accepted by the PDS.

## Validated Assumptions

1. ✅ `bsky.social` PDS accepts **any valid NSID** as a collection name — including `events.smokesignal.calendar.*` and `au.sailor.yacht.*`
2. ✅ `atproto.dart` / `bluesky` SDK works for custom Lexicon record CRUD
3. ✅ RSVP record correctly references event via `at://` URI
4. ✅ Records are readable immediately after creation (~800ms roundtrip)
5. ✅ `listRecords` works with custom collection names
6. ✅ `deleteRecord` works for cleanup

## Proceed to Phase 1

The RSVP test data flow is validated. PDS accepts custom Lexicon collection names. No blockers found.
