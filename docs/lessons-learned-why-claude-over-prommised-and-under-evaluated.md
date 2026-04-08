# Lessons Learned: Why Claude Over-Promised and Under-Evaluated

> A post-mortem on how an AI coding assistant led a solo developer through ~565KB of research documentation, ~3,900 lines of aspirational protocol interfaces, and multiple architectural pivots — before a cold-eyed audit revealed that 75% of it was unusable.
>
> *Written: 2026-04-08*

---

## The Numbers

Before the reckoning:

| Artefact | Volume | Actually Used |
|----------|--------|:------------:|
| Research & architecture docs | **20 files, 14,303 lines, 565KB** | ⚠️ Useful as education, not as engineering |
| `ev_protocol` interfaces & models | **3,946 lines across 12 services** | **3 services** (25%) |
| `ev_protocol_veilid` implementation | **6,909 lines** | ⚠️ VeilidSyncService works; RealVeilidNode broken |
| Sailor app code | **4,405 lines** | ✅ Mostly functional (UI, local DB, state) |
| Protocols evaluated | **12+** (AT Protocol, Veilid, Holochain, Nostr, Waku, Ceramic, Filecoin, Arweave, Lens, SAFE, GUN, Matrix, XMPP, ActivityPub) | **0 shipped to production** |
| Architecture proposals generated | **6** (Veilid pure, AT Protocol pure, AT+Holochain hybrid, AT+Veilid hybrid, Nostr+Holochain, Custom Relay) | **0 validated with real users** |

**The ratio of documentation to working product was roughly 10:1.**

---

## What Happened — The Timeline

### Phase 1: "Let's Build a Decentralised Event Protocol"

Claude was asked to help build an event app. Instead of starting with a working app and adding sync later, it:

1. Designed **12 service interfaces** covering events, RSVPs, chat, groups, media, payments, moderation, search, schema validation, Lexicon registry, sailing, and identity
2. Created **20+ data models** with full JSON serialisation
3. Built ~3,000 lines of "protocol" that was really just Dart abstract classes with no implementations

**The problem**: This was architecture astronautics. 9 of those 12 services had **zero implementations and zero consumers**. They were aspirational API surfaces for features that didn't exist, couldn't exist on the chosen transport (Veilid), and weren't needed for an MVP.

### Phase 2: "Veilid Is Perfect For This"

Claude evaluated Veilid and gave it:
- Centralisation risk: **10/10** ✅
- Relay economics: **10/10** ✅
- Network lock-in: **10/10** ✅
- Privacy: **9/10** ✅
- Flutter/Dart support: **8/10** ✅

And then tucked in at the bottom:
- Ecosystem maturity: **4/10** ⚠️
- Existing social graph: **1/10** ❌
- Event discovery: **3/10** ⚠️

**The problem**: The top scores were for *theoretical protocol properties*, not for *practical buildability*. Claude rated Veilid as if "zero single points of failure" was more important than "can users actually find events" for an event discovery app.

The 4/10 maturity rating should have been the headline, not a footnote.

### Phase 3: "Let's Also Explore These 11 Other Protocols"

Instead of stopping to validate Veilid against core use cases, Claude produced:

- `decentralised-protocols-comparison.md` — 691 lines comparing 12 protocols
- `at-protocol-overview.md` — 797 lines documenting AT Protocol internals
- `hybrid-at-holochain-architecture.md` — 1,051 lines designing AT + Holochain
- `social-vs-pubsub-architecture.md` — 596 lines on social vs pub/sub theory
- `protocol-candidates-solving-weaknesses.md` — 733 lines comparing Veilid vs Waku
- `veilid-scale-identity-search.md` — 73,316 bytes on Veilid at scale
- `ipfs-deep-dive.md` — 28,376 bytes on IPFS

That's **~250KB of protocol analysis** before anyone had a working cross-device event sync.

### Phase 4: The Audit

The `protocol-killer.md` audit finally asked the questions that should have been asked in Phase 1:

> "Can a user RSVP to an event and can the event creator see it?"

**Answer: No.** The RSVP reverse lookup was architecturally impossible on Veilid.

> "Can a user search for events near them?"

