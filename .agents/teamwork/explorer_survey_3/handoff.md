# Handoff Report: Store Upload Materials & Fastlane Deployment Specification

**Agent**: `explorer_survey_3` (teamwork_spec_miner)  
**Parent**: `ca60e4b8-b32f-4ba3-9b98-7262d16a5d53` (teamwork_orchestrator)  
**Date**: 2026-11-04  
**Primary Deliverable**: `/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_3/survey_store_materials.md`

---

## 1. Observation

1. **Current Codebase State**:
   - `find_by_name` for `*fastlane*` in `/Volumes/DAT/GIT/360_verb` returned 0 results. Neither `app/android/fastlane` nor `app/ios/fastlane` exist yet.
   - Target bundle identifier from `ORIGINAL_REQUEST.md` R1: `vn.phuongdan.360verb`. Existing application ID is `com.antigravity.verb360.app` in `app/android/app/build.gradle.kts:8,19` and `app/ios/Runner.xcodeproj/project.pbxproj`.
   - Feature inspection in `app/lib`:
     - 360 irregular verbs dictionary with 3 forms (V1, V2, V3), IPA, native audio TTS, bilingual examples (`data/models/verb.dart`, `data/services/tts_service.dart`).
     - DeepSeek AI integration for sentence evaluation and thematic context generation (`backend/internal/hooks/api_routes.go:36-124`, `backend/internal/ai/gemini.go:38-58`, `app/lib/logic/ai_providers.dart`).
     - Spaced Repetition SM-2 algorithm with Ease Factor calculation (`app/lib/core/srs/sm2_calculator.dart`, `app/lib/logic/srs_providers.dart`).
     - 4 practice modes: Flashcard SRS, Fill in Blanks, Speed Quiz (60s), AI Writing Challenge (`app/lib/presentation/screens/practice/`).
     - Gamification: streaks, XP, level badges (`app/lib/logic/gamification_providers.dart`).
     - In-App Purchase products (`app/lib/data/models/iap_product.dart:22-57`):
       - `verb360_lifetime_299k` (Lifetime, 299.000 VND)
       - `verb360_sub_yearly_199k` (1 Year Subscription, 199.000 VND)
       - `verb360_sub_monthly_19k` (1 Month Subscription, 19.000 VND)

2. **Compliance Rules Observed**:
   - Global Rule `/Users/dan/.gemini/config/rules/store_aso_compliance.md`:
     - Mandatory legal footer at the bottom of all descriptions:
       ```text
       ---
       Privacy Policy: <link_privacy_policy>
       Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
       ```
     - iOS Description: STRICTLY ZERO EMOJIS! Use hyphen `-` for bullet lists. App Store Connect API returns: `An attribute value has invalid characters. Description can't contain the following character(s)`.
     - iOS Subtitle: strictly <= 30 characters.
     - iOS Keywords: strictly <= 100 bytes (UTF-8), comma-separated without spaces, ZERO overlap with words in Name or Subtitle.
     - App Review Contact Info: Dan Nguyen Van, `+84 355533893`, `nguyenvandan868@gmail.com`.
   - Skill `/Users/dan/.gemini/config/skills/app-store-fastlane-deployment/SKILL.md`:
     - Locale mapping: Android uses `en-US` and `vi-VN`; iOS uses `en-US` and `vi`.
     - Character limits: Google Play Title <= 30, Short desc <= 80, Full desc <= 4000; App Store Name <= 30, Subtitle <= 30, Description <= 4000, Keywords <= 100 bytes, Promotional text <= 170 chars.

3. **Validation & Byte Measurement**:
   - Google Play Title EN: "Verb360: 360 Irregular Verbs" (28 chars <= 30).
   - Google Play Title VI: "Verb360: Động Từ Bất Quy Tắc" (28 chars <= 30).
   - Google Play Short EN: "Master 360 English irregular verbs with DeepSeek AI tutor, SRS & smart quizzes." (79 chars <= 80).
   - Google Play Short VI: "Học 360 động từ bất quy tắc cùng gia sư AI DeepSeek, thẻ nhớ SRS & luyện thi." (77 chars <= 80).
   - App Store Name EN: "Verb360: Irregular Verbs AI" (27 chars <= 30).
   - App Store Name VI: "Verb360: Động Từ Bất Quy Tắc" (28 chars <= 30).
   - App Store Subtitle EN: "360 Verbs, SRS & AI Tutor" (25 chars <= 30).
   - App Store Subtitle VI: "360 Động Từ, SRS & Gia Sư AI" (28 chars <= 30).
   - App Store Keywords EN: `grammar,flashcards,english,study,vocabulary,quiz,ielts,toeic,spaced,repetition,offline,conjugation` (98 bytes <= 100 bytes; 0 overlapping words with Name/Subtitle).
   - App Store Keywords VI: `ngữ pháp,tiếng anh,flashcard,luyện thi,ielts,toeic,trắc nghiệm,chia thì,phát âm` (93 bytes <= 100 bytes; 0 overlapping words with Name/Subtitle).
   - App Store Descriptions: EN (3,715 chars) and VI (3,491 chars) — verified 0 emojis, hyphen bullet lists, full IAP pricing disclosures, and mandatory legal footer.

---

