## 2026-11-04T02:02:21Z
You are worker_m3, a teamwork_worker.
Your working directory is: /Volumes/DAT/GIT/360_verb/.agents/teamwork/worker_m3

MANDATORY FIRST STEP:
Read /Volumes/DAT/GIT/360_verb/.agents/teamwork/ORIGINAL_REQUEST.md before starting work.
Also read /Volumes/DAT/GIT/360_verb/PROJECT.md, /Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_3/survey_store_materials.md, and /Users/dan/.gemini/config/rules/store_aso_compliance.md.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE WRITE OWNERSHIP:
You own exclusively:
- `app/android/fastlane/`
- `app/ios/fastlane/`
- `docs/`
Do not modify any files outside this boundary.

TASK SPECIFICATION (Milestone M3: Store Upload Materials & Fastlane Deployment):
Implement all store submission materials based on the turnkey specifications in `survey_store_materials.md`:
1. Google Play Store metadata in `app/android/fastlane/metadata/android/`:
   - `en-US/title.txt` (<= 30 chars)
   - `en-US/short_description.txt` (<= 80 chars)
   - `en-US/full_description.txt` (<= 4000 chars, with legal footer)
   - `vi-VN/title.txt` (<= 30 chars)
   - `vi-VN/short_description.txt` (<= 80 chars)
   - `vi-VN/full_description.txt` (<= 4000 chars, with legal footer)
2. Apple App Store metadata in `app/ios/fastlane/metadata/`:
   - `en-US/name.txt` (<= 30 chars)
   - `en-US/subtitle.txt` (<= 30 chars)
   - `en-US/description.txt` (<= 4000 chars, STRICTLY 0 EMOJIS, `-` bullet lists, mandatory legal footer)
   - `en-US/keywords.txt` (<= 100 bytes UTF-8, comma-separated no spaces, 0 overlap with name/subtitle)
   - `en-US/promotional_text.txt` (<= 170 chars)
   - `en-US/privacy_url.txt`, `en-US/support_url.txt`, `en-US/marketing_url.txt`
   - `vi/name.txt` (<= 30 chars)
   - `vi/subtitle.txt` (<= 30 chars)
   - `vi/description.txt` (<= 4000 chars, STRICTLY 0 EMOJIS, `-` bullet lists, mandatory legal footer)
   - `vi/keywords.txt` (<= 100 bytes UTF-8, comma-separated no spaces, 0 overlap with name/subtitle)
   - `vi/promotional_text.txt` (<= 170 chars)
   - `vi/privacy_url.txt`, `vi/support_url.txt`, `vi/marketing_url.txt`
3. App Review information in `app/ios/fastlane/metadata/review_information/`:
   - `first_name.txt`: `Dan`
   - `last_name.txt`: `Nguyen Van`
   - `phone_number.txt`: `+84 355533893`
   - `email_address.txt`: `nguyenvandan868@gmail.com`
   - `demo_user.txt`, `demo_password.txt`, `notes.txt`
4. Fastlane configuration files:
   - `app/android/fastlane/Appfile`
   - `app/android/fastlane/Fastfile`
   - `app/ios/fastlane/Appfile`
   - `app/ios/fastlane/Fastfile`
5. Legal policy documents in `docs/`:
   - `docs/privacy_policy_en.md` and `docs/privacy_policy_en.html`
   - `docs/privacy_policy_vi.md` and `docs/privacy_policy_vi.html`
   - `docs/terms_of_use_en.md` and `docs/terms_of_use_en.html`
   - `docs/terms_of_use_vi.md` and `docs/terms_of_use_vi.html`
6. Verification:
   Execute an automated python validation script that checks all files for:
   - Character counts <= limits
   - UTF-8 byte sizes for keywords <= 100 bytes
   - Zero emojis in iOS descriptions
   - Presence of Apple EULA link (`https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`) and Privacy Policy link
   - Fastlane syntax validity.

OUTPUT:
Write your complete self-contained `handoff.md` in `/Volumes/DAT/GIT/360_verb/.agents/teamwork/worker_m3/handoff.md`.
When finished, send a message to your parent.
