<div align="center">

# DECCAY

**A quiet, offline companion that slowly fades if forgotten — and leaves behind a Death Certificate when it passes.**

[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Offline](https://img.shields.io/badge/Network-0%20requests-brightgreen)](#privacy-security--compliance)
[![Analytics](https://img.shields.io/badge/Analytics-none-brightgreen)](#privacy-security--compliance)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](#testing--quality-assurance)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](#release-management)
[![PRs](https://img.shields.io/badge/PRs-welcome-ff69b4)](#contributing)

**Open Source under the MIT License** · Zero backend · Zero tracking · 100% on-device

</div>

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Philosophy & Product Principles](#philosophy--product-principles)
3. [Key Features](#key-features)
4. [Technical Architecture](#technical-architecture)
5. [Decay Engine](#decay-engine)
6. [Screen Architecture](#screen-architecture)
7. [Design System](#design-system)
8. [Data Layer & Persistence](#data-layer--persistence)
9. [Native Integrations](#native-integrations)
10. [Privacy, Security & Compliance](#privacy-security--compliance)
11. [Getting Started](#getting-started)
12. [Project Structure](#project-structure)
13. [Testing & Quality Assurance](#testing--quality-assurance)
14. [Build & Release Management](#build--release-management)
15. [Performance & Reliability](#performance--reliability)
16. [Accessibility](#accessibility)
17. [Roadmap](#roadmap)
18. [Contributing](#contributing)
19. [Support & Contact](#support--contact)
20. [Governance & Legal](#governance--legal)
21. [License](#license)

---

## Executive Summary

**Decay** is a fully offline, zero-backend, login-free emotional-reflection application for Android and iOS, built with Flutter. It is not a game, not a productivity tool, and not a utility. It is an interactive meditation on presence and impermanence.

A single soft light — a *companion* — lives on the user's phone. It breathes. It dims when neglected. It recovers slightly when the user returns and stays a while. It fades permanently when forgotten, and on its passing the app composes a Death Certificate from the user's real visit history: a lifespan, a poetic cause, a sincere eulogy, and a quiet timestamp. There is no replay, no score, and no restart button. The only return is a deliberate reinstall.

| Attribute | Value |
|---|---|
| **Platform targets** | Android (primary), iOS |
| **Framework** | Flutter (Dart 3.13) |
| **Backend** | None. Zero servers, zero cloud, zero accounts. |
| **Network footprint** | Zero requests at runtime (user-initiated external links only) |
| **Data storage** | 100% on-device (SQLite + SharedPreferences) |
| **Analytics / tracking** | None — no SDK of any kind |
| **Data residency** | Device-local only; never leaves the sandbox |
| **Compliance posture** | GDPR / CCPA / COPPA exempt by architecture (no personal data collected) |
| **License** | [MIT](LICENSE) — open source |
| **Maturity** | v1.0.0 — production-ready |

### At a Glance

| | |
|---|---|
| 🎭 **Category** | Emotional-reflection / digital art piece |
| 🌐 **Connectivity** | Air-gap safe — functions with networking fully disabled |
| 🔐 **Security model** | No attack surface: no network layer, no auth, no identifiers |
| 📦 **Distribution** | Play Store (AAB) / App Store (IPA) / direct APK |
| ♻️ **Maintainability** | Pure-Dart domain core; 100% VM-testable business logic |
| 🧪 **Quality gates** | `flutter analyze` (zero issues) + `flutter test` (100% pass) |

---

## Philosophy & Product Principles

Every design decision exists to make the experience feel *held, not played*:

- **The void-charcoal palette** (`#0B0D12` → `#12151C`) gives the companion vast negative space to be alone in.
- **The warm gold glow** (`#E8C888`) is the only warmth in the app — it belongs entirely to the companion.
- **The teal-lavender fracture stages** (`#8FA3B0` → `#A594C4`) render decay with dignity, never with alarm.
- **Breathing rhythms slow with each stage** (5.5s → 12s per breath), so the fading is *felt* before it is noticed.
- **The irreversibility is deliberate and disclosed.** The companion fades when neglected and does not return. This is the point of the work, and the user is told so before planting it.

### Non-Negotiable Product Principles

These are engineering constraints, not preferences. Any change violating them is rejected by definition:

| # | Principle | Rationale |
|---|---|---|
| P1 | **Zero network.** No request is ever made at runtime. | The privacy guarantee is architectural, not contractual. |
| P2 | **Zero accounts.** No login, identity, or identifier. | There is nothing to breach because there is nothing to know. |
| P3 | **Zero engagement mechanics.** No streaks, scores, badges, guilt, or urgency notifications. | Decay is the opposite of an attention economy. |
| P4 | **Irreversibility is the contract.** No restart, no replay, no undo after passing. | The work is about impermanence; a restart button would be a lie. |
| P5 | **Deterministic domain.** All generative output is a pure function of stored state. | The companion's life must be replayable, auditable, and stable. |
| P6 | **Graceful degradation.** Unavailable hardware degrades features, never blocks the user. | Presence is never blocked by device limitations. |

---

## Key Features

| Feature | Description | Engineering Notes |
|---|---|---|
| **Living Companion** | A breathing, drifting abstract glow form. | Layered stage-tinted artwork; per-stage animation curves; 60fps `AnimationController` pipeline. |
| **Real Decay Engine** | Six stages driven by actual neglect plus an inescapable impermanence horizon. | Pure Dart; replay-based; clock-resilient; deterministic. |
| **Presence Ritual** | A visit only counts if the user stays ~12s. Face-down presence still counts. | Accelerometer (`z ≤ −7`, `|x| < 3`, `|y| < 3`) with timer-only fallback. |
| **Death Certificate** | Auto-revealed on the slowest moment in the app (3.5s). Exportable 1080×1920 PNG. | 70+ guarded fragment banks; mulberry32 PRNG; `RepaintBoundary.toImage`. |
| **The Quiet Archive** | Post-death certificate storage. No counts, no gallery framing. | JSON export/import for manual continuity; dedup by `passedAt`. |
| **Memory Fragments** | 45 passive, deterministic, never-repeating one-line reflections. | ~5–25% weighted chance; seeded from `plantedAt + visitCount + ms`. |
| **Seasons of Light** | Barely perceptible time-of-day background tint. | Sunset amber (17–20h), late-night lavender (0–4h), neutral otherwise. |
| **Ambient Sound** | Opt-in stage-derived piano loop. Never autoplayed. | Rate (`1.0 → 0.72`) and volume (`0.65 → 0.12`) decay with the companion. |
| **Gentle Reminder** | Optional, off by default. One soft notification after 4 days. | `inexactAllowWhileIdle`; rescheduled (not stacked) on every visit. |
| **Home Screen Widget** | Visual-only Android widget mirroring the live stage. | Native Kotlin `RemoteViews`; 30-min refresh; never blank. |

---

## Technical Architecture

### High-Level Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                        │
│   lib/screens/            lib/components/          lib/theme.dart │
│   (routes, screens)       (form, controls, text)   (design tokens)│
├──────────────────────────────────────────────────────────────────┤
│                         STATE LAYER                               │
│          lib/companion.dart — CompanionController                │
│    (ChangeNotifier: lifecycle · decay · persistence · audio)     │
├────────────────┬─────────────────────────┬───────────────────────┤
│  DOMAIN CORE   │       SERVICES          │     PERSISTENCE       │
│  (pure Dart)   │  (platform-aware)       │                       │
│  decay.dart    │  notification_service   │  store.dart (sqflite) │
│  analysis.dart │  ambient_audio          │  archive.dart (prefs) │
│  eulogy.dart   │  presence.dart          │                       │
│  fragments.dart│  widget_sync.dart       │                       │
│  words.dart    │                         │                       │
│  format.dart   │                         │                       │
└────────────────┴─────────────────────────┴───────────────────────┘
                            │
                ┌───────────┴────────────┐
                │   NATIVE PLATFORM      │
                │   DecayWidgetProvider  │
                │   (Kotlin RemoteViews) │
                └────────────────────────┘
```

### Architectural Principles

- **Strict layering & dependency direction.** Screens depend on state; state depends on domain + services; services depend on persistence and platform channels. Nothing depends upward. Domain modules have **zero Flutter imports**.
- **Hexagonal-ready domain core.** `decay.dart`, `eulogy.dart`, `analysis.dart`, `fragments.dart`, `words.dart`, and `format.dart` form a platform-agnostic core — portable to any target (server-side generation, CLI simulation, tests) without modification.
- **Determinism over randomness.** Every generative output (decay stage, certificate text, memory fragments) is a pure function of stored state. The platform RNG is invoked exactly once in the entire codebase: seeding a new companion.
- **Graceful degradation everywhere.** Every native integration (sensors, audio, notifications, widget) is wrapped so unavailability degrades to a working fallback — never a crash, never a blocked visit.
- **Fail-soft persistence.** A failed write means the next read wins. No modal errors, no data-loss dialogs — the app's emotional contract outranks write guarantees.
- **Single responsibility per module.** Each `lib/*.dart` domain file owns exactly one concern, mirrored 1:1 from the original TypeScript modules for traceability.

---

## Decay Engine

Two pressures act on the companion at once:

1. **Neglect** — measured from the last *real* visit (one where the user actually stayed). Drives the visible day-by-day fading.
2. **Impermanence** — a slow horizon that no amount of care can outrun, so that nothing lives forever.

### Stage Table

| Stage | Doorway (days of neglect) | Visual Character | Breath (s) | Scale | Glow |
|---|---|---|---|---|---|
| **Vibrant** | 0–2 | Full gold aurora, drifting lights | 5.5 | 1.00 | 1.00 |
| **Dimming** | 3–6 | Soft amber edge | 6.5 | 0.97 | 0.88 |
| **Fading** | 7–13 | Teal-lavender desaturation | 7.5 | 0.93 | 0.70 |
| **Cracking** | 14–25 | Subtle fracture overlay | 8.5 | 0.88 | 0.55 |
| **Barely Holding On** | 26–45 | Near-transparent ghost, flicker | 10.0 | 0.80 | 0.34 |
| **Passing** | 46+ | Fully faded; next open triggers Certificate | 12.0 | 0.72 | 0.12 |

### Engine Constants

| Constant | Value | Meaning |
|---|---|---|
| `HEAL_PER_VISIT` | 12 days | Neglect bought back by one real visit — enough to step back a stage, never enough to erase a long absence |
| `HORIZON_BASE` | 170 days | Impermanence horizon at zero visits |
| `HORIZON_PER_VISIT` | 1 day | Extra horizon per real visit (capped at 100 visits) |
| `HORIZON_CURVATURE` | 4 | Power curve — gentle early, decisive late |
| `PRESENCE_MS` | 12,000 ms | Stay-time required for a visit to count as *real* |
| `MINIMUM_MS` | 600 ms | Below this is a mis-tap, not a visit |

> Even an actively cared-for companion reaches Passing within roughly 6–9 months. **This is intentional, not a failure** — per principle P4.

### Determinism & Clock Resilience

- The engine **replays** the stored visit history on every computation rather than accumulating a mutable counter — the same state at the same moment always yields the same stage, regardless of recomputation frequency or clock changes.
- Backward clock jumps greater than 1 hour are capped at the last known-good elapsed time (`computeMonotonicElapsed`).
- All arithmetic is integer-safe; day fractions are derived, never stored.

### Certificate Composition (`lib/eulogy.dart`)

- **70+ fragment banks** (openings / details / closings / causes), each guarded by predicates against what the visit log *actually supports* (pattern, gaps, longest visit, lifespan).
- Seeded by a **mulberry32 PRNG** initialized from the companion's seed — one person's certificate never changes, and two people's never collide.
- **Life-pattern classification:** `never`, `one-visit`, `burst-then-silence`, `frequent-then-silence`, `sparse`, `steady` — derived from visit density, tail silence, and early-share ratios.
- **Number-to-prose rendering** (`words.dart`): all counts render as written language ("forty-two days"), never digits.

---

## Screen Architecture

Routing is handled by named routes registered in `lib/main.dart`, with a uniform 600ms fade transition. No deep links, no web routes — the surface area is deliberately closed.

| Route | Screen | Purpose & Key Behavior |
|---|---|---|
| `/` | `HomeRouter` → `_CompanionHome` | Entry / routing hub. Routes to onboarding → companion → certificate based on state. The living companion: breathing form, passive presence detection, ambient sound (off by default). |
| `/onboarding` | `OnboardingScreen` | First launch only. 4 quiet slides + `BEGIN`. Plants the companion timestamp; the glow fades in on the final slide. |
| `/certificate` | `CertificateScreen` | Death Certificate (auto-reveal). Full-screen, no chrome, elegant 9:16 card. **Save / Share** at 1080×1920. **No restart button.** Also renders archived certificates via `archiveId` argument. |
| `/settings` | `SettingsScreen` | Ambient sound, Gentle reminder, and links to all sub-pages. |
| `/settings/how-it-works` | `HowItWorksScreen` | Presence, fading, impermanence, passing, privacy — explained without giving everything away. |
| `/settings/developer-support` | `DeveloperSupportScreen` | Email / WhatsApp / Patreon. |
| `/settings/terms` · `/settings/privacy` · `/settings/about` | Static pages | Full terms, full privacy policy, credits. |
| `/archive` | `ArchiveScreen` | The Quiet Archive — companions remembered. No counts, no achievements. |

### Death Flow (State Machine)

```
                    ┌─────────────────────┐
                    │  decay.dead == true │
                    │  && passedAt == null│
                    └──────────┬──────────┘
                               ▼
              ┌────────────────────────────────┐
              │  PassingReveal                 │
              │  • form fades 100% → 8%        │
              │  • soft haptic                 │
              │  • duration: 3,500ms           │
              │  • no gesture, no button       │
              └────────────────┬───────────────┘
                               ▼
              ┌────────────────────────────────┐
              │  /certificate                  │
              │  • passedAt recorded once      │
              │  • Keep → Quiet Archive        │
              │  • Save/Share → 1080×1920 PNG  │
              │  • NO restart path exists      │
              └────────────────────────────────┘
```

---

## Design System

### Palette

| Token | Hex | Role |
|---|---|---|
| `voidTop` | `#0B0D12` | Deep charcoal-black — gradient top |
| `voidBottom` | `#12151C` | Deep navy — gradient bottom |
| `ink` | `#F0EDE6` | Warm off-white, never pure white |
| `inkDim` | `rgba(240,237,230,0.60)` | Secondary text |
| `inkFaint` | `rgba(240,237,230,0.36)` | Tertiary text |
| `inkGhost` | `rgba(240,237,230,0.16)` | Inactive indicators |
| `hairline` | `rgba(240,237,230,0.10)` | Dividers |
| `gold` | `#E8C888` | The companion's warmth — signature accent |
| `teal` | `#8FA3B0` | Cracking stage tint |
| `lavender` | `#A594C4` | Barely Holding On stage tint |

### Typography

| Family | Use | Weights |
|---|---|---|
| **Fraunces** (serif) | Headings, eulogy, certificate — the emotional weight | 300, 400, 400-italic, 500, 600 |
| **Source Sans 3** (humanist sans) | UI labels, timestamps, body | 300, 400, 500, 600 |

All fonts are **bundled locally** — no runtime font fetching, ever (principle P1).

### Spacing & Layout

- **8pt base grid** (`4 / 8 / 16 / 24 / 32 / 48 / 72`)
- Generous negative space throughout; the companion is meant to feel alone in vast dark.

### Motion Language

| Moment | Duration | Curve | Notes |
|---|---|---|---|
| Press feedback | 120ms in / 320ms out | `easeOutQuad` | Dim to 45%, never scale or ripple |
| Stage cross-fade | 2,500ms | quiet ease-in-out | No bounce, no snap, ever |
| Passing reveal | 3,500ms | `easeInOut` | The slowest moment in the app |
| Certificate entrance | 2,600ms | `easeIn` | Reverent, not celebratory |
| Breathing | 5,500–12,000ms | `easeInOutSine` | Period scales with decay stage |

### Seasons of Light

An ambient, nearly imperceptible time-of-day background tint: warm amber (~5%) around sunset (17–20h), cool lavender (~4%) late at night (0–4h), neutral (~3%) otherwise. An ambient layer, never a feature.

---

## Data Layer & Persistence

### SQLite Schema v2 (`lib/store.dart`)

```sql
CREATE TABLE meta (
  key   TEXT PRIMARY KEY,
  value INTEGER NOT NULL
);

CREATE TABLE companion (
  id                 INTEGER PRIMARY KEY CHECK (id = 1),
  planted_at         INTEGER,
  passed_at          INTEGER,
  ambient_on         INTEGER DEFAULT 0,
  gentle_reminder_on INTEGER DEFAULT 0,
  onboarded          INTEGER DEFAULT 0,
  seed               INTEGER DEFAULT 0,
  schema_version     INTEGER DEFAULT 2
);

CREATE TABLE visits (
  t       INTEGER PRIMARY KEY,
  present INTEGER NOT NULL,
  ms      INTEGER NOT NULL
);

CREATE TABLE fragments (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  seed       INTEGER NOT NULL,
  text       TEXT NOT NULL,
  created_at INTEGER DEFAULT (strftime('%s','now'))
);
```

### Data Integrity Guarantees

| Guarantee | Mechanism |
|---|---|
| **Atomicity** | Companion row + full visit list replaced in a single `BEGIN/COMMIT/ROLLBACK` transaction |
| **Schema evolution** | Versioned `onUpgrade` migration path; defensive version tracking in `meta` |
| **Clock resilience** | Backward jumps > 1h capped at last known-good elapsed (`computeMonotonicElapsed`) |
| **Deduplication** | Visits keyed by `t`; archive entries deduped by `passedAt` |
| **Crash safety** | Transactional writes; fail-soft read-on-error defaults |
| **First-launch safety** | Missing row → fully-defaulted empty state, no special-casing |

### Quiet Archive (`lib/archive.dart`)

Stored as JSON in `SharedPreferences` under `@decay/archive`. Supports explicit JSON export/import for manual continuity — **the app never auto-restores from a file; the user must open it** (principle P2: no silent identity resolution).

### Reinstall Boundary (Intentional & Disclosed)

The SQLite database lives in the app sandbox. **Uninstalling wipes everything, permanently, by design.** This is documented in-code, and disclosed in both Terms and the Privacy Policy. The only sanctioned continuity path is the user-driven Quiet Archive JSON export.

---

## Native Integrations

| Capability | Package | Purpose | Degradation Path |
|---|---|---|---|
| Storage | `sqflite` | Companion state, visits | Defaulted empty state on error |
| Preferences / Archive | `shared_preferences` | Quiet Archive JSON | Empty archive on error |
| Notifications | `flutter_local_notifications` + `timezone` | Gentle Reminder | Reminder silently skipped |
| Sensors | `sensors_plus` | Accelerometer presence ritual | Timer-only presence |
| Audio | `audioplayers` | Looped piano | Silent mode; visual parity preserved |
| Widget sync | `home_widget` | Stage value → native widget | Widget stays on last known stage |
| Sharing | `share_plus` | Certificate PNG share sheet | Cancel is not an error |
| Links | `url_launcher` | Email, WhatsApp, Patreon, website | External app absent → no-op |

### Home Screen Widget (`android/.../widget/DecayWidgetProvider.kt`)

- **Visual-only.** No text, no numbers, no branding — a window onto the companion.
- Native `RemoteViews` rendering: per-stage `GLOW` / `CORE` color arrays, `ALPHA` (1.0 → 0.12), `SCALE` (1.0 → 0.72), and an unsteady tremble at stage 4+.
- Synced from Dart via `WidgetSync.syncStage()`; the Kotlin provider reads the stage from `HomeWidgetPreferences`.
- **Reliability SLO:** renders within 30 minutes (`updatePeriodMillis`); every render wrapped in `try/catch` with a safe default stage — never blank, never broken.
- **Battery:** Doze-friendly; periodic updates only, zero continuous polling.

---

## Privacy, Security & Compliance

Decay's privacy and security posture is *absolute by construction*, not by policy:

### Privacy

- **Zero network requests** at runtime. No API calls, no telemetry, no crash reporting, no ad SDKs, no third-party SDKs of any kind.
- **Zero accounts.** No login, no identity, no identifiers collected or generated.
- **All data is local** and dies with the app installation. It cannot be recovered by anyone, including the developer.
- External links open **outside the app**, in the user's own browser/mail client, under their own terms.

### Security

| Surface | Status | Notes |
|---|---|---|
| Network attack surface | **None** | No sockets opened; app is air-gap safe |
| Authentication / auth bypass | **N/A** | No identity layer exists |
| Data-at-rest encryption | Device sandbox | OS-level app sandbox; no cloud copy exists to encrypt |
| Data-in-transit | **N/A** | No transit occurs |
| Third-party SDK risk | **None** | Dependency list is small, first-party-audited, Flutter-ecosystem standard |
| Injection / parsing risk | Minimal | All stored data is self-written JSON/SQLite; no external input parsed |
| Permissions | Minimal | Android: `VIBRATE`, `POST_NOTIFICATIONS` (opt-in only). iOS: notifications (opt-in only). No location, contacts, camera, mic, photos, or ad ID. |

### Compliance Posture

| Regulation | Posture | Rationale |
|---|---|---|
| **GDPR** | Exempt by architecture | No personal data processed; no lawful basis needed |
| **CCPA / CPRA** | Exempt by architecture | No personal information collected or sold |
| **COPPA** | Not directed at children; collects nothing from anyone | No data collection of any kind |
| **App Store Review** | Aligned | No tracking, no ATT prompt required, minimal permissions |
| **Play Store Data Safety** | "No data collected" declaration | Fully accurate |

> **Disclaimer:** The above describes the technical architecture. This document is not legal advice; consult counsel for formal compliance determinations.

Full policy text: in-app **Settings → Privacy Policy** and **Settings → Terms and Conditions** (`lib/screens/info_pages.dart`).

---

## Getting Started

### Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| [Flutter SDK](https://flutter.dev) | 3.47+ | Framework (bundles Dart 3.13) |
| Android SDK | API 21+ | Android builds |
| Xcode | Latest stable | iOS builds (macOS only) |
| Device / Emulator | — | Runtime target |

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd deccay

# 2. Fetch dependencies
flutter pub get

# 3. Verify the environment
flutter doctor

# 4. Run on a connected device / emulator
flutter run
```

### Verification (Quality Gates)

```bash
# Static analysis — must report zero issues
flutter analyze

# Unit tests — decay engine, prose rendering, certificate determinism
flutter test
```

---

## Project Structure

```
deccay/
├── lib/
│   ├── main.dart                    # Entry point, MaterialApp, named routes
│   ├── companion.dart               # CompanionController (app state)
│   ├── decay.dart                   # Decay engine (pure Dart)
│   ├── analysis.dart                # Life analysis / pattern classification
│   ├── eulogy.dart                  # Certificate composition (pure Dart)
│   ├── fragments.dart               # Memory fragment bank
│   ├── words.dart                   # Number → prose helpers
│   ├── format.dart                  # Timestamp formatting
│   ├── store.dart                   # SQLite persistence (sqflite)
│   ├── archive.dart                 # Quiet Archive (SharedPreferences)
│   ├── notification_service.dart    # Gentle Reminder
│   ├── ambient_audio.dart           # Stage-based piano controller
│   ├── presence.dart                # Presence ritual (timer + sensors)
│   ├── widget_sync.dart             # Stage → home screen widget
│   ├── theme.dart                   # Design tokens, stage visuals, season tint
│   ├── components/
│   │   ├── companion_form.dart      # Breathing glow form (the heart of the app)
│   │   ├── quiet_text.dart          # Typography system
│   │   ├── controls.dart            # QuietPressable, ListRow, Toggle, Divider
│   │   ├── page.dart                # QuietPage, Prose, BackLink
│   │   └── screen.dart              # Void gradient background + safe-area padding
│   └── screens/
│       ├── home_screen.dart         # Router, companion home, passing reveal
│       ├── onboarding_screen.dart   # 4 quiet slides + Begin
│       ├── certificate_screen.dart  # Death Certificate + PNG export
│       ├── archive_screen.dart      # The Quiet Archive
│       ├── settings_screen.dart     # Settings
│       └── info_pages.dart          # How it works, Terms, Privacy, About, Support
├── android/
│   └── app/src/main/
│       ├── kotlin/com/hamzapowerplayer/decay/
│       │   └── widget/DecayWidgetProvider.kt   # Native home screen widget
│       ├── res/
│       │   ├── layout/decay_widget.xml
│       │   ├── drawable/decay_widget_{field,bloom,core}.xml
│       │   └── xml/decay_widget_info.xml
│       └── AndroidManifest.xml
├── ios/                             # Runner project
├── assets/
│   ├── images/                      # glow-bloom, glow-body, glow-core, cracks
│   ├── audio/                       # piano_full.wav, ambient.wav
│   └── fonts/                       # Fraunces + Source Sans 3 (bundled)
├── test/
│   └── decay_test.dart              # Engine, words, certificate determinism
├── pubspec.yaml
├── analysis_options.yaml
├── LICENSE                          # MIT
└── README.md
```

### Module Map (Source ↔ Port)

Every original TypeScript module maps 1:1 to a Dart module for traceability:

| Original (Expo/React Native) | Flutter Port |
|---|---|
| `src/lib/decay.ts` | `lib/decay.dart` |
| `src/lib/analysis.ts` | `lib/analysis.dart` |
| `src/lib/eulogy.ts` | `lib/eulogy.dart` |
| `src/lib/fragments.ts` | `lib/fragments.dart` |
| `src/lib/words.ts` | `lib/words.dart` |
| `src/lib/format.ts` | `lib/format.dart` |
| `src/lib/sqlite-store.ts` | `lib/store.dart` |
| `src/lib/archive.ts` | `lib/archive.dart` |
| `src/lib/notification.ts` | `lib/notification_service.dart` |
| `src/lib/stage-sound.ts` + `src/hooks/use-ambient-audio.ts` | `lib/ambient_audio.dart` |
| `src/hooks/use-presence.ts` | `lib/presence.dart` |
| `src/lib/widget.ts` + `plugins/with-decay-widget.js` | `lib/widget_sync.dart` + `android/.../DecayWidgetProvider.kt` |
| `src/state/companion.tsx` | `lib/companion.dart` |
| `src/theme/index.ts` | `lib/theme.dart` |
| `src/components/*` | `lib/components/*` |
| `src/app/*` | `lib/screens/*` |

---

## Testing & Quality Assurance

### Test Suite (`test/decay_test.dart`)

| Test | Guarantee Verified |
|---|---|
| Freshly planted companion is vibrant | Stage 0 on day 0 |
| Neglect darkens over time | Stage ≥ 4 after 30 days unvisited |
| Real visits heal but never fully reset | Neglect < 10 days after a visit; stage ≤ 2 |
| Impermanence horizon ends every companion | Daily visits for 400 days still leads to Passing |
| Words and phrases read like prose | `word`, `ordinal`, `daysPhrase` outputs |
| Certificate is deterministic per seed | Identical cause + sentences for identical inputs |

### Quality Gates (Merge Prerequisites)

| Gate | Command | Standard |
|---|---|---|
| Static analysis | `flutter analyze` | **Zero** issues |
| Unit tests | `flutter test` | **100%** pass |
| Manual smoke | device run-through | Onboarding → presence → death → certificate |

### Testability Architecture

Domain logic is pure Dart (no Flutter imports), so the engine, eulogy composer, and helpers are testable on the Dart VM **without emulators, mocks, or platform channels**. Adding coverage means extending `test/` with more `computeDecay` / `composeCertificate` scenarios — no infrastructure required.

---

## Build & Release Management

### Commands

| Command | Artifact |
|---|---|
| `flutter run` | Development build |
| `flutter build apk --release` | Android APK (direct distribution) |
| `flutter build appbundle --release` | Android AAB (Play Store) |
| `flutter build ipa --release` | iOS IPA (App Store) |

### Release Checklist

- [ ] `flutter analyze` — clean (zero issues)
- [ ] `flutter test` — all passing
- [ ] Version bumped in `pubspec.yaml` (`version: X.Y.Z+N`)
- [ ] Manual smoke test: onboarding → presence → certificate flow on a physical device
- [ ] Widget sync verified on Android home screen
- [ ] Store listing copy reviewed against the irreversibility disclosure
- [ ] Data Safety declaration re-confirmed accurate ("no data collected")

### Versioning Policy

Semantic versioning (`MAJOR.MINOR.PATCH` + build number). The irreversible companion mechanic is treated as a **contract**: any change to engine constants or stage doorways warrants at least a MINOR bump and a changelog entry.

| Change Type | Bump |
|---|---|
| Engine constant / stage doorway change | MINOR (contract-affecting) |
| New feature, backwards-compatible | MINOR |
| Bug fix, no contract change | PATCH |
| Irreversibility or privacy posture change | MAJOR (principles P1/P4) |

---

## Performance & Reliability

| Concern | Target | Mechanism |
|---|---|---|
| Frame rate | 60fps sustained | `AnimationController` pipeline; no per-frame allocations in build |
| Cold start | Immediate; no loading states | Local-only reads; splash held until fonts + state ready |
| Battery (widget) | Doze-safe | 30-min periodic refresh only |
| Battery (app) | No background work | Lifecycle-aware timers pause off-screen |
| Audio stutter | None on stage change | Preloaded looped players; segment seeks, not reloads |
| Crash resilience | Fail-soft by default | Every native call wrapped; state read returns defaults on error |
| Storage failure | Next read wins | Documented, intentional (emotional contract > write guarantees) |

---

## Accessibility

- **Readable sizes:** body copy at 16–17pt; smallest labels at 10–12pt letterspaced caps — all ≥ WCAG-recommended minimums for their context.
- **Sufficient contrast:** warm off-white (`#F0EDE6`) on void-charcoal (`#0B0D12`) — far above WCAG AA thresholds.
- **Screen-reader semantics:** every interactive element carries a semantic label and role (`button`, `switch`, `toggled`), despite the deliberately minimal UI.
- **Decorative elements excluded:** the companion form, drifting lights, and flourishes are hidden from the accessibility tree.
- **Haptics:** a single soft haptic confirms presence registration — never urgent, never repeated.

---

## Roadmap

| Phase | Item | Status |
|---|---|---|
| v1.0.0 | Core companion, decay engine, certificate, archive, widget, Flutter port | ✅ Released |
| v1.x | Expanded fragment banks (seasonal / contextual quiet lines) | 🔍 Under consideration |
| v1.x | iOS home-screen widget (lock screen / standby) | 🔍 Under consideration |
| v1.x | Quiet Archive encrypted JSON export | 🔍 Under consideration |
| v2.x | Localized fragment banks (multi-language prose) | 💭 Backlog |

> Roadmap is indicative, not contractual. Principle P4 (irreversibility) and P1 (zero network) gate every item.

---

## Contributing

**Open source under the [MIT License](LICENSE)** — contributions are welcome and subject to the product principles above.

### Workflow

1. Fork / branch from `main`
2. Keep the domain core pure (no Flutter imports in `lib/decay.dart`, `eulogy.dart`, `analysis.dart`, `fragments.dart`, `words.dart`, `format.dart`)
3. Add or extend tests for any domain change
4. Run the quality gates locally:

```bash
flutter analyze   # must be clean
flutter test      # must be 100% green
```

5. Open a pull request with a clear description of intent and rationale

### Contribution Standards

| Standard | Requirement |
|---|---|
| **Purity of the domain** | Domain modules remain Flutter-free and deterministic |
| **Graceful degradation** | Any new native integration must degrade to a working fallback |
| **Emotional contract** | Features adding scores, streaks, urgency, guilt, or replay are rejected by design (P3, P4) |
| **Quality gates** | `flutter analyze` clean and `flutter test` green are merge prerequisites |
| **Style** | Follow existing naming and structure; the codebase mirrors its TypeScript origins 1:1 — keep it that way |

---

## Support & Contact

| Channel | Value |
|---|---|
| **Email** | `hamzapowerplayer.global@gmail.com` |
| **WhatsApp** | `+923129584661` |
| **Developer Support** | [Patreon](https://www.patreon.com/posts/heartfelt-thank-153029964) |
| **Website** | [hamzapowerplayer.com](https://hamzapowerplayer.com) |
| **Bug Reports** | Email or GitHub issue |

Bug reports, kind words, and long messages are all equally fine. There are no ratings prompts, no badges, and no popups asking anything of the user — if you want to help, tell someone you know about it, and stay with the ones you have already planted.

---

## Governance & Legal

- **Author & Maintainer:** HAMZA POWERPLAYER ([hamzapowerplayer.com](https://hamzapowerplayer.com))
- **License:** [MIT](LICENSE) — open source, permissive
- **Terms:** The irreversible death mechanic is disclosed clearly before planting. Standard liability disclaimers apply (see MIT warranty disclaimer). Full text: in-app **Settings → Terms and Conditions**.
- **Privacy:** Collects NO personal data. Requires NO account. All data stored 100% locally. No analytics SDKs. No network requests. Full text: in-app **Settings → Privacy Policy**.
- **Attribution:** Decay was designed and built by HAMZA POWERPLAYER. The copyright notice in [LICENSE](LICENSE) should be retained in copies and substantial portions of the Software.

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for the full text.

```
MIT License

Copyright (c) 2026 HAMZA POWERPLAYER (hamzapowerplayer.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<div align="center">

*Built slowly. Without a single analytics SDK in it.*

**DECCAY** · v1.0.0 · [MIT License](LICENSE) · © 2026 HAMZA POWERPLAYER

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>
# DECAY-FLUTTER-VERSION