## 2. Logic Chain

1. **Step 1 (Grounding in Core App Capabilities)**:
   - To write accurate, high-converting, and compliant ASO copy, the actual features in the codebase were probed. The app is not a generic dictionary; it specifically features:
     1. Complete 360 verbs database with IPA and offline TTS.
     2. DeepSeek AI grammar tutor with scoring 1-10, tense breakdown, and semantic caching.
     3. SuperMemo-2 spaced repetition flashcards.
     4. 4 practice modes: Flashcard, Fill Blanks, Speed Quiz (60s), and AI Writing.
     5. 3 IAP tiers: Lifetime (299k), Yearly (199k), Monthly (19k).

2. **Step 2 (Resolving Character & Byte Constraints)**:
   - Google Play strictly rejects titles > 30 characters and short descriptions > 80 characters.
   - Apple App Store strictly rejects names > 30 characters, subtitles > 30 characters, keywords > 100 bytes UTF-8, descriptions > 4000 characters, and descriptions with emoji.
   - Vietnamese diacritical characters consume 2 to 3 bytes per character in UTF-8. Initial candidate Vietnamese keywords exceeded 112 bytes. By pruning and tokenizing without redundant title/subtitle terms (`động`, `từ`, `bất`, `quy`, `tắc`, `360`, `srs`, `ai`), the keyword string was optimized to 9 high-volume terms at exactly 93 bytes.

3. **Step 3 (Legal Compliance & Apple Guideline 3.1.2 / 5.1.1)**:
   - For auto-renewing subscriptions, Apple requires clear pricing, duration, renewal terms, cancellation steps, and active links to the Privacy Policy and standard Apple EULA.
   - Both descriptions and independent Privacy Policy / Terms of Use documents were drafted in English and Vietnamese to fulfill this requirement completely.

4. **Step 4 (Fastlane Pipeline Architecture)**:
   - Automated deployment requires separate `Appfile` and `Fastfile` setups under `app/android/fastlane/` and `app/ios/fastlane/` using target package ID `vn.phuongdan.360verb`. Lanes for `beta`, `release`, and `metadata` were specified to enable flexible deployment without requiring full binary compilation for metadata updates.

---

## 3. Caveats

- **Domain Resolution**: The privacy policy and support URLs use `https://360verb.phuongdan.io.vn/privacy.html` and `https://360verb.phuongdan.io.vn/terms.html`. If the production domain is hosted elsewhere, update the base domain in `privacy_url.txt`, `support_url.txt`, `marketing_url.txt`, and the footers of `description.txt` / `full_description.txt`.
- **Apple Team IDs**: The iOS `Appfile` uses environment variables `ENV["ITC_TEAM_ID"]` and `ENV["TEAM_ID"]`. These will be populated from developer account secrets during CI/CD execution.
- **Play Store Service Account**: The Android `Appfile` uses `play-store-credentials.json` or `ENV["SUPPLY_JSON_KEY"]`, which must be provisioned in the Google Play Console for automated uploading.

---

## 4. Conclusion

All specifications, character/byte constraints, copywriting in English and Vietnamese, legal policies (Privacy Policy & EULA), and Fastlane configurations for `vn.phuongdan.360verb` have been completely surveyed, rigorously verified, and documented in:
`/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_3/survey_store_materials.md`

The downstream implementation developer has a complete, turnkey reference with exact text and paths ready for file creation.

---

## 5. Verification Method

To independently verify the character lengths, byte limits, and absence of emojis:

```bash
python3 -c "
import unicodedata

# 1. Keywords byte verification
kw_en = 'grammar,flashcards,english,study,vocabulary,quiz,ielts,toeic,spaced,repetition,offline,conjugation'
kw_vi = 'ngữ pháp,tiếng anh,flashcard,luyện thi,ielts,toeic,trắc nghiệm,chia thì,phát âm'
print('KW EN bytes:', len(kw_en.encode('utf-8')), '<= 100:', len(kw_en.encode('utf-8')) <= 100)
print('KW VI bytes:', len(kw_vi.encode('utf-8')), '<= 100:', len(kw_vi.encode('utf-8')) <= 100)

# 2. Character length verification
titles = [
    ('GP Title EN', 'Verb360: 360 Irregular Verbs', 30),
    ('GP Title VI', 'Verb360: Động Từ Bất Quy Tắc', 30),
    ('GP Short EN', 'Master 360 English irregular verbs with DeepSeek AI tutor, SRS & smart quizzes.', 80),
    ('GP Short VI', 'Học 360 động từ bất quy tắc cùng gia sư AI DeepSeek, thẻ nhớ SRS & luyện thi.', 80),
    ('iOS Name EN', 'Verb360: Irregular Verbs AI', 30),
    ('iOS Name VI', 'Verb360: Động Từ Bất Quy Tắc', 30),
    ('iOS Sub EN', '360 Verbs, SRS & AI Tutor', 30),
    ('iOS Sub VI', '360 Động Từ, SRS & Gia Sư AI', 30),
]
for name, val, limit in titles:
    print(f'{name}: {len(val)}/{limit} -> Pass: {len(val) <= limit}')
"
```

To inspect the generated specification report:
```bash
cat /Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_3/survey_store_materials.md
```
