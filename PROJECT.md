# Project: Verb360 AI

## Architecture
- **Framework**: Flutter Multiplatform (`app/`), Target: Android & iOS, with Riverpod (`flutter_riverpod`) state management and Material 3 design.
- **Backend**: Golang with PocketBase (`backend/`), Go Event Hooks, local SQLite WAL mode, REST & SSE APIs at `https://verd.phuongdan.io.vn` (LAN: `http://192.168.1.5:8103`).
- **Target Application ID**: `vn.phuongdan.360verb` on iOS (`PRODUCT_BUNDLE_IDENTIFIER`); on Android, due to strict Java/AAPT2 identifier rules prohibiting segment leading digits (`360verb`), Android uses `vn.phuongdan.verb360` (or `vn.phuongdan.v360verb`) for `namespace` and `applicationId`.
- **Display Name**: `Verb360 AI` across Android (`AndroidManifest.xml`) and iOS (`Info.plist`).
- **Core Modules**:
  1. `app/lib/data`: Models (`Verb`, `IapProduct`), repositories, and services (TTS, PocketBase client, Local Cache).
  2. `app/lib/logic`: Riverpod providers for dictionary, SRS (SM-2 Spaced Repetition), AI writing tutor (DeepSeek), gamification (XP, streaks), and IAP.
  3. `app/lib/presentation`: UI screens, `AdaptiveScaffold`, navigation, modals (`PaywallModal`, `AuthModal`), practice screens (`FlashcardScreen`, `FillBlanksScreen`, `SpeedQuizScreen`, `AiWritingScreen`).
  4. `metadata`: Store upload materials for Apple App Store and Google Play Store in English and Vietnamese.
  5. `fastlane`: Automated deployment pipelines for Android and iOS.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---|---|---|---|
| F01 | Application ID Configuration | Migrate Android package/namespace and iOS bundle ID to `vn.phuongdan.360verb` / `vn.phuongdan.verb360` cleanly | M1 | ORIGINAL_REQUEST §R1 |
| F02 | Native Package Directory Refactoring | Move Kotlin `MainActivity.kt` to match new package path, clean legacy com/... tree | M1 | survey_app_id |
| F03 | iOS Xcode & Plist Alignment | Configure `project.pbxproj` and `Info.plist` with bundle ID and `Verb360 AI` display name | M1 | survey_app_id |
| F04 | Paywall Modal Responsive Fix | Replace unconstrained footer Row with Wrap/Responsive layout to eliminate RenderFlex overflow | M2 | survey_ui_layout |
| F05 | Auth Modal Dynamic Height | Resolve TabBarView hardcoded height overflow when validation errors appear | M2 | survey_ui_layout |
| F06 | AI Writing Screen Layout Fix | Constrain nested title/badge Rows with Expanded/Flexible to eliminate overflows on <390dp | M2 | survey_ui_layout |
| F07 | Profile VIP Status Layout Fix | Wrap VIP status card row in Flexible/Wrap to prevent overflow on narrow viewports | M2 | survey_ui_layout |
| F08 | Speed Quiz & Flashcard Landscape Fix | Add SingleChildScrollView to completion / game over views for landscape & split-screen | M2 | survey_ui_layout |
| F09 | AdaptiveScaffold State Sync | Implement `didUpdateWidget` in AdaptiveScaffold for programmatic tab navigation | M2 | survey_ui_layout |
| F10 | Google Pixel 4 XL UI Verification | Verify zero RenderFlex overflows and clean rendering on physical device `99051FFBA004TL` | M2, M4 | ORIGINAL_REQUEST §R2 |
| F11 | Multi-Device Responsive Tests | Automated layout tests across 320x568, 390x844, 412x869, 768x1024, 1024x768 | M2, E2E | survey_ui_layout |
| F12 | Google Play Metadata (EN & VI) | Title (<=30), Short desc (<=80), Full desc (<=4000) in `en-US` and `vi-VN` with legal footers | M3 | survey_store_materials |
| F13 | Apple App Store Metadata (EN & VI) | Name (<=30), Subtitle (<=30), Desc (<=4000, 0 emoji), Keywords (<=100 bytes) in `en-US` and `vi` | M3 | survey_store_materials |
| F14 | App Review Information Setup | Contact details (Dan Nguyen Van, +84 355533893, nguyenvandan868@gmail.com) | M3 | store_aso_compliance |
| F15 | Legal Policies (Privacy & EULA) | Bilingual Privacy Policy and Terms of Use (EULA) with standard Apple EULA links | M3 | survey_store_materials |
| F16 | Fastlane Configuration Files | `Appfile` and `Fastfile` for both Android and iOS with beta, release, and metadata lanes | M3 | app-store-fastlane |
| F17 | Static Analysis & Test Verification | `flutter analyze` 0 issues (0 errors, 0 warnings), 100% tests passing | M4 | ORIGINAL_REQUEST Criteria |
| F18 | Forensic Integrity & Adversarial Audit | Independent verification of zero cheating, genuine implementation, and zero regression | M4 | Integrity Forensics |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|---|---|---|---|
| M1 | Application ID & Build Alignment | F01, F02, F03 | None | DONE |
| M2 | UI Inspection & Layout Bug Fixes | F04, F05, F06, F07, F08, F09, F10, F11 | M1 | DONE |
| M3 | Store Upload Materials & Fastlane | F12, F13, F14, F15, F16 | None | DONE |
| M4 | Final Milestone & Victory Verification | F10, F11, F17, F18 (100% E2E Pass + Pixel 4 XL audit) | M1, M2, M3 | DONE |
| E2E | E2E Testing Track | Requirement-driven test harness, multi-device layout tests, runner | None | DONE |

