# Comprehensive Application ID & Package Migration Survey Report

**Project**: Verb360 AI (`360_verb`)  
**Investigator**: `explorer_survey_1` (Teamwork Explorer)  
**Date**: 2026-11-04  
**Target Identity in Request**: `vn.phuongdan.360verb`  
**Current Identity in Repository**: `com.antigravity.verb360.app`  

---

## 1. Executive Summary & Critical Architectural Finding

### 🚨 Critical Android & Java Identifier Restriction (Immediate Blocker)
During our technical analysis and empirical testing with the project's Android build chain (Android Gradle Plugin 9.0.1, Gradle 9.1.0, and AAPT2), we discovered that **`vn.phuongdan.360verb` is syntactically invalid for Android**:

1. **Android Specification Rule**:
   - According to official Android and Google Play guidelines, an `applicationId` and `namespace` consists of dot-separated segments.
   - **Every segment must start with an ASCII letter (`[a-zA-Z]`)**, never with a digit (`0-9`) or an underscore.
   - The segment `360verb` begins with the digit `3`.

2. **Empirical Reproduction & Verbatim Error Output**:
   We created isolated test configurations using the project's exact AGP/Gradle stack:
   - When `namespace = "vn.phuongdan.360verb"`:
     ```
     FAILURE: Build failed with an exception.
     * What went wrong:
     Namespace 'vn.phuongdan.360verb' is not a valid Java package name as '360verb' is not a valid Java identifier.
     ```
   - When `applicationId = "vn.phuongdan.360verb"` during AAPT2 resource linking (`:app:processDebugResources`):
     ```
     FAILURE: Build failed with an exception.
     * What went wrong:
     Execution failed for task ':app:processDebugResources'.
     > Android resource linking failed
       ERROR: .../AndroidManifest.xml:2: AAPT: error: attribute 'package' in <manifest> tag is not a valid Android package name: 'vn.phuongdan.360verb'.
     ```
   - When attempting `vn.phuongdan._360verb`:
     ```
     AAPT: error: attribute 'package' in <manifest> tag is not a valid Android package name: 'vn.phuongdan._360verb'.
     ```
   - When testing `vn.phuongdan.verb360`:
     ```
     BUILD SUCCESSFUL in 3s (14 actionable tasks executed)
     ```
   - Physical device confirmation: Inspection of the connected Google Pixel 4 XL (`99051FFBA004TL`) revealed that an existing app with numeric digits was packaged as `vn.phuongdan.c1000cau` (prefixed with `c`), confirming this exact platform rule.

### 💡 Recommendation & Resolution Strategy
To avoid breaking the Android build while aligning with the user's domain `phuongdan.vn` and brand:
- **Recommended Option (Universal & Clean)**: Use **`vn.phuongdan.verb360`** for both Android (`applicationId`, `namespace`) and iOS (`PRODUCT_BUNDLE_IDENTIFIER`).
  - Matches the existing internal naming conventions (`verb360`, e.g., IAP product IDs `verb360_lifetime_299k`, Go module `verb360`, and previous package `com.antigravity.verb360.app`).
  - Passes 100% of AGP, AAPT2, Google Play Store, and Apple App Store validations.
- **Alternative Option (Platform-Divergent)**: If iOS strictly requires `vn.phuongdan.360verb` (since iOS allows bundle ID segments to start with digits), Android MUST use a valid identifier such as `vn.phuongdan.verb360` or `vn.phuongdan.v360verb`.

---

## 2. Complete Inventory of Current Package / Application ID Occurrences

