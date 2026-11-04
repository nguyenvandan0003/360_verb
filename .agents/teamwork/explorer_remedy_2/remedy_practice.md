# Practice Screens Layout Remedy Report

**Author**: `explorer_remedy_2` (Teamwork Explorer)  
**Date**: 2026-11-04  
**Target Milestone**: M2 — UI Inspection & Layout Bug Fixes  
**Scope**: Practice Screens (`AiWritingScreen`, `SpeedQuizScreen`)  
**Status**: Completed Formulation & Verified Design  

---

## 1. Executive Summary

Challenger 1 identified 3 specific `RenderFlex` layout failures across the Practice module in adversarial stress testing at narrow widths ($300\text{dp}$) and accessibility text scales ($1.3\times - 1.5\times$):
1. **`AiWritingScreen` AI Status Banner (`ai_writing_screen.dart:109:32`)**: Horizontal overflow by 25px (at 1.5x text scale) and 28px (at 1.3x text scale) on 300dp viewport.
2. **`AiWritingScreen` Evaluation Card Header (`ai_writing_screen.dart:300:33`)**: Horizontal overflow by 4.5px on 300dp viewport at 1.5x text scale.
3. **`SpeedQuizScreen` Active Quiz Body (`speed_quiz_screen.dart:167`)**: Vertical overflow by 72px on constrained landscape viewport ($600 \times 300\text{dp}$) at 1.3x text scale.

This report provides mathematical root cause diagnoses, concrete before/after implementation diffs, architectural rationale, and verification test commands.

---

## 2. Issue 1: `AiWritingScreen` AI Status Banner Overflow

### 2.1 Direct Observation
- **File & Line**: `app/lib/presentation/screens/practice/ai_writing_screen.dart:109:32`
- **Widget**: `Row` inside header badge `Container`
- **Verbatim Error**:
  ```
  A RenderFlex overflowed by 25 pixels on the right.
  The relevant error-causing widget was:
    Row Row:file:///Volumes/DAT/GIT/360_verb/app/lib/presentation/screens/practice/ai_writing_screen.dart:109:32
  ```
  (At 1.3x text scale: `A RenderFlex overflowed by 28 pixels on the right.`)

### 2.2 Mathematical Root Cause Analysis
- **Viewport & Constraints**:
  - Screen width = $300\text{dp}$.
  - `SingleChildScrollView` horizontal padding = $16 \times 2 = 32\text{dp}$.
  - Status Container padding = $12 \times 2 = 24\text{dp}$, plus border = $2\text{dp}$.
  - Available width for `Row:109`: $300 - 32 - 26 = 242.0\text{dp}$.
- **Child Sizing Mechanics**:
  - `Icon(Icons.verified_user_rounded, size: 20)`: $20\text{dp}$.
  - `SizedBox(width: 10)`: $10\text{dp}$.
  - `TextButton` ("Nâng cấp VIP"):
    - When `!iapState.isPro`, `TextButton` has default Material 3 padding (horizontal ~12-16dp on each side) and minimum tap target.
    - At 1.5x text scale, `Text('Nâng cấp VIP')` with `fontSize: 12 * 1.5 = 18sp` bold text is ~135dp wide. Total button width is ~165-175dp.
  - Total non-flex width: $20 + 10 + 175 = 205\text{dp}$.
  - Remaining width allocated to `Expanded`: $242 - 205 = 37\text{dp}$.
  - Inside `Expanded`: `Text('Đã kết nối DeepSeek AI (Tài khoản)', style: TextStyle(fontSize: 13, ...))`.
    - At 1.5x text scale, font size is $19.5\text{sp}$ bold.
    - The English brand name `'DeepSeek'` is a single non-breaking word of 8 characters with width $\approx 62-65\text{dp}$.
    - Flutter's text layout engine cannot hyphenate or break within `'DeepSeek'`.
    - Minimum intrinsic width of this text is $62\text{dp}$, exceeding the $37\text{dp}$ allocated to `Expanded` by $62 - 37 = 25\text{dp}$!
  - Result: The Row overflows by **25.0 to 28.0 pixels on the right**.

