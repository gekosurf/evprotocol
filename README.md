# EV Protocol

> **Event Vector (EV)** — A decentralised event discovery, coordination, and communication protocol built on Veilid networking.

## Repository Structure

```
├── docs/                    ← Research, architecture, and protocol specification
│   ├── ev-protocol-spec-v0.1.md   ← Formal protocol spec (source of truth)
│   ├── market-summary.md          ← Market analysis & data ownership matrix
│   ├── apple-approval.md          ← App Store compliance guide
│   └── ...                        ← Architecture research docs
│
└── packages/
    └── ev_protocol/         ← Pure Dart interface package (zero dependencies)
        └── lib/
            ├── ev_protocol.dart    ← Barrel export
            └── src/
                ├── core/           ← Result type, DHT key, pubkey, timestamp
                ├── identity/       ← Identity service + models
                ├── event/          ← Event + RSVP service + models
                ├── group/          ← Group + Vessel service + models
                ├── media/          ← Media reference service + models
                ├── payment/        ← Payment + Ticket service + models
                ├── chat/           ← Chat service + models
                ├── search/         ← Search service + models
                ├── moderation/     ← Moderation service + models
                ├── sync/           ← Offline sync service
                ├── schema/         ← Lexicon registry + validator
                └── sailing/        ← Sailing extension (race, course, track)
```

## Quick Start

```dart
import 'package:ev_protocol/ev_protocol.dart';

// All services are abstract — implement with your backend:
class VeilidEventService implements EvEventService { ... }
class VeilidChatService implements EvChatService { ... }
class VeilidIdentityService implements EvIdentityService { ... }
```

## Design Principles

| Principle | Description |
|---|---|
| **Privacy by default** | All communication E2E encrypted, IPs hidden via private routing |
| **Data ownership** | Every record signed by creator's key — no server can modify user data |
| **App portability** | Data lives in the protocol, not in any app |
| **Graceful degradation** | Core functions work without any server |
| **Schema-first** | All data conforms to versioned Lexicon schemas |
| **Payment boundary** | Protocol carries payment schemas; money moves off-protocol |
| **Zero base cost** | Core infrastructure cost is $0 |

## Documentation

| Document | Description |
|---|---|
| [Protocol Spec v0.1](docs/ev-protocol-spec-v0.1.md) | Formal specification — the source of truth |
| [Market Summary](docs/market-summary.md) | SWOT analysis, data ownership matrix |
| [Apple Approval](docs/apple-approval.md) | App Store compliance for P2P/Veilid |
| [Payment Architecture](docs/ev-protocol-payments.md) | Payment schema design |
| [Chat Architecture](docs/use-cases-chat.md) | Real-time chat via DHT + AppMessage |
| [Search Architecture](docs/ev-protocol-search-architecture.md) | 3-tier search system |
| [Veilid Assessment](docs/veilid-risk-assessment.md) | Risk analysis for Veilid dependency |

## License

MPL-2.0