### A. Android Subsystem (`app/android`)
| File Path | Line(s) | Current Content | Required Change |
|---|---|---|---|
| `app/android/app/build.gradle.kts` | Line 8 | `namespace = "com.antigravity.verb360.app"` | `namespace = "vn.phuongdan.verb360"` |
| `app/android/app/build.gradle.kts` | Line 19 | `applicationId = "com.antigravity.verb360.app"` | `applicationId = "vn.phuongdan.verb360"` |
| `app/android/app/src/main/kotlin/com/antigravity/verb360/app/MainActivity.kt` | Line 1 | `package com.antigravity.verb360.app` | `package vn.phuongdan.verb360` |
| `app/android/app/src/main/kotlin/com/antigravity/verb360/app/` (Directory) | Directory tree | `com/antigravity/verb360/app/` | Move to `vn/phuongdan/verb360/` and delete old directories |
| `app/android/app/src/main/AndroidManifest.xml` | Line 10 | `android:name=".MainActivity"` | Remains `.MainActivity` (resolves to `${namespace}.MainActivity` automatically) |
| `app/android/app/src/debug/AndroidManifest.xml` | - | Contains only `<uses-permission android:name="android.permission.INTERNET"/>` | No changes needed |
| `app/android/app/src/profile/AndroidManifest.xml` | - | Contains only `<uses-permission android:name="android.permission.INTERNET"/>` | No changes needed |
| `app/android/build.gradle.kts` | - | Standard root Gradle file | No package references |
| `app/android/settings.gradle.kts` | - | Uses AGP 9.0.1, Kotlin 2.3.20 | No package references |

### B. iOS Subsystem (`app/ios`)
| File Path | Line(s) | Current Content | Required Change |
|---|---|---|---|
| `app/ios/Runner.xcodeproj/project.pbxproj` | Line 386 | `PRODUCT_BUNDLE_IDENTIFIER = com.antigravity.verb360.app;` (Runner - Profile) | `PRODUCT_BUNDLE_IDENTIFIER = vn.phuongdan.verb360;` (or `vn.phuongdan.360verb;`) |
| `app/ios/Runner.xcodeproj/project.pbxproj` | Line 402 | `PRODUCT_BUNDLE_IDENTIFIER = com.antigravity.verb360.app.RunnerTests;` (RunnerTests - Debug) | `PRODUCT_BUNDLE_IDENTIFIER = vn.phuongdan.verb360.RunnerTests;` |
| `app/ios/Runner.xcodeproj/project.pbxproj` | Line 419 | `PRODUCT_BUNDLE_IDENTIFIER = com.antigravity.verb360.app.RunnerTests;` (RunnerTests - Release) | `PRODUCT_BUNDLE_IDENTIFIER = vn.phuongdan.verb360.RunnerTests;` |
| `app/ios/Runner.xcodeproj/project.pbxproj` | Line 434 | `PRODUCT_BUNDLE_IDENTIFIER = com.antigravity.verb360.app.RunnerTests;` (RunnerTests - Profile) | `PRODUCT_BUNDLE_IDENTIFIER = vn.phuongdan.verb360.RunnerTests;` |
| `app/ios/Runner.xcodeproj/project.pbxproj` | Line 566 | `PRODUCT_BUNDLE_IDENTIFIER = com.antigravity.verb360.app;` (Runner - Debug) | `PRODUCT_BUNDLE_IDENTIFIER = vn.phuongdan.verb360;` (or `vn.phuongdan.360verb;`) |
| `app/ios/Runner.xcodeproj/project.pbxproj` | Line 589 | `PRODUCT_BUNDLE_IDENTIFIER = com.antigravity.verb360.app;` (Runner - Release) | `PRODUCT_BUNDLE_IDENTIFIER = vn.phuongdan.verb360;` (or `vn.phuongdan.360verb;`) |
| `app/ios/Runner/Info.plist` | Line 14 | `<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>` | No changes needed (inherits from `project.pbxproj`) |
| `app/ios/Runner/Info.plist` | Line 10 | `<key>CFBundleDisplayName</key><string>App</string>` | Update to `Verb360 AI` for release consistency |
| `app/ios/Flutter/AppFrameworkInfo.plist` | Line 10 | `<string>io.flutter.flutter.app</string>` | Standard framework ID, no change needed |
| `app/ios/Podfile` | - | Standard Podfile | No package references |
| Entitlements | - | None present | No change needed |

### C. Firebase & Third-Party Backend Check
- **Firebase Configurations**:
  - `google-services.json`: **NOT PRESENT** in repository.
  - `GoogleService-Info.plist`: **NOT PRESENT** in repository.
  - `firebase.json`: **NOT PRESENT** in repository.
  - `pubspec.yaml`: Does **not** include any Firebase packages (`firebase_core`, `firebase_auth`, etc.). The app uses self-hosted PocketBase and local SQLite/SharedPreferences.