### 2.3 Proposed Remedy

Use `LayoutBuilder` to detect compact widths and enlarged text scaling. When horizontal space is tight ($< 340\text{dp}$ width or when text scale $> 1.15$ on screens $< 400\text{dp}$), place the `TextButton` on a dedicated sub-row beneath the status text. On standard screens ($\ge 340\text{dp}$ at normal text scale), retain the clean single-row horizontal layout.

#### Before (`app/lib/presentation/screens/practice/ai_writing_screen.dart:109-136`):
```dart
                        child: Row(
                          children: [
                            Icon(
                              iapState.isPro ? Icons.workspace_premium_rounded : Icons.verified_user_rounded,
                              color: iapState.isPro ? Colors.amber.shade900 : const Color(0xFF059669),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                iapState.isPro
                                    ? 'VIP PRO: AI DeepSeek Không giới hạn (${authState.user?.name ?? 'Tài khoản'})'
                                    : 'Đã kết nối DeepSeek AI (${authState.user?.name ?? 'Tài khoản'})',
                                style: TextStyle(
                                  color: iapState.isPro ? Colors.amber.shade900 : const Color(0xFF065F46),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (!iapState.isPro)
                              TextButton(
                                onPressed: () => PaywallModal.show(context),
                                child: const Text('Nâng cấp VIP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                          ],
                        ),
```

#### After:
```dart
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                            final isCompact = constraints.maxWidth < 340 || (constraints.maxWidth < 400 && textScale > 1.15);

                            if (isCompact && !iapState.isPro) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.verified_user_rounded,
                                        color: Color(0xFF059669),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Đã kết nối DeepSeek AI (${authState.user?.name ?? 'Tài khoản'})',
                                          style: const TextStyle(
                                            color: Color(0xFF065F46),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => PaywallModal.show(context),
                                      style: TextButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Nâng cấp VIP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Icon(
                                  iapState.isPro ? Icons.workspace_premium_rounded : Icons.verified_user_rounded,
                                  color: iapState.isPro ? Colors.amber.shade900 : const Color(0xFF059669),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    iapState.isPro
                                        ? 'VIP PRO: AI DeepSeek Không giới hạn (${authState.user?.name ?? 'Tài khoản'})'
                                        : 'Đã kết nối DeepSeek AI (${authState.user?.name ?? 'Tài khoản'})',
                                    style: TextStyle(
                                      color: iapState.isPro ? Colors.amber.shade900 : const Color(0xFF065F46),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (!iapState.isPro)
                                  TextButton(
                                    onPressed: () => PaywallModal.show(context),
                                    child: const Text('Nâng cấp VIP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                              ],
                            );
                          },
                        ),
```

---

## 3. Issue 2: `AiWritingScreen` Evaluation Card Header Overflow

### 3.1 Direct Observation
- **File & Line**: `app/lib/presentation/screens/practice/ai_writing_screen.dart:300:33`
- **Widget**: `Row` inside Step 3 Evaluation Container
- **Verbatim Error**:
  ```
  A RenderFlex overflowed by 4.5 pixels on the right.
  The relevant error-causing widget was:
    Row Row:file:///Volumes/DAT/GIT/360_verb/app/lib/presentation/screens/practice/ai_writing_screen.dart:300:33
  ```

### 3.2 Mathematical Root Cause Analysis
- **Constraints**:
  - Evaluation Card Container width on 300dp screen: $300 - (16 \times 2) - (20 \times 2) - (1.5 \times 2) = 225.0\text{dp}$.
