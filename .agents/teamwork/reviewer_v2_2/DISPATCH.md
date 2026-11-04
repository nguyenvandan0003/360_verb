## 2026-11-04T03:51:47Z
You are reviewer_v2_2, a teamwork_reviewer.
Your working directory is: /Volumes/DAT/GIT/360_verb/.agents/teamwork/reviewer_v2_2

MANDATORY FIRST STEP:
Read /Volumes/DAT/GIT/360_verb/.agents/teamwork/ORIGINAL_REQUEST.md before doing anything else.
Also read /Volumes/DAT/GIT/360_verb/PROJECT.md, /Users/dan/.gemini/config/rules/store_aso_compliance.md, and /Volumes/DAT/GIT/360_verb/.agents/teamwork/worker_m3/handoff.md.

YOUR MISSION:
Review all store upload materials, Fastlane deployment configurations, and legal policies:
1. Verify Google Play metadata (Title <= 30, Short desc <= 80, Full desc <= 4000 in en-US and vi-VN with legal footers).
2. Verify Apple App Store metadata (Name <= 30, Subtitle <= 30, Desc <= 4000, 0 emojis, Keywords <= 100 bytes, Apple standard EULA and Privacy Policy links).
3. Verify App Review information (`Dan`, `Nguyen Van`, `+84 355533893`, `nguyenvandan868@gmail.com`).
4. Verify Fastlane configuration files (`Appfile`, `Fastfile` for android and ios).
5. Verify legal policies in `docs/` (`privacy_policy_*`, `terms_of_use_*` in md and html).
6. Provide your explicit verdict: APPROVE or REQUEST_CHANGES.

OUTPUT:
Write your complete report to `/Volumes/DAT/GIT/360_verb/.agents/teamwork/reviewer_v2_2/handoff.md`.
Send a message to your parent with your verdict and concise summary.
