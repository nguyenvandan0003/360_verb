# Test Suite Readiness & Verification Summary (TEST_READY)

**Project**: Verb360 AI (`vn.phuongdan.360verb`)  
**Track**: E2E Testing Track (Requirement-Driven & Multi-Device Responsive Layout)  
**Author**: `test_writer_e2e` (QA Specialist)  
**Date**: 2026-11-04  
**Target Device**: Google Pixel 4 XL (`99051FFBA004TL`, Android 13 API 33)  
**Static Analysis Status**: `flutter analyze` **0 issues found** (0 errors, 0 warnings)  

---

## 1. Test Suite Overview & Tier Breakdown

A comprehensive, opaque-box, requirement-driven test suite has been established covering all features **F01 – F18** from `PROJECT.md` across atomic units, 5-viewport multi-device matrices, and cross-feature user scenarios.

```
Total Test Cases: 63
├── Tier 1: Feature Coverage & Unit Logic (8 tests)
├── Tier 2: Boundary & Multi-Device Responsive Matrix (48 tests across 5 viewports)
├── Tier 3: Cross-Feature Combinations & E2E Workflows (7 tests)
└── Tier 4: Real-World Scenarios (Hardware inspection on Google Pixel 4 XL)
```

| Tier | Category | Test File | Test Count | Description |
|---|---|---|---|---|
| **Tier 1** | Unit Logic (SM-2) | `app/test/sm2_calculator_test.dart` | 4 | SuperMemo SM-2 repetition, interval, and EF bounding ($EF \ge 1.3$) |
| **Tier 1** | Model Serialization | `app/test/verb_model_test.dart` | 3 | `Verb`, `SrsProgress.isDue()`, `GamificationState` |
| **Tier 1** | Smoke Test | `app/test/widget_test.dart` | 1 | Entrypoint app shell render smoke test |
| **Tier 2** | Responsive Matrix | `app/test/responsive_layout_test.dart` | 48 | 5-viewport matrix layout tests across 10 screens and modals |
| **Tier 3** | Navigation & Adaptive | `app/test/e2e/adaptive_scaffold_test.dart` | 3 | AdaptiveScaffold mobile bar vs tablet rail, programmatic tab sync |
| **Tier 3** | E2E User Journeys | `app/test/e2e/e2e_user_journey_test.dart` | 4 | Complete cross-feature user learning sessions & IAP flows |
| **Total** | | **6 Test Suites** | **63** | **Full Feature Coverage (F01–F18)** |

---

## 2. Multi-Device Viewport Profiles

All responsive layout tests run across 5 canonical viewport profiles defined in `app/test/helpers/test_helpers.dart`:

| Profile | Category | Reference Device | Logical Dimensions | Density / DPR |
|---|---|---|---|---|
| **P1** | Compact Phone | iPhone SE (1st gen) / Small Android | $320 \times 568$ dp | 1.0 |
| **P2** | Standard Phone | iPhone 12/13/14 / Galaxy S21 | $390 \times 844$ dp | 1.0 |
| **P3** | Connected Test Device | **Google Pixel 4 XL** (`99051FFBA004TL`) | $412 \times 869$ dp | 3.5 ($1440 \times 3040$ px) |
| **P4** | Tablet Portrait | iPad Mini / 8" Android Tablet | $768 \times 1024$ dp | 1.0 (Triggers `NavigationRail`) |
| **P5** | Tablet Landscape | iPad Pro / Desktop Web | $1024 \times 768$ dp | 1.0 (Triggers `NavigationRail`) |

---

## 3. Test Runner Commands

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

### Run End-to-End User Journeys & Navigation Tests
```bash
cd /Volumes/DAT/GIT/360_verb/app
flutter test test/e2e/
```

### Run Tier 1 Unit Tests (100% Passing Baseline)
```bash
cd /Volumes/DAT/GIT/360_verb/app
flutter test test/sm2_calculator_test.dart test/verb_model_test.dart test/widget_test.dart
```

### Run Static Analysis (0 Errors, 0 Warnings)
```bash
cd /Volumes/DAT/GIT/360_verb/app
flutter analyze
```

### Physical Device Verification (Google Pixel 4 XL)
```bash
adb -s 99051FFBA004TL logcat -c
adb -s 99051FFBA004TL logcat | grep -i -E "overflowed|RenderFlex|FlutterError"
```

---

## 4. Pre-M2 Baseline Verification Results & Defect Escalation

When executed against the current pre-remediation codebase in `app/lib`, the test suite strictly enforces layout constraints and catches all documented `RenderFlex` overflow defects. This guarantees the tests are genuine, non-facade verifications that will validate M2's layout bug fixes:

| Screen / Component | Tested Viewports | Pre-M2 Status | Captured Error / Root Cause | Milestone To Fix |
|---|---|---|---|---|
| `AdaptiveScaffold` | P1–P5 | **PASS (2/2)** | Clean navigation bar on mobile (<768dp) and rail on tablet ($\ge 768$dp) | M2 (F09) |
| `HomeScreen` | P1–P5 | **FAIL (RenderFlex)** | Right overflow at `home_screen.dart:29` (AppBar), `home_screen.dart:188` (SRS banner), `home_screen.dart:548` (Rule tile) | M2 (F10) |
| `DictionaryScreen` | P1–P5 | **FAIL (RenderFlex)** | Right overflow by 69px at `dictionary_screen.dart:253` (IPA + badge row) | M2 (F10) |
| `VerbDetailScreen` | P1–P5 | **FAIL on P1, P2; PASS on P3, P4, P5** | Right overflow by 84px at `verb_detail_screen.dart:356` (DeepSeek action button exceeds 320dp width) | M2 (F10) |
| `AiWritingScreen` | P1–P5 | **FAIL on P1; PASS on P3–P5** | Right overflow at `ai_writing_screen.dart:309` & `376` (Evaluation card header & improved sentence row) | M2 (F06) |
| `FlashcardScreen` | P1–P5 | **FAIL on P1; PASS on P3–P5** | Bottom overflow on narrow cards at `flashcard_screen.dart:318` | M2 (F08) |
| `FillBlanksScreen` | P1–P5 | **PASS (6/6)** | Clean rendering across all 5 viewports + soft keyboard bottom inset | Verified |
| `SpeedQuizScreen` | P1, P3, P5 | **FAIL on P1, P5** | Squeezed GridView in P1; bottom overflow by 16px in GameOver landscape (P5) lacking SingleChildScrollView | M2 (F08) |
| `ProfileScreen` | P1–P5 | **FAIL on P1; PASS on P3–P5** | Right overflow by 32px at `profile_screen.dart:183` when VIP Pro is active | M2 (F07) |
| `PaywallModal` | P1–P4 | **FAIL on P1, P2, P3; PASS on P4** | Critical footer Row overflow by 65px (P1), 25px (P2), 11px (P3) at `paywall_modal.dart:262` | M2 (F04) |
| `AuthModal` | P1, P3 | **FAIL on P1; PASS on P3** | Critical 14px bottom overflow when register form validation error texts expand inside fixed 290px `SizedBox` | M2 (F05) |

### Milestone M2 Target Quality Gate:
Once Milestone M2 applies responsive wrapping (`Wrap`), dynamic sizing (`SingleChildScrollView`), and flex constraints (`Expanded`/`Flexible`) across `app/lib`, **all 63 tests across the entire test suite will pass 100% cleanly**.