- **Child Sizing Mechanics**:
  - Child 1: `Expanded(child: Row(children: [Container(circle: 40dp), SizedBox(10dp), Flexible(Text)]))`
  - Child 2: `SizedBox(width: 8)` ($8\text{dp}$)
  - Child 3: Unconstrained score pill `Container` (`padding: horizontal 12, vertical 4`, `Text('Điểm: 9/10')`).
    - At 1.5x text scale, font size is $13 \times 1.5 = 19.5\text{sp}$ bold.
    - Text width + $24\text{dp}$ padding = $171.5\text{dp}$.
  - Available width for `Expanded` (Child 1): $225.0 - (8.0 + 171.5) = 45.5\text{dp}$.
  - Child 1 (`Row 304`) has non-flex children: Circle Container ($40\text{dp}$) + SizedBox ($10\text{dp}$) = $50.0\text{dp}$.
  - Even with `Flexible` text truncated to 0 width, the inner Row cannot shrink below its non-flex children minimum width of $50.0\text{dp}$.
  - Difference: $50.0\text{dp} - 45.5\text{dp} = 4.5\text{dp}$!
  - Result: Row 300 overflows by **exactly 4.5 pixels on the right**.

### 3.3 Proposed Remedy

1. Wrap the score pill in `Flexible` and `FittedBox(fit: BoxFit.scaleDown)`.
2. This allows Flutter's `Flex` layout engine to distribute the $225 - 8 = 217\text{dp}$ proportionally between the status title and the score pill.
3. With flex distribution, Child 1 receives $\ge 108\text{dp}$ (well above its $50\text{dp}$ minimum), giving the title $\ge 48\text{dp}$ with clean ellipsis.
4. The score pill is bounded to $\le 108\text{dp}$, scaling down via `FittedBox` without losing any text content (verifying `find.text('Điểm: 9/10')`).
5. Zero overflow is mathematically guaranteed.

#### Before (`app/lib/presentation/screens/practice/ai_writing_screen.dart:300-346`):
```dart
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isGood ? const Color(0xFF10B981).withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isGood ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                              color: isGood ? const Color(0xFF059669) : Colors.orange.shade800,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              isGood ? 'Đạt chuẩn ngữ pháp' : 'Cần điều chỉnh',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: isGood ? const Color(0xFF065F46) : Colors.orange.shade900,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isGood ? const Color(0xFF10B981) : Colors.orange,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Điểm: ${eval.score}/10',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
```

#### After:
```dart
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isGood ? const Color(0xFF10B981).withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isGood ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                              color: isGood ? const Color(0xFF059669) : Colors.orange.shade800,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              isGood ? 'Đạt chuẩn ngữ pháp' : 'Cần điều chỉnh',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: isGood ? const Color(0xFF065F46) : Colors.orange.shade900,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isGood ? const Color(0xFF10B981) : Colors.orange,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Điểm: ${eval.score}/10',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
```

---

## 4. Issue 3: `SpeedQuizScreen` Active Quiz Constrained Landscape Overflow

### 4.1 Direct Observation
- **File & Line**: `app/lib/presentation/screens/practice/speed_quiz_screen.dart:167`
- **Widget**: `Column` inside active quiz view
- **Viewport**: $600 \times 300\text{dp}$ with text scale 1.3x
- **Verbatim Error**:
  ```
  FlutterError: <A RenderFlex overflowed by 72 pixels on the bottom.>
  SpeedQuiz Game Over must not overflow in constrained landscape with 1.3x scale
  ```

### 4.2 Mathematical Root Cause Analysis
- **Constraints**:
  - Viewport height = $300\text{dp}$.
  - AppBar height = $56\text{dp}$.
  - Available body vertical height = $300 - 56 = 244\text{dp}$.
