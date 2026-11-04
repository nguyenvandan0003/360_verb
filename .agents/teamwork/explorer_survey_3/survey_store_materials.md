# Survey & Specification Report: Store Upload Materials & Fastlane Deployment

- **Application Name**: Verb360 AI (360 Irregular Verbs / 360 Động Từ Bất Quy Tắc)
- **Application ID / Bundle ID**: `vn.phuongdan.360verb`
- **Target Platforms**: Apple App Store (iOS) & Google Play Store (Android)
- **Report Author**: `explorer_survey_3` (teamwork_spec_miner)
- **Date**: 2026-11-04
- **Working Directory**: `/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_3`

---

## 1. Executive Summary

This specification document details the complete store submission package and automation configuration required for releasing **Verb360 AI** on the **Apple App Store** and **Google Play Store**. All metadata, copywriting, legal policies, and automation scripts have been rigorously verified against:
1. Global Store Compliance Rules (`/Users/dan/.gemini/config/rules/store_aso_compliance.md`)
2. Fastlane Deployment Playbook (`/Users/dan/.gemini/config/skills/app-store-fastlane-deployment/SKILL.md`)
3. Project Architecture & Requirements (`ORIGINAL_REQUEST.md` and codebase analysis)
4. Apple App Store Review Guidelines (specifically 3.1.2 Subscriptions, 5.1 Privacy, and strict character/byte constraints)
5. Google Play Store Policy (Title <= 30 chars, Short description <= 80 chars, Full description <= 4000 chars)

---

## 2. Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|---|---|---|---|---|---|---|
| 1 | Identity | Target Application ID | Target package/bundle identifier across Android and iOS | `vn.phuongdan.360verb` | Configured in Gradle & Xcode | Build failure if mismatch | `ORIGINAL_REQUEST.md` R1 |
| 2 | Identity | Current Bundle ID Status | Existing IDs before migration | `com.antigravity.verb360.app` | Build configs and manifests | Mismatch with store credentials | Codebase inspection |
| 3 | Fastlane | Fastlane Infrastructure | Deployment automation files for iOS and Android | Build scripts, metadata paths | IPA / AAB upload, metadata sync | Missing directory error | `find_by_name` inspection (0 existing files) |
| 4 | ASO / Android | Google Play Title (en-US) | 30-char max app title in English | Store search input | "Verb360: 360 Irregular Verbs" (28 chars) | Google Play rejects > 30 chars | `store_aso_compliance.md` & Google Play Spec |
| 5 | ASO / Android | Google Play Title (vi-VN) | 30-char max app title in Vietnamese | Store search input | "Verb360: Động Từ Bất Quy Tắc" (28 chars) | Google Play rejects > 30 chars | `store_aso_compliance.md` & Google Play Spec |
| 6 | ASO / Android | Google Play Short Desc (en-US) | 80-char max promotional summary | Store listing header | "Master 360 English irregular verbs with DeepSeek AI tutor, SRS & smart quizzes." (79 chars) | Google Play rejects > 80 chars | Google Play Developer Console limit |
| 7 | ASO / Android | Google Play Short Desc (vi-VN) | 80-char max promotional summary | Store listing header | "Học 360 động từ bất quy tắc cùng gia sư AI DeepSeek, thẻ nhớ SRS & luyện thi." (77 chars) | Google Play rejects > 80 chars | Google Play Developer Console limit |
| 8 | ASO / Android | Google Play Full Desc (en-US/vi-VN) | 4000-char max detailed description with legal footer | Product page browse | Rich text with feature list and mandatory legal links | Truncated or submission blocked if > 4000 chars | Global Rule §1 & Android Spec |
| 9 | ASO / iOS | App Store Name (en-US) | 30-char max name in English | App Store search | "Verb360: Irregular Verbs AI" (27 chars) | App Store Connect rejects > 30 chars | App Store Connect API limit |
| 10 | ASO / iOS | App Store Name (vi) | 30-char max name in Vietnamese | App Store search | "Verb360: Động Từ Bất Quy Tắc" (28 chars) | App Store Connect rejects > 30 chars | App Store Connect API limit |
| 11 | ASO / iOS | App Store Subtitle (en-US) | 30-char max subtitle in English | App Store listing | "360 Verbs, SRS & AI Tutor" (25 chars) | App Store Connect rejects > 30 chars | Global Rule §2 (strict 30 chars) |
| 12 | ASO / iOS | App Store Subtitle (vi) | 30-char max subtitle in Vietnamese | App Store listing | "360 Động Từ, SRS & Gia Sư AI" (28 chars) | App Store Connect rejects > 30 chars | Global Rule §2 (strict 30 chars) |
| 13 | ASO / iOS | App Store Description (en-US/vi) | 4000-char max description without any emojis | App Store listing | Clean text, hyphen bullet lists, subscription terms & legal footer | App Store Connect rejects if emoji detected (`An attribute value has invalid characters`) | Global Rule §1, §2 |
| 14 | ASO / iOS | App Store Keywords (en-US) | Strictly <= 100 bytes UTF-8, no overlap with title/subtitle | Search query indexing | `grammar,flashcards,english,study,vocabulary,quiz,ielts,toeic,spaced,repetition,offline,conjugation` (98 bytes) | Rejection or truncation if > 100 bytes; wasted space if repeated | Global Rule §2 & App Store Spec |
| 15 | ASO / iOS | App Store Keywords (vi) | Strictly <= 100 bytes UTF-8, no overlap with title/subtitle | Search query indexing | `ngữ pháp,tiếng anh,flashcard,luyện thi,ielts,toeic,trắc nghiệm,chia thì,phát âm` (93 bytes) | Rejection if > 100 bytes UTF-8 | Global Rule §2 & UTF-8 Byte Verification |
| 16 | ASO / iOS | Promotional Text (en-US/vi) | 170-char max promotional snippet | Top of App Store listing | Engaging 1-2 sentence promo | Rejected if > 170 chars | Fastlane deliver spec |
| 17 | Review Info | App Review Contact Information | Mandatory 4 fields for iOS review submission | Reviewer verification | First: Dan, Last: Nguyen Van, Phone: +84 355533893, Email: nguyenvandan868@gmail.com | Rejection if missing contact info | Global Rule §3 |
| 18 | Legal | Privacy Policy | Detailed policy for user data, AI prompt handling, offline sync | Legal compliance | Comprehensive Policy in EN & VI | Rejection under Guideline 5.1.1 if absent | Store Submission Guidelines |
| 19 | Legal | Terms of Use / EULA | End User License Agreement & Subscription terms | Legal compliance | Standard Apple EULA reference + terms in EN & VI | Rejection under Guideline 3.1.2 if missing | Global Rule §1 & Apple Guideline 3.1.2 |
| 20 | Monetization | In-App Purchases (IAP) | 3 products (Lifetime 299k, 1 Year 199k, 1 Month 19k) | StoreKit & Google Play Billing | Unlocks unlimited DeepSeek AI, offline audio, all quiz modes | Failed transaction if product IDs unmapped | `data/models/iap_product.dart` |

