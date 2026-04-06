# EV Protocol v0.1

> Abstract interfaces and data models for the **Event Vector** decentralised event protocol.

## What is this?

This is a **pure Dart interface package** — it contains only abstract classes and immutable data models. It has **zero external dependencies**.

Implementation packages (e.g., `ev_protocol_veilid`) provide concrete implementations backed by Veilid DHT, SQLite, etc.

## Usage

```dart
import 'package:ev_protocol/ev_protocol.dart';

// Implement the abstract interfaces with your chosen backend:
class VeilidEventService implements EvEventService {
  @override
  Future<EvResult<EvEvent>> createEvent(EvEvent event) async {
    // ... Veilid-specific implementation
  }
}
```

## Package Structure

| Domain | Interface | Models |
|---|---|---|
| **Core** | — | `EvResult<T>`, `EvDhtKey`, `EvPubkey`, `EvTimestamp`, `EvProtocolConfig` |
| **Identity** | `EvIdentityService` | `EvIdentity`, `EvIdentityBridge` |
| **Event** | `EvEventService` | `EvEvent`, `EvRsvp` |
| **Group** | `EvGroupService` | `EvGroup`, `EvVessel` |
| **Media** | `EvMediaService` | `EvMediaReference` |
| **Payment** | `EvPaymentService` | `EvPaymentIntent`, `EvPaymentReceipt`, `EvTicket` |
| **Chat** | `EvChatService` | `EvChatChannel`, `EvChatMessage` |
| **Search** | `EvSearchService` | `EvSearchResult` |
| **Moderation** | `EvModerationService` | `EvModerationReport`, `EvModerationAction` |
| **Sync** | `EvSyncService` | `EvSyncEvent` |
| **Schema** | `EvSchemaValidator` | `EvLexiconRegistry`, `EvLexicons` |
| **Sailing** | `EvSailingService` | `EvRace`, `EvCourse`, `EvTrack`, `EvRaceResult` |

## Design Principles

- **All services are abstract** — no Veilid dependency in this package
- **Immutable models** — `final` fields, `copyWith` pattern
- **No exceptions** — all service methods return `EvResult<T>`
- **JSON serializable** — every model has `toJson()` / `fromJson()`
- **Sequence diagrams** — every service interface has a Mermaid diagram in its doc comment

## License

MPL-2.0
