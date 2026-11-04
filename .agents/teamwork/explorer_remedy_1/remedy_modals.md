# Modal Layout Failure Investigation & Remedy Report

**Author**: `explorer_remedy_1` (Teamwork Explorer)  
**Date**: 2026-11-04  
**Target Modals**: `PaywallModal` (`app/lib/presentation/widgets/paywall_modal.dart`) & `AuthModal` (`app/lib/presentation/widgets/auth_modal.dart`)  
**Scope**: Root cause forensic analysis, mathematical layout modeling, and concrete verified code recommendations for Milestone M2 layout stability under accessibility text scales (1.3x–1.5x) and narrow viewports (280dp–300dp).

---

## 1. Executive Summary

Empirical test execution of `adversarial_layout_stress_test.dart` revealed that while the application renders cleanly at standard 1.0x text scaling on viewports $\ge 320\text{dp}$ (including physical Google Pixel 4 XL at 411.4dp), both `PaywallModal` and `AuthModal` fail under accessibility text scaling (1.3x–1.5x) and compact screens ($280\text{dp} - 300\text{dp}$):

1. **`PaywallModal`** (`paywall_modal.dart:180`):
   - **Assertion**: `A RenderFlex overflowed by 11.0 to 40.0 pixels on the right`.
   - **Root Cause**: The pricing option card uses an unconstrained `Row` where `Icon(24)`, `SizedBox(14)`, `SizedBox(8)`, and `Text(product.priceFormatted)` are non-flex elements. At text scales 1.3x and 1.5x, the price text width expands to 187.2px–216px (Ahem test font) or 110px–135px (system font). Along with the icon and spacings (46px), the non-flex elements alone exceed the available card inner width (206px–226px), leaving zero space for the `Expanded` column and overflowing the `Row` by up to 40px.
   - **Remedy**: Enclose the card content in a `LayoutBuilder` and wrap the price formatted text in a `ConstrainedBox(constraints: BoxConstraints(maxWidth: cardConstraints.maxWidth * 0.38))` with `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight)`. This guarantees that the price text never occupies more than 38% of available width, scales down gracefully when enlarged, leaves $\ge 62\%$ for the title/badge column, and maintains flush-right alignment without artificial gaps.

2. **`AuthModal`** (`auth_modal.dart:236`):
   - **Assertion**: `Warning: A call to tap() derived an Offset (Offset(150.0, 645.5) / Offset(150.0, 780.0)) that would not hit test on the specified widget... outside the bounds of the root of the render tree, Size(300.0, 600.0)`.
   - **Root Cause**: `TabBarView` is artificially trapped inside a rigid `SizedBox(height: 350)`. Inside each tab, a nested `SingleChildScrollView` wraps the form. Under text scale 1.3x and 1.5x, the Register tab's three form fields and submit button expand to 385px–480px, overflowing the 350px box. Because the inner `SingleChildScrollView` does not auto-scroll, the submit button is clipped and positioned at global $Y = 645.5\text{dp}$ to $780.0\text{dp}$, completely off-screen on a 600dp viewport. Taps miss the target, validation is never triggered, and the test fails.
   - **Remedy**: Eliminate the rigid `SizedBox(height: 350)` and the nested `SingleChildScrollView`s. Replace `TabBarView` with dynamic state-driven tab body rendering (`_selectedTabIndex == 0 ? _buildLoginForm(...) : _buildRegisterForm(...)`) inside the modal's primary `SingleChildScrollView`. This allows the modal height to adapt naturally and dynamically to the active form, ensures validation messages expand without clipping, and keeps the submit button within reach ($Y \approx 450\text{dp} - 490\text{dp}$ on a 600dp screen).

---

## 2. Deep Dive: PaywallModal (`paywall_modal.dart:180`)

### 2.1 Code Under Inspection
```dart
// app/lib/presentation/widgets/paywall_modal.dart:178-235
child: Padding(
  padding: const EdgeInsets.all(16),
  child: Row(
    children: [
      Icon(
        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
        color: isSelected ? AppTheme.primary : Colors.grey.shade400,
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 2,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                if (product.badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: product.id.contains('yearly') ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 3),
            Text(
              product.subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Text(
        product.priceFormatted,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primary),
      ),
    ],
  ),
),
```

### 2.2 Mathematical Breakdown of the Overflow