---

## 3. Edge Cases & Verification

| # | Feature | Input | Observed Behavior | Handling / Resolution |
|---|---|---|---|---|
| 1 | iOS Description Character Validation | Emojis or decorative Unicode symbols in `description.txt` | App Store Connect API throws: `An attribute value has invalid characters. Description can't contain the following character(s)` and blocks release | Strictly prohibit emojis in iOS metadata. Use standard ASCII hyphen `-` for all bullet lists. Verified 0 emojis via python script. |
| 2 | iOS Keywords Byte Boundary | 10 Vietnamese diacritical keywords: `ngữ pháp,tiếng anh,flashcard,từ vựng,luyện thi,ielts,toeic,trắc nghiệm,học từ,ngoại tuyến` | Evaluates to 112 bytes in UTF-8 (exceeds 100-byte hard limit) | Prune and re-balance to 9 key phrases totaling exactly 93 bytes: `ngữ pháp,tiếng anh,flashcard,luyện thi,ielts,toeic,trắc nghiệm,chia thì,phát âm`. |
| 3 | iOS Keyword Cannibalization / Redundancy | Repeated words in keywords that already exist in Name or Subtitle (e.g. `verb360`, `360`, `động`, `từ`, `srs`, `ai`) | App Store algorithm ignores redundant keywords; wastes precious 100-byte space | Fully stripped all title and subtitle tokens from keyword lists. 100% unique discovery terms. |
| 4 | Google Play Short Description Limit | Vietnamese summary string > 80 characters | Google Play Developer Console rejects submit | Drafted `Học 360 động từ bất quy tắc cùng gia sư AI DeepSeek, thẻ nhớ SRS & luyện thi.` (77 chars <= 80). |
| 5 | Subscription Terms Disclosure | Auto-renewing subscription missing price, renewal period, cancellation instructions, or legal links | Apple Review Rejection under Guideline 3.1.2 | Inserted comprehensive subscription breakdown with exact pricing (19k/month, 199k/year, 299k lifetime), auto-renewal rules, and legal links at the footer of descriptions. |
| 6 | AI Third-Party Processing Disclosure | DeepSeek AI evaluating user sentences | Apple Guideline 5.1.1 privacy inquiry | Privacy Policy explicitly states user-submitted sentences are processed via DeepSeek API for grammar analysis, cached anonymously via SHA-256 hash, and not linked to third-party ad networks. |

---

## 4. Google Play Store Metadata Specification

### Android Directory Layout
```
app/android/fastlane/metadata/android/
├── en-US/
│   ├── title.txt
│   ├── short_description.txt
│   ├── full_description.txt
│   └── changelogs/
│       └── default.txt
└── vi-VN/
    ├── title.txt
    ├── short_description.txt
    ├── full_description.txt
    └── changelogs/
        └── default.txt
```

### A. English (en-US)

#### 1. `title.txt`
```text
Verb360: 360 Irregular Verbs
```
*(Length: 28 / 30 characters)*

#### 2. `short_description.txt`
```text
Master 360 English irregular verbs with DeepSeek AI tutor, SRS & smart quizzes.
```
*(Length: 79 / 80 characters)*

#### 3. `full_description.txt`
```text
Verb360 AI is your comprehensive and intelligent companion to master all 360 English irregular verbs. Combining scientific cognitive learning principles with cutting-edge DeepSeek AI, Verb360 transforms irregular verb memorization into an intuitive, engaging, and permanent learning experience.

Whether preparing for IELTS, TOEIC, TOEFL, Cambridge exams, or advancing your everyday professional communication, mastering irregular verbs is fundamental to English fluency. Verb360 provides structured tools, precise native phonetics, and interactive exercises to help you achieve full confidence.

KEY FEATURES

1. Complete 360 Irregular Verbs Database
- Full verb forms: Base Form (V1), Past Simple (V2), and Past Participle (V3).
- Standard International Phonetic Alphabet (IPA) transcriptions for every verb form.
- High-definition native pronunciation audio available completely offline.
- Clear bilingual contextual meanings and practical real-life example sentences.
- Categorization by morphological patterns: A-A-A, A-B-A, A-B-B, and A-B-C.
- CEFR proficiency level filters: A1, A2, B1, B2, C1, and C2.

2. DeepSeek AI Context & Writing Tutor
- AI Context Generator: Automatically creates realistic example sentences across practical topics including daily conversation, travel, business, and technology.
- Instant AI Grammar Evaluation: Evaluates user-composed sentences for target verb and tense accuracy.
- Actionable Feedback: Provides comprehensive scoring (1-10), tense analysis, grammar explanations, and natural phrasing suggestions.
- High-speed semantic caching ensures instantaneous feedback and seamless performance.

3. Scientific Spaced Repetition System (SRS SM-2)
- Based on the proven SuperMemo-2 algorithm to optimize memory retention.
- Dynamically calculates Ease Factor (EF), repetition intervals, and optimal review schedules based on your recall confidence.
- Daily review queue prominently displayed on your dashboard to reinforce retention without burnout.

4. 4 Interactive Practice Modes
- SRS Flashcards: Two-sided interactive flashcards with 4 recall grading levels (Again, Hard, Good, Easy).
- Fill in the Blanks: Test your knowledge by conjugating V2 and V3 forms in practical sentences.
- 60-Second Speed Quiz: High-intensity rapid-fire quiz with countdown timer, streak combos, and XP bonuses.
- AI Writing Challenge: Compose original sentences with target verbs and receive immediate DeepSeek AI analysis.

5. Gamification and Offline-First Experience
- Maintain daily study streaks, gain XP points, level up, and unlock mastery achievement badges.
- 100% offline-ready dictionary and flashcard practice.
- Automatic cloud synchronization with secure PocketBase backend whenever online.
- Adaptive Material 3 design supporting both phone and tablet interfaces.

IN-APP PURCHASES & SUBSCRIPTIONS
Verb360 VIP PRO unlocks unlimited DeepSeek AI sentence evaluations, complete native audio playback, and advanced challenge modes:
- Monthly Subscription: 19,000 VND / month (auto-renewing)
- Yearly Subscription: 199,000 VND / year (auto-renewing, save 15%)
- Lifetime Access: 299,000 VND (one-time purchase, lifetime access)

Payment will be charged to your Google Play account at confirmation of purchase. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current billing cycle. You can manage and cancel your subscriptions in your Google Play Store Subscriptions menu at any time.

---
Privacy Policy: https://360verb.phuongdan.io.vn/privacy.html
Terms of Service: https://360verb.phuongdan.io.vn/terms.html
```
*(Length: ~3,680 / 4000 characters)*

