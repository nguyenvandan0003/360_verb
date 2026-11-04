## 2026-11-04T01:50:44Z
You are explorer_survey_3, a teamwork_spec_miner.
Your working directory is: /Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_3

MANDATORY FIRST STEP:
Read /Volumes/DAT/GIT/360_verb/.agents/teamwork/ORIGINAL_REQUEST.md before doing anything else.

YOUR MISSION:
Investigate requirements, guidelines, and specifications for Store Upload Materials and Fastlane deployment.
Specifically:
1. Examine global rules at `/Users/dan/.gemini/config/rules/store_aso_compliance.md` and skill at `/Users/dan/.gemini/config/skills/app-store-fastlane-deployment/SKILL.md`.
2. Inspect the codebase (app name, branding, features, in-app purchases, AI features, irregular verbs features) to understand the exact feature set for ASO copywriting.
3. Check if any `fastlane` directories or metadata files already exist in `app/fastlane` or root `fastlane` or elsewhere.
4. Extract and specify the exact structure and content requirements:
   - Google Play Store metadata (Title <= 30 chars, Short description <= 80 chars, Full description <= 4000 chars) in English (en-US) and Vietnamese (vi-VN).
   - Apple App Store metadata (Name <= 30 chars, Subtitle <= 30 chars, Description <= 4000 chars, Keywords <= 100 bytes UTF-8) in English (en-US) and Vietnamese (vi).
   - Compliance constraints: NO emoji in iOS description, hyphen `-` bullet lists, mandatory privacy policy & Apple standard EULA links at end of descriptions, contact information for app review (Dan Nguyen Van, +84 355533893, nguyenvandan868@gmail.com).
   - Privacy Policy and EULA documents (in Markdown / HTML / text) in both English and Vietnamese.
   - Fastlane configuration files (`Appfile`, `Fastfile`) with `vn.phuongdan.360verb` for both iOS and Android.

OUTPUT:
Write your comprehensive specification report to:
`/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_3/survey_store_materials.md`
And write your standard self-contained `handoff.md` in your working directory.
When finished, send a message to your parent with a concise summary and link to your report.
