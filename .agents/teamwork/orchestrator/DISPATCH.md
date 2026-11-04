# Dispatch Log

## 2026-11-04T01:48:35Z
Update application ID to `vn.phuongdan.360verb`, perform comprehensive UI inspection and fix all layout and overflow issues, and prepare all required materials for store upload in English and Vietnamese.

Working directory: /Volumes/DAT/GIT/360_verb
Integrity mode: development

## Verification Resources
- Connected test device: Google Pixel 4 XL (device ID: `99051FFBA004TL`)
- Flutter static analysis and testing tools (`flutter analyze`, `flutter test`)
- Local PocketBase backend at `http://127.0.0.1:8095`

## Requirements

### R1. Application ID Update
Update the application ID / bundle identifier from `com.antigravity.verb360.app` to `vn.phuongdan.360verb` across both Android (`app/android`) and iOS (`app/ios`), updating all relevant build configurations, manifests, project settings, and folder structures.

### R2. UI Inspection and Layout Bug Fixes
Perform comprehensive UI inspection and testing on the connected Google Pixel 4 XL test device (99051FFBA004TL) and automated widget/layout tests across standard phone and tablet screen sizes. Detect and fix all layout bugs, `RenderFlex` overflows, clipping, and responsive alignment issues across all screens (360 Irregular Verbs, DeepSeek AI tutor & grammar evaluation, SRS Spaced Repetition, Fill Blanks, Speed Quiz, In-App Purchases).

### R3. Store Upload Materials Preparation
Prepare comprehensive store submission materials in both English and Vietnamese, including App Store and Google Play metadata (titles, short/full descriptions, keywords, release notes), Privacy Policy, EULA, and Fastlane deployment configurations.

## Acceptance Criteria

### Application ID Configuration
- [ ] Android `applicationId` and namespace in `build.gradle` set to `vn.phuongdan.360verb`.
- [ ] iOS `PRODUCT_BUNDLE_IDENTIFIER` set to `vn.phuongdan.360verb` in Xcode project configuration.
- [ ] Flutter app builds cleanly for Android and iOS without bundle/package ID mismatch errors.

### UI Quality and Bug Resolution
- [ ] Zero `RenderFlex` overflow errors on the connected Google Pixel 4 XL device (`99051FFBA004TL`) across all screens and user flows.
- [ ] Automated widget/layout tests pass across standard phone and tablet screen dimensions.
- [ ] `flutter analyze` passes with 0 issues (0 errors, 0 warnings).
- [ ] All Flutter unit and widget tests pass.

### Store Upload Materials
- [ ] Google Play Store metadata prepared in English and Vietnamese adhering to store guidelines and character limits (Title <= 30, Short description <= 80, Full description <= 4000).
- [ ] Apple App Store metadata prepared in English and Vietnamese adhering to store guidelines and character limits (Name <= 30, Subtitle <= 30, Description <= 4000, Keywords <= 100).
- [ ] Privacy Policy and EULA documents generated in English and Vietnamese.
- [ ] Fastlane configuration files (`Appfile`, `Fastfile`) created with `vn.phuongdan.360verb`.
