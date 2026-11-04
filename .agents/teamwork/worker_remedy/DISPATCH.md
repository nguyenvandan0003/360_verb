## 2026-11-04T03:21:43Z

You are worker_remedy, a teamwork_worker.
Your working directory is: /Volumes/DAT/GIT/360_verb/.agents/teamwork/worker_remedy

MANDATORY FIRST STEP:
Read /Volumes/DAT/GIT/360_verb/.agents/teamwork/ORIGINAL_REQUEST.md before doing anything else.
Also read /Volumes/DAT/GIT/360_verb/PROJECT.md, /Volumes/DAT/GIT/360_verb/.agents/teamwork/challenger_1/handoff.md, and all 3 remedy reports:
- `/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_remedy_1/remedy_modals.md`
- `/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_remedy_2/remedy_practice.md`
- `/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_remedy_3/remedy_general.md`

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE WRITE OWNERSHIP:
You own exclusively:
- `app/lib/presentation/widgets/paywall_modal.dart`
- `app/lib/presentation/widgets/auth_modal.dart`
- `app/lib/presentation/screens/practice/ai_writing_screen.dart`
- `app/lib/presentation/screens/practice/speed_quiz_screen.dart`
- `app/lib/presentation/screens/profile_screen.dart`
- `app/lib/presentation/screens/home_screen.dart`
- `app/lib/presentation/screens/verb_detail_screen.dart`
- `app/android/fastlane/Appfile`
Do not modify any other files.

TASK SPECIFICATION:
Apply the exact drop-in code fixes documented in `remedy_modals.md`, `remedy_practice.md`, and `remedy_general.md`:
1. `paywall_modal.dart`: In pricing option cards, wrap content in `LayoutBuilder` with `ConstrainedBox(maxWidth: cardConstraints.maxWidth * 0.38)` and `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight)` on formatted price text.
2. `auth_modal.dart`: Remove rigid `SizedBox(height: 350)` on `TabBarView`, render form dynamically inside primary modal scroll view so submit button is always reachable and within hit-test bounds.
3. `ai_writing_screen.dart`: In AI status banner, use `LayoutBuilder` / `Wrap` so action button wraps cleanly on widths < 340dp; in evaluation card header, wrap score pill in `Flexible` + `FittedBox`.
4. `speed_quiz_screen.dart`: In active quiz layout, wrap in responsive `LayoutBuilder` + `SingleChildScrollView` (or 2-column landscape) so height < 400dp does not overflow.
5. `profile_screen.dart`: In VIP active status header and AI status/logout row, use responsive layout/stacking.
6. `home_screen.dart`: Wrap section header title in `Expanded` (line 319) and review due header in `Wrap` (line 220).
7. `verb_detail_screen.dart`: Replace `OutlinedButton.icon` with custom `OutlinedButton` with `Flexible(Text(..., overflow: TextOverflow.ellipsis))`.
8. `app/android/fastlane/Appfile`: Update fallback package name to `"vn.phuongdan.verb360"`.
9. Verification:
   - Run `cd /Volumes/DAT/GIT/360_verb/app && flutter analyze` (must be 0 issues, 0 errors, 0 warnings).
   - Run `flutter test test/adversarial_layout_stress_test.dart` (all 39 tests must pass!).
   - Run `flutter test` (all 70 tests across standard test suites must pass!).
   - Check Pixel 4 XL (`99051FFBA004TL`) via `adb logcat -d | grep -i -E "RenderFlex|overflowed"` to confirm 0 overflows.

OUTPUT:
Write your complete self-contained `handoff.md` in `/Volumes/DAT/GIT/360_verb/.agents/teamwork/worker_remedy/handoff.md`.
When finished, send a message to your parent.