**Answer: No.** Veilid DHT is `get(key)` / `set(key, value)`. No indexing. No queries. No search.

> "Do the 12 service interfaces match the transport's capabilities?"

**Answer: Most don't.** `EvChatService.sendMessage()` assumes multi-writer channels. `EvSearchService.registerEvent()` assumes a shared index. `EvGroupService.addMember()` assumes admin can write to group roster. None of these are possible with Veilid's single-owner DFLT records.

---

## The Failure Modes

### 1. Theoretical Scoring vs Practical Scoring

Claude evaluated protocols on axes like "centralisation risk" and "relay economics" — properties that matter at scale but are irrelevant when you have 2 test devices. It should have scored on:

| Should Have Scored | Why |
|-------------------|-----|
| **Can I build a working RSVP flow in 1 week?** | This is the table-stakes feature |
| **Does the SDK actually work on iOS?** | Battery drain and background limits matter |
| **Has anyone shipped a production app with this?** | VeilidChat was invite-only beta, not production |
| **Can I debug sync failures?** | DHT is opaque; server has SQL logs |
| **What happens when it breaks?** | Veilid: undocumented FFI errors. Server: standard HTTP errors. |

### 2. Designing Interfaces Before Validating Constraints

The `ev_protocol` package defined method signatures like `searchNearby(lat, lng, radius)` without checking if the transport could support spatial queries. It defined `listRsvps(eventDhtKey)` without checking if reverse lookups were possible.

**Rule violated**: "Make it work, then make it right, then make it fast." Claude went straight to "make it right" (elegant interfaces) without first establishing "make it work" (can data actually flow?).

### 3. Volume Masquerading As Progress

565KB of documentation *felt* productive because it was detailed, well-structured, and covered every angle. But documentation about a system that doesn't work is not progress — it's procrastination with good formatting.

The Mermaid diagrams were beautiful. The comparison tables were thorough. The sequence diagrams were accurate. None of it shipped.

### 4. Exploring Breadth Instead of Depth

Claude evaluated 12+ protocols at a surface level rather than deeply validating 1-2 against core use cases. The `decentralised-protocols-comparison.md` covered Nostr, Farcaster, ActivityPub, Matrix, XMPP, Ceramic, Filecoin, Arweave, Lens, Holochain, SAFE Network, and GUN.js — but never ran a single integration test against any of them.

**A 2-hour spike with `atproto.dart` creating and reading an event record would have been worth more than the entire 691-line comparison doc.**

### 5. Anchoring Bias Toward Complexity

Claude is trained on complex systems and gravitates toward elegant architecture. Given a choice between:
- A) Simple REST API that solves the problem
- B) Hybrid AT Protocol + Holochain + Bridge Service architecture

...it will produce a 1,051-line document about option B, complete with Rust DNA code, capability token flows, and a phased implementation roadmap. This document was impressively thorough AND completely impractical for a solo developer.

### 6. Not Asking the Competitive Question Early

The competitive analysis against Spond (§10 of `protocol-killer.md`) was arguably the most valuable section of all the documentation — and it was written *last*, as part of the audit that questioned everything. If it had been written *first*, the answer would have been obvious early:

> "Spond uses Java, Spring Boot, and AWS. No exotic protocols. No decentralised anything. They have 3M users. Maybe the protocol isn't the product."

### 7. Confirmation Bias in "What You Gain" Tables

Every protocol evaluation had a "What You Gain" section that read like a sales pitch. Veilid's gains were listed as "$0 infrastructure cost, true decentralisation, privacy by default, native Flutter." These were technically true but implied production-readiness that didn't exist.

The "What You Lose" tables existed but were always shorter and less emphatic. When you rate something 10/10 on three axes and bury the 1/10 score, you're selling, not evaluating.

---

## What Should Have Happened

### Week 1: Spike, Don't Spec

```
Day 1-2: Build the simplest possible cross-device event sync
         - Device A creates event → Device B sees it
         - Try Veilid DHT for real (not in MockVeilidNode)
         
Day 3:   Hit the wall
         - Discover DFLT record limitations
         - Discover DHT query limitations
         - Document ACTUAL capabilities, not theoretical ones
         
Day 4-5: Make the call
         - Can Veilid support the core use case? Y/N
         - If N: move to server or AT Protocol immediately
         - If Y: build the RSVP flow next
```

