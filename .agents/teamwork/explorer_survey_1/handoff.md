# Handoff Report: Application ID & Package Name Migration Survey

**Agent**: `explorer_survey_1`  
**Working Directory**: `/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_1`  
**Type**: Hard Handoff (Investigation & Survey Complete)  
**Deliverable Document**: `/Volumes/DAT/GIT/360_verb/.agents/teamwork/explorer_survey_1/survey_app_id.md`  

---

## 1. Observation

1. **Current Codebase Identifiers**:
   - `app/android/app/build.gradle.kts:8`: `namespace = "com.antigravity.verb360.app"`
   - `app/android/app/build.gradle.kts:19`: `applicationId = "com.antigravity.verb360.app"`
   - `app/android/app/src/main/kotlin/com/antigravity/verb360/app/MainActivity.kt:1`: `package com.antigravity.verb360.app`
   - `app/ios/Runner.xcodeproj/project.pbxproj:386,566,589`: `PRODUCT_BUNDLE_IDENTIFIER = com.antigravity.verb360.app;` (Target: Runner for Profile, Debug, Release)
   - `app/ios/Runner.xcodeproj/project.pbxproj:402,419,434`: `PRODUCT_BUNDLE_IDENTIFIER = com.antigravity.verb360.app.RunnerTests;` (Target: RunnerTests for Debug, Release, Profile)
   - `app/ios/Runner/Info.plist:14`: `$(PRODUCT_BUNDLE_IDENTIFIER)`
   - `app/ios/Runner/Info.plist:10`: `<key>CFBundleDisplayName</key><string>App</string>`
   - `app/android/app/src/main/AndroidManifest.xml:5`: `android:label="Verb360 AI"`
   - `app/android/app/src/main/AndroidManifest.xml:10`: `android:name=".MainActivity"`

2. **Absence of Firebase, Custom Entitlements, or Fastlane**:
   - Files searched: `google-services.json`, `GoogleService-Info.plist`, `firebase.json`, `*.entitlements`, `fastlane/Appfile`, `fastlane/Fastfile`.
   - Result: 0 matches found across the repository.
   - `app/pubspec.yaml`: No Firebase packages present. State management uses `flutter_riverpod`, backend uses `pocketbase`.

3. **In-App Purchase Identifiers**:
   - `app/lib/data/models/iap_product.dart:22-24` and `backend/internal/hooks/api_routes.go:144-156`:
     - `verb360_lifetime_299k`
     - `verb360_sub_yearly_199k`
     - `verb360_sub_monthly_19k`
   - Neither client nor backend validates or couples to the package name/bundle ID for IAP verification.

4. **Fatal Platform Constraint on Android Package Naming**:
   - Android Gradle Plugin (AGP 9.0.1) and AAPT2 enforce that each segment of `namespace` and `applicationId` must start with an ASCII letter `[a-zA-Z]`.
   - When tested in isolated Gradle build:
     - `namespace = "vn.phuongdan.360verb"`:
       `Namespace 'vn.phuongdan.360verb' is not a valid Java package name as '360verb' is not a valid Java identifier.`
     - `applicationId = "vn.phuongdan.360verb"`:
       `AAPT: error: attribute 'package' in <manifest> tag is not a valid Android package name: 'vn.phuongdan.360verb'.`
     - `namespace = "vn.phuongdan._360verb"`:
       `AAPT: error: attribute 'package' in <manifest> tag is not a valid Android package name: 'vn.phuongdan._360verb'.`
     - `namespace = "vn.phuongdan.verb360"` and `applicationId = "vn.phuongdan.verb360"`:
       `BUILD SUCCESSFUL in 3s` with 14/14 actionable tasks executed cleanly.

5. **Physical Device State**:
   - Connected test device: Google Pixel 4 XL (`99051FFBA004TL`).
   - `adb -s 99051FFBA004TL shell pm list packages` contains `com.antigravity.verb360.app` currently installed, as well as `vn.phuongdan.c1000cau`.

---

## 2. Logic Chain

1. **Premise 1 (From Observation 1 & 4)**: The user requested migration to `vn.phuongdan.360verb`. However, the segment `360verb` starts with a digit (`3`).
2. **Premise 2 (From Observation 4)**: In Java and Android, package names and application IDs cannot have segments starting with a digit. AGP and AAPT2 fail with hard compile-time errors when encountering `360verb` or `_360verb`.
3. **Premise 3 (From Observation 1 & 3)**: The project's existing identity throughout the codebase (IAP products, Go backend module, AndroidManifest label) is `verb360`, not `360verb`.
4. **Premise 4 (From Observation 4)**: `vn.phuongdan.verb360` passes 100% of AGP and AAPT2 validations, compiles cleanly, and satisfies both Google Play Store and Apple App Store naming rules.
5. **Premise 5 (From Observation 1 & 2)**: There are no Firebase files, no entitlements, and no fastlane files in the repository. The exact scope of files to modify is strictly contained to `build.gradle.kts`, `MainActivity.kt` (path and package), and `project.pbxproj`.
6. **Conclusion**: To cleanly migrate without build errors, the application ID should be configured as `vn.phuongdan.verb360` (or `vn.phuongdan.360verb` strictly on iOS with `vn.phuongdan.verb360` on Android).

---

## 3. Caveats

1. **iOS Identifier Difference**: Apple's App Store allows bundle identifiers where a segment starts with a number (e.g. `vn.phuongdan.360verb`), whereas Google Play and Android do not. If the user strictly requires `vn.phuongdan.360verb` on iOS, the implementer can use `vn.phuongdan.360verb` for iOS and `vn.phuongdan.verb360` for Android. However, keeping both platforms synchronized with `vn.phuongdan.verb360` is highly recommended.
2. **Device State**: Pixel 4 XL currently has `com.antigravity.verb360.app` installed. When the new package is deployed, the old package should be uninstalled (`adb uninstall com.antigravity.verb360.app`) to ensure clean state and avoid confusion.
3. **Display Name**: `app/ios/Runner/Info.plist` currently has `CFBundleDisplayName` set to `App`. It should be updated to `Verb360 AI` to match `app/android/app/src/main/AndroidManifest.xml:5`.

---

## 4. Conclusion

The application ID migration path is fully surveyed, documented, and ready for implementation.
- All target files, line numbers, and required Kotlin directory moves are specified in `survey_app_id.md`.
- Crucial technical blocker regarding `360verb` starting with a digit on Android is identified and resolved via `vn.phuongdan.verb360`.
- Baseline static analysis (`flutter analyze`) is 100% clean (0 issues), and all unit/widget tests (8/8) pass.

---

## 5. Verification Method

To independently verify all findings:
1. **Verify Android Package Syntax Rule**:
   Run AAPT / AGP resource link check on `vn.phuongdan.360verb` vs `vn.phuongdan.verb360`. Observe AAPT error on `360verb` and success on `verb360`.
2. **Verify Occurrence Coverage**:
   Run:
   `grep -rn "com.antigravity.verb360.app" /Volumes/DAT/GIT/360_verb`
   Confirm exactly 3 files matched: `build.gradle.kts`, `MainActivity.kt`, and `project.pbxproj`.
3. **Verify Baseline Quality**:
   Run `cd app && flutter analyze && flutter test`
   Confirm 0 errors, 0 warnings, 8 passed tests.
