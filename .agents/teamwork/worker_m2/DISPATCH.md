## 2026-11-04T02:10:37Z
You are worker_m2, a teamwork_worker.
Your working directory is: /Volumes/DAT/GIT/360_verb/.agents/teamwork/worker_m2

MANDATORY FIRST STEP:
Read /Volumes/DAT/GIT/360_verb/.agents/teamwork/ORIGINAL_REQUEST.md before starting work.
Also read /Volumes/DAT/GIT/360_verb/PROJECT.md and /Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_2/survey_ui_layout.md.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE WRITE OWNERSHIP:
You own exclusively:
- `app/lib/` (specifically UI screens and widgets under `app/lib/presentation/`)
Do not modify files outside this boundary (do not touch `app/android`, `app/ios`, `fastlane`, or `docs`).

TASK SPECIFICATION (Milestone M2: UI Inspection & Layout Bug Fixes):
1. Fix all 15 layout vulnerabilities identified in `survey_ui_layout.md`:
   - Bug 1 (CRITICAL): `app/lib/presentation/widgets/paywall_modal.dart:262` - Replace unconstrained footer `Row` with `Wrap` (spacing: 8, runSpacing: 4, alignment: WrapAlignment.center) so the 3 text buttons wrap gracefully on screens <= 390dp without `RenderFlex` overflow.
   - Bug 2 (CRITICAL): `app/lib/presentation/widgets/auth_modal.dart:235` - Remove hardcoded `height: 290` on `TabBarView` or wrap content in `SingleChildScrollView` / dynamic sizing so validation errors do not overflow vertically.
   - Bug 3 & 4: `app/lib/presentation/screens/practice/ai_writing_screen.dart:309-348` and `376-401` - Wrap titles and text children in `Expanded` / `Flexible` in the nested evaluation result rows, preventing overflow on small viewports.
   - Bug 5: `app/lib/presentation/screens/profile_screen.dart:183-237` - Wrap VIP status badge / subtitle row in `Flexible` or `Wrap`.
   - Bug 6 & 7: `app/lib/presentation/screens/practice/speed_quiz_screen.dart:128-158` & `app/lib/presentation/screens/practice/flashcard_screen.dart:92-132` - Enclose Game Over and Completion views in `SingleChildScrollView` so they scroll cleanly without bottom overflow in landscape / split-screen.
   - Bug 8: `app/lib/presentation/screens/practice/flashcard_screen.dart:318` - Wrap `VerticalDivider` row in `IntrinsicHeight` or explicit height constraint.
   - Bug 9: `app/lib/presentation/screens/dictionary_screen.dart:253-284` - Add `Flexible` to IPA text row next to morphological group and CEFR badge.
   - Bug 10: `app/lib/presentation/screens/verb_detail_screen.dart:356` - Ensure long button label wraps or has flexible text sizing.
   - Bug 11: `app/lib/presentation/adaptive_scaffold.dart:20-26` - Implement `didUpdateWidget` so external tab index updates (`HomeScreen.onNavigateToDictionary`) sync properly.
   - Other layout robustness improvements across all screens in R2.
2. Verify on Google Pixel 4 XL test device (`99051FFBA004TL`):
   - Check device connection: `adb devices`.
   - Reverse PocketBase port: `adb -s 99051FFBA004TL reverse tcp:8095 tcp:8095`.
   - Build debug APK (`flutter build apk --debug`) and install on Pixel 4 XL: `adb -s 99051FFBA004TL install -r build/app/outputs/flutter-apk/app-debug.apk`.
   - Launch app: `adb -s 99051FFBA004TL shell am start -n vn.phuongdan.verb360/.MainActivity`.
   - Check logcat: verify ZERO `RenderFlex overflowed` occurrences.
3. Verify static analysis and tests:
   - `cd /Volumes/DAT/GIT/360_verb/app && flutter analyze` (0 issues, 0 errors, 0 warnings).
   - `flutter test` (all tests pass).
4. Write complete self-contained `handoff.md` in `/Volumes/DAT/GIT/360_verb/.agents/teamwork/worker_m2/handoff.md`.
When finished, send a message to your parent.

## 2026-11-04T02:41:17Z
**Context**: Milestone M2 UI layout fixes and Pixel 4 XL test execution
**Content**: Heartbeat check: Please provide a quick status update on which layout bugs are fixed, your current testing/build phase, and update your `progress.md` file with your latest progress.
**Action**: Continue execution and reply with current progress or report when complete.
