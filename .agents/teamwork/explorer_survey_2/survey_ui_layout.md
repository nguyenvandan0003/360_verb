# Comprehensive UI Architecture, Screen Implementations, Layout Audit & Test Plan

**Project**: Verb360 AI (`vn.phuongdan.360verb` / `com.antigravity.verb360.app`)  
**Investigator**: `explorer_survey_2` (teamwork_explorer)  
**Date**: 2026-11-04  
**Connected Test Device**: Google Pixel 4 XL (`99051FFBA004TL`, Android 13 API 33)  
**Status**: Completed Read-Only Survey & Layout Audit

---

## 1. Executive Summary

A comprehensive investigation was conducted on the Flutter application codebase (`app/lib` and `app/test`), inspecting navigation routes, screen implementations, layout constraints, test infrastructure, and physical device connectivity on the Google Pixel 4 XL.

### Core Discoveries:
1. **Physical Device Ready**: The connected Google Pixel 4 XL (`99051FFBA004TL`) was verified via `adb` and `flutter devices`. Resolution: `1440 x 3040` px at `560` dpi (`411.4 x 868.5` dp logical size, scale factor 3.5x).
2. **Current Test Status**: `flutter analyze` runs clean with **0 errors and 0 warnings**. 8 existing unit/model/widget tests pass, but test coverage is limited to basic model serialization and a single smoke widget test. No responsive screen or multi-device layout tests exist.
3. **15 Layout & Overflow Vulnerabilities Identified**:
   - **2 Critical Overflows**:
     - `presentation/widgets/paywall_modal.dart:262-280`: Footer legal buttons (`Row`) unconditionally overflow on all mobile screens $\le 390$ dp width.
     - `presentation/widgets/auth_modal.dart:235-237`: Hardcoded `SizedBox(height: 290)` for `TabBarView` overflows when 3 validation error messages appear in Register tab.
   - **4 High-Probability Overflows**:
     - `presentation/screens/practice/ai_writing_screen.dart:309-348`: Unconstrained nested `Row` in evaluation result card header overflows on narrow devices / scaled text.
     - `presentation/screens/practice/ai_writing_screen.dart:376-401`: Suggestion title + `Spacer()` + 2 `IconButton`s overflows on $\le 360$ dp screens.
     - `presentation/screens/profile_screen.dart:183-237`: Unconstrained nested `Row` with VIP status and badge overflows horizontally when VIP is active.
     - `presentation/screens/practice/speed_quiz_screen.dart:128-158`: Game Over view `Column` lacks `SingleChildScrollView`, overflowing vertically in landscape or split-screen.
   - **1 Navigation State Sync Bug**:
     - `presentation/adaptive_scaffold.dart:20-26`: `_AdaptiveScaffoldState` misses `didUpdateWidget`, causing `onNavigateToDictionary` from `HomeScreen` to fail switching tabs.

---

## 2. Screen & Navigation Enumeration (R2 Scope)