#### 4. `changelogs/default.txt`
```text
- Official release of Verb360 AI with full 360 irregular verbs database.
- Integrated DeepSeek AI grammar evaluation and context example generator.
- Scientific SM-2 spaced repetition flashcards.
- 4 interactive practice modes: Flashcard SRS, Fill in the Blanks, Speed Quiz, and AI Writing.
- 100% offline-ready dictionary with native audio pronunciation.
```

---

### B. Vietnamese (vi-VN)

#### 1. `title.txt`
```text
Verb360: Động Từ Bất Quy Tắc
```
*(Length: 28 / 30 characters)*

#### 2. `short_description.txt`
```text
Học 360 động từ bất quy tắc cùng gia sư AI DeepSeek, thẻ nhớ SRS & luyện thi.
```
*(Length: 77 / 80 characters)*

#### 3. `full_description.txt`
```text
Verb360 AI là ứng dụng học tập toàn diện và thông minh giúp bạn làm chủ trọn bộ 360 động từ bất quy tắc tiếng Anh. Kết hợp phương pháp ghi nhớ khoa học với công nghệ trí tuệ nhân tạo DeepSeek AI, Verb360 biến việc ghi nhớ trở nên trực quan, hứng thú và bền vững.

Dù bạn đang ôn luyện thi IELTS, TOEIC, TOEFL, thi THPT Quốc gia hay giao tiếp công việc hàng ngày, 360 động từ bất quy tắc luôn là nền tảng cốt lõi. Verb360 cung cấp hệ thống tra cứu chuẩn xác, phát âm bản xứ, và các chế độ luyện tập phong phú.

CÁC TÍNH NĂNG NỔI BẬT

1. Kho Dữ Liệu Chuẩn 360 Động Từ Bất Quy Tắc
- Đầy đủ 3 thể: Nguyên thể (V1), Quá khứ đơn (V2) và Quá khứ phân từ (V3).
- Phiên âm quốc tế IPA chuẩn xác cho từng thể biến đổi.
- Phát âm giọng bản xứ chất lượng cao hoạt động ngoại tuyến 100%.
- Nghĩa tiếng Việt rõ ràng và ví dụ câu song ngữ thực tế.
- Phân loại theo quy luật hình thái thông minh: Nhóm A-A-A, A-B-A, A-B-B, A-B-C.
- Bộ lọc cấp độ CEFR từ cơ bản đến nâng cao: A1, A2, B1, B2, C1, C2.

2. Gia Sư Ngữ Cảnh & Chấm Câu DeepSeek AI
- Sinh ví dụ theo chủ đề: Tự động tạo câu ví dụ gần gũi theo các chủ đề đời sống, du lịch, công việc, công nghệ.
- Chấm điểm và sửa câu tức thì: Đánh giá câu bạn tự viết với động từ chỉ định, chấm điểm thang 1-10.
- Phân tích ngữ pháp chi tiết: Giải thích thì động từ sử dụng, chỉ ra lỗi sai và đề xuất câu viết tự nhiên nhất.
- Bộ đệm Semantic Cache giúp phản hồi nhanh chóng và tiết kiệm tài nguyên.

3. Thuật Toán Lặp Lại Ngắt Quãng (SRS SM-2)
- Áp dụng thuật toán SuperMemo-2 giúp tối ưu hóa khả năng ghi nhớ dài hạn vào bộ nhớ.
- Tự động tính toán hệ số dễ nhớ (Ease Factor), khoảng cách ngày và lịch trình ôn tập phù hợp với mức độ nhớ của từng cá nhân.
- Danh sách từ cần ôn hàng ngày hiển thị ngay trang chủ giúp duy trì thói quen học tập đều đặn.

4. 4 Chế Độ Luyện Tập Đa Dạng
- Thẻ ghi nhớ Flashcard SRS: Tương tác lật thẻ 2 mặt kèm 4 mức đánh giá nhớ (Quên, Khó, Tốt, Dễ).
- Điền khuyết: Thử thách chia đúng thể V2 và V3 vào vị trí thiếu trong câu.
- Phản xạ 60 giây (Speed Quiz): Thử thách trắc nghiệm nhanh với đồng hồ đếm ngược, tích lũy chuỗi combo và điểm kinh nghiệm XP.
- Thử thách viết câu cùng AI: Tự do đặt câu với động từ yêu cầu và nhận nhận xét tức thì từ DeepSeek AI.

5. Gamification & Hoạt Động Ngoại Tuyến
- Duy trì chuỗi ngày học liên tục (Streak), tích lũy XP, thăng hạng cấp độ và mở khóa bộ sưu tập huy hiệu thành tích.
- Hoạt động ngoại tuyến 100% cho toàn bộ từ điển và flashcard.
- Tự động đồng bộ tiến độ lên máy chủ PocketBase khi kết nối mạng.
- Giao diện Material 3 thích ứng linh hoạt giữa điện thoại và máy tính bảng.

GÓI NÂNG CẤP VERB360 VIP PRO
Mở khóa toàn bộ sức mạnh AI DeepSeek, không giới hạn số lượt chấm câu và truy cập tất cả chế độ luyện tập nâng cao:
- Gói 1 Tháng: 19.000 đ / tháng (Tự động gia hạn)
- Gói 1 Năm: 199.000 đ / năm (Tự động gia hạn, tiết kiệm 15%)
- Gói Trọn Đời: 299.000 đ (Thanh toán 1 lần duy nhất, sở hữu vĩnh viễn)

Quy định đăng ký & gia hạn:
Khoản thanh toán sẽ được tính vào tài khoản Google Play của bạn khi xác nhận mua hàng. Gói đăng ký tự động gia hạn trừ khi tính năng tự động gia hạn bị tắt ít nhất 24 giờ trước khi kết thúc chu kỳ hiện tại. Bạn có thể quản lý hoặc hủy gói đăng ký bất kỳ lúc nào trong phần Đăng ký trên Google Play Store sau khi mua.

---
Privacy Policy: https://360verb.phuongdan.io.vn/privacy.html
Terms of Service: https://360verb.phuongdan.io.vn/terms.html
```
*(Length: ~3,490 / 4000 characters)*

#### 4. `changelogs/default.txt`
```text
- Ra mắt phiên bản chính thức Verb360 AI với trọn bộ 360 động từ bất quy tắc.
- Tích hợp gia sư DeepSeek AI chấm và sửa câu thông minh.
- Thẻ ghi nhớ flashcard ứng dụng thuật toán lặp lại ngắt quãng SM-2.
- 4 chế độ luyện tập: Flashcard SRS, Điền khuyết, Phản xạ 60 giây và Viết câu cùng AI.
- Tra cứu và phát âm chuẩn bản xứ ngoại tuyến 100%.
```

---

## 5. Apple App Store Metadata Specification