Total documentation needed: **1 page** of real findings, not 20 files of theoretical analysis.

### The RSVP Test

The single question that kills or validates any architecture for an event app:

```
Alice creates an event.
Bob RSVPs "going."
Alice opens her event and sees Bob's RSVP.

Can the architecture do this in < 5 seconds
without manual key exchange?
```

If the answer is no, everything else is irrelevant.

---

## Patterns to Recognise in AI-Assisted Development

### 🚩 Red Flag: "Let Me Evaluate All Options"

When an AI produces a comparison of 12 protocols for a problem that 2 could solve, it's optimising for comprehensiveness, not decision-making. The right response is: *"Pick the two most likely candidates and spike them. We can research the others if both fail."*

### 🚩 Red Flag: Beautiful Architecture Diagrams With No Running Code

Mermaid diagrams of data flows between components that don't exist aren't architecture — they're fiction. Insist on running code before drawing boxes and arrows.

### 🚩 Red Flag: Scoring High on Ideology, Low on Practicality

"Zero single points of failure" sounds amazing. "4/10 ecosystem maturity" and "1/10 existing user base" are the actual constraints you'll fight every day. When the ideological scores dominate the practical ones, the evaluation is wish-fulfilment.

### 🚩 Red Flag: "Phase 1... Phase 2... Phase 3..."

Multi-phase implementation roadmaps for unvalidated architectures are a way to defer the hard question: "Does Phase 1 even work?" The AT + Holochain hybrid had a 4-phase roadmap spanning 12+ months. Phase 1 hadn't been validated.

### 🚩 Red Flag: Growing Documentation, Stagnant Features

If the `docs/` directory is growing faster than the `lib/` directory, you're not building a product — you're writing a thesis.

---

## What Was Actually Valuable

Not everything was wasted. Some outputs had genuine value:

| Artefact | Value |
|----------|-------|
| `protocol-killer.md` audit | **High** — the cold-eyed evaluation that broke the logjam |
| Competitive analysis (Spond, Eventbrite, AU sailing tools) | **High** — informed positioning strategy |
| Offline-first SQLite + sync queue architecture | **High** — this survives regardless of transport |
| Smoke Signal Lexicon research | **Medium** — useful if Option C is chosen |
| Sailor app UI/UX code | **High** — this is the actual product |
| `ev_protocol` core models (EvEvent, EvRsvp) | **Medium** — the data shape is ~80% reusable |
| The 9 unimplemented service interfaces | **Zero** — delete them |
| AT + Holochain hybrid architecture doc | **Zero** — an impractical architecture for a solo developer |
| 12-protocol comparison doc | **Low** — interesting reading, didn't inform a decision |

---

## Rules Going Forward

1. **Spike before you spec.** Run code against the real technology before designing interfaces.
2. **The RSVP test first.** If the core data flow doesn't work, nothing else matters.
3. **1 page per decision.** If a document exceeds 2 pages, it's exploring, not deciding.
4. **Score on buildability, not ideology.** "Can I ship this in 2 weeks?" beats "Is this theoretically decentralised?"
5. **Competitive analysis before architecture.** Know what you're competing against before choosing how to build.
6. **Kill the darlings.** Delete the 9 unimplemented interfaces. They're not a roadmap, they're dead weight.
7. **Treat AI research output as a first draft of questions, not answers.** The comparison tables are starting points for spikes, not conclusions.

---

## Summary

Claude did what language models do well: produce comprehensive, well-structured, technically accurate analysis. It did what language models do poorly: exercise judgement about what matters, when to stop researching and start building, and when an elegant architecture is worse than a simple one.

The result was a project that *looked* sophisticated — clean architecture, protocol-level thinking, competitive awareness — but couldn't do the one thing an event app must do: let someone RSVP to an event and have the organiser see it.

The fix was not better AI output. It was a human asking: *"Does any of this actually work?"*

---

*Related: [protocol-killer.md](./protocol-killer.md) | [bidirectional_sync_plan.md](./bidirectional_sync_plan.md)*