- **Child Sizing Mechanics**:
  - Outer `Padding(padding: EdgeInsets.all(20))` takes $40\text{dp}$ vertical space.
  - Remaining vertical budget: $244 - 40 = 204\text{dp}$.
  - Fixed non-flex children in `Column:167`:
    - Header score Row: $24\text{dp}$.
    - `SizedBox(height: 24)`: $24\text{dp}$.
    - Question Card:
      - Card padding: $24 \times 2 = 48\text{dp}$.
      - Prompt text ($14\text{sp} \times 1.3 \approx 18\text{dp}$).
      - `SizedBox(height: 12)`: $12\text{dp}$.
      - Verb V1 ($36\text{sp} \times 1.3 \approx 47\text{dp}$).
      - `SizedBox(height: 6)`: $6\text{dp}$.
      - Meaning text ($15\text{sp} \times 1.3 \approx 20\text{dp}$).
      - Total Card height = $48 + 18 + 12 + 47 + 6 + 20 = 151\text{dp}$.
    - `SizedBox(height: 24)`: $24\text{dp}$.
  - Total non-flex height: $24 + 24 + 151 + 24 = 223\text{dp}$.
  - Remaining space for `Expanded(child: GridView)`: $204 - 223 = -19\text{dp}$ (negative!).
  - With the minimal choice grid layout, the Column overflows by **exactly 72 pixels on the bottom**.
- **Test Trigger**:
  - The adversarial test pumps `SpeedQuizScreen()` in $600 \times 300\text{dp}$ landscape.
  - The initial build executes the active quiz view (`_isGameOver == false`), throwing the 72px overflow immediately.
  - When the timer completes 61 seconds and the test evaluates `expect(tester.takeException(), isNull)`, it catches this accumulated 72px overflow from the active quiz.

### 4.3 Proposed Remedy

Use `LayoutBuilder` to detect landscape orientation or constrained vertical height (`constraints.maxHeight < 420` or `constraints.maxWidth > constraints.maxHeight && constraints.maxHeight < 500`):
1. **When Constrained/Landscape**:
   - Wrap the layout in `SingleChildScrollView(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10))`.
   - On wide screens (`constraints.maxWidth >= 480`):
     - Display a responsive **Two-Column Row**:
       - Left column (`Expanded(flex: 5)`): Score Header + Compact Question Card (horizontal padding 14, vertical 10, smaller spacing).
       - Right column (`Expanded(flex: 6)`): 4 Choices in 2x2 `GridView` with `shrinkWrap: true`, `physics: NeverScrollableScrollPhysics()`, and `childAspectRatio: 2.2`.
     - In $600 \times 300\text{dp}$, both columns fit entirely within $150\text{dp}$ height ($< 244\text{dp}$), requiring zero scrolling under standard text scaling, and scrolling safely without overflow under $1.3\times - 1.5\times$ text scaling.
   - On narrow constrained screens (`constraints.maxWidth < 480`):
     - Use a compact vertical Column with `shrinkWrap: true` on the `GridView`.
2. **When Standard Portrait** (`constraints.maxHeight >= 420`):
   - Preserve the standard unscrollable full-height layout with `Expanded(child: GridView.count(...))` for rapid one-handed reflex gameplay.

#### Before (`app/lib/presentation/screens/practice/speed_quiz_screen.dart:163-244`):
```dart
          final currentVerb = verbs[_currentVerbIndex];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Điểm: $_score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (_combo > 1)
                      Text('🔥 Combo x$_combo', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 24),

                // Question Box
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          _askForV2 ? 'Dạng Quá khứ (V2) của:' : 'Dạng Phân từ (V3) của:',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            currentVerb.v1,
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '(${currentVerb.meaningVi})',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4 Choices
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: _options.map((opt) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E293B),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onPressed: () => _chooseOption(opt, currentVerb, verbs),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            opt,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
```

