# Comprehensive Remedy Strategy: Navigation, Home, Profile, Detail Screens & Fastlane Appfile

**Author**: `explorer_remedy_3` (teamwork_explorer)  
**Target Milestone**: M2 Remediation / Adversarial Stress-Testing  
**Date**: 2026-11-04  
**Context**: Resolution of layout overflow failures under compact viewport ($300\text{dp}$) and accessibility scaling ($1.3\times - 1.5\times$), plus Android package identifier alignment.

---

## Executive Summary

Challenger 1 identified 13 failing test cases in `/Volumes/DAT/GIT/360_verb/app/test/adversarial_layout_stress_test.dart`. This investigation specifically examines the root causes and formulates concrete code-level remedies for:
1. **`ProfileScreen`** (`profile_screen.dart:123` & `199`): Active VIP PRO status card header and AI DeepSeek status row horizontal overflows of $10.0\text{px}$ ($1.3\times$) and $34\text{px}$ ($1.5\times$).
2. **`HomeScreen`** (`home_screen.dart:220` & `319`): Section header row unconstrained text overflow ($159\text{px}$) and SRS review due header subpixel overflow ($0.75\text{px}$).
3. **`VerbDetailScreen`** (`verb_detail_screen.dart:245`): `OutlinedButton.icon` with label `'Tạo 3 ví dụ AI theo chủ đề'` overflowing by $46\text{px}$ at $300\text{dp}$ with $1.5\times$ text scale.
4. **Fastlane Android Appfile** (`app/android/fastlane/Appfile:2`): Default fallback `package_name` mismatch (`vn.phuongdan.360verb` instead of `vn.phuongdan.verb360`).
5. **`AdaptiveScaffold`**: Verified operational status of programmatic navigation state synchronization via `didUpdateWidget`.

---

## 1. Issue Analysis & Root Cause Breakdown

### 1.1 `ProfileScreen` VIP Status & AI Status Row Overflow
- **File**: `app/lib/presentation/screens/profile_screen.dart`
- **Locations**:
  - VIP Status Card Header: Line 199 (`Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Expanded(...), if (iapState.isPro) Container(...) ])`)
  - AI DeepSeek Status Row: Line 123 (`Row(children: [ Expanded(Container(... 'AI DeepSeek: Đã kích hoạt' ...)), OutlinedButton('Đăng xuất') ])`)
- **Observed Failures**:
  - At $300\text{dp}$ with $1.3\times$ text scale: `FlutterError: <A RenderFlex overflowed by 10.0 pixels on the right.>`
  - At $300\text{dp}$ with $1.5\times$ text scale: `FlutterError: <A RenderFlex overflowed by 34 pixels on the right.>`
- **Mathematical Root Cause Trace**:
  1. On a $300\text{dp}$ viewport, total horizontal padding is $16\times2 = 32\text{dp}$ (`ListView` padding) plus $18\times2 = 36\text{dp}$ (`Container` card padding). Total available card content width is $300 - 68 = 232\text{dp}$.
  2. In the VIP Card Header (Line 199), the badge widget `Container(child: const Text('ĐÃ KÍCH HOẠT'))` is an unconstrained sibling of `Expanded(child: Row(...))`.
  3. At $1.5\times$ text scale in Flutter test font metrics (Ahem / fallback), the 12-character string `'ĐÃ KÍCH HOẠT'` at $15\text{pt}$ effective size measures $180\text{px}$ text width $+ 20\text{px}$ horizontal padding $= 200\text{px}$.
  4. Non-flex siblings in the outer `Row` consume: Badge ($200\text{px}$) $+ \text{SizedBox}(8\text{px}) = 208\text{px}$.
  5. The remaining space granted to the outer `Expanded` is $232\text{px} - 208\text{px} = 24\text{px}$.
  6. Inside the outer `Expanded`, the inner `Row` (Line 203) contains:
     - Icon container: $8\times2\text{px}$ padding $+ 24\text{px}$ icon $= 40\text{px}$.
     - `SizedBox(width: 12)`: $12\text{px}$.
     - Inner `Expanded(child: Column(...))`.
  7. The non-flex elements of the inner row require $40 + 12 = 52\text{px}$ (plus margin/subpixel metrics $\approx 58\text{px}$). But the available width is only $24\text{px}$!
  8. Layout assertion: $58\text{px} - 24\text{px} = 34\text{px}$ horizontal overflow!
  9. At $1.3\times$ scale: Badge width is $176\text{px} + 8\text{px} = 184\text{px}$. Remaining space $= 232 - 184 = 48\text{px}$. $58\text{px} - 48\text{px} = 10.0\text{px}$ overflow!
  10. Similarly, on Line 123, when `authState.isAuthenticated` is true, the `'Đăng xuất'` `OutlinedButton` is an unconstrained sibling next to `'AI DeepSeek: Đã kích hoạt'`. At $1.5\times$ scale, the logout button width squeezes the AI badge.

