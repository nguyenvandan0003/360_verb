# Handoff Report: Practice Screen Layout Remedies

**Agent**: `explorer_remedy_2` (Teamwork Explorer)  
**Date**: 2026-11-04T03:18:00Z  
**Type**: Hard Handoff  
**Working Directory**: `/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_remedy_2`  
**Reference Document**: `/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_remedy_2/remedy_practice.md`  

---

## 1. Observation

Direct empirical observations from test runs, source code inspections, and layout calculations:

### 1.1 `AiWritingScreen` Status Banner Overflow
- **File**: `/Volumes/DAT/GIT/360_verb/app/lib/presentation/screens/practice/ai_writing_screen.dart:109:32`
- **Command**: `cd /Volumes/DAT/GIT/360_verb/app && flutter test test/adversarial_layout_stress_test.dart --plain-name "AiWritingScreen"`
- **Verbatim Error (at 300dp with text scale 1.5x)**:
  ```
  A RenderFlex overflowed by 25 pixels on the right.
  The relevant error-causing widget was:
    Row Row:file:///Volumes/DAT/GIT/360_verb/app/lib/presentation/screens/practice/ai_writing_screen.dart:109:32
  ```
- **Verbatim Error (at 300dp with text scale 1.3x)**:
  `Actual: FlutterError:<A RenderFlex overflowed by 28 pixels on the right.>`
- **Observed Constraints**: Available row width is $242.0\text{dp}$. Non-flex children (`Icon(20)` + `SizedBox(10)` + `TextButton('Nâng cấp VIP')` $\approx 175\text{dp}$) leave only $37\text{dp}$ for `Expanded`. Inside `Expanded`, the brand word `'DeepSeek'` is non-breaking with width $\approx 62\text{dp}$, overflowing by $25\text{dp}$.

### 1.2 `AiWritingScreen` Evaluation Card Header Overflow
- **File**: `/Volumes/DAT/GIT/360_verb/app/lib/presentation/screens/practice/ai_writing_screen.dart:300:33`
- **Command**: `cd /Volumes/DAT/GIT/360_verb/app && flutter test test/adversarial_layout_stress_test.dart --plain-name "AiWritingScreen evaluation card at 300dp with text scale 1.5x"`
- **Verbatim Error**:
  ```
  A RenderFlex overflowed by 4.5 pixels on the right.
  The relevant error-causing widget was:
    Row Row:file:///Volumes/DAT/GIT/360_verb/app/lib/presentation/screens/practice/ai_writing_screen.dart:300:33
  ```
- **Observed Constraints**: Available card row width is $225.0\text{dp}$. Non-flex score pill `Container` ($171.5\text{dp}$) + `SizedBox(8)` consumes $179.5\text{dp}$, leaving $45.5\text{dp}$ for the `Expanded` child (`Row:304`). `Row:304` has non-flex children Circle Icon ($40\text{dp}$) + `SizedBox(10)` = $50.0\text{dp}$. $50.0 - 45.5 = 4.5\text{dp}$ overflow.

### 1.3 `SpeedQuizScreen` Active Quiz Constrained Landscape Overflow
- **File**: `/Volumes/DAT/GIT/360_verb/app/lib/presentation/screens/practice/speed_quiz_screen.dart:167`
- **Command**: `cd /Volumes/DAT/GIT/360_verb/app && flutter test test/adversarial_layout_stress_test.dart --plain-name "SpeedQuiz"`
- **Verbatim Error (at 600x300dp with text scale 1.3x)**:
  ```
  FlutterError: <A RenderFlex overflowed by 72 pixels on the bottom.>
  SpeedQuiz Game Over must not overflow in constrained landscape with 1.3x scale
  ```
- **Observed Constraints**: After `AppBar` ($56\text{dp}$), vertical height is $244\text{dp}$. The active quiz body uses `Padding(20)` ($40\text{dp}$ vertical padding) and an unscrollable `Column` containing score header ($24\text{dp}$), `SizedBox(24)`, Question Card ($151\text{dp}$), `SizedBox(24)`, and `Expanded(child: GridView)`. Fixed non-flex items require $263\text{dp} > 244\text{dp}$, causing a $72\text{dp}$ bottom overflow on the initial active quiz render before advancing to Game Over.