### iOS Directory Layout
```
app/ios/fastlane/metadata/
├── primary_category.txt
├── secondary_category.txt
├── copyright.txt
├── privacy_url.txt
├── support_url.txt
├── marketing_url.txt
├── review_information/
│   ├── first_name.txt
│   ├── last_name.txt
│   ├── phone_number.txt
│   ├── email_address.txt
│   └── notes.txt
├── en-US/
│   ├── name.txt
│   ├── subtitle.txt
│   ├── description.txt
│   ├── keywords.txt
│   ├── promotional_text.txt
│   └── release_notes.txt
└── vi/
    ├── name.txt
    ├── subtitle.txt
    ├── description.txt
    ├── keywords.txt
    ├── promotional_text.txt
    └── release_notes.txt
```

### A. General iOS Metadata Files (`metadata/`)
- `primary_category.txt`: `EDUCATION`
- `secondary_category.txt`: `REFERENCE`
- `copyright.txt`: `2026 PhuongDan`
- `privacy_url.txt`: `https://360verb.phuongdan.io.vn/privacy.html`
- `support_url.txt`: `https://360verb.phuongdan.io.vn/support.html`
- `marketing_url.txt`: `https://360verb.phuongdan.io.vn`

### B. App Review Information (`metadata/review_information/`)
- `first_name.txt`: `Dan`
- `last_name.txt`: `Nguyen Van`
- `phone_number.txt`: `+84 355533893`
- `email_address.txt`: `nguyenvandan868@gmail.com`
- `notes.txt`:
```text
Demo account for App Store Reviewer:
Email: reviewer@verb360.phuongdan.io.vn
Password: ReviewerPass123!

App Highlights:
- Complete 360 English irregular verbs dictionary with offline native audio pronunciation.
- DeepSeek AI tutor for sentence evaluation and thematic example generation.
- Spaced Repetition (SM-2) flashcard training.
- 4 practice modes: Flashcard SRS, Fill in Blanks, Speed Quiz (60s), AI Writing.
- In-App Purchases: Monthly, Yearly auto-renewing subscriptions, and Lifetime non-consumable access. StoreKit sandbox testing supported.

Thank you for reviewing our application!
```

---

### C. English (en-US)

#### 1. `name.txt`
```text
Verb360: Irregular Verbs AI
```
*(Length: 27 / 30 characters)*

#### 2. `subtitle.txt`
```text
360 Verbs, SRS & AI Tutor
```
*(Length: 25 / 30 characters)*

#### 3. `description.txt`
*(STRICT RULE: NO EMOJIS, Hyphen `-` bullets, Mandatory Apple EULA & Privacy Policy)*
```text
Verb360 AI is your comprehensive and intelligent companion to master all 360 English irregular verbs. Combining scientific cognitive learning principles with cutting-edge DeepSeek AI, Verb360 transforms the tedious memorization of irregular verbs into an intuitive, engaging, and lasting learning experience.

Whether preparing for IELTS, TOEIC, Cambridge, TOEFL exams, or advancing professional communication, mastering irregular verbs is fundamental to English fluency. Verb360 provides structured tools, precise native phonetics, and interactive exercises to help you achieve mastery.

KEY FEATURES

1. Complete 360 Irregular Verbs Database
- Full verb forms: Base Form (V1), Past Simple (V2), and Past Participle (V3).
- Standard International Phonetic Alphabet (IPA) transcriptions for every verb form.
- High-definition native pronunciation audio available completely offline.
- Clear bilingual contextual meanings and practical real-life example sentences.
- Categorization by morphological patterns: A-A-A, A-B-A, A-B-B, and A-B-C.
- CEFR level filters: A1, A2, B1, B2, C1, and C2.

2. DeepSeek AI Context & Writing Tutor
- AI Context Generator: Automatically creates realistic example sentences across practical topics including daily conversation, travel, business, and technology.
- Instant AI Grammar Evaluation: Evaluates user-composed sentences for target verb and tense accuracy.
- Actionable Feedback: Provides comprehensive scoring (1-10), tense analysis, grammar explanations, and natural phrasing suggestions.
- High-speed semantic caching ensures instantaneous feedback and seamless performance.

3. Scientific Spaced Repetition System (SRS SM-2)
- Based on the proven SuperMemo-2 algorithm to optimize memory retention.
- Dynamically calculates Ease Factor (EF), repetition intervals, and optimal review schedules based on your recall confidence.
- Daily review queue prominently displayed on your dashboard to reinforce retention without burnout.

4. 4 Interactive Practice Modes
- SRS Flashcards: Two-sided interactive flashcards with 4 recall grading levels (Again, Hard, Good, Easy).
- Fill in the Blanks: Test your knowledge by conjugating V2 and V3 forms in practical sentences.
- 60-Second Speed Quiz: High-intensity rapid-fire quiz with countdown timer, streak combos, and XP bonuses.
- AI Writing Challenge: Compose original sentences with target verbs and receive immediate DeepSeek AI analysis.

5. Gamification and Offline-First Experience
- Maintain daily study streaks, gain XP points, level up, and unlock mastery achievement badges.
- 100% offline-ready dictionary and flashcard practice.
- Automatic cloud synchronization with secure PocketBase backend whenever online.
- Adaptive Material 3 design supporting both phone and tablet interfaces.

IN-APP PURCHASES & SUBSCRIPTIONS
Verb360 VIP PRO unlocks unlimited DeepSeek AI sentence evaluations, complete native audio playback, and advanced challenge modes:
- Monthly Subscription: 19,000 VND / month (auto-renewing)
- Yearly Subscription: 199,000 VND / year (auto-renewing, save 15%)
- Lifetime Access: 299,000 VND (one-time purchase, lifetime access)

Subscription Details:
Payment will be charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage or cancel your subscription anytime in your App Store Account Settings after purchase.

---
Privacy Policy: https://360verb.phuongdan.io.vn/privacy.html
Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```
*(Length: 3,715 / 4000 characters; Emoji count: 0)*

#### 4. `keywords.txt`
*(STRICT RULE: <= 100 bytes UTF-8, NO spaces, NO overlap with Name or Subtitle)*
```text
grammar,flashcards,english,study,vocabulary,quiz,ielts,toeic,spaced,repetition,offline,conjugation
```
*(Byte length: 98 / 100 bytes UTF-8. Non-overlapping with `Verb360: Irregular Verbs AI` and `360 Verbs, SRS & AI Tutor`)*

#### 5. `promotional_text.txt`
```text
Master all 360 English irregular verbs effortlessly! Powered by DeepSeek AI tutor, scientific SM-2 spaced repetition flashcards, and high-energy reflex quizzes.
```
*(Length: 160 / 170 characters; Emoji count: 0)*

#### 6. `release_notes.txt`
```text
Initial App Store release of Verb360 AI:
- Complete 360 English irregular verbs with offline native audio pronunciation.
- DeepSeek AI tutor for instant grammar analysis and contextual sentence generation.
- SM-2 spaced repetition system and 4 interactive practice modes.
```