| Screen / Component | File Path | Route / Entry Point | Layout Pattern | Responsive Pattern |
|---|---|---|---|---|
| **App Entrypoint & Shell** | `app/lib/main.dart` | `main()` -> `Verb360App` -> `MainNavigationShell` | `MaterialApp` with Material 3 | `AdaptiveScaffold` (breakpoint 768 dp) |
| **Adaptive Scaffold** | `app/lib/presentation/adaptive_scaffold.dart` | Embedded in `MainNavigationShell` | `LayoutBuilder` | Mobile: `NavigationBar`; Tablet/Desktop ($\ge 768$ dp): `NavigationRail` |
| **Home Screen** | `app/lib/presentation/screens/home_screen.dart` | Tab 0 (`Trang chủ`) | `Scaffold` + `ListView` | Cards with `Row` + `Expanded`, `Wrap` |
| **360 Dictionary Screen** | `app/lib/presentation/screens/dictionary_screen.dart` | Tab 1 (`Tra cứu 360`) | `Scaffold` + `Column` + `Expanded(ListView)` | Horizontal `SingleChildScrollView` for filters |
| **Verb Detail Screen** | `app/lib/presentation/screens/verb_detail_screen.dart` | `Navigator.push` from Dictionary card | `Scaffold` + `ListView` | 3-column `Row(Expanded)` for V1, V2, V3 |
| **DeepSeek AI Tutor** | `app/lib/presentation/screens/practice/ai_writing_screen.dart` | Tab 2 (`Gia sư AI`) & practice buttons | `Scaffold` + `SingleChildScrollView` | Form inputs, evaluation card |
| **SRS Flashcard Repetition** | `app/lib/presentation/screens/practice/flashcard_screen.dart` | Practice flow from SRS banner | `Scaffold` + `SafeArea` + `Column(Expanded)` | 3D Flip Card animation, 4 rating buttons |
| **Fill Blanks Practice** | `app/lib/presentation/screens/practice/fill_blanks_screen.dart` | Practice button on Home screen | `Scaffold` + `SingleChildScrollView` | Vertical form with V2/V3 text inputs |
| **Speed Quiz (60s Reflex)** | `app/lib/presentation/screens/practice/speed_quiz_screen.dart` | Practice button on Home screen | `Scaffold` + `Column` + `Expanded(GridView)` | 2x2 grid for multiple-choice buttons |
| **Profile Screen** | `app/lib/presentation/screens/profile_screen.dart` | Tab 3 (`Cá nhân`) | `Scaffold` + `ListView` | Status cards, badge wrap, server status |
| **Paywall & IAP Modal** | `app/lib/presentation/widgets/paywall_modal.dart` | `PaywallModal.show(context)` modal bottom sheet | `SingleChildScrollView` inside bottom sheet | Benefits card, 3 radio options, footer |
| **Authentication Modal** | `app/lib/presentation/widgets/auth_modal.dart` | `AuthModal.show(context)` modal bottom sheet | `SingleChildScrollView` + `TabBarView` | 2-tab switch (Login & Register) |

---

## 3. Comprehensive Layout & Overflow Vulnerability Audit

### Issue 1: State Synchronization Failure in AdaptiveScaffold
- **File**: `app/lib/presentation/adaptive_scaffold.dart:19-26`
- **Severity**: Medium (Navigation defect)
- **Observation**:
  ```dart
  class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
    late int _currentIndex;

    @override
    void initState() {
      super.initState();
      _currentIndex = widget.initialIndex;
    }
    // Missing didUpdateWidget!
  ```
- **Failure Scenario**: In `main.dart:45-47`, `HomeScreen` provides `onNavigateToDictionary: () => setState(() => _currentIndex = 1);`. Rebuilding `AdaptiveScaffold(initialIndex: 1)` does NOT update `_AdaptiveScaffoldState._currentIndex`. The user taps "Xem tất cả" or "Ôn tập" but remains on the Home screen.
- **Remediation**:
  ```dart
  @override
  void didUpdateWidget(covariant AdaptiveScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() => _currentIndex = widget.initialIndex);
    }
  }
  ```

---

### Issue 2: Paywall Footer Row Horizontal Overflow (CRITICAL)
- **File**: `app/lib/presentation/widgets/paywall_modal.dart:262-280`
- **Severity**: Critical (`RenderFlex` right overflow guaranteed on mobile)
- **Observation**:
  ```dart
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TextButton(
        onPressed: () => iapNotifier.restorePurchases(),
        child: const Text('Khôi phục gói mua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
      const Text('•', style: TextStyle(color: Colors.grey)),
      TextButton(
        onPressed: () {},
        child: const Text('Điều khoản (EULA)', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ),
      const Text('•', style: TextStyle(color: Colors.grey)),
      TextButton(
        onPressed: () {},
        child: const Text('Bảo mật', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    ],
  )
  ```