## Interface Contracts
### Application ID Contract
- Android Gradle: `namespace = "vn.phuongdan.verb360"`, `applicationId = "vn.phuongdan.verb360"`.
- Android Kotlin entrypoint: `app/android/app/src/main/kotlin/vn/phuongdan/verb360/MainActivity.kt`.
- iOS Xcode Project: `PRODUCT_BUNDLE_IDENTIFIER = vn.phuongdan.360verb;` (or `vn.phuongdan.verb360;`).
- iOS Display Name: `CFBundleDisplayName = "Verb360 AI"`.

### UI Component Contracts
- `AdaptiveScaffold`: Must respond dynamically to `widget.initialIndex` changes via `didUpdateWidget`.
- `PaywallModal`: Footer actions must wrap or adapt down to 320dp without horizontal overflow.
- `AuthModal`: Body must dynamically size or scroll cleanly without vertical RenderFlex overflow under validation errors.
- Responsive Breakpoints: Mobile (<768dp) uses BottomNavigationBar; Tablet/Desktop (>=768dp) uses NavigationRail.

### Store Metadata File Structure Contract
- Android: `app/android/fastlane/metadata/android/` with `en-US/` and `vi-VN/` containing `title.txt`, `short_description.txt`, `full_description.txt`.
- iOS: `app/ios/fastlane/metadata/` with `en-US/` and `vi/` containing `name.txt`, `subtitle.txt`, `description.txt`, `keywords.txt`, `privacy_url.txt`, `support_url.txt`, `marketing_url.txt`.
- Review Info: `app/ios/fastlane/metadata/review_information/` containing `first_name.txt`, `last_name.txt`, `phone_number.txt`, `email_address.txt`.
- Legal Docs: `docs/privacy_policy_en.md`, `docs/privacy_policy_vi.md`, `docs/terms_of_use_en.md`, `docs/terms_of_use_vi.md` (and corresponding `.html`).

## Code Layout
- `app/lib/`: Flutter application source code.
- `app/test/`: Unit, widget, and responsive layout test suites.
- `app/android/`: Android platform files, Gradle build scripts, Kotlin entrypoint, Android Fastlane.
- `app/ios/`: iOS platform files, Xcode project configuration, Info.plist, iOS Fastlane.
- `docs/`: Legal policies, store submission documentation, Privacy Policy and Terms of Use.
- `.agents/teamwork/`: Orchestrator and agent metadata, plans, reports, handoffs.