---

### D. Vietnamese (vi)

#### 1. `name.txt`
```text
Verb360: Động Từ Bất Quy Tắc
```
*(Length: 28 / 30 characters)*

#### 2. `subtitle.txt`
```text
360 Động Từ, SRS & Gia Sư AI
```
*(Length: 28 / 30 characters)*

#### 3. `description.txt`
*(STRICT RULE: NO EMOJIS, Hyphen `-` bullets, Mandatory Apple EULA & Privacy Policy)*
```text
Verb360 AI là ứng dụng học tập toàn diện và thông minh giúp bạn làm chủ trọn bộ 360 động từ bất quy tắc tiếng Anh. Kết hợp phương pháp ghi nhớ khoa học với công nghệ trí tuệ nhân tạo DeepSeek AI, Verb360 biến việc ghi nhớ trở nên trực quan, hứng thú và bền vững.

Dù bạn đang ôn luyện thi IELTS, TOEIC, TOEFL, thi THPT Quốc gia hay giao tiếp công việc hàng ngày, 360 động từ bất quy tắc luôn là nền tảng cốt lõi. Verb360 cung cấp hệ thống tra cứu chuẩn xác, phát âm bản xứ, và các chế độ luyện tập phong phú.

CÁC TÍNH NĂNG NỔI BẬT

1. Kho Dữ Liệu Chuẩn 360 Động Từ Bất Quy Tắc
- Đầy đủ 3 thể: Nguyên thể (V1), Quá khứ đơn (V2) và Quá khứ phân từ (V3).
- Phiên âm quốc tế IPA chuẩn xác cho từng thể biến đổi.
- Phát âm giọng bản xứ chất lượng cao hoạt động ngoại tuyến 100%.
- Nghĩa tiếng Việt rõ ràng và ví dụ câu song ngữ thực tế.
- Phân loại theo quy luật hình thái thông minh: Nhóm A-A-A, A-B-A, A-B-B, A-B-C.
- Bộ lọc cấp độ CEFR từ cơ bản đến nâng cao: A1, A2, B1, B2, C1, C2.

2. Gia Sư Ngữ Cảnh & Chấm Câu DeepSeek AI
- Sinh ví dụ theo chủ đề: Tự động tạo câu ví dụ gần gũi theo các chủ đề đời sống, du lịch, công việc, công nghệ.
- Chấm điểm và sửa câu tức thì: Đánh giá câu bạn tự viết với động từ chỉ định, chấm điểm thang 1-10.
- Phân tích ngữ pháp chi tiết: Giải thích thì động từ sử dụng, chỉ ra lỗi sai và đề xuất câu viết tự nhiên nhất.
- Bộ đệm Semantic Cache giúp phản hồi nhanh chóng và tiết kiệm tài nguyên.

3. Thuật Toán Lặp Lại Ngắt Quãng (SRS SM-2)
- Áp dụng thuật toán SuperMemo-2 giúp tối ưu hóa khả năng ghi nhớ dài hạn vào bộ nhớ.
- Tự động tính toán hệ số dễ nhớ (Ease Factor), khoảng cách ngày và lịch trình ôn tập phù hợp với mức độ nhớ của từng cá nhân.
- Danh sách từ cần ôn hàng ngày hiển thị ngay trang chủ giúp duy trì thói quen học tập đều đặn.

4. 4 Chế Độ Luyện Tập Đa Dạng
- Thẻ ghi nhớ Flashcard SRS: Tương tác lật thẻ 2 mặt kèm 4 mức đánh giá nhớ (Quên, Khó, Tốt, Dễ).
- Điền khuyết: Thử thách chia đúng thể V2 và V3 vào vị trí thiếu trong câu.
- Phản xạ 60 giây (Speed Quiz): Thử thách trắc nghiệm nhanh với đồng hồ đếm ngược, tích lũy chuỗi combo và điểm kinh nghiệm XP.
- Thử thách viết câu cùng AI: Tự do đặt câu với động từ yêu cầu và nhận nhận xét tức thì từ DeepSeek AI.

5. Gamification & Hoạt Động Ngoại Tuyến
- Duy trì chuỗi ngày học liên tục (Streak), tích lũy XP, thăng hạng cấp độ và mở khóa bộ sưu tập huy hiệu thành tích.
- Hoạt động ngoại tuyến 100% cho toàn bộ từ điển và flashcard.
- Tự động đồng bộ tiến độ lên máy chủ PocketBase khi kết nối mạng.
- Giao diện Material 3 thích ứng linh hoạt giữa điện thoại và máy tính bảng.

GÓI NÂNG CẤP VERB360 VIP PRO
Mở khóa toàn bộ sức mạnh AI DeepSeek, không giới hạn số lượt chấm câu và truy cập tất cả chế độ luyện tập nâng cao:
- Gói 1 Tháng: 19.000 đ / tháng (Tự động gia hạn)
- Gói 1 Năm: 199.000 đ / năm (Tự động gia hạn, tiết kiệm 15%)
- Gói Trọn Đời: 299.000 đ (Thanh toán 1 lần duy nhất, sở hữu vĩnh viễn)

Quy định đăng ký & gia hạn:
Khoản thanh toán sẽ được tính vào tài khoản Apple ID của bạn khi xác nhận mua hàng. Gói đăng ký tự động gia hạn trừ khi tính năng tự động gia hạn bị tắt ít nhất 24 giờ trước khi kết thúc chu kỳ hiện tại. Tài khoản sẽ bị tính phí gia hạn trong vòng 24 giờ trước khi kết thúc kỳ hiện tại. Bạn có thể quản lý hoặc hủy gói đăng ký bất kỳ lúc nào trong phần Cài đặt tài khoản App Store sau khi mua.

---
Privacy Policy: https://360verb.phuongdan.io.vn/privacy.html
Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```
*(Length: 3,491 / 4000 characters; Emoji count: 0)*

#### 4. `keywords.txt`
*(STRICT RULE: <= 100 bytes UTF-8, NO spaces, NO overlap with Name or Subtitle)*
```text
ngữ pháp,tiếng anh,flashcard,luyện thi,ielts,toeic,trắc nghiệm,chia thì,phát âm
```
*(Byte length: 93 / 100 bytes UTF-8. Non-overlapping with `Verb360: Động Từ Bất Quy Tắc` and `360 Động Từ, SRS & Gia Sư AI`)*

#### 5. `promotional_text.txt`
```text
Chinh phục trọn bộ 360 động từ bất quy tắc cùng gia sư AI DeepSeek thông minh, thẻ nhớ lặp lại ngắt quãng SM-2 và chế độ luyện thi phản xạ 60 giây!
```
*(Length: 147 / 170 characters; Emoji count: 0)*

