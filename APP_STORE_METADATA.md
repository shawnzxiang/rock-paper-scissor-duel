# App Store Connect submission — pre-filled fields

This is the content I'll paste into App Store Connect for the new app listing. Review and edit before submission.

## New App form (Apple's first screen)

| Field | Value |
|---|---|
| Platforms | iOS |
| Name | **Rock Paper Scissor** |
| Primary Language | English (U.S.) |
| Bundle ID | com.shawn.shoot |
| SKU | shoot-ios-001 |
| User Access | Full Access |

> *Bundle ID note:* if `com.shawn.shoot` doesn't yet exist in your developer portal, Apple won't list it in the dropdown — you'll need to register it first under **Certificates, Identifiers & Profiles → Identifiers → +**.

## App Information

| Field | Value |
|---|---|
| Subtitle (30 chars max) | Two-player Rock Paper Scissors |
| Category — Primary | Games |
| Category — Subcategory | Casual |
| Category — Secondary | Family |
| Content Rights | Does NOT use third-party content |
| Age Rating | 4+ (no objectionable content) |

## Pricing and Availability
- Price: **Free** (tier 0)
- Availability: All territories
- Pre-orders: off

## App Privacy

The app collects **no data**. The privacy manifest (`PrivacyInfo.xcprivacy`) declares:
- `NSPrivacyTracking`: `false`
- `NSPrivacyTrackingDomains`: empty
- `NSPrivacyCollectedDataTypes`: empty
- `NSPrivacyAccessedAPITypes`: UserDefaults only, reason CA92.1 (settings persistence)

When Apple's privacy questionnaire asks, select:
- **"No, we do not collect data from this app"**

## Version 1.0 — App Store listing

### Promotional Text (170 chars, can change without resubmit)
Pass the phone between you and a friend, hold your side, and play Rock Paper Scissors. No ads, no accounts — just thumbs.

### Description (4000 chars max)
```
Shoot is a two-player Rock Paper Scissors game you play on one phone.

Hold the phone vertically between you and a friend. Each person presses and holds their half of the screen. After a quick "ROCK / PAPER / SCISSORS" countdown, both sides reveal a random pick — the winning half gets confetti and a score; the losing half dims. Hit the yellow ⟳ button to play again.

— FEATURES —
• Built for two players on one device — pass-and-play, no networking, no accounts
• The top half is automatically flipped 180° so the player opposite you reads right-side up
• Four bold themes: Candy, Mono (black & white), Flat, and Pop
• Persistent score counter that climbs as you play, resets when you ask it to
• Localized in 22 languages including Spanish, French, German, Chinese (Simplified & Traditional), Japanese, Korean, Arabic, Hindi, and more
• Playful sound effects and gentle haptics on every round (both togglable)
• Reduce-motion option for a calmer experience

— PRIVACY —
Shoot collects no data, makes no network calls, and shows no ads. Your scores and settings stay on your device.

Free. Forever. No tracking.
```

### Keywords (100 chars, comma-separated)
```
rock paper scissors,rps,two player,couch game,party,multiplayer,kids,family,quick,offline
```

### Support URL
TBD — use a GitHub repo link or a personal page

### Marketing URL (optional)
TBD

### Privacy Policy URL (required)
TBD — even a 1-page "this app collects nothing" works

## Build

| Field | Value |
|---|---|
| Build version | 1.0 |
| Build number | 1 |
| Minimum iOS | 17.0 |
| Devices | iPhone, iPad |
| Orientations | Portrait only |

## Screenshots needed

Required for at least one display size. **6.7" iPhone (1290 × 2796)** covers most modern devices.

Suggested shots:
1. Idle screen with Flat palette — "Two players, one phone"
2. Countdown mid-flight (SCISSORS visible)
3. Reveal with confetti — "Winning side celebrates"
4. Settings sheet showing palette picker
5. Mono palette idle screen — "Themes for every vibe"

I can re-capture these via `xcrun simctl io booted screenshot` on an iPhone 17 Pro Max simulator (which is 6.9", close enough — Apple accepts).

## App Review Information

| Field | Value |
|---|---|
| Sign-in required | No |
| Demo account | Not applicable |
| Notes | Two-player local game. Tap and hold both halves of the screen to start a round. The yellow VS button in the center runs a demo round (useful for review since only one touch can come from the simulator at a time). |
| Contact First Name | Shawn |
| Contact Last Name | Xiang |
| Contact Phone | TBD |
| Contact Email | shawnzxiang@gmail.com |

## Export Compliance

- Uses encryption? **No** (the app makes no network calls and uses no cryptographic APIs beyond what Apple ships)
- No export-compliance docs needed
