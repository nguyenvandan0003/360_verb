# Handoff Report — UI Architecture, Screen Implementations, Layout Audit & Test Plan

**Agent**: `explorer_survey_2` (teamwork_explorer)  
**Parent Conversation ID**: `ca60e4b8-b32f-4ba3-9b98-7262d16a5d53`  
**Milestone**: `survey_ui_layout`  
**Date**: 2026-11-04  

---

## 1. Observation

1. **Connected Physical Device Connectivity**:
   - Command: `adb devices && flutter devices`
   - Result:
     ```
     List of devices attached
     99051FFBA004TL	device

     Found 3 connected devices:
       Pixel 4 XL (mobile) • 99051FFBA004TL • android-arm64 • Android 13 (API 33)
     ```
   - Physical display inspection:
     `adb -s 99051FFBA004TL shell wm size` $\rightarrow$ `Physical size: 1440x3040`.
     `adb -s 99051FFBA004TL shell wm density` $\rightarrow$ `Physical density: 560`.
     Logical dimensions: $411.4 \times 868.5$ dp (scale factor 3.5x).
   - Currently installed package: `package:com.antigravity.verb360.app`.

2. **Existing Tests and Linter Status**:
   - Command: `cd /Volumes/DAT/GIT/360_verb/app && flutter analyze && flutter test`
   - Result:
     `Analyzing app... No issues found! (ran in 6.3s)`
     `All 8 tests passed! (ran in 10s)`
   - Files inspected:
     - `app/test/sm2_calculator_test.dart` (4 unit tests)
     - `app/test/verb_model_test.dart` (3 unit tests)
     - `app/test/widget_test.dart` (1 smoke test finding 4 strings)
   - Zero tests exist for practice screens (`FillBlanksScreen`, `SpeedQuizScreen`, `FlashcardScreen`, `AiWritingScreen`), modals (`PaywallModal`, `AuthModal`), or multi-device screen sizes (phone/tablet).

3. **Screen & Navigation Architecture**:
   - `app/lib/main.dart:77-81`: `AdaptiveScaffold(initialIndex: _currentIndex, pages: pages, destinations: destinations)`
   - `app/lib/presentation/adaptive_scaffold.dart:20-26`:
     ```dart
     @override
     void initState() {
       super.initState();
       _currentIndex = widget.initialIndex;
     }
     ```
     `_AdaptiveScaffoldState` does NOT implement `didUpdateWidget`. `initialIndex` changes from `HomeScreen.onNavigateToDictionary` are ignored.
   - `app/lib/presentation/widgets/paywall_modal.dart:262-280`:
     Footer with 3 `TextButton`s and 2 bullet points laid out inside a single unconstrained `Row`:
     ```dart
     Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         TextButton(onPressed: ..., child: const Text('Khôi phục gói mua', ...)),
         const Text('•', ...),
         TextButton(onPressed: ..., child: const Text('Điều khoản (EULA)', ...)),
         const Text('•', ...),
         TextButton(onPressed: ..., child: const Text('Bảo mật', ...)),
       ],
     )
     ```
     Minimum required width: $\approx 383$ dp. On mobile screens $\le 390$ dp width (modal body 320–350 dp), this Row triggers `RenderFlex overflowed by 35-65 pixels on the right`.
   - `app/lib/presentation/widgets/auth_modal.dart:235-237`:
     `SizedBox(height: 290, child: TabBarView(...))`
     In Register tab, 3 text fields + button = 244 dp. When validation fails, 3 error messages add $\approx 60$ dp ($= 304$ dp $> 290$ dp), triggering `RenderFlex overflowed by 14 pixels on the bottom`.
   - `app/lib/presentation/screens/practice/ai_writing_screen.dart:309-348` and `376-401`:
     Unconstrained nested `Row` in evaluation result header (left icon + title $\approx 200$ dp, right badge $\approx 90$ dp, card padding 40 dp, screen padding 32 dp $= 362$ dp $> 320$ dp).
     Unconstrained `Row` with title + `Spacer()` + 2 `IconButton`s ($= 372$ dp $> 320$ dp).
   - `app/lib/presentation/screens/profile_screen.dart:183-237`:
     Unconstrained nested `Row` inside VIP status card; when `isPro` is active, subtitle `'Gói: LIFETIME • Vĩnh viễn'` + `'ĐÃ KÍCH HOẠT'` badge overflows on screens $< 390$ dp.
   - `app/lib/presentation/screens/practice/speed_quiz_screen.dart:128-158` & `flashcard_screen.dart:92-132`:
     Game Over and Completion views are `Center -> Padding -> Column` without `SingleChildScrollView`, overflowing vertically in landscape ($< 360$ dp height) or split-screen.
   - `app/lib/presentation/screens/practice/flashcard_screen.dart:318`:
     `VerticalDivider(width: 1)` in `Row` without `IntrinsicHeight`.
   - `app/lib/presentation/screens/dictionary_screen.dart:253-284`:
     Row with `verb.ipaV1` + Morph group badge + CEFR badge lacks `Flexible` on IPA text.
   - `app/lib/presentation/screens/verb_detail_screen.dart:356`:
     Button label `'Luyện Viết Câu Với Gia Sư AI DeepSeek'` in `ElevatedButton.icon` can overflow on 320 dp viewports.