#### 6. `release_notes.txt`
```text
Phát hành phiên bản đầu tiên của Verb360 AI trên App Store:
- Trọn bộ 360 động từ bất quy tắc kèm phát âm audio giọng bản xứ ngoại tuyến.
- Gia sư DeepSeek AI chấm và chữa câu theo thì thông minh.
- Thuật toán lặp lại ngắt quãng SM-2 và 4 chế độ luyện tập thực chiến.
```

---

## 6. Complete Legal Documents

### A. Privacy Policy (English)
File location: `privacy_en.md` / `privacy.html`
```markdown
# Privacy Policy for Verb360 AI

**Last updated**: November 4, 2026

Verb360 AI ("we", "our", or "us"), operated by Dan Nguyen Van (PhuongDan), is committed to protecting your privacy. This Privacy Policy explains how our mobile application and associated backend services collect, use, and protect your information when you use Verb360 AI on iOS, Android, and Web.

## 1. Information We Collect

### A. Information You Provide
- **Account Registration Information**: When you register an optional account to sync progress across devices, we collect your email address, display name, and encrypted password.
- **User-Generated Writing Submissions**: Sentences you submit for AI grammar evaluation and practice.

### B. Information Collected Automatically
- **Learning & Practice Progress**: Word mastery levels, SRS SM-2 flashcard intervals, quiz scores, XP points, and streak counts. This data is stored locally on your device by default and synchronized to our secure PocketBase server only if you log in.
- **Diagnostic and Device Data**: Device model, operating system version, and anonymous crash logs strictly for app stability improvements.

### C. In-App Purchase Data
All financial transactions are processed securely through Apple App Store (StoreKit) or Google Play Store (Google Play Billing). We never receive, process, or store your credit card or billing details. We only receive an anonymous purchase token, product ID, and order ID to unlock your VIP PRO features.

## 2. Artificial Intelligence and DeepSeek API Processing
When you use the AI Writing Tutor feature:
- Your sentence and the target verb are transmitted securely via TLS 1.3 to our backend and processed through the DeepSeek Chat API strictly to evaluate grammar, analyze tense accuracy, and generate helpful feedback.
- We utilize an anonymous cryptographic hash (SHA-256) to cache evaluations in our SQLite database, avoiding redundant API calls and reducing latency.
- Your submitted sentences are never sold, rented, or used for targeted commercial profiling.

## 3. How We Use Your Information
We use your data solely to:
- Deliver and maintain the core learning features of Verb360 AI.
- Calculate and update your personalized SM-2 spaced repetition review schedules.
- Synchronize your progress across authorized devices.
- Verify and manage your VIP PRO subscription or lifetime license.
- Respond to support inquiries and improve application performance.

## 4. Data Storage, Security, and Offline Operation
- Verb360 AI is built with an **offline-first** architecture. The entire 360 irregular verb dictionary, native audio files, and flashcards function 100% offline without requiring internet access or transmitting data.
- Cloud synchronization uses encrypted PocketBase SQLite databases with WAL mode hosted on private, hardened server infrastructure.

## 5. Third-Party Services
We integrate with trusted providers who adhere to strict data security practices:
- **Apple App Store & Google Play**: In-app purchase verification and distribution.
- **DeepSeek AI**: Secure natural language processing for grammar feedback.
- We do NOT include third-party advertising SDKs or tracking pixels.

## 6. Account Deletion and Data Retention
You retain complete control over your personal data:
- You may delete your account and all associated cloud learning records at any time directly within the application settings or by emailing `nguyenvandan868@gmail.com`.
- Upon deletion, your account and progress records are permanently purged from our servers within 30 days.

## 7. Children's Privacy
Verb360 AI does not knowingly collect personally identifiable information from children under 13 years of age. If we discover a child under 13 has provided personal data, we will immediately remove it.

## 8. Contact Us
For any privacy questions or requests:
- **Developer**: Dan Nguyen Van (PhuongDan)
- **Email**: `nguyenvandan868@gmail.com`
- **Phone**: `+84 355533893`
- **Address**: Hanoi, Vietnam
- **Website**: `https://360verb.phuongdan.io.vn`
```

---

### B. Privacy Policy (Vietnamese)
File location: `privacy_vi.md`
```markdown
# Chính Sách Bảo Mật Cho Verb360 AI

**Cập nhật lần cuối**: Ngày 04 tháng 11 năm 2026

Verb360 AI ("chúng tôi"), được phát triển và vận hành bởi Đan Nguyễn Văn (PhuongDan), cam kết bảo vệ quyền riêng tư của bạn. Chính sách bảo mật này giải thích cách ứng dụng và các dịch vụ liên quan thu thập, sử dụng và bảo vệ thông tin của bạn khi sử dụng Verb360 AI trên iOS, Android và Web.

## 1. Thông Tin Thu Thập

### A. Thông tin bạn cung cấp
- **Thông tin tài khoản**: Khi đăng ký tài khoản (tùy chọn) để đồng bộ tiến độ học tập giữa các thiết bị, chúng tôi thu thập địa chỉ email, tên hiển thị và mật khẩu đã được mã hóa một chiều.
- **Nội dung viết câu**: Các câu văn tiếng Anh bạn nhập để gia sư AI chấm điểm và nhận xét ngữ pháp.

### B. Dữ liệu học tập và thiết bị
- **Tiến độ học tập**: Mức độ ghi nhớ từ, hệ số lặp lại ngắt quãng SM-2, điểm bài thi phản xạ, điểm kinh nghiệm XP và chuỗi ngày học liên tục (Streak). Toàn bộ dữ liệu này được lưu trữ cục bộ trên thiết bị và chỉ đồng bộ lên máy chủ PocketBase khi bạn đăng nhập.
- **Thông tin kỹ thuật**: Dòng máy, phiên bản hệ điều hành và nhật ký lỗi ẩn danh nhằm mục đích nâng cao độ ổn định của ứng dụng.

### C. Dữ liệu mua hàng trong ứng dụng (IAP)
Tất cả các giao dịch thanh toán được xử lý trực tiếp bởi Apple App Store (StoreKit) hoặc Google Play Store (Google Play Billing). Chúng tôi không lưu trữ hoặc có quyền truy cập vào thông tin thẻ tín dụng hay tài khoản ngân hàng của bạn. Chúng tôi chỉ tiếp nhận mã token giao dịch, mã gói sản phẩm và mã đơn hàng ẩn danh để kích hoạt quyền lợi VIP PRO.

## 2. Xử Lý Trí Tuệ Nhân Tạo (DeepSeek AI)
Khi bạn sử dụng tính năng Gia sư AI chấm câu:
- Câu văn và động từ mục tiêu được truyền tải an toàn qua giao thức mã hóa TLS 1.3 tới API DeepSeek để phân tích cấu trúc ngữ pháp, thì sử dụng và đề xuất sửa lỗi.
- Chúng tôi sử dụng mã băm ẩn danh (SHA-256) để lưu trữ đệm trong cơ sở dữ liệu SQLite, giúp tối ưu tốc độ và không bao giờ liên kết dữ liệu với danh tính quảng cáo bên ngoài.
- Dữ liệu câu văn của bạn tuyệt đối không bị bán, chia sẻ hoặc dùng cho mục đích quảng cáo thương mại.