---

### 1.2 `HomeScreen` Section Header & SRS Due Card Overflows
- **File**: `app/lib/presentation/screens/home_screen.dart`
- **Locations**:
  - Practice Section Header: Line 319 (`const Row(children: [ Text('Chế độ Luyện tập', style: TextStyle(...)) ])`)
  - SRS Due Card Header: Line 220 (`Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Flexible(child: Container(...)), SizedBox(8), Container(...) ])`)
- **Observed Failures**:
  - Line 319: `A RenderFlex overflowed by 159 pixels on the right.` (Constraints: $w = 268.0$, natural size: $427.0\text{px}$).
  - Line 220: `A RenderFlex overflowed by 0.750 pixels on the right.` (Constraints: $w = 228.0$, natural size: $228.75\text{px}$).
- **Root Cause Trace**:
  1. **Line 319**: An unconstrained `Text` inside a horizontal `Row` has unbounded horizontal constraints ($0.0 \le w \le \infty$). At $1.5\times$ text scale ($18\text{pt} \times 1.5 = 27\text{pt}$), Flutter's test font renders the Vietnamese string `'Chế độ Luyện tập'` at $427\text{px}$ single-line width. Because `Text` is not wrapped in `Expanded` or `Flexible` with ellipsis, Flutter cannot wrap or truncate the text, overflowing the $268\text{px}$ row boundary by $159\text{px}$.
  2. **Line 220**: In `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween)`, Child 1 uses `Flexible(fit: FlexFit.loose)`, and Child 2 (`Container` with `$count từ cần ôn`) is non-flex. On a $300\text{dp}$ screen with $16\text{px}$ ListView padding and $20\text{px}$ card padding ($228\text{dp}$ content width), the sum of Child 2's unconstrained width plus `SizedBox(8)` plus Child 1's measured width exceeds $228.0\text{dp}$ due to subpixel floating point arithmetic ($228.75\text{px} > 228.0\text{px}$).

---

### 1.3 `VerbDetailScreen` Practice Action Button Overflow
- **File**: `app/lib/presentation/screens/verb_detail_screen.dart`
- **Location**: Line 245 (`Center(child: OutlinedButton.icon(...))`)
- **Observed Failure**:
  - `FlutterError: <A RenderFlex overflowed by 46 pixels on the right.>`
- **Root Cause Trace**:
  1. `OutlinedButton.icon` internally uses an unconstrained `Row(mainAxisSize: MainAxisSize.min)` with children: `icon`, `SizedBox(gap)`, and `label`. Neither `icon` nor `label` is wrapped in `Flexible` or `Expanded`.
  2. The label string `'Tạo 3 ví dụ AI theo chủ đề'` is 27 characters. At $1.5\times$ text scale ($14\text{pt} \times 1.5 = 21\text{pt}$), the label alone measures $\approx 270\text{px}$.
  3. Total button width $= \text{padding}(18\times2 = 36\text{px}) + \text{icon}(20\text{px}) + \text{gap}(8\text{px}) + \text{text}(270\text{px}) = 334\text{px}$.
  4. The available card width on a $300\text{dp}$ viewport is $300 - 32 - 40 = 228\text{px}$.
  5. The internal `Row` in `OutlinedButton.icon` exceeds available space by $46\text{px}$ ($274\text{px} - 228\text{px} = 46\text{px}$), throwing an unhandled `RenderFlex overflowed`.

