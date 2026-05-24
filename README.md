# Shoot — two-player Rock Paper Scissors (iOS)

A native SwiftUI port of the **Shoot** Claude Design prototype: two players share one phone, each holds their half of the screen, and a "ROCK / PAPER / SCISSORS / SHOOT!" countdown picks a winner.

## Open it

```
open Shoot/Shoot.xcodeproj
```

Pick the **Shoot** scheme + any iPhone simulator (or a real device) and ⌘R.

Built and verified with **Xcode 26.2** targeting **iOS 17+**, portrait-only.

## How to play

- Both players press and hold their half of the screen.
- After a short ready-hold (configurable: Fast / Normal / Slow) the countdown **ROCK → PAPER → SCISSORS** plays.
- On the next beat each side reveals a random pick. Winning side gets confetti, losing side dims.
- Tap the yellow **⟳** in the middle to play another round. The win counter under each half keeps climbing — there is no match end. Tap **Reset scores** in Settings (or relaunch the app) to zero it.

The yellow **VS** button on idle runs a self-playing demo round (useful in the simulator, which only forwards one touch at a time from the trackpad).

## What's implemented

- Two-player split layout — top half rotated 180° so the opponent reads naturally.
- Custom-drawn cartoon hands (rock = fist with knuckles, paper = tall fingers, scissors = V with tucked thumb).
- Three idle-icon variants: **Trio** (default), **Cycle**, **Morph** (single hand cycling R→P→S).
- Four bold palettes: **Candy** (default), **Sunset**, **Neon**, **Vapor**.
- "TAP & HOLD" → "READY!" badge with hold-pulse outline.
- 3-step ROCK / PAPER / SCISSORS countdown (auto-fits to one line), hold-to-cancel, reveal on the 4th beat.
- Reveal with hand + verdict + per-side dimming.
- Confetti (TimelineView-driven) on the winning side.
- Persistent per-player score tally that resets on relaunch.
- Settings sheet (per-side; rotates 180° when opened from top):
  - **Appearance** — palette + idle icon
  - **Game** — no-ties (default ON) / hold-to-ready timing
  - **Accessibility** — haptics, reduce motion
  - **Reset scores**
- Settings persisted in `UserDefaults` under `rps_settings_v3`; scores are session-only.
- Haptics via `UIImpactFeedbackGenerator` (gated on the setting).
- Custom app icon baked from the trio-of-hands artwork on a candy gradient.

## Project structure

```
Shoot/
├── Shoot.xcodeproj/               # Hand-authored, uses Xcode 15+ file-system synchronized groups
└── Shoot/
    ├── ShootApp.swift             # @main
    ├── ContentView.swift          # Top half / divider / bot half / settings sheet
    ├── Info.plist
    ├── Models/                    # GameTypes, GameSettings, GameViewModel
    ├── Views/                     # HalfView, IdleContentView, CountContentView, RevealContentView,
    │                              # MatchEndContentView, ScoreBadgeView, ConfettiView,
    │                              # DividerOverlay, SettingsSheet, ColorblindPattern
    ├── Shapes/                    # HandPaths (SVG→Path data), HandView, Trio/Cycle/Morph icons,
    │                              # TrophyShape, RefreshShape
    ├── Theme/                     # Ink (color + fonts), Palettes
    ├── Haptics.swift
    ├── Fonts/                     # LilitaOne (display) + Fredoka variable (body) — Google Fonts (OFL)
    └── Assets.xcassets/           # AccentColor + AppIcon (generated from the trio artwork)
```

## Caveats

- **Two-finger hold** only works naturally on a real device. The simulator delivers one touch at a time from a mouse/trackpad; use the **VS** button to trigger a demo round there. (Xcode → Window → Devices for multi-touch on connected hardware, or hold ⌥/Option in the simulator for synthetic two-finger gestures.)
- The hand silhouettes were transcribed directly from the prototype's SVG paths into SwiftUI `Path`. They render faithfully but if you nudge them visually, edit `Shoot/Shapes/HandPaths.swift` — every other view consumes those four paths.
- App icon was rendered offline by `/tmp/gen_appicon.swift` (kept out-of-tree). Re-run with `swift /tmp/gen_appicon.swift <out.png>` if you change the artwork.

## License

The bundled Google Fonts (Lilita One, Fredoka) are SIL Open Font License 1.1. Everything else: do what you want.
