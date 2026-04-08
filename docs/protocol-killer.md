# EV Protocol — Architecture Decision & Competitive Analysis

> A complete audit of the ev_protocol stack, Veilid transport viability, Search Level feasibility, operational cost modelling at scale, and competitive benchmarking against Eventbrite and Spond.
>
> *Last updated: 2026-04-07*

---

## Table of Contents

1. [Protocol Audit Summary](#1-protocol-audit-summary)
2. [Veilid Constraints vs Protocol Assumptions](#2-veilid-constraints-vs-protocol-assumptions)
3. [Search Levels 1–3 — Honest Assessment](#3-search-levels-13--honest-assessment)
4. [The RSVP Black Hole](#4-the-rsvp-black-hole)
5. [The Three Options](#5-the-three-options)
6. [Build Time & Developer Effort](#6-build-time--developer-effort)
7. [Technology Maturity](#7-technology-maturity)
8. [Security Assessment](#8-security-assessment)
9. [Operational Cost at Scale](#9-operational-cost-at-scale)
10. [Competitive Benchmarking](#10-competitive-benchmarking)
11. [Decision Summary](#11-decision-summary)
12. [Recommendation](#12-recommendation)
13. [Open Questions](#13-open-questions)

---

## 1. Protocol Audit Summary

After reading every file in `ev_protocol` (12 service interfaces, 20+ data models) and `ev_protocol_veilid` (4 sync files, 4 DB tables, 1 crypto service):

| Fact | Detail |
|------|--------|
| Protocol interfaces defined | 12 services, 20+ models (~3,000 lines) |
| Interfaces with implementations | **3** (Sync, Event repo, Identity repo) |
| Interfaces with zero implementation | **9** (Chat, Group, Media, Payment, Moderation, Search, Schema, Lexicon, Sailing) |
| Interfaces consumed by Sailor app | **3** (EvEvent, EvRsvp, EvSyncService — but via repo wrappers, not directly) |
| Critical bugs | Registry write fails on secondary devices; `restoreFromBackup()` generates new key |
| RSVP reverse lookup | **Impossible** on current architecture — no discovery path from Event→RSVPs |
| Search Levels 1–3 | **Unachievable** on Veilid DHT without centralised infrastructure |

### What Exists vs What's Implemented

| Service | Interface | Sailor Uses? | Veilid Impl? |
|---------|-----------|:------------:|:------------:|
| **EvEventService** | `ev_event_service.dart` (88 lines) | ✅ Partially (via repo) | ❌ None |
| **EvSyncService** | `ev_sync_service.dart` (95 lines) | ✅ Yes | ✅ `VeilidSyncService` |
| **EvIdentityService** | `ev_identity_service.dart` (94 lines) | ✅ Partially (via auth repo) | ❌ None |
| **EvSearchService** | `ev_search_service.dart` (76 lines) | ❌ Not used | ❌ None |
| **EvGroupService** | `ev_group_service.dart` (93 lines) | ❌ Not used | ❌ None |
| **EvChatService** | `ev_chat_service.dart` (116 lines) | ❌ Not used | ❌ None |
| **EvMediaService** | `ev_media_service.dart` (63 lines) | ❌ Not used | ❌ None |
| **EvPaymentService** | `ev_payment_service.dart` (114 lines) | ❌ Not used | ❌ None |
| **EvModerationService** | `ev_moderation_service.dart` (91 lines) | ❌ Not used | ❌ None |
| **EvSchemaValidator** | `ev_schema_validator.dart` (77 lines) | ❌ Not used | ❌ None |
| **EvLexiconRegistry** | `ev_lexicon.dart` (159 lines) | ❌ Not used | ❌ None |
| **EvSailingService** | `ev_sailing_service.dart` (~100 lines) | ❌ Not used | ❌ None |

> **9 of 12 service interfaces have ZERO implementations and ZERO consumers.** The protocol package is ~3,000 lines of aspirational API surface with no backing code.

### ev_protocol_veilid — What's Actually Built

| Component | Status | Notes |
|-----------|--------|-------|
| `AppDatabase` (Drift) | ✅ Working | 4 tables: events, RSVPs, identities, sync queue |
| `VeilidSyncService` | ✅ Working | Outbound queue processing, inbound discovery |
| `RealVeilidNode` | ⚠️ Broken | Registry write fails on secondary devices |
| `MockVeilidNode` | ✅ Working | In-memory fallback |
| `VeilidCryptoService` | ⚠️ Partial | Keypair gen works; restore generates NEW keypair |
| `SeedDataService` | ✅ Working | 6 local fixture events |
| `EvProtocolVeilid` base | ❌ Empty | 3 TODOs, no code |

---

## 2. Veilid Constraints vs Protocol Assumptions

The `ev_protocol` interfaces were designed assuming capabilities Veilid does not have:

### Single-Owner DFLT Records Break Multi-Writer Assumptions

| Interface Method | Assumes | Veilid Reality |
|-----------------|---------|----------------|
| `EvEventService.updateEvent()` | Any authorised user can update | Only the creator keypair can write |
| `EvChatService.sendMessage()` | Multi-writer DHT channel | Each message needs its own DFLT record |
| `EvGroupService.addMember()` | Admin writes to group roster | Only group creator can write |
| `EvModerationService.reportContent()` | Reports written to shared record | Each report needs its own record + discovery |
| `EvSearchService.registerEvent()` | Write to shared search index | Cannot write to another key's DHT record |

> The `SMPL` multi-writer schema exists in Veilid but is poorly documented, untested in production, and has inconsistent Dart FFI support.

### The 32KB Payload Limit

- `EvEvent.toJson()` with full ticketing, location, tags: ~2–4KB per event
- Announcement record storing 100 event keys: ~8KB ✅
- Announcement record storing 500 event keys: ~40KB ❌ exceeds limit
- Chat channel with message history: exceeds immediately

### No Query/Filter Capability

Veilid DHT is a key→value store. `get(key)` and `set(key, value)`. Nothing else.

| Interface Method | Requires | Veilid Provides |
|-----------------|----------|-----------------|
| `searchNearby(lat, lng, radius)` | Geospatial index | Nothing |
| `searchByText(query)` | Full-text index | Nothing |
| `searchByDateRange(from, to)` | Date range index | Nothing |
| `listRsvps(eventDhtKey)` | Reverse index lookup | Nothing |
| `listEventChannels(eventDhtKey)` | Foreign key lookup | Nothing |
| `listMyUpcomingEvents()` | Multi-criteria query | Nothing |

---

## 3. Search Levels 1–3 — Honest Assessment

### Level 1: Deterministic Well-Known Keys + Geohash

**Documented approach**: `sha256('events-index:perth:tech:v1')` → shared DHT record.

**Fatal flaw**: To create a DHT record at a deterministic key, you need the keypair that created it. If you publish the private key so anyone can write, anyone can also **delete all entries or write garbage**. Without access control, shared indices are a griefing vector.

**Verdict**: ❌ Not viable as documented.

### Level 2: Community Curators

**Documented approach**: Trusted community member maintains a curated list.

**Reality**: Works, but:
- Manual curation doesn't scale
- Single point of failure per community
- No way for event creators to self-register
- Curator must be online to update

**Verdict**: ⚠️ Technically viable but operationally fragile. Works for a sailing club with 1 admin.

### Level 3: App-Level Search Node (Opt-In VPS)

**Documented approach**: VPS crawls DHT records, builds search index, serves results.

**Reality**: This is a **centralised server** with extra steps. Same architecture as a PDS or Relay, without the standards, ecosystem, or tooling.

**Verdict**: ⚠️ Works, but it's literally building a traditional server.

---

## 4. The RSVP Black Hole

The most critical missing piece:

```
Current flow:
1. Alice creates Event → writes to her DFLT record → announces key ✅
2. Bob discovers Event → reads Alice's record ✅
3. Bob RSVPs → creates RSVP in local SQLite → queues sync ✅
4. Sync pushes RSVP to Bob's own DFLT record ✅
5. Alice needs to see Bob's RSVP → ??? HOW ???

Alice has NO WAY to discover Bob's RSVP because:
- Bob's RSVP is in Bob's DHT record
- Alice doesn't know Bob's DHT key
- There is no reverse index from Event → RSVPs
- The announcement record only contains event keys, not RSVP keys
```

`EvEventService.listRsvps(eventDhtKey)` is **impossible to implement** on Veilid without:
1. Bob manually sending Alice his RSVP key (terrible UX)
2. A shared multi-writer record per event (SMPL schema, untested)
3. Alice polling ALL known peers for RSVPs matching her event (O(n) per event per peer)

---

## 5. The Three Options

### Option A — Trim & Fix Veilid (P2P Prototype)
Strip to working core. Per-device announcement records. Manual key exchange. No search. "Close friends" model.

### Option B — Custom Relay Server
Keep offline-first SQLite + sync queue. Replace Veilid transport with a lightweight REST API server (Dart Shelf, Go, or Rust). Server handles storage, indexing, RSVP aggregation.

### Option C — AT Protocol (PDS + Relay)
Replace Veilid with AT Protocol infrastructure. Use Lexicon schemas compatible with Smoke Signal. Full ecosystem interop.

---

## 6. Build Time & Developer Effort

| Dimension | A: Veilid P2P | B: Custom Relay | C: AT Protocol |
|-----------|:-:|:-:|:-:|
| **Time to working cross-device sync** | 1–2 weeks | 2–3 weeks | 4–6 weeks |
| **Time to RSVP visibility** | 2–3 weeks | 1 week (trivial SQL join) | 2 weeks (Lexicon + PDS) |
| **Time to search/discovery** | ❌ Not achievable | 1 week (SQL FTS5) | 2 weeks (AppView or Relay query) |
| **Time to chat** | 4–6 weeks (complex) | 2 weeks (WebSocket + DB) | 3 weeks (AT Protocol DMs) |
| **Total to MVP (events + RSVP + search)** | **4–6 weeks** (search won't work) | **4–5 weeks** | **8–10 weeks** |
| **Ongoing maintenance burden** | High (Veilid FFI updates) | Medium (standard server ops) | Medium (PDS updates) |
| **Documentation quality** | ⚠️ Poor (sparse Veilid docs) | ✅ Standard patterns | ✅ Good (atproto.com) |

---

## 7. Technology Maturity

| Dimension | A: Veilid P2P | B: Custom Relay | C: AT Protocol |
|-----------|:-:|:-:|:-:|
| **Protocol age** | ~3 years (2023) | N/A (proven patterns) | ~4 years (2022) |
| **Production apps** | VeilidChat (invite-only beta) | Thousands of platforms | Bluesky (30M+), Smoke Signal |
| **Flutter/Dart SDK** | ⚠️ Official FFI, rough edges | ✅ Standard HTTP | ⚠️ Community `atproto.dart` |
| **Mobile stability** | ⚠️ Battery drain, background issues | ✅ Standard HTTP client | ✅ Standard HTTP client |
| **Data durability** | ⚠️ DHT records can expire | ✅ Server DB with backups | ✅ PDS with repo export |
| **Breaking change risk** | 🔴 High (pre-1.0) | 🟢 Low (you control API) | 🟡 Medium |

---

## 8. Security Assessment

| Dimension | A: Veilid P2P | B: Custom Relay | C: AT Protocol |
|-----------|:-:|:-:|:-:|
| **E2E encryption** | ✅ Native | ⚠️ Must implement | ⚠️ TLS only; PDS reads data |
| **IP privacy** | ✅ Onion-style routing | ❌ Server sees client IP | ❌ PDS sees client IP |
| **Identity model** | ✅ Self-sovereign Ed25519 | ✅ Ed25519 + server tokens | ⚠️ DID:PLC (centralised dir) |
| **Data sovereignty** | ✅ Device + DHT | ⚠️ Server (self-hostable) | ⚠️ PDS (portable) |
| **Spam/abuse resistance** | ❌ No mechanism | ✅ Rate limiting, moderation | ✅ Labelers, rate limits |

---

## 9. Operational Cost at Scale

### Infrastructure Cost Per Month

| Scale | A: Veilid P2P | B: Custom Relay | C: AT Protocol |
|-------|:-:|:-:|:-:|
| **10,000 users** | **$0** | **$20–50/mo** | **$40–80/mo** |
| **1,000,000 users** | **$0** | **$500–2,000/mo** | **$300–1,500/mo** |
| **10,000,000 users** | **$0** | **$5,000–15,000/mo** | **$3,000–10,000/mo** |

### Hidden Costs — The "$0 Infrastructure" Trap

| Cost Type | A: Veilid P2P | B: Custom Relay | C: AT Protocol |
|-----------|:-:|:-:|:-:|
| **User battery/data** | 🔴 Significant (DHT node) | 🟢 Minimal | 🟢 Minimal |
| **User churn from UX friction** | 🔴 Manual key exchange, slow sync | 🟢 Standard UX | 🟢 Standard UX |
| **Developer debugging time** | 🔴 DHT is opaque | 🟢 Server logs, SQL | 🟡 AT learning curve |

> **Option A shows $0 server cost, but shifts cost to users.** Each device runs a DHT node: 50–200MB extra data/month, 5–15% extra battery/day, 2–10 second sync latency. At 10M users, you have $0 server cost but potentially millions in lost users from battery drain and slow UX.

---

## 10. Competitive Benchmarking

### The Competitor Landscape

There are three tiers of competitors relevant to Sailor:

**Tier 1 — Direct threat (sports/sailing club management):**
| Platform | Users | Model | Funding | Status (Apr 2026) |
|----------|:-----:|-------|:-------:|:-:|
| **Spond** | 3M MAU | Free + transaction fees | $17M raised | ✅ Active, growing |
| **TeamSnap** | 25M+ | Freemium ($13–24/mo) | $85M+ raised | ✅ Active |
| **Heja** | 1M+ | Free + premium | Seed funded | ✅ Active |
| **SportsEngine** | 35M+ | Platform fee | Acquired by NBC Sports | ✅ Active |

**Tier 2 — Adjacent (event platforms):**
| Platform | Users | Model | Status |
|----------|:-----:|-------|:-:|
| **Eventbrite** | 100M+ | 3.7% + $1.79/ticket | Public company |
| **Luma** | ~5M | Free + 5% or $59/mo | VC-funded |
| **Partiful** | ~10M | Free (growth mode) | VC-funded |

**Tier 3 — Australian sailing-specific:**
| Platform | Purpose | Status |
|----------|---------|:-:|
| **revSPORT** | Australian Sailing's official membership, finance & event system | ✅ Mandated |
| **TopYacht** | Race results & event management | ✅ Standard in AU |
| **SailSys** | Race management & scoring | ✅ Used by major clubs |

### Spond — Deep Dive (Primary Competitive Threat)

#### Current Status (April 2026)
Spond is **alive, well-funded, and growing**. No acquisition, no shutdown, no pivot. They raised £8M from Verdane in 2021 and have continued raising since (~$17M total). They're valued at ~$25–30M and are actively expanding in the UK, US, Germany, and France. Their app was last updated in March 2026.

#### What Spond Does Well

| Capability | What It Looks Like | Why It Wins |
|------------|-------------------|-------------|
| **1-tap RSVP** | Parent opens push notification → taps "Going" → done | 2-second interaction vs. Sailor's broken flow |
| **Attendance dashboard** | Coach sees 14/18 confirmed, 2 maybe, 2 not replied | Real-time headcount for planning |
| **Sub-groups** | "U14 Boys", "Race Crew", "Volunteers" within one club | Natural sailing club structure |
| **Guardian management** | Parent accounts linked to child accounts | Youth sailing compliance |
| **Payment collection** | "Pay $50 membership fee" → Stripe → money in club account | Clubs need this, Eventbrite doesn't serve it |
| **Group chat** | Integrated chat per team/sub-group + DMs | Replaces WhatsApp groups |
| **Fundraising** | Digital fundraiser campaigns within the app | Revenue for Spond, value for clubs |
| **Brand partnerships** | Non-intrusive sponsors in the feed | Revenue without subscription fees |

#### Spond's Tech Stack
```
Backend:   Java, Spring Boot, JPA (microservices)
Frontend:  React, TypeScript
Infra:     AWS, Kubernetes, CircleCI, ArgoCD, Terraform
Data:      Databricks, dbt, Fivetran
Payments:  Stripe
```
Nothing exotic. Purely product-driven value, not protocol-driven.

#### Spond's Estimated Unit Economics
| Metric | Value |
|--------|-------|
| MAU | ~3,000,000 |
| Total funding | ~$17M |
| Estimated annual infra cost | $2–5M |
| **Infra cost per MAU/month** | **$0.10–0.15** |
| Revenue model | Transaction fees + brand partnerships + fundraising cuts |
| Profitability | Not yet (growth stage) |

### Australian Sailing Club Context

Australian sailing clubs typically use a **three-layer** tool stack. Understanding this is critical for Sailor's positioning:

```
Layer 1: GOVERNANCE (mandated)
├── revSPORT — Australian Sailing's official membership, finance & event system
├── Used for: member registrations, insurance, club affiliation
└── Status: Non-optional. Clubs MUST use this for Australian Sailing compliance.

Layer 2: RACE MANAGEMENT (specialised)
├── TopYacht — Race results, event management, series scoring
├── SailSys — Alternative race management & scoring
└── Status: Deeply entrenched. Years of historical results data.

Layer 3: DAY-TO-DAY COORDINATION (replaceable)
├── WhatsApp groups — "Who's coming Saturday?"
├── Spond — Attendance, scheduling, chat
├── Email / committee meetings — Announcements
├── Facebook groups — Community engagement
└── Status: ← THIS IS WHERE SAILOR CAN WIN
```

**Sailor's realistic entry point is Layer 3** — replacing WhatsApp groups and informal coordination tools. Layers 1 and 2 are locked down by mandated/entrenched systems.

### Platform Overview Comparison

| Dimension | **Eventbrite** | **Spond** | **Sailor (current)** |
|-----------|:-:|:-:|:-:|
| **Target market** | Public ticketed events | Sports clubs & team management | Sailing clubs & community events |
| **Users** | ~100M+ (public company) | ~3M MAU | 2 devices |
| **Revenue model** | 3.7% + $1.79/ticket + 2.9% processing | Free app; transaction fees + brand partnerships + fundraiser cuts | None |
| **Cost to organiser** | $2–$15+ per ticket sold | $0 (free tier) | $0 |
| **Tech stack** | Python/Java, AWS, monolith → microservices | Java/Spring Boot, React, AWS/Kubernetes | Flutter/Dart, SQLite, Veilid P2P |
| **Infrastructure cost** | Estimated $50M+/yr | Estimated $2–5M/yr (AWS/K8s at 3M MAU) | $0 (broken) |
| **Funding** | Public company (IPO 2018) | ~$17M raised, valued ~$25–30M | Bootstrapped |
| **Infra cost per MAU** | ~$0.04/user/mo | ~$0.10–0.15/user/mo | N/A |

### Feature Comparison — What Matters for Sailing Clubs

| Feature | Eventbrite | Spond | Sailor (now) | Sailor (Option B) |
|---------|:-:|:-:|:-:|:-:|
| **Event creation** | ✅ Rich editor | ✅ Simple, fast | ✅ Basic | ✅ |
| **RSVP / attendance** | ✅ Ticketed only | ✅ **Excellent** — tap going/can't go, sub-groups | ⚠️ Local only, broken | ✅ |
| **Group/team management** | ❌ | ✅ **Core strength** — roles, sub-groups, guardians | ❌ | ✅ (buildable) |
| **Chat / messaging** | ❌ | ✅ **Built-in** — group chat + DMs | ❌ | ✅ (buildable) |
| **Payment collection** | ✅ **Core strength** | ✅ Stripe — membership fees, match fees | ❌ | ✅ (Stripe) |
| **Calendar sync** | ✅ iCal | ✅ iCal + in-app calendar | ❌ | ✅ (buildable) |
| **Push notifications** | ✅ | ✅ | ❌ | ✅ (APNS/FCM) |
| **Recurring events** | ✅ | ✅ **Excellent** — weekly training, schedules | ❌ | ✅ (buildable) |
| **Attendance tracking** | ⚠️ Check-in only | ✅ **Excellent** — history, stats, patterns | ❌ | ✅ (buildable) |
| **Discovery / search** | ✅ Public marketplace | ❌ Closed groups only | ❌ | ✅ (SQL FTS5) |
| **Offline support** | ❌ | ❌ | ✅ **Unique** | ✅ Preserved |
| **Cross-device sync** | ✅ Account-based | ✅ Account-based | ❌ Broken | ✅ |
| **Privacy / E2E** | ❌ | ❌ | ✅ **Unique** | ⚠️ Achievable |
| **Data ownership** | ❌ | ❌ | ✅ Local-first | ✅ Self-hostable |
| **Sailing-specific features** | ❌ | ❌ | ❌ | ✅ **Unique opportunity** |

### Sailor's Realistic Differentiators vs Spond

Spond is a well-funded, well-executed incumbent. Competing head-to-head on generic club management is a losing strategy. Sailor must differentiate on axes Spond *cannot or will not* cover:

| Differentiator | Why Spond Can't/Won't Match | Sailor's Opportunity |
|----------------|----------------------------|---------------------|
| **Sailing-specific features** | Spond is sport-agnostic by design — they serve football, hockey, swimming equally. No sport-specific tooling. | Race course management, weather integration, GPS tracking, start/finish lines, series scoring — all from existing codebase. |
| **Offline-first** | Spond requires connectivity. Zero offline support. | Sailors are frequently offshore/out-of-range. Offline-first is a genuine competitive moat for maritime use. |
| **Privacy / data ownership** | Spond owns all club data on their servers. GDPR compliance is their burden, not the club's choice. | Self-hostable option for clubs that want full data control. E2E encrypted chat for sensitive committee discussions. |
| **Open protocol / interop** | Spond is a closed platform. No API, no data export, no interop. | Open event protocol means clubs can federate, share events across clubs, integrate with revSPORT/TopYacht. |
| **No vendor lock-in** | If Spond raises prices or shuts down, clubs lose everything. | Self-hostable server + data export = clubs are never trapped. |

### What This Means Strategically

**Don't build "Spond but decentralised".** That's a feature-parity race you'll lose against a team with $17M and 3 years head start.

**Build "the sailing team app that works offshore."** That's a niche Spond doesn't serve and can't easily pivot to without losing their sport-agnostic positioning.

### Competitive Position by Option

**Option A (Veilid)**: Unique privacy positioning but missing table-stakes features (search, discovery, working sync). Competes on ideology, not UX. Addressable market: privacy-focused niche (~1% of event users). **Cannot achieve Spond feature parity.**

**Option B (Custom Relay)**: Full feature control, fastest path to Spond-level UX with sailing-specific features on top. Can add privacy as differentiator. Addressable market: sailing clubs → water sports → niche sports (~5-10% of sports club market). **Best path to a viable product.**

**Option C (AT Protocol)**: Smoke Signal interop gives instant content network. Decentralisation narrative. Addressable market: AT Protocol ecosystem users (~5–10%, growing). **Best long-term ecosystem play but doesn't address sailing niche.**

---

## 11. Decision Summary

| Factor | A: Veilid P2P | B: Custom Relay | C: AT Protocol |
|--------|:-:|:-:|:-:|
| Time to working demo | 🟡 2 weeks | 🟢 3 weeks | 🔴 6 weeks |
| Time to competitive MVP | 🔴 Never (search impossible) | 🟢 5 weeks | 🟡 10 weeks |
| Server cost at 10K users | 🟢 $0 | 🟢 $30/mo | 🟢 $50/mo |
| Server cost at 1M users | 🟢 $0 | 🟡 $1,000/mo | 🟡 $800/mo |
| Server cost at 10M users | 🟢 $0 | 🔴 $10,000/mo | 🟡 $7,000/mo |
| User-side cost (battery/data) | 🔴 High | 🟢 None | 🟢 None |
| Security / privacy | 🟢 Excellent | 🟡 Good (with effort) | 🟡 Good |
| Technology maturity | 🔴 Pre-production | 🟢 Proven | 🟡 Maturing |
| Search & discovery | 🔴 Impossible | 🟢 Trivial | 🟢 Built-in |
| RSVP aggregation | 🔴 Broken | 🟢 Trivial | 🟢 Standard |
| Ecosystem / network effects | 🔴 None | 🟡 Build from zero | 🟢 Smoke Signal + Bluesky |
| Data sovereignty | 🟢 Full | 🟡 Server-dependent | 🟡 PDS-portable |
| Offline-first | 🟢 Native | 🟢 Preserved | 🟢 Can preserve |
| Code reuse from current | 🟢 90% | 🟢 80% | 🟡 60% |
| Spond feature parity | 🔴 Impossible | 🟢 Achievable | 🟡 Achievable |

---

## 12. Recommendation

**Option B (Custom Relay) is the strongest overall choice:**

1. **Fastest path to a competitive product** — search, RSVPs, and sync "just work" with a standard server
2. **$30/mo at 10K users** is trivially fundable and 100x cheaper than user-side battery costs of Veilid
3. **Preserves 80% of existing code** — the offline-first SQLite + sync queue architecture transfers directly
4. **Privacy can be added incrementally** — E2E encryption for private events, signed records for data integrity
5. **No vendor lock-in** — you own the server, the protocol, and the data format
6. **Can evolve to AT Protocol later** — add `ev_protocol_at` as a second transport without discarding the relay
7. **Spond parity is achievable** — RSVP, groups, chat, payments all map to standard server patterns

Option A is a dead end for anything beyond a 2-device demo. Option C is the right long-term play if Smoke Signal interop matters, but at 2x the build time.

---

## 13. Open Questions

1. **Privacy priority**: Is "zero server" a hard requirement (→ must be A), or is "encrypted + self-hostable server" sufficient (→ B)?
2. **Smoke Signal**: Do you want interop with the AT Protocol event ecosystem (→ C), or building your own (→ A or B)?
3. **Timeline**: Working demo this week (→ A), or solid foundation in a few weeks (→ B or C)?
4. **Funding model**: Transaction fees (favours B), or ideologically free (favours A or C)?

---

*Related docs: [bidirectional_sync_plan.md](./bidirectional_sync_plan.md) | [veilid-scale-identity-search.md](./veilid-scale-identity-search.md) | [protocol-candidates-solving-weaknesses.md](./protocol-candidates-solving-weaknesses.md)*
