# Apple App Store Approval: Veilid & EV Protocol

> Can a Flutter app using Veilid's P2P networking, private routing, and DHT ship on the iOS App Store?
>
> **Yes, but with care.** There's no ban on P2P networking. The risk isn't the protocol — it's implementation quality and compliance with specific Apple guidelines.

---

## What's Fine ✅

### P2P Networking (DHT, Kademlia)

**ALLOWED.** Apps like LocalSend use P2P on the App Store. Apple cares about HOW you network, not that it's P2P. Veilid uses standard UDP/TCP/WebSocket — no exotic transport.

### Encryption (E2E, ed25519, x25519)

**ALLOWED.** Signal, WhatsApp, iMessage all do this. You need to declare encryption in App Store Connect (the annual compliance self-classification). Standard checkbox — every chat app does it.

### Flutter + Rust FFI

**ALLOWED.** Flutter is officially supported by Apple. Rust FFI is just a compiled binary — Apple doesn't care what language your code is written in, only what it does.

---

## What Needs Careful Handling ⚠️

### 1. Private Routing (The Tor-Like Part)

Veilid's private routes ARE similar to Tor circuits. But Apple has Onion Browser and Orbot on the App Store. Tor-like routing is NOT banned.

```
It's allowed IF:
  → You don't call it a VPN or proxy
  → You don't route ALL device traffic through it
  → It's used for your app's own networking, not as a system-wide tunnel

Veilid does this correctly:
  → Private routes are app-internal (not system-wide)
  → No NEVPNManager needed (it's not a VPN)
  → It's just how YOUR app talks to peers

✅ SAFE — same as how Signal routes messages through its own
servers. Your app controls its own networking.
```

### 2. Background Networking (The Real Apple Headache)

Apple aggressively kills background processes on iOS. A DHT node that runs 24/7 is NOT possible on iOS.

```
This means:
  → Your app is a "light node" — only participates in DHT
    while in foreground
  → When backgrounded: iOS kills the Veilid process
  → When foregrounded: reconnects to DHT (~2-3 seconds)
  → Push notifications via APNS to wake app for messages

⚠️ This is a DESIGN constraint, not a policy violation.
Every P2P app on iOS works this way.
```

### 3. Battery / Data Usage

DHT participation uses CPU, battery, and data. Apple can reject for excessive battery drain (Guideline 2.5.4 — Performance).

```
Mitigation:
  → Veilid has "low power mode" for mobile
  → Limit DHT routing participation on cellular
  → Only full participation on WiFi + charging
  → Show battery usage estimates to user

⚠️ MANAGEABLE — but needs careful tuning and testing.
```

### 4. User-Generated Content (Guideline 1.2)

Any app with photos, chat, or social features MUST have:

```
Required by Apple:
  → Block user functionality
  → Report content functionality
  → Mechanism to remove abusive content

EV Protocol already covers this:
  → On-device AI moderation (Tier 1)
  → Organiser admin controls (Tier 2)
  → Community reports with auto-hide (Tier 3)

✅ COVERED — the moderation stack handles this.
```

---

## VeilidChat's Current iOS Status

```
VeilidChat current status on iOS:
  → Distributed via TestFlight (beta), NOT on the public App Store
  → Most likely reason: still in active development,
    not ready for public release
  → VeilidChat has known bugs (message loss, invitation failures)
  → Apple would reject it for quality alone, not policy violations
  
This tells us:
  → No evidence of POLICY rejection (Veilid isn't banned)
  → The reference app just isn't polished enough yet
  → A well-built app using Veilid should be fine
```

---

## Precedents: P2P/Privacy Apps on the App Store

| App | Technology | App Store Status |
|---|---|---|
| **Onion Browser** | Tor routing, .onion access | ✅ Approved |
| **Orbot** | Tor system-wide proxy | ✅ Approved |
| **Signal** | E2E encrypted P2P messaging | ✅ Approved |
| **LocalSend** | P2P file transfer over LAN | ✅ Approved |
| **Session** | Onion routing, decentralised messaging | ✅ Approved |
| **Briar** | Tor + P2P messaging | ❌ Not on iOS (developer choice, Android-only) |
| **BitTorrent clients** | P2P file sharing | ❌ Not on iOS (background limits, not policy ban) |

> [!NOTE]
> The pattern is clear: Apple allows P2P and onion routing in apps. They reject apps that are buggy, drain battery excessively, lack content moderation, or try to act as system-wide VPNs without proper APIs. The networking technology itself is not the issue.