- **Fastlane Configurations**:
  - `app/android/fastlane`: Currently does not exist.
  - `app/ios/fastlane`: Currently does not exist.
  - Fastlane files will be generated as part of requirement R3 using the new package identity.
- **In-App Purchases (IAP) & Backend**:
  - `app/lib/data/models/iap_product.dart`:
    - `idLifetime = 'verb360_lifetime_299k'`
    - `idYearly = 'verb360_sub_yearly_199k'`
    - `idMonthly = 'verb360_sub_monthly_19k'`
  - `backend/internal/hooks/api_routes.go`:
    - Handles verification for the above product IDs. Neither backend nor client validates or depends on the application ID string.

---

## 3. Step-by-Step Migration Plan

### Step 1: Update Android Gradle Configuration
File: `app/android/app/build.gradle.kts`
```kotlin
<<<< Line 8:
    namespace = "com.antigravity.verb360.app"
====
    namespace = "vn.phuongdan.verb360"
>>>>

<<<< Line 19:
        applicationId = "com.antigravity.verb360.app"
====
        applicationId = "vn.phuongdan.verb360"
>>>>
```

### Step 2: Refactor Android Kotlin Directory Structure & Package
1. Create new directory path:
   `mkdir -p app/android/app/src/main/kotlin/vn/phuongdan/verb360`
2. Move `MainActivity.kt`:
   `mv app/android/app/src/main/kotlin/com/antigravity/verb360/app/MainActivity.kt app/android/app/src/main/kotlin/vn/phuongdan/verb360/MainActivity.kt`
3. Update package header in `app/android/app/src/main/kotlin/vn/phuongdan/verb360/MainActivity.kt`:
   ```kotlin
   package vn.phuongdan.verb360

   import io.flutter.embedding.android.FlutterActivity

   class MainActivity : FlutterActivity()
   ```
4. Remove legacy directory tree:
   `rm -rf app/android/app/src/main/kotlin/com`

### Step 3: Update iOS Xcode Project Configurations
File: `app/ios/Runner.xcodeproj/project.pbxproj`
Replace occurrences of `com.antigravity.verb360.app` with `vn.phuongdan.verb360` (or `vn.phuongdan.360verb`):
- Runner target (Profile, Debug, Release):
  `PRODUCT_BUNDLE_IDENTIFIER = vn.phuongdan.verb360;` (Lines 386, 566, 589)
- RunnerTests target (Debug, Release, Profile):
  `PRODUCT_BUNDLE_IDENTIFIER = vn.phuongdan.verb360.RunnerTests;` (Lines 402, 419, 434)

Also in `app/ios/Runner/Info.plist`:
- Update `CFBundleDisplayName` from `App` to `Verb360 AI`.

### Step 4: Clean Build Caches & Test Device Alignment
1. In `app/`:
   `flutter clean`
   `flutter pub get`
2. If testing on connected Pixel 4 XL (`99051FFBA004TL`):
   - Existing installed package is `com.antigravity.verb360.app`.
   - To avoid conflict:
     `adb -s 99051FFBA004TL uninstall com.antigravity.verb360.app`
3. Execute validation builds:
   - `flutter analyze`
   - `flutter test`
   - `flutter build apk --debug`

---

## 4. Verification Checkpoints

| Checkpoint | Target | Expected Result |
|---|---|---|
| Linter | `flutter analyze` | 0 errors, 0 warnings |
| Unit & Widget Tests | `flutter test` | 8/8 tests passed |
| Android Build | `flutter build apk --debug` | Successful APK compilation with zero AAPT or manifest errors |
| Package verification on APK | `aapt dump badging build/app/outputs/flutter-apk/app-debug.apk` | `package: name='vn.phuongdan.verb360'` |
| iOS PBXProj check | `grep -rn "PRODUCT_BUNDLE_IDENTIFIER" app/ios` | Matches new identifier |