- **Failure Scenario**: Total width of 3 `TextButton`s (with default padding 16 dp per side) + 2 bullet points is $\approx 383$ dp. On mobile screens with width $\le 390$ dp (minus modal padding 40 dp $\rightarrow$ available width 320–350 dp), Flutter throws:
  `A RenderFlex overflowed by 35-65 pixels on the right.`
- **Remediation**: Replace `Row` with `Wrap`:
  ```dart
  Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 4,
    runSpacing: 2,
    children: [
      TextButton(
        style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8)),
        onPressed: () => iapNotifier.restorePurchases(),
        child: const Text('Khôi phục gói mua', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
      const Text('•', style: TextStyle(color: Colors.grey)),
      TextButton(
        style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8)),
        onPressed: () {},
        child: const Text('Điều khoản (EULA)', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ),
      const Text('•', style: TextStyle(color: Colors.grey)),
      TextButton(
        style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8)),
        onPressed: () {},
        child: const Text('Bảo mật', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ),
    ],
  )
  ```

---

### Issue 3: Fixed Height in AuthModal TabBarView (CRITICAL)
- **File**: `app/lib/presentation/widgets/auth_modal.dart:235-237`
- **Severity**: Critical (`RenderFlex` bottom overflow upon validation error)
- **Observation**:
  ```dart
  SizedBox(
    height: 290,
    child: TabBarView(
      controller: _tabController,
      children: [
        // Login Form (3 widgets)
        // Register Form (4 widgets: Name, Email, Password, Button)
      ],
    ),
  )
  ```
- **Failure Scenario**: In the Register Tab, 3 `TextFormField`s (52 dp each) + `SizedBox` spacers (40 dp) + `ElevatedButton` (48 dp) = 244 dp. When user taps "Tạo tài khoản" with empty inputs, Form validation fails and injects 3 error text lines ($\approx 20$ dp each $\rightarrow +60$ dp), totaling 304 dp. Because height is clamped to 290 dp:
  `A RenderFlex overflowed by 14 pixels on the bottom.`
  Also overflows under accessibility text scale $\ge 1.15\times$.
- **Remediation**: Increase height to at least 340 dp and wrap the inner Form columns in `SingleChildScrollView`:
  ```dart
  SizedBox(
    height: 350,
    child: TabBarView(
      controller: _tabController,
      children: [
        SingleChildScrollView(child: Form(key: _loginFormKey, ...)),
        SingleChildScrollView(child: Form(key: _registerFormKey, ...)),
      ],
    ),
  )
  ```

---

### Issue 4: AI Writing Screen Evaluation Card Header Row Overflow
- **File**: `app/lib/presentation/screens/practice/ai_writing_screen.dart:309-348`
- **Severity**: High (`RenderFlex` right overflow on narrow devices)
- **Observation**:
  ```dart
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Container(...),
          const SizedBox(width: 10),
          Text(isGood ? 'Đạt chuẩn ngữ pháp' : 'Cần điều chỉnh', ...),
        ],
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text('Điểm: ${eval.score}/10', ...),
      ),
    ],
  )
  ```
- **Failure Scenario**: Neither the outer Row nor inner Row contains `Expanded` or `Flexible`. Left icon + text ($\approx 200$ dp) + right score badge ($\approx 90$ dp) + card padding (40 dp) + screen padding (32 dp) = 362 dp. On screens $\le 360$ dp (e.g. iPhone SE, compact Androids) or high text scaling:
  `A RenderFlex overflowed by 8-25 pixels on the right.`
- **Remediation**: Wrap the left `Row` in `Expanded(child: Row(children: [..., Flexible(child: Text(..., overflow: TextOverflow.ellipsis))]))`.

---