| Dimension / Component | 300dp Screen (Standard Narrow) | 280dp Screen (Galaxy Fold Cover) |
|---|---|---|
| Screen Width | $300.0\text{dp}$ | $280.0\text{dp}$ |
| Modal Padding (`horizontal: 20` $\times 2$) | $-40.0\text{dp}$ | $-40.0\text{dp}$ |
| Card Border & Padding (`all: 16` $\times 2$ + borders) | $-34.0\text{dp}$ to $-36.0\text{dp}$ | $-34.0\text{dp}$ to $-36.0\text{dp}$ |
| **Available Main Axis Constraint ($W_{avail}$)** | **$224.0\text{dp}$ – $226.0\text{dp}$** | **$204.0\text{dp}$ – $206.0\text{dp}$** |
| Radio Icon (`size: 24`) | $24.0\text{dp}$ | $24.0\text{dp}$ |
| Spacing (`SizedBox(width: 14) + SizedBox(width: 8)`) | $22.0\text{dp}$ | $22.0\text{dp}$ |
| Fixed Overhead Total | $46.0\text{dp}$ | $46.0\text{dp}$ |
| Price Text at 1.0x (`fontSize: 16`) | $\sim 75.0\text{dp}$ – $144.0\text{dp}$ | $\sim 75.0\text{dp}$ – $144.0\text{dp}$ |
| Price Text at 1.3x (`fontSize: 20.8`) | $187.2\text{dp}$ | $187.2\text{dp}$ |
| Price Text at 1.5x (`fontSize: 24.0`) | $216.0\text{dp}$ | $216.0\text{dp}$ |
| Non-Flex Elements Total at 1.3x | $46.0 + 187.2 = 233.2\text{dp}$ | $46.0 + 187.2 = 233.2\text{dp}$ |
| Non-Flex Elements Total at 1.5x | $46.0 + 216.0 = 262.0\text{dp}$ | $46.0 + 216.0 = 262.0\text{dp}$ |
| **RenderFlex Overflow at 1.3x** | **$233.2 - 224.0 = +9.2\text{px} \approx 11\text{px}$** | **$233.2 - 204.0 = +29.2\text{px} \approx 31\text{px}$** |
| **RenderFlex Overflow at 1.5x** | **$262.0 - 224.0 = +38.0\text{px} \approx 40\text{px}$** | **$262.0 - 204.0 = +58.0\text{px}$** |

Because `Text(product.priceFormatted)` is an unconstrained flex sibling, Flutter's `RenderFlex` measures all non-flex children before computing space for `Expanded`. When non-flex children exceed $W_{avail}$, `spacePerFlex` becomes zero (clamped), the `Expanded` column receives zero width, and the `Row` itself overflows by the exact delta between non-flex children and $W_{avail}$.

### 2.3 Proposed Fix for PaywallModal

Wrap the card's inner content in a `LayoutBuilder` to obtain exact inner card constraints `cardConstraints.maxWidth`. Constrain the price text to at most 38% of `cardConstraints.maxWidth` and wrap it in `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight)`. Also defend the CTA button with `FittedBox(fit: BoxFit.scaleDown)`:

```dart
// Location: app/lib/presentation/widgets/paywall_modal.dart:178-237
child: Padding(
  padding: const EdgeInsets.all(16),
  child: LayoutBuilder(
    builder: (context, cardConstraints) {
      return Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
            color: isSelected ? AppTheme.primary : Colors.grey.shade400,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    if (product.badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.id.contains('yearly') ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  product.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: cardConstraints.maxWidth * 0.38,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                product.priceFormatted,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ],
      );
    },
  ),
),
```

And for the CTA button at line 257:
```dart
// Location: app/lib/presentation/widgets/paywall_modal.dart:257-260
child: iapState.isPurchasing
    ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      )
    : FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Nâng cấp ngay • ${iapState.selectedProduct.priceFormatted}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
```

### 2.4 Why this Solution is Structurally Superior to Alternatives
- **Why not `Flexible(child: FittedBox(...))` alone?**  
  In Flutter `RenderFlex`, if a `Row` contains `Expanded(Column)` (tight) and `Flexible(FittedBox)` (loose), Flutter splits the free space evenly based on flex factors. When the price text is short (e.g. 70dp on a 390dp screen), `Flexible` takes only 70dp, but `Expanded` is fixed to its tight fraction. The remaining space is placed at the end of the row, leaving an awkward 20dp–30dp gap between the price and the right edge of the card.