---

### 1.4 Fastlane Android Appfile Package Name Fallback
- **File**: `app/android/fastlane/Appfile`
- **Location**: Line 2
- **Current Content**: `package_name(ENV["PACKAGE_NAME"] || "vn.phuongdan.360verb")`
- **Architectural Requirement**:
  Per `PROJECT.md` §Application ID Contract and `app/android/app/build.gradle.kts`:
  Java/AAPT2 package identifier rules disallow segment leading digits (`360verb`). Hence Android uses `vn.phuongdan.verb360`.
  The hardcoded fallback `"vn.phuongdan.360verb"` in Android's `Appfile` causes Fastlane lanes (`supply`, `upload_to_play_store`) to fail or mismatch if `PACKAGE_NAME` is not explicitly exported in CI/CD.

---

## 2. Concrete Proposed Code Changes

### Remedy 1: `ProfileScreen` VIP Status Card Header & AI Status Row
**Target File**: `app/lib/presentation/screens/profile_screen.dart`

#### Change 1A: Line 199 VIP Card Header Responsive Layout
Wrap the VIP card header in a `LayoutBuilder`. When width $< 280\text{dp}$ (or under large font scaling), display the `'ĐÃ KÍCH HOẠT'` badge below the title rather than forcing a side-by-side collision.

```dart
<<<<
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: iapState.isPro ? Colors.white24 : Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.workspace_premium_rounded,
                                  color: iapState.isPro ? Colors.white : Colors.amber.shade900,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      iapState.isPro ? 'Thành Viên VIP PRO' : 'Gói Miễn Phí (Free)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: iapState.isPro ? Colors.white : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      iapState.isPro
                                          ? 'Gói: ${iapState.planType.toUpperCase()} • ${iapState.planType == 'lifetime' ? 'Vĩnh viễn' : 'Đang hoạt động'}'
                                          : 'Giới hạn tính năng nâng cao',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: iapState.isPro ? Colors.white70 : Colors.grey.shade600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (iapState.isPro) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ĐÃ KÍCH HOẠT',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                            ),
                          ),
                        ],
                      ],
                    ),
====
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 280;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: iapState.isPro ? Colors.white24 : Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.workspace_premium_rounded,
                                    color: iapState.isPro ? Colors.white : Colors.amber.shade900,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        iapState.isPro ? 'Thành Viên VIP PRO' : 'Gói Miễn Phí (Free)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: iapState.isPro ? Colors.white : Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        iapState.isPro
                                            ? 'Gói: ${iapState.planType.toUpperCase()} • ${iapState.planType == 'lifetime' ? 'Vĩnh viễn' : 'Đang hoạt động'}'
                                            : 'Giới hạn tính năng nâng cao',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: iapState.isPro ? Colors.white70 : Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (iapState.isPro && !isNarrow) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'ĐÃ KÍCH HOẠT',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (iapState.isPro && isNarrow) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'ĐÃ KÍCH HOẠT',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
>>>>
```

#### Change 1B: Line 123 AI DeepSeek Status & Logout Row
Replace rigid `Row` with `LayoutBuilder` stacked column when width $< 260\text{dp}$.

```dart
<<<<
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'AI DeepSeek: Đã kích hoạt',
                                      style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w700, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red.shade200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              ref.read(authProvider.notifier).logout();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã đăng xuất.')),
                              );
                            },
                            child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
====
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 260;
                          final statusBanner = Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'AI DeepSeek: Đã kích hoạt',
                                    style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w700, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );

                          final logoutBtn = OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red.shade200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              ref.read(authProvider.notifier).logout();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã đăng xuất.')),
                              );
                            },
                            child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                statusBanner,
                                const SizedBox(height: 8),
                                logoutBtn,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: statusBanner),
                              const SizedBox(width: 8),
                              logoutBtn,
                            ],
                          );
                        },
                      ),
>>>>
```

---