### Issue 5: AI Writing Screen Improved Sentence Header Row Overflow
- **File**: `app/lib/presentation/screens/practice/ai_writing_screen.dart:376-401`
- **Severity**: High (`RenderFlex` right overflow on narrow devices)
- **Observation**:
  ```dart
  Row(
    children: [
      const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 18),
      const SizedBox(width: 6),
      const Text(
        'Câu gợi ý viết lại tự nhiên:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      const Spacer(),
      IconButton(icon: const Icon(Icons.volume_up_rounded, ...)),
      IconButton(icon: const Icon(Icons.copy_rounded, ...)),
    ],
  )
  ```
- **Failure Scenario**: Left side (204 dp) + `Spacer()` + 2 `IconButton`s (96 dp) = 300 dp. Inside card (padding 40 dp, screen padding 32 dp) = 372 dp. On 320–360 dp viewports, `Spacer` collapses to 0 and the Row overflows to the right.
- **Remediation**: Wrap `Text('Câu gợi ý viết lại tự nhiên:')` in `Expanded(child: Text(..., overflow: TextOverflow.ellipsis))`.

---

### Issue 6: Profile Screen VIP Card Row Overflow
- **File**: `app/lib/presentation/screens/profile_screen.dart:183-237`
- **Severity**: High (`RenderFlex` right overflow when user is VIP)
- **Observation**:
  ```dart
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Container(...),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(iapState.isPro ? 'Thành Viên VIP PRO' : 'Gói Miễn Phí (Free)', ...),
              Text(iapState.isPro ? 'Gói: ${iapState.planType.toUpperCase()} • ${iapState.planType == 'lifetime' ? 'Vĩnh viễn' : 'Đang hoạt động'}' : 'Giới hạn tính năng nâng cao', ...),
            ],
          ),
        ],
      ),
      if (iapState.isPro)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: const Text('ĐÃ KÍCH HOẠT', ...),
        ),
    ],
  )
  ```
- **Failure Scenario**: When `isPro == true`, the inner unconstrained `Row` contains a long subtitle string `'Gói: LIFETIME • Vĩnh viễn'`. Along with the trailing `'ĐÃ KÍCH HOẠT'` badge (80 dp), the row overflows on viewports $< 390$ dp.
- **Remediation**: Wrap the left inner `Row` in `Expanded(child: Row(children: [..., Expanded(child: Column(...))]))`.

---

### Issue 7: SpeedQuiz GameOver Screen Missing ScrollView
- **File**: `app/lib/presentation/screens/practice/speed_quiz_screen.dart:128-158`
- **Severity**: Medium (`RenderFlex` bottom overflow in landscape / split-screen)
- **Observation**:
  ```dart
  Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏁', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('Hết giờ!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ...
          ElevatedButton(...),
        ],
      ),
    ),
  )
  ```
- **Failure Scenario**: Fixed vertical height is 310 dp. In landscape orientation (height $\approx 360$ dp minus 56 dp AppBar = 304 dp), the Column overflows by 10–30 dp.
- **Remediation**: Wrap the `Column` in `SingleChildScrollView`.

---

### Issue 8: Flashcard Completion Screen Missing ScrollView
- **File**: `app/lib/presentation/screens/practice/flashcard_screen.dart:92-132`
- **Severity**: Medium (`RenderFlex` bottom overflow in landscape / split-screen)
- **Observation**: Same pattern as Issue 7. The completion Column has emoji (64px) + title + description + XP badge + action button without `SingleChildScrollView`.
- **Remediation**: Wrap `Column` in `SingleChildScrollView`.

---

### Issue 9: Flashcard Back Card VerticalDivider and Card Height Overflow
- **File**: `app/lib/presentation/screens/practice/flashcard_screen.dart:307-328`
- **Severity**: Medium (Layout warning / bottom overflow on small viewports)
- **Observation**:
  Line 318 has `VerticalDivider(width: 1)` in a `Row` without `IntrinsicHeight`. Additionally, the card body inside `Expanded` is a bare `Column` with meaning, V2/V3 comparison, and example sentences ($\approx 280$ dp height). On short screens or landscape, `Expanded` forces a height $< 280$ dp, causing a bottom overflow.
