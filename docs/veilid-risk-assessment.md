# Veilid: Risk Assessment & Fork Viability

> Can we depend on Veilid? What happens if it stalls? Could we fork and maintain it?

---

## Licensing

**Mozilla Public License 2.0 (MPL-2.0)** — confirmed via [GitLab repo](https://gitlab.com/veilid/veilid).

| Aspect | MPL-2.0 means... |
|---|---|
| **Use in your app** | ✅ Yes, freely |
| **Modify Veilid source** | ✅ Yes, but share modifications to *those files* under MPL |
| **Combine with proprietary code** | ✅ Yes — your app code can be any license |
| **Commercial use** | ✅ Yes, no restrictions |
| **Patent grant** | ✅ Yes, contributors grant patent rights |
| **Fork the project** | ✅ Yes, unconditionally |

Same license as Firefox. You can build a fully commercial product on top of it. Only modifications to Veilid's own source files must be shared — your Flutter app, Lexicon schemas, and business logic can remain proprietary.

---

## Codebase Overview

```
Repository:         gitlab.com/veilid/veilid
License:            MPL-2.0
Primary language:   Rust
Total commits:      2,300+
Releases:           26 (roughly one per 6 weeks)
Tags:               30
Branches:           7
```

### Project Structure

```
veilid/
├── veilid-core/       ~102,000 lines of Rust (the engine)
│   ├── DHT (Kademlia)
│   ├── Private routing (onion-like)
│   ├── Encryption (ed25519, x25519)
│   ├── Transport (UDP, TCP, WebSocket)
│   └── RPC protocol (Cap'n Proto)
│
├── veilid-flutter/    Flutter/Dart FFI bindings
├── veilid-tools/      Utility library
├── veilid-wasm/       WebAssembly bindings
├── veilid-server/     Headless node daemon
└── veilid-cli/        Command-line interface
```

### Size in Context

```
veilid-core:        ~102,000 lines of Rust
SQLite:             ~150,000 lines of C
Tokio (Rust async): ~70,000 lines of Rust
libsignal (Signal): ~80,000 lines of Rust

Verdict: Medium-sized. Substantial but not a monolith.
A skilled Rust developer can navigate and maintain it.
```

---

## Current Maintenance Status

| Signal | Status |
|---|---|
| **Commits** | 2,300+ (active, consistent over ~3 years since Aug 2023) |
| **Releases** | 26 releases (roughly one per 6 weeks) |
| **Recent activity** | DHT transaction improvements, encryption fixes, API bug fixes |
| **Community** | Discord-based coordination, community-driven |
| **Backing** | Cult of the Dead Cow (cDc), no corporate sponsor |
| **Philosophy** | Explicitly **no blockchain, no crypto, no AI** — focused |
| **Reference app** | VeilidChat — invite-only beta, functional |
| **Developer docs** | "Veilid Book" in progress, some gaps remain |

---

## Known Outstanding Issues

```
DOCUMENTED ISSUES:
  ⚠️ Network lag — slow message delivery, repeated messages
  ⚠️ Cellular vs WiFi — worse performance on cellular networks
  ⚠️ VeilidChat bugs — invitation failures, message loss, oddities
  ⚠️ Push notifications — not fully working (expected, iOS limitation)
  ⚠️ Battery drain — DHT participation is resource-hungry on mobile
  ⚠️ Documentation — developer book "in progress", gaps remain
  ⚠️ Beta status — VeilidChat is invite-only beta

IMPORTANT DISTINCTION:
  Most of these are VeilidChat app-level bugs, NOT veilid-core issues.
  The core library (which is what EV Protocol uses) is more stable
  than the reference chat app built on top of it.
```

---

## Fork Viability: Could You Maintain It?

### What you'd need

```
Scenario: Veilid project stalls, no more upstream commits.

Personnel:
  1 senior Rust developer (part-time): bug fixes, security patches
  Cost: ~$50-80K/year part-time contractor

What you WOULDN'T need to maintain:
  - The DHT protocol itself (well-established, Kademlia-based)
  - The crypto primitives (uses standard ed25519, x25519)
  - The transport layer (UDP/TCP/WebSocket — standard)

What you WOULD need to maintain:
  - Flutter FFI bindings as Dart/Flutter evolves
  - iOS/Android platform compatibility as OS APIs change
  - Bootstrap node operation (see below)
  - Security patches if vulnerabilities are found
```

### Risk Matrix

```
Scenario                    Probability    Impact       Mitigation
──────────────────────     ────────────   ──────────   ──────────────────────
Veilid thrives, grows       40%           👍 Positive  Best case
Veilid maintains slowly     35%           ⚠️ Low       Fork + maintain critical path
Veilid stalls, stops        20%           ⚠️ Medium    Fork, hire 1-2 Rust devs
Veilid dies + hostile fork  5%            🔴 High      Abstract networking layer early
```

> [!NOTE]
> The 5% catastrophic case: someone forks Veilid and makes it incompatible. Mitigated by your app controlling the Veilid version it ships (you bundle the Rust binary). Your app pins the exact Veilid binary — no one can force an upgrade on you.

---

## Bootstrap Nodes: The Hidden Dependency

### What are bootstrap nodes?

Every P2P network has a chicken-and-egg problem: **how does a brand new node find its first peer?**

```
Your app starts for the first time on a user's iPhone.
It knows NOTHING about the Veilid network.
No peers. No IP addresses. No routing table.

It needs to ask SOMEONE "hey, who's out there?"

That someone = a bootstrap node.

┌─────────────────────────────────────────────────────────┐
│                                                         │
│  New iPhone App                                          │
│  "I just installed. Who's on the network?"              │
│       │                                                  │
│       │  Step 1: Connect to known bootstrap node         │
│       ▼                                                  │
│  bootstrap1.veilid.net:5150                              │
│  bootstrap2.veilid.net:5150                              │
│       │                                                  │
│       │  Step 2: Bootstrap returns a list of peers       │
│       ▼                                                  │
│  "Here are 20 active nodes near your DHT keyspace"       │
│       │                                                  │
│       │  Step 3: Connect to those peers directly         │
│       ▼                                                  │
│  Now you're a full DHT participant.                      │
│  You NEVER need the bootstrap node again                 │
│  (until you completely restart).                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

A bootstrap node is like the reception desk at a party. It points you to people to talk to. After that, you're on your own. It doesn't route your messages, store your data, or have any ongoing role.

### What happens if cDc stops running theirs?

```
Scenario: cDc shuts down bootstrap1.veilid.net and bootstrap2.veilid.net

EXISTING USERS:
  ✅ Fine. They already have a routing table cached locally.
  Their app knows hundreds of peers from previous sessions.
  They reconnect directly to known peers. No bootstrap needed.

NEW USERS installing the app for the first time:
  ❌ Stuck. App starts, tries to connect to bootstrap nodes,
  gets DNS timeout. Can't find any peers. Network appears dead.

USERS who cleared app data / reinstalled:
  ❌ Same problem. Lost their cached routing table.
```

This is the **exact same vulnerability** that BitTorrent, IPFS, and every other DHT network has. And they all solve it the same way.

### The solution: Run your own

A bootstrap node is just a `veilid-server` instance that:

```
What it DOES:
  ✅ Stays online 24/7
  ✅ Has a known, stable IP address or DNS name
  ✅ Maintains a large routing table (knows many peers)
  ✅ Responds to "who's out there?" queries

What it does NOT do:
  ❌ Store any user data
  ❌ Route any messages
  ❌ Have any special privileges
  ❌ See message content
  ❌ Know user identities
  ❌ Act as a relay or proxy

It's literally: "give me a list of peers" → "here's 20 IP addresses"
```

### Cost to operate

```
Option A: Single VPS (minimum viable)
  Provider:     Hetzner / DigitalOcean / Vultr
  Specs:        1 vCPU, 1GB RAM, 20GB SSD
  Cost:         $4-6/month
  Runs:         veilid-server binary (single process)
  Bandwidth:    Minimal (peer lists are ~2KB per request)

Option B: Multiple regions (recommended for resilience)
  3 VPS instances across 3 regions:
    - US West (DigitalOcean SFO): $5/mo
    - EU Central (Hetzner Falkenstein): $4/mo
    - AP Southeast (Vultr Sydney): $6/mo
  Total: $15/month for global bootstrap coverage

Option C: Piggyback on existing infrastructure
  Your Tier 3 search nodes (from the search architecture)
  already run veilid-server. They can ALSO serve as
  bootstrap nodes. No additional cost.
```

### Setup

```bash
# On a VPS, it's literally:
$ apt install veilid-server
$ veilid-server --bootstrap

# Or run your own binary from your fork:
$ cargo build --release -p veilid-server
$ ./target/release/veilid-server --bootstrap
```

```dart
// In your Flutter app's Veilid config
final config = VeilidConfig(
  bootstrap: [
    // Point to YOUR bootstrap nodes, not cDc's
    'bootstrap1.yourdomain.com:5150',
    'bootstrap2.yourdomain.com:5150',
    'bootstrap3.yourdomain.com:5150',
    
    // ALSO keep cDc's as fallback (if they're still running)
    'bootstrap1.veilid.net:5150',
  ],
);
```

### Defence in depth: Multiple bootstrap sources

```
The smart approach (and what you should do from day one):

┌──────────────────────────────────────────────────────┐
│  Bootstrap Resolution Order                           │
│                                                      │
│  1. Cached peers from last session (instant)          │
│     → 99% of app launches use this. No network call. │
│                                                      │
│  2. YOUR bootstrap nodes (you control these)          │
│     → bootstrap.ev-protocol.app:5150                 │
│     → 3 VPS instances, $15/month                     │
│                                                      │
│  3. cDc's bootstrap nodes (free, community-run)       │
│     → bootstrap1.veilid.net:5150                     │
│     → May or may not exist in the future             │
│                                                      │
│  4. Hardcoded peer list (baked into app binary)       │
│     → 10-20 known stable node IDs compiled into app  │
│     → Works even if ALL bootstrap DNS goes down      │
│     → Updated with each app release                  │
│                                                      │
│  5. Manual peer entry (last resort)                   │
│     → User can type in a peer address                │
│     → "My friend's node is 203.0.113.42:5150"        │
│                                                      │
│  If steps 1-4 all fail: network is truly dead.        │
│  That would require YOUR servers + cDc servers +      │
│  all hardcoded peers to be offline simultaneously.    │
│  Probability: essentially zero.                       │
└──────────────────────────────────────────────────────┘
```

### Why bootstrap nodes are NOT a centralisation risk

```
AT Protocol Relay (BGS):              Veilid Bootstrap Node:
──────────────────────                ──────────────────────
❌ Routes ALL data through it         ✅ Only for initial peer discovery
❌ Stores the full firehose           ✅ Stores nothing (stateless)
❌ $50,000+/month to operate          ✅ $5/month to operate
❌ If it dies, the app dies           ✅ If it dies, existing users are fine
❌ Has full visibility into content   ✅ Sees nothing (just "give me peers")
                                     ✅ Anyone can run one (no special access)
                                     ✅ Multiple can exist independently

It's the difference between:
  "You must go through my toll booth for every trip"
  vs
  "You asked me for a map once, now you drive yourself"
```

---

## Summary: Total Cost of Independence

```
If Veilid stalls and you need to go it alone:

Bootstrap nodes (3 regions):          $15/month ($180/year)
Part-time Rust developer:             $50-80K/year
Total annual cost:                    $50,180 - $80,180/year

Compare:
  Eventbrite minimum plan:            $1,176/year + per-ticket fees
  Running AT Protocol relay:          $600,000+/year at scale
  Building custom P2P from scratch:   $500K-1M in dev costs

The fork scenario is expensive but manageable.
The architecture is designed so this is a backstop,
not the expected path.
```

> [!IMPORTANT]
> **Day-one action**: From the very first release, ship the app with your own bootstrap node addresses. Don't rely solely on cDc's infrastructure. This costs $15/month and eliminates the single most practical dependency on the Veilid project's continued operation. The Tier 3 search nodes you'd already be running can double as bootstrap nodes.

---

*Last updated: 2026-04-06*
*Part of: [Market Summary](./market-summary.md) | [EV Search Architecture](./ev-protocol-search-architecture.md) | [Protocol Candidates](./protocol-candidates-solving-weaknesses.md)*