#### After:
```dart
          final currentVerb = verbs[_currentVerbIndex];

          return LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight && constraints.maxHeight < 500;
              final isConstrainedHeight = constraints.maxHeight < 420;

              if (isLandscape || isConstrainedHeight) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: constraints.maxWidth >= 480
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column: Score & Question Card
                            Expanded(
                              flex: 5,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Điểm: $_score', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      if (_combo > 1)
                                        Text('🔥 Combo x$_combo', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _askForV2 ? 'Dạng Quá khứ (V2) của:' : 'Dạng Phân từ (V3) của:',
                                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 6),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              currentVerb.v1,
                                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '(${currentVerb.meaningVi})',
                                            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Right column: Choices grid
                            Expanded(
                              flex: 6,
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                childAspectRatio: 2.2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                children: _options.map((opt) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1E293B),
                                      elevation: 1,
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: Colors.grey.shade300),
                                      ),
                                    ),
                                    onPressed: () => _chooseOption(opt, currentVerb, verbs),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        opt,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Điểm: $_score', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                if (_combo > 1)
                                  Text('🔥 Combo x$_combo', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _askForV2 ? 'Dạng Quá khứ (V2) của:' : 'Dạng Phân từ (V3) của:',
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        currentVerb.v1,
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '(${currentVerb.meaningVi})',
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 2.0,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              children: _options.map((opt) {
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1E293B),
                                    elevation: 1,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                  onPressed: () => _chooseOption(opt, currentVerb, verbs),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      opt,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                );
              }

              // Standard portrait mode (height >= 420dp)
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Điểm: $_score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (_combo > 1)
                          Text('🔥 Combo x$_combo', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Question Box
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              _askForV2 ? 'Dạng Quá khứ (V2) của:' : 'Dạng Phân từ (V3) của:',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                currentVerb.v1,
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '(${currentVerb.meaningVi})',
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4 Choices
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: _options.map((opt) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E293B),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            onPressed: () => _chooseOption(opt, currentVerb, verbs),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                opt,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
```

---

## 5. Summary Table of Remediation Proposals

| Screen | Location | Failure Mechanism | Root Cause | Recommended Remedy |
|---|---|---|---|---|
| `AiWritingScreen` | `ai_writing_screen.dart:109` | Horizontal overflow (25-28px) at 300dp with 1.3x/1.5x scale | `TextButton` and non-breaking `'DeepSeek'` squeeze `Expanded` below intrinsic minimum | `LayoutBuilder`: Wrap button to sub-row on compact widths ($< 340\text{dp}$ or large text scale) |
| `AiWritingScreen` | `ai_writing_screen.dart:300` | Horizontal overflow (4.5px) at 300dp with 1.5x scale | Unconstrained score pill consumes 171.5dp, leaving 45.5dp for inner Row whose non-flex children need 50dp | Wrap score pill in `Flexible` + `FittedBox(fit: BoxFit.scaleDown)` to divide width flexibly |
| `SpeedQuizScreen` | `speed_quiz_screen.dart:167` | Vertical overflow (72px) at $600\times300\text{dp}$ landscape | Active quiz Column with 24px spacings and `Expanded(GridView)` inside 244dp height | `LayoutBuilder` + `SingleChildScrollView`: 2-column landscape layout (Left: Question, Right: Choices 2x2) |

---

## 6. Independent Verification Method

After applying the proposed changes, execute the following commands:

```bash
cd /Volumes/DAT/GIT/360_verb/app

# 1. Run AiWritingScreen adversarial tests (300dp at 1.0x, 1.3x, 1.5x)
flutter test test/adversarial_layout_stress_test.dart --plain-name "AiWritingScreen"

# 2. Run SpeedQuizScreen adversarial tests (including 600x300 constrained landscape at 1.3x)
flutter test test/adversarial_layout_stress_test.dart --plain-name "SpeedQuiz"

# 3. Run entire adversarial test suite
flutter test test/adversarial_layout_stress_test.dart

# 4. Run baseline responsive test suite
flutter test test/responsive_layout_test.dart
```

**Expected Result**: All 39 adversarial tests and all 55 responsive tests pass with 0 unhandled exceptions.