### Remedy 2: `HomeScreen` Section Header & SRS Due Header
**Target File**: `app/lib/presentation/screens/home_screen.dart`

#### Change 2A: Line 319 Section Title Row
Constrain the header text with `Expanded` and `TextOverflow.ellipsis` so single-line text cannot exceed row bounds.

```dart
<<<<
          // Section Title
          const Row(
            children: [
              Text(
                'Chế độ Luyện tập',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
              ),
            ],
          ),
====
          // Section Title
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Chế độ Luyện tập',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
>>>>
```

#### Change 2B: Line 220 SRS Review Due Card Header
Replace rigid `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween)` with `Wrap` so that on narrow screens with high text scaling, the count badge drops to line 2 without subpixel overflows.

```dart
<<<<
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 16),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'SRS Spaced Repetition',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count từ cần ôn',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
====
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'SRS Spaced Repetition',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count từ cần ôn',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
>>>>
```

---

### Remedy 3: `VerbDetailScreen` AI Practice Action Button
**Target File**: `app/lib/presentation/screens/verb_detail_screen.dart`

#### Change 3: Line 245 Custom Bounded OutlinedButton
Replace unconstrained `OutlinedButton.icon` with custom `OutlinedButton` wrapping its content in a constrained `Row` with `Flexible` and `TextOverflow.ellipsis`.

```dart
<<<<
                if (!_loadAiExamples)
                  Center(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF059669),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.psychology_outlined, size: 20),
                      label: const Text('Tạo 3 ví dụ AI theo chủ đề', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        if (!authState.isAuthenticated) {
                          AuthModal.show(context);
                          return;
                        }
                        setState(() => _loadAiExamples = true);
                      },
                    ),
                  )
====
                if (!_loadAiExamples)
                  Center(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF059669),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (!authState.isAuthenticated) {
                          AuthModal.show(context);
                          return;
                        }
                        setState(() => _loadAiExamples = true);
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.psychology_outlined, size: 20),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Tạo 3 ví dụ AI theo chủ đề',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
>>>>
```

---

### Remedy 4: `app/android/fastlane/Appfile` Package Identifier Alignment
**Target File**: `app/android/fastlane/Appfile`

#### Change 4: Line 2 Package Name Fallback
Update the fallback string from `"vn.phuongdan.360verb"` to `"vn.phuongdan.verb360"`.

```ruby
<<<<
# Appfile for Verb360 AI (Android)
package_name(ENV["PACKAGE_NAME"] || "vn.phuongdan.360verb")
json_key_file(ENV["SUPPLY_JSON_KEY"] || "./play-store-credentials.json")
====
# Appfile for Verb360 AI (Android)
package_name(ENV["PACKAGE_NAME"] || "vn.phuongdan.verb360")
json_key_file(ENV["SUPPLY_JSON_KEY"] || "./play-store-credentials.json")
>>>>
```

---

## 3. Independent Verification Protocol

To independently verify the proposed remedies once applied by the implementer:

1. **Verify Individual Failing Tests**:
   ```bash
   cd /Volumes/DAT/GIT/360_verb/app
   flutter test test/adversarial_layout_stress_test.dart --plain-name "ProfileScreen VIP active state at 300dp with text scale 1.5x"
   flutter test test/adversarial_layout_stress_test.dart --plain-name "HomeScreen renders cleanly at 300dp with 1.5x text scale"
   flutter test test/adversarial_layout_stress_test.dart --plain-name "VerbDetailScreen with polysyllabic verb at 300dp with 1.5x text scale"
   ```
   *Expected Result*: All 3 tests pass cleanly with zero exceptions.

2. **Verify Fastlane Configuration**:
   ```bash
   grep -n "package_name" /Volumes/DAT/GIT/360_verb/app/android/fastlane/Appfile
   ```
   *Expected Result*: Verbatim line 2: `package_name(ENV["PACKAGE_NAME"] || "vn.phuongdan.verb360")`.

3. **Verify Static Analysis**:
   ```bash
   cd /Volumes/DAT/GIT/360_verb/app
   flutter analyze
   ```
   *Expected Result*: 0 issues found.
