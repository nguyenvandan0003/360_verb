## 2026-11-04T02:56:54Z
You are reviewer_2, a teamwork_reviewer.
Your working directory is: /Volumes/DAT/GIT/360_verb/.agents/teamwork/reviewer_2

MANDATORY FIRST STEP:
Read /Volumes/DAT/GIT/360_verb/.agents/teamwork/ORIGINAL_REQUEST.md before starting.
Also read /Volumes/DAT/GIT/360_verb/PROJECT.md, /Users/dan/.gemini/config/rules/store_aso_compliance.md, and /Volumes/DAT/GIT/360_verb/.agents/teamwork/worker_m3/handoff.md.

YOUR MISSION:
Review all store upload materials, Fastlane deployment configurations, and legal policies:
1. Validate Google Play metadata (`app/android/fastlane/metadata/android/`):
   - Check character limits: Title <= 30, Short desc <= 80, Full desc <= 4000 in both en-US and vi-VN.
   - Verify mandatory legal footer at the bottom of descriptions.
2. Validate Apple App Store metadata (`app/ios/fastlane/metadata/`):
   - Check character limits: Name <= 30, Subtitle <= 30, Desc <= 4000 in both en-US and vi.
   - STRICT ENFORCEMENT: 0 emojis in `description.txt` (only `-` bullet lists).
   - Check Keywords: <= 100 bytes UTF-8, comma-separated no spaces, 0 token overlap with title/subtitle.
   - Verify inclusion of Apple standard EULA link (`https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`) and Privacy Policy link.
3. Validate App Review information (`app/ios/fastlane/metadata/review_information/`):
   - Contact details: Dan Nguyen Van, +84 355533893, nguyenvandan868@gmail.com.
4. Validate Fastlane configs:
   - Check syntax of `Appfile` and `Fastfile` in `app/android/fastlane` and `app/ios/fastlane`.
5. Validate legal policy documents in `docs/` (`privacy_policy_en.md`, `privacy_policy_vi.md`, `terms_of_use_en.md`, `terms_of_use_vi.md`, and HTML files).
6. Provide your explicit verdict: APPROVE or REQUEST_CHANGES in your handoff report.

OUTPUT:
Write your complete report to `/Volumes/DAT/GIT/360_verb/.agents/teamwork/reviewer_2/handoff.md`.
Send a message to your parent with your verdict and concise summary.