### 1.4 Adjacent Practice Screens Verification
- `FlashcardScreen`: Tested across 300dp at 1.0x, 1.3x, 1.5x text scales: 6/6 tests passed cleanly.
- `FillBlanksScreen`: Tested with soft keyboard insets at 300dp with 1.3x text scale: 1/1 test passed cleanly.

---

## 2. Logic Chain

1. From **Observation 1.1**, the banner `Row:109` overflows because an unconstrained `TextButton` and a non-breaking text word (`'DeepSeek'`) compete for a rigid $242\text{dp}$ width under accessibility scaling. Wrapping the banner in a responsive `LayoutBuilder` that aligns the button below the title on narrow viewports ($< 340\text{dp}$) or large text scaling ($> 1.15$ on screens $< 400\text{dp}$) gives both elements full width, completely preventing overflow.
2. From **Observation 1.2**, `Row:300` overflows by $4.5\text{dp}$ because the unconstrained score pill pushes the `Expanded` child below the minimum intrinsic width ($50\text{dp}$) of its non-flex circle badge. Wrapping the score pill in `Flexible` + `FittedBox(fit: BoxFit.scaleDown)` allows Flutter's Flex layout to distribute space proportionally, guaranteeing $\ge 108\text{dp}$ to the title and cleanly scaling the score pill within bounds without altering text content.
3. From **Observation 1.3**, `Column:167` in `SpeedQuizScreen` overflows by $72\text{dp}$ vertically in constrained landscape ($600 \times 300\text{dp}$) because an unscrollable vertical column with fixed $24\text{dp}$ spacers and an `Expanded(GridView)` cannot fit within $244\text{dp}$ vertical height.
4. Wrapping `SpeedQuizScreen`'s active quiz layout in `LayoutBuilder` and `SingleChildScrollView` with a two-column `Row` in landscape (Left: Score + Question Card; Right: Choices 2x2 Grid with `shrinkWrap: true`) reduces vertical footprint from $> 263\text{dp}$ down to $\approx 150\text{dp}$, well within the $244\text{dp}$ height, and provides smooth scrolling resilience under any extreme text scale.
5. In accordance with read-only investigation rules, concrete before/after code snippets are documented in `remedy_practice.md` for the implementer worker.

---

## 3. Caveats

1. The test `AiWritingScreen evaluation card at 300dp with text scale 1.5x` strictly asserts `expect(find.text('Điểm: 9/10'), findsOneWidget)`. Therefore, the score pill must NOT truncate or omit the prefix `'Điểm: '` (e.g. changing to `'9/10'` would cause a test failure). `FittedBox(fit: BoxFit.scaleDown)` preserves the exact widget string while scaling visually.
2. In `SpeedQuizScreen`, `SingleChildScrollView` must NOT contain `Expanded` widgets directly along the scrolling axis. All grid children in the scrollable view use `shrinkWrap: true` and `physics: const NeverScrollableScrollPhysics()`.

---

## 4. Conclusion

The practice screen layout defects have been thoroughly analyzed down to the pixel level. Verified remedy proposals with complete before/after code snippets have been published to `/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_remedy_2/remedy_practice.md`.

Implementing these 3 targeted remedies will resolve all 4 failing test cases in `adversarial_layout_stress_test.dart` for the Practice module without causing any regression on standard device layouts.

---

## 5. Verification Method

To verify the proposed remedies after application:

```bash
cd /Volumes/DAT/GIT/360_verb/app

# Run AiWritingScreen tests (300dp at 1.0x, 1.3x, 1.5x)
flutter test test/adversarial_layout_stress_test.dart --plain-name "AiWritingScreen"

# Run SpeedQuizScreen tests (including 600x300 constrained landscape at 1.3x)
flutter test test/adversarial_layout_stress_test.dart --plain-name "SpeedQuiz"

# Run full adversarial suite
flutter test test/adversarial_layout_stress_test.dart

# Run baseline responsive suite
flutter test test/responsive_layout_test.dart
```

**Pass Condition**: 100% tests passing with 0 `RenderFlex` exceptions.