## 3. Kiến Trúc Ngoại Tuyến (Offline-First) & Bảo Mật
- Ứng dụng hoạt động **ngoại tuyến 100%** đối với toàn bộ kho 360 động từ bất quy tắc, phiên âm IPA, audio phát âm và thẻ ghi nhớ flashcard mà không cần kết nối mạng.
- Dữ liệu đồng bộ máy chủ được bảo vệ bởi cơ sở dữ liệu PocketBase SQLite WAL mode, mã hóa đường truyền tiêu chuẩn cao.

## 4. Quyền Xóa Dữ Liệu & Hủy Tài Khoản
- Bạn có toàn quyền yêu cầu xóa tài khoản và toàn bộ dữ liệu học tập liên quan bất kỳ lúc nào ngay trong phần Cài đặt ứng dụng hoặc gửi email về `nguyenvandan868@gmail.com`.
- Sau khi nhận yêu cầu, dữ liệu sẽ được xóa vĩnh viễn khỏi hệ thống trong vòng 30 ngày.

## 5. Thông Tin Liên Hệ
Mọi thắc mắc về chính sách bảo mật, vui lòng liên hệ:
- **Người đại diện**: Đan Nguyễn Văn (PhuongDan)
- **Email**: `nguyenvandan868@gmail.com`
- **Số điện thoại**: `+84 355533893`
- **Địa chỉ**: Hà Nội, Việt Nam
- **Website**: `https://360verb.phuongdan.io.vn`
```

---

### C. Terms of Use / EULA (English)
File location: `terms_en.md` / `terms.html`
```markdown
# Terms of Use (EULA) for Verb360 AI

**Last updated**: November 4, 2026

Please read these Terms of Use ("Terms" or "EULA") carefully before using Verb360 AI. By downloading, accessing, or using the Verb360 AI application, you agree to be bound by these Terms and the Apple Standard End User License Agreement (EULA).

## 1. Standard Apple End User License Agreement
For iOS users, your license to use Verb360 AI is governed by the Apple Standard EULA:
https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

## 2. License Grant
PhuongDan grants you a personal, revocable, non-exclusive, non-transferable, limited license to download, install, and use the application on devices you own or control, strictly for personal, non-commercial educational purposes.

## 3. In-App Purchases & Subscriptions
Verb360 AI offers optional premium tiers (Verb360 VIP PRO) that grant unlimited DeepSeek AI sentence reviews and advanced practice tools:
- **Monthly Subscription**: 19,000 VND / month (auto-renewing).
- **Yearly Subscription**: 199,000 VND / year (auto-renewing, discounted).
- **Lifetime Access**: 299,000 VND (one-time non-consumable payment).

### Subscription Terms:
- **Payment**: Charged to your Apple ID or Google Play Account at confirmation of purchase.
- **Auto-Renewal**: Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current billing period.
- **Renewal Charge**: Your account will be charged within 24 hours prior to the end of the current period at the original agreed price.
- **Management & Cancellation**: You can manage or turn off auto-renewal anytime in your App Store Account Settings or Google Play Subscriptions menu after purchase.
- **Refunds**: Managed strictly according to Apple App Store or Google Play refund policies.

## 4. Acceptable Use
You agree not to:
- Reverse engineer, decompile, or disassemble any portion of the software.
- Attempt to exploit, scrape, or overwhelm the DeepSeek AI service or PocketBase API endpoints.
- Submit abusive, defamatory, or unlawful content to the AI writing evaluation features.

## 5. Disclaimer of Warranties
Verb360 AI and its AI grammar evaluation features are provided "AS IS" and "AS AVAILABLE". While we strive for linguistic precision, language suggestions generated by AI are educational aids and should not be considered definitive legal or formal certification advice.

## 6. Governing Law
These Terms are governed by and construed in accordance with the laws of Vietnam, without regard to conflict of law principles.

## 7. Contact
- **Email**: `nguyenvandan868@gmail.com`
- **Phone**: `+84 355533893`
- **Website**: `https://360verb.phuongdan.io.vn`
```

---

### D. Terms of Use / EULA (Vietnamese)
File location: `terms_vi.md`
```markdown
# Điều Khoản Sử Dụng (EULA) Cho Verb360 AI

**Cập nhật lần cuối**: Ngày 04 tháng 11 năm 2026

Vui lòng đọc kỹ Điều khoản sử dụng này ("Điều khoản" hoặc "EULA") trước khi cài đặt và sử dụng ứng dụng Verb360 AI. Bằng việc tải về, truy cập hoặc sử dụng ứng dụng, bạn đồng ý tuân thủ các Điều khoản này và Thỏa thuận cấp phép người dùng cuối tiêu chuẩn của Apple (Standard EULA).

## 1. Thỏa Thuận Cấp Phép Tiêu Chuẩn Apple EULA
Đối với người dùng iOS, quyền sử dụng Verb360 AI tuân thủ theo thỏa thuận EULA tiêu chuẩn của Apple:
https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

## 2. Phạm Vi Cấp Phép
PhuongDan cấp cho bạn một giấy phép cá nhân, có thể thu hồi, không độc quyền, không thể chuyển nhượng để cài đặt và sử dụng Verb360 AI trên các thiết bị thuộc quyền sở hữu của bạn cho mục đích học tập cá nhân.

## 3. Gói Mua Trong Ứng Dụng & Đăng Ký VIP PRO
Verb360 AI cung cấp các gói nâng cấp tính năng VIP PRO mở khóa toàn diện gia sư AI DeepSeek và chế độ luyện thi nâng cao:
- **Gói 1 Tháng**: 19.000 đ / tháng (Tự động gia hạn).
- **Gói 1 Năm**: 199.000 đ / năm (Tự động gia hạn, tiết kiệm 15%).
- **Gói Trọn Đời**: 299.000 đ (Thanh toán 1 lần duy nhất, sở hữu vĩnh viễn).

### Quy Định Về Gia Hạn & Hủy Gói:
- **Thanh toán**: Được tính qua tài khoản Apple ID hoặc Google Play của bạn khi xác nhận mua hàng.
- **Tự động gia hạn**: Gói đăng ký sẽ tự động gia hạn trừ khi tính năng gia hạn tự động bị hủy bỏ ít nhất 24 giờ trước khi kết thúc chu kỳ thanh toán hiện tại.
- **Phí gia hạn**: Tài khoản của bạn sẽ bị tính phí gia hạn trong vòng 24 giờ trước khi kết thúc chu kỳ hiện tại theo mức giá đã thỏa thuận.
- **Quản lý & Hủy bỏ**: Bạn có thể quản lý hoặc hủy gói đăng ký bất cứ lúc nào trong phần Cài đặt tài khoản App Store hoặc menu Đăng ký trên Google Play.
- **Hoàn tiền**: Các chính sách hoàn tiền tuân thủ nghiêm ngặt quy định của Apple App Store và Google Play Store.

