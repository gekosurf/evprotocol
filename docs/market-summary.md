# EV Protocol: Market Summary & Strategic Assessment

> An honest assessment of the EV Protocol's market position, strengths, weaknesses, and go-to-market strategy.

## Table of Contents

- [Assessment: Do I Like It?](#assessment-do-i-like-it)
- [What's the Real Market?](#whats-the-real-market)
  - [Target Market Segments](#target-market-segments)
- [Strengths](#strengths)
  - [1. Cost Structure](#1-cost-structure-the-killer-advantage)
  - [2. Schema Extensibility](#2-schema-extensibility)
  - [3. Graceful Degradation](#3-graceful-degradation)
  - [4. True Data Ownership](#4-true-data-ownership)
  - [5. Privacy-by-Default](#5-privacy-by-default)
- [Weaknesses (Honest)](#weaknesses-honest)
  - [1. Cold Start Problem](#1-cold-start-problem--the-biggest-risk)
  - [2. Veilid Maturity](#2-veilid-maturity-️)
  - [3. First-Load Latency](#3-first-load-latency-️)
  - [4. "Decentralised" Is a Hard Sell](#4-decentralised-is-a-hard-sell-️)
  - [5. Legal Grey Areas](#5-legal-grey-areas-️)
  - [6. No Discovery Network Effect](#6-no-discovery-network-effect-️)
- [Strategic Assessment](#strategic-assessment)
  - [The Play](#the-play)
  - [The Risk](#the-risk)
  - [The Timeline](#the-timeline)
- [SWOT Summary](#swot-summary)
- [Data Ownership, Sharing & App Portability by Role](#data-ownership-sharing--app-portability-by-role)
  - [1. System Owner](#1-system-owner-protocol-operator)
  - [2. Event Organiser](#2-event-organiser)
  - [3. Attendee](#3-attendee)
  - [4. Venue Partner](#4-venue-partner)
  - [5. Artist / Performer](#5-artist--performer)
  - [6. Search Node Operator](#6-search-node-operator)
  - [Data Ownership Summary Matrix](#data-ownership-summary-matrix)
  - [Compare: Eventbrite Data Ownership](#compare-eventbrite-data-ownership)
- [The Bottom Line](#the-bottom-line)

---

## Assessment: Do I Like It?

**Yes, genuinely.** The architecture is one of the most coherent decentralised application designs I've seen. Most "web3" or "decentralised" projects bolt crypto onto a centralised backend and call it innovation. The EV Protocol is architecturally honest — every layer has a real reason to exist, the separation of concerns is clean (protocol handles coordination, Stripe handles money, R2 handles blobs), and the cost structure is genuinely revolutionary ($200/mo vs $200K/mo at 100M users is not marketing — it's math).

The three-tier search design is the standout piece. Most decentralised projects hit a wall at "but how do you search?" and either give up, add a centralised index (defeating the purpose), or hand-wave. The EV Protocol actually solves it by exploiting the fact that **events cluster geographically and temporally**, making the search space orders of magnitude smaller than general-purpose search.

---

## What's the Real Market?

**The market is NOT "replace Eventbrite."** That's the wrong framing and it would kill you.

Here's why:

```
Eventbrite's moat is not technology. It's:
  1. Trust         — "I'll put my credit card into Eventbrite"
  2. Discovery     — "I browse Eventbrite to find events"
  3. Convenience   — "My grandma can create an event in 5 minutes"
  4. Brand         — "Eventbrite tickets look legit"

EV Protocol does NOT compete on any of these axes.
It competes on:
  1. Cost          — $0 platform fee vs 3.7% + $1.79/ticket
  2. Ownership     — Your data, your attendees, your relationship
  3. Privacy       — E2E encrypted, no data harvesting
  4. Independence  — No platform can deplatform you or change terms
```

### Target Market Segments

| Segment | Pain Point | EV Protocol Fit |
|---|---|---|
| **Community organisers** (clubs, meetups, maker spaces) | Paying Eventbrite $2-5/ticket for events they built | ⭐⭐⭐⭐⭐ Perfect — $0 fees |
| **Niche sports** (sailing, cycling, parkrun) | Need domain-specific features (GPS, results, standings) | ⭐⭐⭐⭐⭐ Extensible schemas |
| **Underground/indie music** | Don't want corporate platforms controlling their audience | ⭐⭐⭐⭐ Strong privacy story |
| **Privacy-conscious communities** | Activist events, support groups, sensitive gatherings | ⭐⭐⭐⭐⭐ E2E + no metadata |
| **International / developing markets** | Eventbrite doesn't serve their country, Stripe fees are painful | ⭐⭐⭐⭐ Crypto payment option |
| **Mainstream consumers** | "I just want to buy a concert ticket" | ⭐⭐ Wrong audience — they want Eventbrite's brand trust |

> [!IMPORTANT]
> **The beachhead is niche communities, not mainstream consumers.** Specifically: organised sports clubs, recurring community events, and privacy-sensitive gatherings. These people are already frustrated, already somewhat technical, and the cost savings are tangible (a sailing club running 30 events/year saves $3,000-5,000 in Eventbrite fees alone).

---

## Strengths

### 1. Cost Structure (The Killer Advantage)

Not 10% cheaper. Not 50% cheaper. **1,000-2,500x cheaper.**

```
At 100M users:   $200/mo     vs  $200,000-500,000/mo
At 1M users:     $100/mo     vs  $50,000/mo
At 10K users:    $0-15/mo    vs  $98/mo + per-ticket fees
At 100 users:    $0/mo       vs  $0-98/mo
```

This isn't marginal — it's a different category entirely. The infrastructure cost approaches zero because every user's device contributes network capacity. More users make the network *faster*, not more expensive.

### 2. Schema Extensibility

This is underrated. No other event platform lets you add "GPS track recording" or "race results with handicap scoring" without building a whole new product. The Lexicon system means any community can extend the protocol for their domain without permission, forks, or protocol changes.

```
Sailing club needs:    GPS tracks, course marks, race results, handicaps
Music scene needs:     Set times, artist profiles, live reactions
Tech meetup needs:     Speaker bios, presentation slides, Q&A
Activism needs:        Anonymous RSVPs, encrypted attendee lists

ALL OF THESE: just new Lexicon schemas registered at the app level.
Zero protocol changes. Zero infrastructure changes.
```

### 3. Graceful Degradation

When Eventbrite goes down, every event on the platform dies. When EV Protocol's search nodes go down, search slows from 200ms to 4 seconds. Events, tickets, and chat **still work**. The app gets worse, it doesn't die. This is a genuinely novel property that no centralised platform can match.

### 4. True Data Ownership

This isn't marketing fluff. Every record is cryptographically signed by the user's key in their Secure Enclave. No server operator, no government agency, no corporate policy change can modify or delete your data. In a world of increasing platform deplatforming and policy shifts, this matters.

```
Compare:
  Eventbrite:     They own your attendee list. Change ToS anytime.
  Meetup:         Raised prices 40% overnight in 2019. No recourse.
  Facebook Events: Algorithmic suppression. Shadow-banning. Pay to reach.
  EV Protocol:    Your data. Your keys. Your attendees. Forever.
```

### 5. Privacy-by-Default

Not privacy as a premium feature. Privacy as the baseline. E2E encrypted events, IP-hidden networking, onion routing. For activist communities, LGBTQ+ events in hostile countries, support groups — this is life-or-death important.

---

## Weaknesses (Honest)

### 1. Cold Start Problem ❌ (The Biggest Risk)

Events are a two-sided marketplace. Organisers won't come without attendees. Attendees won't come without events.

Eventbrite has 100M registered users. EV Protocol has 0. A beautifully architected empty platform is still empty.

```
Mitigation:
  Start with ONE community (your sailing club).
  Build for them. They bring their friends. Grow organically.
  Don't try to launch as a platform — launch as a tool.
```

### 2. Veilid Maturity ⚠️

Veilid is real, open-source, and functional. But:

```
Concerns:
  - Small developer community (~100-200 active devs)
  - Limited production apps (VeilidChat is the main one)
  - Flutter FFI bindings are functional but not polished
  - Documentation has gaps
  - No major company backing it

Mitigation:
  Abstract the network layer behind interfaces.
  If Veilid dies, you could (painfully) swap to libp2p
  or a custom DHT. It would take months, not years.
```

### 3. First-Load Latency ⚠️

```
DHT lookups:   2-5 seconds for first load
Eventbrite:    200ms

Cached user:   Both are instant
First-time:    EV feels slow
```

This is the "decentralised tax" — you pay it on every P2P protocol. It's acceptable for engaged users, but it **will** lose casual, impatient newcomers.

### 4. "Decentralised" Is a Hard Sell ⚠️

Normal people don't care about decentralisation. They care about: *"Does it work? Is it cheap? Is it easy?"*

```
If you lead with "decentralised protocol," you're talking
to crypto-bros, not event organisers.

Reframe:
  ❌ "Decentralised event protocol built on Veilid DHT"
  ✅ "Free event platform. No fees. You own your data."

Same product. Human pitch.
```

### 5. Legal Grey Areas ⚠️

No centralised moderation means:

```
  - No DMCA takedown compliance (required in US/EU)
  - No ability to respond to law enforcement requests
  - No Terms of Service enforcement
  - Potential liability for hosting illegal content

The on-device AI moderation + organiser admin helps,
but it's not legally sufficient in many jurisdictions.
A truly decentralised event platform may face legal challenges.
```

### 6. No Discovery Network Effect ⚠️

```
Eventbrite users browse Eventbrite to FIND events.
That's a massive discovery channel the EV Protocol lacks.

EV Protocol relies on:
  - Direct sharing (links, QR codes)
  - AT Protocol bridge (Bluesky posts)
  - Search nodes (Tier 3)
  - Word of mouth

This works for community events (organiser shares with
their audience) but doesn't help with serendipitous
discovery ("what's happening in Perth this weekend?").
```

---

## Strategic Assessment

### The Play

```
DON'T build "decentralised Eventbrite."
DO build "the free toolkit for community event organisers."
```

**Lead with:**

- ✅ Zero platform fees
- ✅ Own your attendee relationships
- ✅ Works for YOUR specific community (sailing, music, whatever)
- ✅ Add the features YOU need (GPS tracks, race results, etc.)

**Don't lead with:**

- ❌ "Decentralised"
- ❌ "Protocol"
- ❌ "DHT"
- ❌ "Cryptographic identity"

The tech is the **HOW**, not the **WHAT**. Users want the result, not the mechanism.

### The Risk

**Veilid maturity. Full stop.**

If Veilid delivers on its promise: the architecture is sound. If Veilid stalls: you have a beautiful design with no runtime.

### The Timeline

```
0-6 months:    Build for your sailing club. 50 users.
               Prove the tech works. Find the friction.
               Ship GPS tracks, race results, event chat.

6-12 months:   Expand to 3-5 Perth communities. 500 users.
               Add 2-3 more community schemas (music, tech meetups).
               Test payment flow with real money.

12-24 months:  Open to any community. 5,000 users.
               Deploy first Tier 2 search indexes.
               AT Protocol bridge for social discovery.

24+ months:    If it's working, add Tier 3 search nodes.
               Public launch. 50,000+ users.
               The architecture is proven at this point.
```

> [!CAUTION]
> **DO NOT try to scale to 100M before you have 100.** The architecture *supports* 100M. The go-to-market needs to start at 50. Every successful platform started as a tool for a specific community, not as a protocol for the world.

---

## SWOT Summary

```
     STRENGTHS                          WEAKNESSES
  ┌─────────────────────┐           ┌──────────────────────┐
  │ 1000x cheaper infra │           │ Cold start (0 users) │
  │ Schema extensibility│           │ Veilid maturity      │
  │ True data ownership │           │ First-load latency   │
  │ Privacy by default  │           │ Legal grey areas     │
  │ Graceful degradation│           │ Hard to explain      │
  │ $0 platform fees    │           │ No brand trust yet   │
  └─────────────────────┘           └──────────────────────┘

     OPPORTUNITIES                      THREATS
  ┌─────────────────────┐           ┌──────────────────────┐
  │ Platform fee fatigue │           │ Veilid gets abandoned│
  │ Privacy backlash     │           │ Eventbrite goes free │
  │ Niche sports/clubs   │           │ Apple restricts P2P  │
  │ Developing markets   │           │ Legal/regulatory     │
  │ AT Protocol growth   │           │ Centralised competitor│
  │ AI-powered features  │           │ with better UX wins  │
  └─────────────────────┘           └──────────────────────┘
```

---

## Data Ownership, Sharing & App Portability by Role

Every user in the EV Protocol ecosystem has a clear answer to three questions:
1. **What do I own?** — Data signed by my private key, stored on my device + replicated to DHT
2. **What do I share?** — Data I explicitly publish or grant access to
3. **Can I use a different app?** — Yes, my data is in an open protocol with Lexicon schemas — any compatible app can read it

---

### 1. System Owner (Protocol Operator)

> *The entity that decides to deploy EV Protocol for their community (e.g., you, the app developer)*

```
OWNS:
  ┌──────────────────────────────────────────────────────────────┐
  │  App binary & custom Lexicon schemas                         │
  │  Bootstrap node infrastructure ($15/month)                   │
  │  Tier 3 search node infrastructure (optional, $15-50/month)  │
  │  App Store listing & brand                                   │
  │  Stripe Connect platform account                             │
  │  R2/S3 media storage bucket (optional shared storage)        │
  └──────────────────────────────────────────────────────────────┘

DOES NOT OWN:
  ❌ User data (cryptographically impossible — no private keys)
  ❌ Event records (owned by organisers)
  ❌ Attendee lists (owned by organisers)
  ❌ Payment receipts (owned by payers)
  ❌ Photos/media references (owned by uploaders)
  ❌ The protocol itself (open standard, MPL-2.0)

SHARES:
  → Bootstrap node addresses (public, enables network joining)
  → Search indexes (public, aggregated from public event data)
  → Lexicon schema definitions (public, so other apps can interop)

APP PORTABILITY:
  The system owner does NOT have lock-in over users.
  If users don't like your app, they can use any other EV Protocol
  app and bring ALL their data with them (events, RSVPs, receipts,
  photos, chat history). Your app is a window into the protocol,
  not a walled garden.
  
  This is both the strength and risk:
    ✅ Users trust you more because they CAN leave
    ⚠️ You can't lock users in with data hostage tactics
```

---

### 2. Event Organiser

> *A sailing club commodore, DJ promoter, community meetup host*

```
OWNS (signed by organiser's private key):
  ┌──────────────────────────────────────────────────────────────┐
  │  Event records         All event metadata, description,      │
  │                        dates, location, pricing              │
  │                                                              │
  │  Ticketing config      Tiers, prices, refund policy          │
  │                                                              │
  │  Attendee list         Who RSVPed, payment receipts          │
  │                        (organiser's copy of receipts)        │
  │                                                              │
  │  Announcements         Event updates posted to DHT           │
  │                                                              │
  │  Chat channels         Discussion room configuration         │
  │                                                              │
  │  Moderation actions    Content they've hidden/removed        │
  │                                                              │
  │  Domain schemas        Race results, course maps, standings  │
  │                        (if they created domain-specific data)│
  │                                                              │
  │  Stripe payouts        Revenue from ticket sales             │
  │                        (via Stripe Connect, off-protocol)    │
  └──────────────────────────────────────────────────────────────┘

SHARES:
  → Event details (PUBLIC — anyone can read from DHT)
  → Ticketing schema (PUBLIC — anyone can see pricing)
  → Announcements (PUBLIC to attendees of the event)
  → Race results/standings (PUBLIC or PRIVATE per event settings)
  → Attendee list:
      PUBLIC events → attendee count visible, names if opted-in
      PRIVATE events → encrypted, only organiser sees full list

DOES NOT SHARE:
  ❌ Revenue data (only they + Stripe see this)
  ❌ Private notes on attendees
  ❌ Draft events (until published)
  ❌ Moderation logs (private to organiser)

APP PORTABILITY:
  Organiser's data lives in the DHT, signed by their key.
  
  Scenario: "I don't like App X anymore, switching to App Y"
    1. Install App Y (any EV Protocol compatible app)
    2. Import private key (or restore from Keychain backup)
    3. App Y reads all organiser's DHT records
    4. All events, attendee lists, results: instantly available
    5. App X is no longer needed
    
  Scenario: "I want to use BOTH App X and App Y"
    ✅ Both apps read the same DHT records
    ✅ Both can write (same private key)
    ✅ Think of it like email: multiple clients, one inbox
    
  Scenario: "I want to export all my data"
    ✅ Export from local SQLite DB at any time
    ✅ All records are JSON (Lexicon-structured)
    ✅ No API request to a server needed — data is local
```

---

### 3. Attendee

> *A sailor registering for a regatta, a fan buying a DJ ticket*

```
OWNS (signed by attendee's private key):
  ┌──────────────────────────────────────────────────────────────┐
  │  Profile              Display name, avatar, bio              │
  │                                                              │
  │  RSVPs                Every event they've RSVP'd to          │
  │                                                              │
  │  Payment receipts     Cryptographic proof of every payment   │
  │                       (ticket purchases, registrations)      │
  │                                                              │
  │  Photos uploaded      References to photos they shared       │
  │                                                              │
  │  GPS tracks           Their sailing tracks, routes           │
  │                                                              │
  │  Chat messages        Their messages in discussion rooms     │
  │                                                              │
  │  DM conversations     Private messages (E2E encrypted)       │
  │                                                              │
  │  Social connections   Who they follow / are friends with     │
  │                       (private, encrypted)                   │
  │                                                              │
  │  Ticket QR codes      Cryptographic proof of ticket          │
  │                       ownership (works offline)              │
  └──────────────────────────────────────────────────────────────┘

SHARES:
  → RSVP status (PUBLIC or PRIVATE per attendee's choice):
      "Going" → visible to other attendees
      "Going (private)" → only organiser sees
  → Photos (PUBLIC to event gallery, or PRIVATE)
  → GPS tracks (PUBLIC to event participants, or PRIVATE)
  → Chat messages (VISIBLE to channel participants)
  → Profile (PUBLIC — name/avatar visible to others)

DOES NOT SHARE:
  ❌ Payment details (card number, etc. — Stripe only)
  ❌ DM content (E2E encrypted, only recipient can read)
  ❌ Social connections list (encrypted, only owner reads)
  ❌ Location data (GPS track is opt-in, never automatic)
  ❌ Contact information (email/phone never in protocol)

APP PORTABILITY:
  Same as organiser — key-based, not app-based ownership.
  
  Scenario: "My sailing club uses App X, music events use App Y"
    ✅ Same identity (Veilid keypair) works in both
    ✅ Same payment receipts valid in both
    ✅ Same profile appears in both
    ✅ One private key = one identity across all apps
    
  Scenario: "App X shut down"
    ✅ Install any other EV Protocol app
    ✅ Import key → all data appears (events, receipts, photos)
    ✅ Nothing lost — data was never in App X's servers
    
  Scenario: "I want to delete all my data"
    ✅ Delete local SQLite DB (instant)
    ✅ Overwrite DHT records with empty data (propagates in ~5s)
    ✅ Delete media from R2/IPFS (if self-hosted)
    ✅ True deletion — no "we keep it for 90 days" retention
```

---

### 4. Venue Partner

> *RAC Arena providing venue details for the DJ event*

```
OWNS (signed by venue's private key):
  ┌──────────────────────────────────────────────────────────────┐
  │  Venue profile        Name, address, capacity, facilities    │
  │                                                              │
  │  Venue subkey data    Doors time, parking info, accessibility│
  │                       (written to event's venue subkey)      │
  │                                                              │
  │  Venue media          Photos of the venue, maps, floorplans  │
  └──────────────────────────────────────────────────────────────┘

SHARES:
  → Venue info (PUBLIC — written to event's multi-writer record)
  → Venue profile (PUBLIC — visible to event attendees)

DOES NOT OWN:
  ❌ The event record (owned by organiser)
  ❌ Attendee data (owned by attendees)
  ❌ Ticket revenue (handled by organiser's Stripe)

APP PORTABILITY:
  ✅ Venue can use any EV Protocol app to manage their subkey
  ✅ Venue's profile is protocol-level, not app-level
  ✅ Can participate in events across multiple apps/communities
```

---

### 5. Artist / Performer

> *DJ Kestra, support acts, guest speakers*

```
OWNS (signed by artist's private key):
  ┌──────────────────────────────────────────────────────────────┐
  │  Artist profile       Bio, genre, social links, photos       │
  │                                                              │
  │  Artist subkey data   Set time, setlist, rider info          │
  │                       (written to event's artist subkey)     │
  │                                                              │
  │  Published content    Promo photos, clips shared to event    │
  └──────────────────────────────────────────────────────────────┘

SHARES:
  → Artist profile (PUBLIC — visible to all event attendees)
  → Set times (PUBLIC — via event's artist subkey)
  → Promo media (PUBLIC — referenced in event gallery)

DOES NOT OWN:
  ❌ Event record (owned by promoter/organiser)
  ❌ Ticket revenue (unless payment split configured in Stripe)
  ❌ Attendee photos of them (owned by photo uploaders)

APP PORTABILITY:
  ✅ Artist can manage same identity across touring events
  ✅ Portfolio of past events readable from DHT
  ✅ Not dependent on any single promoter's app choice
```

---

### 6. Search Node Operator

> *Community member or service provider running a Tier 3 search node*

```
OWNS:
  ┌──────────────────────────────────────────────────────────────┐
  │  Search node VPS      Hardware they run ($5-20/month)        │
  │                                                              │
  │  Search index         Derived/aggregated data from public    │
  │                       events (NOT original data)             │
  │                                                              │
  │  Operator reputation  Track record of uptime, accuracy       │
  └──────────────────────────────────────────────────────────────┘

DOES NOT OWN:
  ❌ Event data (indexes are derived copies, originals in DHT)
  ❌ User data (search nodes never see private data)
  ❌ Payment data (never touches search nodes)

SHARES:
  → Search results (PUBLIC — anyone can query the node)
  → Uptime/health status (PUBLIC — community monitoring)

APP PORTABILITY:
  Search nodes are interchangeable. Any app can query any
  search node. If one goes down, apps fall back to Tier 1-2
  search (slower but functional). No vendor lock-in.
```

---

### Data Ownership Summary Matrix

| Role | Owns Data? | Signs Data? | Can Export? | Can Delete? | Can Switch Apps? | Depends on Server? |
|---|---|---|---|---|---|---|
| **System Owner** | Infra only | N/A | N/A | Infra only | N/A | Runs own |
| **Event Organiser** | ✅ All event data | ✅ Own key | ✅ Full export | ✅ True delete | ✅ Any EV app | ❌ No |
| **Attendee** | ✅ All personal data | ✅ Own key | ✅ Full export | ✅ True delete | ✅ Any EV app | ❌ No |
| **Venue Partner** | ✅ Venue data | ✅ Own key | ✅ Full export | ✅ Own subkeys | ✅ Any EV app | ❌ No |
| **Artist** | ✅ Artist data | ✅ Own key | ✅ Full export | ✅ Own subkeys | ✅ Any EV app | ❌ No |
| **Search Node** | ❌ Derived only | N/A | N/A | ✅ Own index | ✅ Standard API | Runs own |

> [!TIP]
> **The portability principle**: In the EV Protocol, your app is a *lens* into the protocol, not a *container* for user data. Users can install a competing app, import their private key, and see all their data instantly. This is identical to how email works — you can switch from Gmail to Outlook and keep all your messages because the protocol (IMAP/SMTP) is open. The EV Protocol achieves the same for events.

### Compare: Eventbrite Data Ownership

```
On Eventbrite today:

  Organiser:
    ❌ Cannot export full attendee contact details
    ❌ Attendee list locked to Eventbrite platform
    ❌ Revenue data controlled by Eventbrite
    ❌ Event history disappears if account closed
    ❌ Cannot use different app to manage same events

  Attendee:
    ❌ Cannot export ticket purchase history
    ❌ Cannot prove ticket ownership offline
    ❌ No data portability to competing platform
    ❌ Eventbrite can cancel/modify tickets unilaterally
    ❌ Account deletion doesn't remove all data (retention policies)

On EV Protocol:
    ✅ Every item above is reversed.
    ✅ Your data. Your keys. Your choice of app. Always.
```

---

## The Bottom Line

The EV Protocol is a **technically excellent solution** to a **real but niche problem**. The architecture holds up under stress testing, the cost structure is genuinely revolutionary, and the privacy model is best-in-class. The risk is not technical — it's market execution and Veilid ecosystem maturity.

**Start with 50 sailors. Build from there.**

---

*Last updated: 2026-04-06*
*Part of: [Use Cases](./use-cases.md) | [Chat Analysis](./use-cases-chat.md) | [EV Search Architecture](./ev-protocol-search-architecture.md) | [EV Payments](./ev-protocol-payments.md)*