---

## Apple's Relevant Review Guidelines

### Guideline 1.2 — User-Generated Content

```
Apps with UGC must include:
  ✅ A method for filtering objectionable material
  ✅ A mechanism to report offensive content
  ✅ The ability to block abusive users
  ✅ The developer must act on reports

EV Protocol compliance:
  ✅ On-device AI content scanning (pre-upload)
  ✅ ev.moderation.report schema (user reporting)
  ✅ ev.moderation.action schema (organiser admin)
  ✅ Block user functionality (per-user block list)
```

### Guideline 2.5.4 — Performance / Battery

```
Apple's concern:
  Apps must not drain battery excessively or cause device overheating.

EV Protocol compliance:
  → Veilid "low power" mode on mobile
  → DHT participation only in foreground
  → Reduced routing on cellular data
  → Background tasks limited to push notification handling
```

### Guideline 5.4 — VPN Apps

```
Apple's concern:
  VPN apps must use NEVPNManager, be from an organisation account,
  and clearly disclose data practices.

EV Protocol compliance:
  → NOT a VPN. Does not route system-wide traffic.
  → Private routes are internal to the app only.
  → No NEVPNManager needed.
  → This guideline does NOT apply to Veilid.
```

### Guideline 5.1 — Privacy

```
Apple's concern:
  Apps must explain data collection, provide privacy labels,
  and honour user consent.

EV Protocol compliance:
  → No data collection (no server to collect TO)
  → Privacy labels: "Data Not Collected" for most categories
  → E2E encryption means even DHT nodes can't read content
  → This is actually EASIER than most apps — less data to disclose
```

---

## App Store Submission Checklist

```
PRE-SUBMISSION:
  ☐ Encryption declaration in App Store Connect
    → Self-classify as using encryption (standard process)
    → No export compliance issues (standard crypto, not custom)
    
  ☐ Privacy nutrition labels accurately completed
    → Data Not Collected for most categories
    → Disclose: device identifiers (push tokens for APNS)
    → Disclose: usage data (if analytics enabled, opt-in only)
    
  ☐ NSLocalNetworkUsageDescription in Info.plist
    → Required for any local network access
    → Message: "EV uses local networking for peer discovery"

CONTENT MODERATION (visible to App Review team):
  ☐ Block user button visible in UI
  ☐ Report content button visible in UI
  ☐ Content moderation policy accessible in-app
  ☐ Organiser admin panel for content removal
  
PERFORMANCE:
  ☐ Battery usage tested and within acceptable ranges
  ☐ No background DHT when app is suspended
  ☐ Cellular data usage reasonable (limit DHT on cellular)
  ☐ App reconnects cleanly after background → foreground
  
PUSH NOTIFICATIONS:
  ☐ APNS integration for message/update notifications
  ☐ No attempt to keep Veilid running in background via hacks
  ☐ Silent push to wake app → check DHT → show notification
  
APP REVIEW NOTES:
  ☐ Explain P2P architecture (it's for event data, not file sharing)
  ☐ Explain encryption usage (E2E for user privacy)
  ☐ Explain private routing (app-internal, not a VPN)
  ☐ Provide test account or demo event for reviewers
  ☐ Highlight moderation features prominently
```

---

## Risk Assessment

```
Will Apple reject your app because it uses Veilid?
  → NO, not for the networking technology itself.

Will Apple reject your app for these reasons?
  → Battery drain:         Possible if not tuned for mobile
  → Missing moderation:    Possible if block/report not visible
  → Quality/crashes:       Possible if Veilid FFI causes instability
  → Not enough "app":      Possible if it feels like a web wrapper

The protocol ISN'T the risk. The implementation quality IS.

Ship a polished, stable, well-moderated app with clear privacy
disclosures and Apple will approve it. Ship a buggy beta with
background battery drain and Apple will reject it.

Risk level: LOW — with proper implementation
Confidence: HIGH — based on Onion Browser, Signal, Session precedents
```

> [!IMPORTANT]
> **The private routing / "Tor circuit" part is not a problem.** It's app-internal networking, not a system-wide VPN. Apple's concern is with apps that tunnel ALL device traffic (VPNs) or facilitate piracy. An event discovery app with encrypted peer communications is fine — Signal does exactly this.

---

*Last updated: 2026-04-06*
*Part of: [Veilid Risk Assessment](./veilid-risk-assessment.md) | [Market Summary](./market-summary.md) | [Use Cases](./use-cases.md)*