- **Remediation**: Wrap the V2/V3 row in `IntrinsicHeight` and wrap card content in `SingleChildScrollView`.

---

### Issue 10: Dictionary Screen Card IPA + Badge Row Overflow
- **File**: `app/lib/presentation/screens/dictionary_screen.dart:253-284`
- **Severity**: Low/Medium (Right overflow with long IPA or font scale $> 1.2\times$)
- **Observation**:
  ```dart
  Row(
    children: [
      Text(verb.ipaV1, ...),
      const SizedBox(width: 10),
      Container(child: Text('Nhóm ${verb.morphGroup}')),
      const SizedBox(width: 6),
      Container(child: Text(verb.cefrLevel)),
    ],
  )
  ```
- **Remediation**: Wrap `Text(verb.ipaV1)` in `Flexible(child: Text(..., overflow: TextOverflow.ellipsis))` or use `Wrap`.

---

### Issue 11: VerbDetailScreen Action Button Label Overflow
- **File**: `app/lib/presentation/screens/verb_detail_screen.dart:348-363`
- **Severity**: Medium (Right overflow on 320 dp screens)
- **Observation**:
  `ElevatedButton.icon(label: const Text('Luyện Viết Câu Với Gia Sư AI DeepSeek', style: TextStyle(fontSize: 15)))`.
  On 320 dp screen (available width 288 dp), icon + 36-char bold text exceeds 288 dp.
- **Remediation**: Wrap label in `Flexible(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis))` or use a shorter responsive label.

---

### Issue 12: VerbDetailScreen 3-Form Column Width Squeeze
- **File**: `app/lib/presentation/screens/verb_detail_screen.dart:69-76`
- **Severity**: Low (Text wrapping / clipping on narrow screens)
- **Observation**: 3 `Expanded` columns inside a card. On 320–360 dp width, each column has $\approx 75$ dp. Polysyllabic verbs (e.g. `misunderstand`, `telecast`) or 'V3: Phân từ II' can wrap awkwardly.
- **Remediation**: Apply `FittedBox(fit: BoxFit.scaleDown)` to the verb text and titles.

---

### Issue 13: HomeScreen SRS Due Banner Header Row
- **File**: `app/lib/presentation/screens/home_screen.dart:188-225`
- **Severity**: Low (Potential overflow on 320 dp screen with high font scale)
- **Observation**: Banner row contains `'SRS Spaced Repetition'` badge on the left and `'$count từ cần ôn'` on the right without `Flexible`.
- **Remediation**: Wrap the left container in `Flexible`.

---

### Issue 14: HomeScreen Rule Group Title Row
- **File**: `app/lib/presentation/screens/home_screen.dart:549-567`
- **Severity**: Low (Potential overflow on narrow screen)
- **Observation**: In `_buildRuleGroupTile`, `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title), Container(count)])` lacks `Expanded` on `title`.
- **Remediation**: Wrap `title` in `Expanded`.

---

### Issue 15: SpeedQuiz Options Grid Fixed Aspect Ratio in Expanded
- **File**: `app/lib/presentation/screens/practice/speed_quiz_screen.dart:210-234`
- **Severity**: Low/Medium (Squeezed buttons on short screens)
- **Observation**: `Expanded(child: GridView.count(childAspectRatio: 1.8))` inside Column.
- **Remediation**: Allow the parent container to be scrollable if height is constrained.

---

## 4. Test Infrastructure Assessment

### Existing Tests:
Location: `app/test`
1. `app/test/sm2_calculator_test.dart` (4 unit tests):
   - Perfect score (grade 5) increases repetitions to 1 and interval to 1.
   - Second review (grade 4) increases interval to 6.
   - Failure (grade 2) resets repetitions to 0.
   - Easiness factor boundary check ($\ge 1.3$).
