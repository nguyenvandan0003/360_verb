## 2026-11-04T02:02:33Z
You are test_writer_e2e, a teamwork_test_writer.
Your working directory is: /Volumes/DAT/GIT/360_verb/.agents/teamwork/test_writer_e2e

MANDATORY FIRST STEP:
Read /Volumes/DAT/GIT/360_verb/.agents/teamwork/ORIGINAL_REQUEST.md before starting work.
Also read /Volumes/DAT/GIT/360_verb/PROJECT.md and /Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_2/survey_ui_layout.md.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE WRITE OWNERSHIP:
You own exclusively:
- `TEST_INFRA.md` at project root
- `TEST_READY.md` at project root
- `app/test/e2e/` (new directory)
- `app/test/responsive_layout_test.dart`
- `app/test/helpers/`
Do not modify any application implementation code in `app/lib`.

TASK SPECIFICATION (E2E Testing Track):
1. Create `TEST_INFRA.md` at `/Volumes/DAT/GIT/360_verb/TEST_INFRA.md` following the Project Pattern template:
   - Test Philosophy: Opaque-box, requirement-driven.
   - Feature Inventory covering F01 - F18 from `PROJECT.md`.
   - Test Architecture: runner command, test case tiers (Tier 1: Feature Coverage, Tier 2: Boundary & Corner, Tier 3: Cross-Feature Combinations, Tier 4: Real-World Scenarios).
   - Multi-device matrix: 320x568 (compact phone), 390x844 (standard phone), 412x869 (Pixel 4 XL), 768x1024 (tablet portrait), 1024x768 (tablet landscape).
2. Implement automated multi-device responsive layout tests:
   - Create `app/test/responsive_layout_test.dart` and `app/test/e2e/` suites using Flutter `WidgetTester` and `binding.setSurfaceSize`.
   - Test all screens from R2:
     - 360 Irregular Verbs dictionary screen & verb detail
     - DeepSeek AI tutor & grammar evaluation UI
     - SRS Spaced Repetition (Flashcard screen)
     - Fill Blanks practice screen
     - Speed Quiz screen (portrait & landscape)
     - Paywall modal & In-App Purchases UI
     - Auth modal
     - AdaptiveScaffold navigation across mobile (<768dp) and tablet (>=768dp).
   - In each test, assert `tester.takeException() == null` and ensure NO `RenderFlex` overflow errors occur across all viewports.
3. Run the test suite:
   `cd /Volumes/DAT/GIT/360_verb/app && flutter test test/responsive_layout_test.dart`
   (Document passing tests and any expected failures that expose current layout bugs before M2 fixes them).
4. Create `TEST_READY.md` at `/Volumes/DAT/GIT/360_verb/TEST_READY.md` summarizing the test runner command, tier breakdown, and test counts.
5. Write your complete self-contained `handoff.md` in `/Volumes/DAT/GIT/360_verb/.agents/teamwork/test_writer_e2e/handoff.md`.
When finished, send a message to your parent.