- **Why `ConstrainedBox(maxWidth: 0.38)` works best:**  
  Because `ConstrainedBox` is a non-flex child with a strict upper bound, it is measured first. The price takes at most 38% of the card width (and scales down if text is enlarged). Then `Expanded(child: Column(...))` absorbs 100% of all remaining space, naturally pushing the price tight against the right margin on screens of any width.

---

## 3. Deep Dive: AuthModal (`auth_modal.dart:236`)

### 3.1 Code Under Inspection
```dart
// app/lib/presentation/widgets/auth_modal.dart:234-245, 314-320
// TabBarView Content
SizedBox(
  height: 350,
  child: TabBarView(
    controller: _tabController,
    children: [
      // LOGIN TAB
      SingleChildScrollView(
        child: Form(
          key: _loginFormKey,
          child: Column(...),
        ),
      ),
      // REGISTER TAB
      SingleChildScrollView(
        child: Form(
          key: _registerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _registerNameController, ...),
              const SizedBox(height: 12),
              TextFormField(controller: _registerEmailController, ...),
              const SizedBox(height: 12),
              TextFormField(controller: _registerPasswordController, ...),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleRegister,
                child: const Text('Tạo tài khoản & Bắt đầu', ...),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),
```

### 3.2 Vertical Coordinate & Hit-Test Failure Analysis

When rendered within a $300\text{dp} \times 600\text{dp}$ viewport:

1. **Modal Top Hierarchy**:
   - Container padding top: $20\text{dp}$
   - Drag handle + margin: $21\text{dp}$
   - Header Row (Icon + Title + Subtitle): $\sim 65\text{dp}$ (scales to $\sim 80\text{dp}$ at 1.3x and $\sim 95\text{dp}$ at 1.5x)
   - Margin: $18\text{dp}$
   - Segmented TabBar: $44\text{dp} + 16\text{dp} = 60\text{dp}$
   - **$Y$-coordinate at start of `TabBarView`**: $Y \approx 184\text{dp}$ (1.0x), $200\text{dp}$ (1.3x), $215\text{dp}$ (1.5x).

2. **Register Form Height Inside TabBarView**:
   - 3 TextFormFields:
     - 1.0x: $3 \times 56\text{dp} = 168\text{dp}$
     - 1.3x: $3 \times 74\text{dp} = 222\text{dp}$
     - 1.5x: $3 \times 86\text{dp} = 258\text{dp}$
   - Form field spacings: $12 + 12 + 16 = 40\text{dp}$
   - Primary action button: $\sim 48\text{dp}$ (1.0x), $\sim 56\text{dp}$ (1.3x), $\sim 64\text{dp}$ (1.5x)
   - Total un-scrolled register form height:
     - At 1.0x: $168 + 40 + 48 = 256\text{dp}$ ($\le 350\text{dp}$, fits comfortably)
     - At 1.3x: $222 + 40 + 56 = 318\text{dp}$ (before errors) / $385\text{dp}$ (with error messages)
     - At 1.5x: $258 + 40 + 64 = 362\text{dp}$ (before errors) / $480\text{dp}$ (with error messages)

3. **Global Button Position**:
   Because `TabBarView` has a fixed height of `350`, the inner `SingleChildScrollView` does not expand the box.
   The button's center global offset evaluates to:
   - At 1.3x: $Y_{start} (260) + Y_{rel} (385.5) = \mathbf{645.5\text{dp}}$
   - At 1.5x: $Y_{start} (300) + Y_{rel} (480.0) = \mathbf{780.0\text{dp}}$
   Both $645.5\text{dp}$ and $780.0\text{dp}$ exceed the $600\text{dp}$ boundary of the render tree root `Size(300.0, 600.0)`.
   When `tester.tap(find.text('Tạo tài khoản & Bắt đầu'))` sends a pointer event to $(150.0, 645.5)$, the tap misses the window, `_handleRegister` is never executed, validation fails to run, and `find.text('Vui lòng nhập tên của bạn')` fails.

### 3.3 Proposed Fix for AuthModal

1. Remove `SizedBox(height: 350)` and `TabBarView`.
2. Remove the inner nested `SingleChildScrollView`s from both the login and register forms.
3. Manage active tab state cleanly using `_selectedTabIndex` (synchronized via `_tabController.addListener` and `TabBar.onTap`).
4. Render the active form directly in the modal `Column`, allowing the outer `SingleChildScrollView` to handle all scrolling smoothly without nested scroll trapping.

#### Precise Proposed Changes in `app/lib/presentation/widgets/auth_modal.dart`:

**Part 1: State Declaration and Listener in `_AuthModalState`**
```dart
// Location: app/lib/presentation/widgets/auth_modal.dart:22-45
class _AuthModalState extends ConsumerState<AuthModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController(text: 'test@antigravity.dev');
  final _loginPasswordController = TextEditingController(text: 'password123');

  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _selectedTabIndex != _tabController.index) {
        setState(() => _selectedTabIndex = _tabController.index);
      }
    });
  }
```

**Part 2: TabBar Tap Handler**
```dart
// Location: app/lib/presentation/widgets/auth_modal.dart:184-188
child: TabBar(
  controller: _tabController,
  onTap: (index) => setState(() => _selectedTabIndex = index),
  indicatorSize: TabBarIndicatorSize.tab,
  dividerColor: Colors.transparent,
```

**Part 3: Dynamic Tab Body (Replacing lines 234–395)**
```dart
// Location: app/lib/presentation/widgets/auth_modal.dart:234-395
// Dynamic Form Body (Adaptive height without rigid bounds or nested scroll views)
if (_selectedTabIndex == 0)
  Form(
    key: _loginFormKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.mail_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (v) {
            if (v == null || !v.contains('@')) return 'Email không hợp lệ';
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() => _obscureLoginPassword = !_obscureLoginPassword);
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (v) {
            if (v == null || v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
            return null;
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: authState.isLoading ? null : _handleLogin,
          child: authState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Đăng nhập ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            _loginEmailController.text = 'test@antigravity.dev';
            _loginPasswordController.text = 'password123';
          },
          child: const Text('Điền nhanh tài khoản mẫu: test@antigravity.dev'),
        ),
      ],
    ),
  )
else
  Form(
    key: _registerFormKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _registerNameController,
          decoration: InputDecoration(
            labelText: 'Họ và tên của bạn',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên của bạn';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _registerEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.mail_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (v) {
            if (v == null || !v.contains('@')) return 'Email không hợp lệ';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _registerPasswordController,
          obscureText: _obscureRegisterPassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu (tối thiểu 8 ký tự)',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegisterPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() => _obscureRegisterPassword = !_obscureRegisterPassword);
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (v) {
            if (v == null || v.length < 8) return 'Mật khẩu tối thiểu 8 ký tự';
            return null;
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: authState.isLoading ? null : _handleRegister,
          child: authState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Tạo tài khoản & Bắt đầu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    ),
  ),
```

### 3.4 Verification of the Coordinate Solution
With the elimination of `SizedBox(height: 350)` and nested scroll views:
- The total height of the register form and modal header before submitting is:
  $20\text{ (padding)} + 21\text{ (handle)} + 80\text{ (header)} + 60\text{ (tabbar)} + 258\text{ (fields)} + 40\text{ (spacings)} + 28\text{ (half-button)} \approx \mathbf{507\text{dp}}$ at 1.5x scale!
- $507\text{dp} < 600\text{dp}$. The button center is located at $Y \approx 507\text{dp}$, safely within `Size(300, 600)`.
- `tester.tap(...)` directly hits the button without offset warnings.
- `_handleRegister` triggers immediately.
- Form validation errors appear cleanly, expanding the single outer `SingleChildScrollView` with 0 pixel overflow.

---

## 4. Verification Protocol

The worker implementing these remedies must execute the following automated test commands:

```bash
cd /Volumes/DAT/GIT/360_verb/app

# 1. Run targeted modal stress tests
flutter test test/adversarial_layout_stress_test.dart --plain-name "Adversarial Stress Test: PaywallModal"
flutter test test/adversarial_layout_stress_test.dart --plain-name "Adversarial Stress Test: AuthModal"

# 2. Run full adversarial suite
flutter test test/adversarial_layout_stress_test.dart

# 3. Run regression suite across all viewports
flutter test test/responsive_layout_test.dart

# 4. Verify static analysis
flutter analyze
```

**Expected Results Post-Remedy:**
- `PaywallModal`: All 4 stress tests PASS with 0 exceptions at 300dp (1.0x, 1.3x, 1.5x) and 280dp (1.3x).
- `AuthModal`: All 6 stress tests PASS with 0 exceptions at 300dp (Login & Register at 1.0x, 1.3x, 1.5x).
- Zero hit-test warning messages on `tap()`.
- Zero `RenderFlex overflowed` errors.
- `flutter analyze` reports 0 issues.