2. `app/test/verb_model_test.dart` (3 unit tests):
   - `Verb.fromJson` and `toJson`.
   - `SrsProgress.isDue()`.
   - `GamificationState.initial()`.
3. `app/test/widget_test.dart` (1 smoke test):
   - Pumps `Verb360App` and finds text `'Verb360 AI'`, `'Trang chủ'`, `'Tra cứu 360'`, `'Gia sư AI'`.

### Test Execution Command:
```bash
cd /Volumes/DAT/GIT/360_verb/app
flutter analyze  # Output: No issues found! (ran in 6.3s)
flutter test     # Output: All 8 tests passed! (ran in 10s)
```

### Critical Gaps:
1. **Zero Multi-Form-Factor Layout Tests**: No tests test screen dimensions (320x568, 390x844, 412x869, 768x1024, 1024x768).
2. **Zero Practice Screen Widget Tests**: `FillBlanksScreen`, `SpeedQuizScreen`, `FlashcardScreen`, and `AiWritingScreen` have no automated tests.
3. **Zero Modal Widget Tests**: Neither `PaywallModal` nor `AuthModal` are tested for rendering or form validation overflows.
4. **Zero Accessibility Scaling Tests**: No tests run with `textScaler: TextScaler.linear(1.3)` or `1.5`.

---

## 5. Connected Device Specifications & Verification Setup

### Physical Device Verification:
- **Device Model**: Google Pixel 4 XL
- **Device ID / Serial**: `99051FFBA004TL`
- **Operating System**: Android 13 (API 33, `android-arm64`)
- **Physical Display Resolution**: `1440 x 3040` pixels
- **Display Density**: `560` dpi
- **Logical Resolution**:
  $$\text{Width} = \frac{1440}{560 / 160} = 411.4\text{ dp}$$
  $$\text{Height} = \frac{3040}{560 / 160} = 868.5\text{ dp}$$
  $$\text{Scale Factor} = 3.5\times$$
- **Connection Status**: Authorized (`device`), responsive to `adb` commands.
- **Installed App Package**: `com.antigravity.verb360.app` currently installed on device.

### Verification Tools & Commands:
1. Run application on Pixel 4 XL:
   ```bash
   flutter run -d 99051FFBA004TL
   ```
2. Real-time Logcat Overflow Monitor:
   ```bash
   adb -s 99051FFBA004TL logcat -c && adb -s 99051FFBA004TL logcat | grep -i -E "overflowed|RenderFlex|FlutterError"
   ```
3. Remote Device Screenshot Capture:
   ```bash
   adb -s 99051FFBA004TL exec-out screencap -p > /Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_2/pixel4xl_screenshot.png
   ```

---

## 6. Proposed Layout Test Plan

To satisfy acceptance criteria R2 (*"Zero RenderFlex overflow errors on the connected Google Pixel 4 XL device across all screens and user flows"* and *"Automated widget/layout tests pass across standard phone and tablet screen dimensions"*), the implementer should follow this test plan:

### Part A: Automated Responsive Layout Widget Test Suite
Create `app/test/layout_responsive_test.dart` testing each screen across the following dimension matrix:

| Device Category | Target Reference | Logical Width $\times$ Height | Text Scale Factors | Orientation |
|---|---|---|---|---|
| **Compact Mobile** | iPhone SE (1st gen) / Small Android | $320 \times 568$ dp | $1.0\times$, $1.3\times$ | Portrait |
| **Standard Phone** | iPhone 12/13/14 / Samsung Galaxy S21 | $390 \times 844$ dp | $1.0\times$, $1.3\times$ | Portrait |
| **Connected Device** | Google Pixel 4 XL | $412 \times 869$ dp | $1.0\times$, $1.2\times$, $1.5\times$ | Portrait |
| **Tablet Portrait** | iPad Mini / 8" Tablet | $768 \times 1024$ dp | $1.0\times$ | Portrait (Triggers NavigationRail) |
| **Tablet Landscape** | iPad Pro / Desktop Web | $1024 \times 768$ dp | $1.0\times$ | Landscape (Triggers NavigationRail) |