---

## 2. Logic Chain

1. **Physical Device Readiness** (from Observation 1):
   - The device `99051FFBA004TL` is attached, authorized, running Android 13, and has `com.antigravity.verb360.app` currently installed.
   - Its logical width is 411.4 dp. Any component requiring $> 411.4$ dp will overflow directly on the Pixel 4 XL. Any component requiring $> 320$ dp or $> 360$ dp will overflow in multi-device testing (R2 requirement).

2. **Root Cause Analysis of Layout Overflows** (from Observation 3):
   - **PaywallModal**: `Row` does not wrap or shrink its children. Three `TextButton`s with horizontal padding require $> 380$ dp. On standard phones (360–390 dp), modal padding reduces available width to 320–350 dp, guaranteeing a `RenderFlex` overflow.
   - **AuthModal**: `TabBarView` requires an explicit height inside a scrollable column. The author hardcoded `height: 290`. When `FormState.validate()` fails, three error strings are added into the tree, requiring $\approx 304$ dp. This causes a vertical overflow of 14 dp.
   - **AiWritingScreen & ProfileScreen**: Authors used nested `Row`s with fixed texts, badges, and `Spacer()` without enclosing the text children in `Expanded` or `Flexible`. Whenever viewport width shrinks or text scales up, `Spacer` collapses to zero and the row overflows on the right.
   - **SpeedQuiz & Flashcards**: Authors assumed portrait height is always $> 600$ dp and omitted `SingleChildScrollView` around modal end states. In landscape or split-screen, viewport height is $\approx 300$ dp, causing bottom overflow.

3. **Navigation Sync Bug** (from Observation 3):
   - In Flutter, StatefulWidget state persists when the parent widget rebuilds with new parameters unless `didUpdateWidget` handles property changes. Since `_AdaptiveScaffoldState` only reads `widget.initialIndex` in `initState()`, external tab navigation calls (like `onNavigateToDictionary`) fail silently.

4. **Testing Deficiencies** (from Observation 2):
   - The project currently runs `flutter analyze` cleanly, and all 8 tests pass. However, `widget_test.dart` only tests text presence on a single default surface. It cannot catch the 15 identified layout defects. A responsive test matrix and device-based test workflow are required to satisfy R2.

---

## 3. Caveats

1. **Runtime Verification on Pixel 4 XL**: In this read-only survey role, code modifications to `app/lib` were prohibited. Physical rendering of the proposed fixes must be performed by the implementation agent.
2. **Swift Package Manager Warning on iOS**: `flutter analyze` reported: *"The following plugins do not support Swift Package Manager for ios: flutter_tts"*. This does not fail the current build but is noted for future iOS builds.
3. **PocketBase Backend Dependency**: Certain screens (`AiWritingScreen`, `AuthModal`, `ProfileScreen`) communicate with PocketBase at `http://127.0.0.1:8095`. For physical device testing, `127.0.0.1` refers to localhost on Android; reverse port forwarding (`adb reverse tcp:8095 tcp:8095`) is required when testing network calls on the device.

---

## 4. Conclusion

1. The Flutter UI architecture is modern, clean, and well-structured with Material 3, Riverpod, and `AdaptiveScaffold`. Static analysis is currently 100% clean.
2. **15 layout vulnerabilities** were pinpointed with exact file lines, failure scenarios, and fixes. The 2 critical bugs (`PaywallModal` footer Row overflow and `AuthModal` validation bottom overflow) will fail store review or cause user-visible red screen banners if not fixed.
3. The connected Google Pixel 4 XL (`99051FFBA004TL`) is fully operational and ready for deployment and screenshot capture.
4. A comprehensive, actionable layout test plan with a 5-dimension responsive matrix (320x568, 390x844, 412x869, 768x1024, 1024x768) and device verification procedure has been documented in:
   `/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_2/survey_ui_layout.md`.

---

## 5. Verification Method

To independently verify the observations:
1. **Device Verification**:
   ```bash
   adb -s 99051FFBA004TL shell wm size
   adb -s 99051FFBA004TL shell wm density
   flutter devices
   ```
2. **Static Analysis & Current Test Run**:
   ```bash
   cd /Volumes/DAT/GIT/360_verb/app
   flutter analyze
   flutter test
   ```
3. **Inspect Overflow Locations**:
   - `view_file` at `app/lib/presentation/widgets/paywall_modal.dart:262-280`
   - `view_file` at `app/lib/presentation/widgets/auth_modal.dart:235-237`
   - `view_file` at `app/lib/presentation/screens/practice/ai_writing_screen.dart:309-348`
   - `view_file` at `app/lib/presentation/screens/profile_screen.dart:183-237`
   - `view_file` at `app/lib/presentation/adaptive_scaffold.dart:20-26`
4. **Invalidation Conditions**:
   - If `PaywallModal:262` already wraps in `Wrap`, this finding is invalidated.
   - If `adb devices` does not list `99051FFBA004TL`, physical device verification is invalidated.
