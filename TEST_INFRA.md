# Test Infrastructure & Verification Architecture

**Project**: Verb360 AI (`vn.phuongdan.360verb`)  
**Author**: `test_writer_e2e` (Quality Assurance & Test Specialist)  
**Target Device**: Google Pixel 4 XL (`99051FFBA004TL`, Android 13 API 33)  
**Framework**: Flutter Multiplatform (`app/`), Golang PocketBase Backend (`backend/`)  
**Last Updated**: 2026-11-04  

---

## 1. Test Philosophy: Opaque-Box & Requirement-Driven

The test architecture for **Verb360 AI** adheres strictly to **opaque-box, requirement-driven testing**:
1. **Behavioral Integrity**: Tests interact exclusively through public APIs, widget rendering trees, user gestures, and standard state notifiers. No test relies on internal private implementation details or fragile reflection.
2. **Authoritative Expected Outputs**: Expected outputs are derived directly from:
   - System requirements specified in `ORIGINAL_REQUEST.md` (§R1, §R2, §R3).
   - Architectural and interface contracts in `PROJECT.md` (F01–F18).
   - SM-2 spaced repetition mathematical specification ($EF' = EF + (0.1 - (5 - q) \cdot (0.08 + (5 - q) \cdot 0.02))$, $EF \ge 1.3$).
   - Physical device specifications of Google Pixel 4 XL ($1440 \times 3040$ px, $560$ dpi $\rightarrow 411.4 \times 868.5$ dp).
3. **No Facade or Cheating**: Tests assert genuine widget tree layout, zero unhandled exceptions (`tester.takeException() == null`), zero `RenderFlex` overflow errors, and correct state transitions. Tests never bypass assertion logic or use dummy always-passing mocks.

---

## 2. Comprehensive Feature Inventory (F01 – F18)

Every feature defined in `PROJECT.md` is covered across the test suite and verification matrix:

| Feature ID | Feature Name | Requirement Source | Milestone | Test File / Verification Target | Verification Method |
|---|---|---|---|---|---|
| **F01** | Application ID Configuration | `ORIGINAL_REQUEST` §R1 | M1 | `app/android/app/build.gradle.kts`, `app/ios/...` | Static inspect & Gradle/Xcode validation |
| **F02** | Native Package Directory Refactoring | `ORIGINAL_REQUEST` §R1 | M1 | `app/android/app/src/main/kotlin/vn/phuongdan/verb360/` | File tree audit & compilation check |
| **F03** | iOS Xcode & Plist Alignment | `ORIGINAL_REQUEST` §R1 | M1 | `app/ios/Runner.xcodeproj/project.pbxproj` | Bundle identifier & CFBundleDisplayName check |
| **F04** | Paywall Modal Responsive Fix | `ORIGINAL_REQUEST` §R2 | M2 | `app/test/responsive_layout_test.dart` | Viewport rendering across 320dp–1024dp |
| **F05** | Auth Modal Dynamic Height | `ORIGINAL_REQUEST` §R2 | M2 | `app/test/responsive_layout_test.dart` | Form validation error overflow check |
| **F06** | AI Writing Screen Layout Fix | `ORIGINAL_REQUEST` §R2 | M2 | `app/test/responsive_layout_test.dart` | Evaluation card & header constraint tests |
| **F07** | Profile VIP Status Layout Fix | `ORIGINAL_REQUEST` §R2 | M2 | `app/test/responsive_layout_test.dart` | VIP active status badge row rendering |
| **F08** | Speed Quiz & Flashcard Landscape Fix | `ORIGINAL_REQUEST` §R2 | M2 | `app/test/responsive_layout_test.dart` | Landscape (1024x768 & 568x320) scroll check |
| **F09** | AdaptiveScaffold State Sync | `ORIGINAL_REQUEST` §R2 | M2 | `app/test/e2e/adaptive_scaffold_test.dart` | `didUpdateWidget` programmatic tab switch |
| **F10** | Google Pixel 4 XL UI Verification | `ORIGINAL_REQUEST` §R2 | M2, M4 | Connected Device `99051FFBA004TL` | `adb logcat` RenderFlex monitor & screenshot |
| **F11** | Multi-Device Responsive Tests | `ORIGINAL_REQUEST` §R2 | M2, E2E | `app/test/responsive_layout_test.dart` | 5-viewport matrix automated test runner |
| **F12** | Google Play Metadata (EN & VI) | `ORIGINAL_REQUEST` §R3 | M3 | `metadata/android/` | Character limit & ASO keyword audit |
| **F13** | Apple App Store Metadata (EN & VI) | `ORIGINAL_REQUEST` §R3 | M3 | `metadata/ios/` | Character limit, 0 emoji, subtitle audit |
| **F14** | App Review Information Setup | `ORIGINAL_REQUEST` §R3 | M3 | `metadata/review_information/` | Contact details & reviewer credentials |
| **F15** | Legal Policies (Privacy & EULA) | `ORIGINAL_REQUEST` §R3 | M3 | `docs/privacy_policy_*`, `docs/terms_*` | Bilingual legal compliance verification |
| **F16** | Fastlane Configuration Files | `ORIGINAL_REQUEST` §R3 | M3 | `app/android/fastlane`, `app/ios/fastlane` | Syntax validation & lane execution dry-run |
| **F17** | Static Analysis & Test Verification | `ORIGINAL_REQUEST` DoD | M4 | Project root | `flutter analyze` (0 issues) + `flutter test` |
| **F18** | Forensic Integrity & Adversarial Audit | `ORIGINAL_REQUEST` DoD | M4 | Workspace integrity scan | Independence audit, zero cheating verification |

---

## 3. Test Architecture & 4-Tier Strategy

The test suite is structured into four distinct hierarchical tiers to ensure comprehensive validation from atomic units to end-to-end user journeys:

```
                            ┌───────────────────────────────────────────┐
                            │      Tier 4: Real-World Scenarios         │
                            │  (Pixel 4 XL physical run, IAP & Auth)    │
                            ├───────────────────────────────────────────┤
                            │  Tier 3: Cross-Feature & E2E Workflows   │
                            │  (Navigation sync, Practice -> XP -> Prof)│
                            ├───────────────────────────────────────────┤
                            │    Tier 2: Boundary & Responsive Matrix   │
                            │ (320dp to 1024dp, TextScale 1.3x, errors) │
                            ├───────────────────────────────────────────┤
                            │    Tier 1: Feature & Unit Coverage        │
                            │    (SM-2, Verb model, basic screen pump)  │
                            └───────────────────────────────────────────┘
```

### Tier 1: Feature & Unit Coverage
- **Scope**: Core algorithms, model serialization, and baseline widget rendering.
- **Test Files**:
  - `app/test/sm2_calculator_test.dart`: Validates SuperMemo SM-2 repetition intervals, easiness factor bounding ($EF \ge 1.3$), and grade calculation.
  - `app/test/verb_model_test.dart`: Validates `Verb.fromJson`, `toJson`, `SrsProgress.isDue()`, and `GamificationState`.
  - `app/test/widget_test.dart`: App entrypoint smoke test.

### Tier 2: Boundary & Corner Cases (Multi-Device Responsive Matrix)
- **Scope**: Layout constraints, text scaling, narrow viewports, form validation error expansion, and extreme content lengths.
- **Test File**: `app/test/responsive_layout_test.dart`
- **Key Invariants**:
  - Zero `RenderFlex` overflow errors across all tested screen sizes.
  - Zero unhandled exceptions (`tester.takeException() == null`).
  - Text wrapping and clipping containment within cards and modal boundaries.

### Tier 3: Cross-Feature Combinations & End-to-End Scenarios
- **Scope**: Multi-screen user journeys, state synchronization across Riverpod providers, and navigation shell interactions.
- **Test Files**:
  - `app/test/e2e/e2e_user_journey_test.dart`: Complete learning session (Home $\rightarrow$ Dictionary search $\rightarrow$ Verb detail $\rightarrow$ AI Writing $\rightarrow$ Fill Blanks $\rightarrow$ Speed Quiz $\rightarrow$ Profile XP update).
  - `app/test/e2e/adaptive_scaffold_test.dart`: Responsive shell switching between `NavigationBar` (<768dp) and `NavigationRail` ($\ge 768$dp), and programmatic `initialIndex` navigation.

### Tier 4: Real-World Scenarios & Physical Device Verification
- **Scope**: Hardware-level rendering on connected Google Pixel 4 XL (`99051FFBA004TL`), orientation switches, and modal bottom sheet interactions.
- **Target Device**: Android 13 API 33, 1440x3040 px @ 560 dpi.

---

## 4. Multi-Device Responsive Matrix

All application screens and modals are tested against 5 standard viewport profiles representing the global device distribution:

| Profile | Category | Reference Device | Logical Size (W $\times$ H) | Device Pixel Ratio | Responsive Target |
|---|---|---|---|---|---|
| **P1** | Compact Phone | iPhone SE (1st gen) / Small Android | $320 \times 568$ dp | 1.0 / 2.0 | Minimum mobile width boundary |
| **P2** | Standard Phone | iPhone 12/13/14 / Galaxy S21 | $390 \times 844$ dp | 1.0 / 3.0 | Modern standard smartphone |
| **P3** | Connected Device | **Google Pixel 4 XL** (`99051FFBA004TL`) | $412 \times 869$ dp | 3.5 ($1440 \times 3040$ px) | Physical QA target device |
| **P4** | Tablet Portrait | iPad Mini / 8" Android Tablet | $768 \times 1024$ dp | 1.0 / 2.0 | Breakpoint threshold $\rightarrow$ `NavigationRail` |
| **P5** | Tablet Landscape | iPad Pro / Desktop Web | $1024 \times 768$ dp | 1.0 / 2.0 | Landscape & wide layout adaptation |

### Screens Tested Across the Matrix:
1. **Home Screen** (`HomeScreen`): SRS due banner, practice shortcuts, rule group tiles.
2. **Dictionary Screen** (`DictionaryScreen`): Search bar, filter chip row, verb cards.
3. **Verb Detail Screen** (`VerbDetailScreen`): V1/V2/V3 card, AI sentence button, example list.
4. **AI Writing Screen** (`AiWritingScreen`): Prompt input, evaluation card, improved sentence row.
5. **Flashcard SRS Screen** (`FlashcardScreen`): 3D flip card, rating buttons, completion screen.
6. **Fill Blanks Screen** (`FillBlanksScreen`): V2/V3 inputs, check answer feedback, score banner.
7. **Speed Quiz Screen** (`SpeedQuizScreen`): 60-second reflex 2x2 grid, game-over screen.
8. **Profile Screen** (`ProfileScreen`): User avatar card, VIP status row, gamification stats.
9. **Paywall Modal** (`PaywallModal`): Benefits card, radio plans, footer legal buttons.
10. **Authentication Modal** (`AuthModal`): Login & Register tab forms, validation error states.
11. **Adaptive Navigation Shell** (`AdaptiveScaffold`): Mobile bar vs Tablet rail.

---

## 5. Test Infrastructure & Helpers (`app/test/helpers/`)

To ensure deterministic, reproducible, and isolated execution, the test suite leverages modular helpers:

- **`test_helpers.dart`**:
  - `TestViewports`: Predefined `Size` constants for P1–P5.
  - `pumpResponsiveWidget`: Helper that configures `tester.view.physicalSize`, `tester.view.devicePixelRatio`, and tears down state cleanly after each test.
  - `MockVerbData`: In-memory mock verbs covering monosyllabic, polysyllabic (`misunderstand`, `telecast`), and all CEFR levels (A1 to C2).
  - `createTestProviderScope`: Pre-configured Riverpod `ProviderScope` with mock overrides for audio TTS, PocketBase backend, and in-app purchases.

---

## 6. Test Runner Commands

### Run Full Test Suite
```bash
cd /Volumes/DAT/GIT/360_verb/app
flutter test
```

### Run Multi-Device Responsive Layout Tests
```bash
cd /Volumes/DAT/GIT/360_verb/app
flutter test test/responsive_layout_test.dart
```

### Run End-to-End Journey & Navigation Tests
```bash
cd /Volumes/DAT/GIT/360_verb/app
flutter test test/e2e/
```

### Run Unit Tests Only
```bash
cd /Volumes/DAT/GIT/360_verb/app
flutter test test/sm2_calculator_test.dart test/verb_model_test.dart
```

### Physical Device Logcat Overflow Monitor (Pixel 4 XL)
```bash
adb -s 99051FFBA004TL logcat -c
adb -s 99051FFBA004TL logcat | grep -i -E "overflowed|RenderFlex|FlutterError"
```

---

## 7. Quality Gates & Definition of Done

1. **Zero RenderFlex Overflows**: All screens pass across 320x568, 390x844, 412x869, 768x1024, and 1024x768 without horizontal or vertical overflows.
2. **Static Analysis**: `flutter analyze` returns `0 issues` (0 errors, 0 warnings).
3. **Execution Rate**: 100% of automated unit, widget, responsive, and E2E tests pass cleanly.
4. **Physical Verification**: Google Pixel 4 XL (`99051FFBA004TL`) exhibits zero layout defects during live app exploration.