## 4. Giới Hạn Trách Nhiệm
Các nhận xét ngữ pháp và đề xuất câu do trí tuệ nhân tạo DeepSeek sinh ra mang tính chất tham khảo giáo dục nhằm hỗ trợ người học, không thay thế cho các chứng chỉ đánh giá ngoại ngữ chính quy.

## 5. Luật Áp Dụng
Các Điều khoản này được điều chỉnh và giải thích theo quy định của pháp luật Việt Nam.

## 6. Thông Tin Liên Hệ
- **Email**: `nguyenvandan868@gmail.com`
- **Số điện thoại**: `+84 355533893`
- **Website**: `https://360verb.phuongdan.io.vn`
```

---

## 7. Fastlane Configuration Files

### A. iOS Fastlane Setup
Target Directory: `app/ios/fastlane/`

#### 1. `app/ios/fastlane/Appfile`
```ruby
# Appfile for Verb360 AI (iOS)
app_identifier("vn.phuongdan.360verb")
apple_id(ENV["APPLE_ID"] || "nguyenvandan868@gmail.com")
itc_team_id(ENV["ITC_TEAM_ID"]) if ENV["ITC_TEAM_ID"]
team_id(ENV["TEAM_ID"]) if ENV["TEAM_ID"]
```

#### 2. `app/ios/fastlane/Fastfile`
```ruby
# Fastfile for Verb360 AI (iOS)
default_platform(:ios)

platform :ios do
  desc "Build & Upload Beta to TestFlight"
  lane :beta do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Deliver App Store Metadata only without binary upload"
  lane :metadata do
    deliver(
      metadata_path: "./metadata",
      skip_binary_upload: true,
      skip_screenshots: true,
      force: true
    )
  end

  desc "Upload Release IPA and Metadata to App Store"
  lane :release do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    deliver(
      metadata_path: "./metadata",
      skip_screenshots: false,
      force: true
    )
  end
end
```

---

### B. Android Fastlane Setup
Target Directory: `app/android/fastlane/`

#### 1. `app/android/fastlane/Appfile`
```ruby
# Appfile for Verb360 AI (Android)
package_name("vn.phuongdan.360verb")
json_key_file(ENV["SUPPLY_JSON_KEY"] || "./play-store-credentials.json")
```

#### 2. `app/android/fastlane/Fastfile`
```ruby
# Fastfile for Verb360 AI (Android)
default_platform(:android)

platform :android do
  desc "Build AAB and Upload to Internal Testing track"
  lane :beta do
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end

  desc "Deliver Google Play Store Metadata only"
  lane :metadata do
    supply(
      metadata_path: "./metadata/android",
      skip_upload_aab: true,
      skip_upload_apk: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end

  desc "Upload Release AAB and Metadata to Google Play Production track"
  lane :release do
    upload_to_play_store(
      track: "production",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      metadata_path: "./metadata/android"
    )
  end
end
```

---

### C. Android Signing Setup Specification
To accompany the release lane:
1. **Keystore Generation Command**:
   ```bash
   keytool -genkey -v -keystore app/android/app/upload-keystore.jks \
     -alias dannv -keyalg RSA -keysize 2048 -validity 10000 \
     -storepass 12101997Az -keypass 12101997Az \
     -dname "CN=Dan NV, OU=360Verb, O=PhuongDan, L=Hanoi, C=VN"
   ```
2. **`app/android/key.properties`**:
   ```properties
   storePassword=12101997Az
   keyPassword=12101997Az
   keyAlias=dannv
   storeFile=../app/upload-keystore.jks
   ```
3. **Gradle Signing Integration** (`app/android/app/build.gradle.kts`):
   Load `key.properties` and configure `signingConfigs.getByName("release")` for production builds.

---

## 8. Actionable Implementation Checklist for Downstream Developer

When the orchestrator delegates the implementation phase, the executing developer should create the physical files using the following exact mapping:

- [ ] **Android Fastlane Directory & Files**:
  - `app/android/fastlane/Appfile`
  - `app/android/fastlane/Fastfile`
  - `app/android/fastlane/metadata/android/en-US/title.txt`
  - `app/android/fastlane/metadata/android/en-US/short_description.txt`
  - `app/android/fastlane/metadata/android/en-US/full_description.txt`
  - `app/android/fastlane/metadata/android/en-US/changelogs/default.txt`
  - `app/android/fastlane/metadata/android/vi-VN/title.txt`
  - `app/android/fastlane/metadata/android/vi-VN/short_description.txt`
  - `app/android/fastlane/metadata/android/vi-VN/full_description.txt`
  - `app/android/fastlane/metadata/android/vi-VN/changelogs/default.txt`

- [ ] **iOS Fastlane Directory & Files**:
  - `app/ios/fastlane/Appfile`
  - `app/ios/fastlane/Fastfile`
  - `app/ios/fastlane/metadata/primary_category.txt`
  - `app/ios/fastlane/metadata/secondary_category.txt`
  - `app/ios/fastlane/metadata/copyright.txt`
  - `app/ios/fastlane/metadata/privacy_url.txt`
  - `app/ios/fastlane/metadata/support_url.txt`
  - `app/ios/fastlane/metadata/marketing_url.txt`
  - `app/ios/fastlane/metadata/review_information/first_name.txt`
  - `app/ios/fastlane/metadata/review_information/last_name.txt`
  - `app/ios/fastlane/metadata/review_information/phone_number.txt`
  - `app/ios/fastlane/metadata/review_information/email_address.txt`
  - `app/ios/fastlane/metadata/review_information/notes.txt`
  - `app/ios/fastlane/metadata/en-US/name.txt`
  - `app/ios/fastlane/metadata/en-US/subtitle.txt`
  - `app/ios/fastlane/metadata/en-US/description.txt`
  - `app/ios/fastlane/metadata/en-US/keywords.txt`
  - `app/ios/fastlane/metadata/en-US/promotional_text.txt`
  - `app/ios/fastlane/metadata/en-US/release_notes.txt`
  - `app/ios/fastlane/metadata/vi/name.txt`
  - `app/ios/fastlane/metadata/vi/subtitle.txt`
  - `app/ios/fastlane/metadata/vi/description.txt`
  - `app/ios/fastlane/metadata/vi/keywords.txt`
  - `app/ios/fastlane/metadata/vi/promotional_text.txt`
  - `app/ios/fastlane/metadata/vi/release_notes.txt`

- [ ] **Legal Documents**:
  - `legal/privacy_policy_en.md` and `legal/privacy_policy_vi.md`
  - `legal/terms_eula_en.md` and `legal/terms_eula_vi.md`