#### Automated Overflow Verification Helper:
```dart
Future<void> testScreenWithoutOverflow(
  WidgetTester tester, {
  required Widget screen,
  required Size surfaceSize,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = surfaceSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: surfaceSize,
            textScaler: TextScaler.linear(textScale),
          ),
          child: screen,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Assert no exceptions thrown during layout and rendering
  expect(tester.takeException(), isNull);
}
```

### Part B: Screens to Test in the Suite
1. `HomeScreen`:
   - Test at 320x568, 390x844, 412x869, 768x1024.
   - Verify zero overflow in due banner, practice cards, and rule group tiles.
2. `DictionaryScreen`:
   - Test with search queries, filter chip horizontal scroll, and long IPA strings.
3. `VerbDetailScreen`:
   - Test with polysyllabic verb (`misunderstand`, `telecast`).
4. `AiWritingScreen`:
   - Test both unauthenticated gate screen and authenticated evaluation state.
   - Verify evaluation card header and improved sentence header at 320x568 and 360x640 with textScaler 1.3x.
5. `FillBlanksScreen`:
   - Test with simulated soft keyboard (`viewInsets.bottom = 300`).
   - Verify `SingleChildScrollView` prevents keyboard overflow.
6. `SpeedQuizScreen`:
   - Test active game screen and Game Over screen in landscape (568x320).
7. `FlashcardScreen`:
   - Test front card, back card with long sentences, and completion screen.
8. `PaywallModal`:
   - Test bottom sheet popup at 320x568, 360x640, 390x844.
   - Verify footer legal text buttons do not overflow.
9. `AuthModal`:
   - Test TabBarView switch between Login and Register.
   - Trigger form validation error state (empty fields submit) $\rightarrow$ verify 0 overflow.

### Part C: Physical Device Inspection on Pixel 4 XL
1. Build and install updated app (`vn.phuongdan.360verb`):
   ```bash
   flutter run -d 99051FFBA004TL
   ```
2. Navigate through all 4 navigation shell tabs:
   - Tap `Trang chủ` $\rightarrow$ scroll to bottom $\rightarrow$ verify cards.
   - Tap `Tra cứu 360` $\rightarrow$ filter by 'Nhóm ABC' $\rightarrow$ select verb detail.
   - Tap `Gia sư AI` $\rightarrow$ test login modal and submit sample sentence.
   - Tap `Cá nhân` $\rightarrow$ open Paywall modal $\rightarrow$ inspect footer buttons.
3. Run practice modes:
   - Launch `Điền khuyết`, `Phản xạ nhanh`, `Thẻ nhớ Flashcard SRS`.
4. Rotate device to landscape (`adb shell settings put system user_rotation 1`) and verify screens adapt without overflow.
5. Monitor logcat for `RenderFlex` or `overflowed`.

---

## 7. Next Steps for Implementer

1. **Fix Layout Bugs**:
   - Apply `Wrap` to `PaywallModal` footer (Issue 2).
   - Increase `TabBarView` height and add scrolling to `AuthModal` (Issue 3).
   - Wrap Row contents with `Expanded`/`Flexible` in `AiWritingScreen` (Issues 4 & 5).
   - Wrap Row contents in `ProfileScreen` VIP card (Issue 6).
   - Add `SingleChildScrollView` to Game Over & Completion screens (Issues 7 & 8).
   - Add `didUpdateWidget` to `AdaptiveScaffold` (Issue 1).
2. **Implement Layout Tests**:
   - Add `app/test/layout_responsive_test.dart` implementing the automated multi-device matrix.
3. **Run Verification on Pixel 4 XL**:
   - Deploy to device `99051FFBA004TL`, run automated and manual inspection, capture screenshots.
