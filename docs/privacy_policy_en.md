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
- **Website**: `https://verd.phuongdan.io.vn`
