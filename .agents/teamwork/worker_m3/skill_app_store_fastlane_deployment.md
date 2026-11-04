---
name: app-store-fastlane-deployment
description: "Quy trình thực thi trọn gói chuẩn bị release app lên Apple App Store và Google Play Store sử dụng Fastlane và Flutter"
---

# Fastlane & App Store Deployment Runbook

## Mục đích
Cung cấp playbook chi tiết để thực thi toàn bộ các bước từ setup Fastlane, sinh Keystore, build artifacts cho đến chuẩn bị hồ sơ review khi người dùng yêu cầu "chuẩn bị các đẩy store".

## Quy Trình Thực Thi:

### 1. Android Signing Setup
- **Tạo Keystore (nếu chưa có)**:
  ```bash
  keytool -genkey -v -keystore frontend/android/app/upload-keystore.jks \
    -alias dannv -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass 12101997Az -keypass 12101997Az \
    -dname "CN=Dan NV, OU=DuoNest, O=PhuongDan, L=Hanoi, C=VN"
  ```
- **Tạo file `frontend/android/key.properties`**:
  ```properties
  storePassword=12101997Az
  keyPassword=12101997Az
  keyAlias=dannv
  storeFile=../app/upload-keystore.jks
  ```
- **Cấu hình `frontend/android/app/build.gradle.kts`**:
  Đọc `key.properties` và gắn `signingConfigs.create("release")` vào `buildTypes.getByName("release")`.

### 2. Fastlane Integration

#### A. iOS (`frontend/ios/fastlane/`):
- **`Appfile`**:
  ```ruby
  app_identifier("vn.phuongdan.duonet")
  apple_id(ENV["APPLE_ID"] || "nguyenvandan868@gmail.com")
  ```
- **`Fastfile`**:
  ```ruby
  default_platform(:ios)

  platform :ios do
    desc "Build & Upload Beta to TestFlight"
    lane :beta do
      build_app(workspace: "Runner.xcworkspace", scheme: "Runner", export_method: "app-store")
      upload_to_testflight(skip_waiting_for_build_processing: true)
    end

    desc "Upload to App Store with Metadata"
    lane :release do
      deliver(
        metadata_path: "./metadata",
        skip_screenshots: false,
        force: true
      )
    end
  end
  ```

#### B. Android (`frontend/android/fastlane/`):
- **`Appfile`**:
  ```ruby
  package_name("vn.phuongdan.duonet")
  json_key_file(ENV["SUPPLY_JSON_KEY"] || "./play-store-credentials.json")
  ```
- **`Fastfile`**:
  ```ruby
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

    desc "Upload to Google Play Production track"
    lane :release do
      upload_to_play_store(
        track: "production",
        aab: "../build/app/outputs/bundle/release/app-release.aab"
      )
    end
  end
  ```

### 3. Build & Verify
- Kiểm tra linter:
  ```bash
  cd frontend && flutter analyze
  ```
- Build Android Bundle:
  ```bash
  cd frontend && flutter build appbundle --release
  ```
- Build iOS Archive:
  ```bash
  cd frontend && flutter build ipa --release --no-codesign # (hoặc ký tự động khi có cert)
  ```

### 4. App Review Checklist & Delivery Package
- Kiểm tra tài khoản Reviewer trong metadata: Cặp 2 tài khoản demo và OTP/password.
- Kiểm tra chính sách xóa tài khoản và link Privacy Policy.

### 5. Chuẩn Hóa Metadata 10 Ngôn Ngữ Phổ Biến (App Store & Google Play)

Khi tích hợp Fastlane hoặc chuẩn bị release, **BẮT BUỘC** tự động sinh và dịch metadata hoàn chỉnh sang **10 ngôn ngữ phổ biến nhất toàn cầu** để tối ưu hóa thứ hạng tìm kiếm (ASO) và chuyển đổi cài đặt:

#### A. Bảng Ánh Xạ Mã Locale (Locale Mapping):
| STT | Ngôn ngữ | Tên tiếng Việt | Android (`supply`) | iOS (`deliver`) | Ghi chú thị trường |
|:---:|:---|:---|:---|:---|:---|
| 1 | English (US) | Tiếng Anh (Mỹ) | `en-US` | `en-US` | Toàn cầu (Default) |
| 2 | Vietnamese | Tiếng Việt | `vi-VN` | `vi` | Thị trường nội địa VN |
| 3 | Japanese | Tiếng Nhật | `ja-JP` | `ja` | Nhật Bản (Doanh thu & ASO cao) |
| 4 | Korean | Tiếng Hàn | `ko-KR` | `ko` | Hàn Quốc |
| 5 | Chinese (Simplified) | Tiếng Trung giản thể | `zh-CN` | `zh-Hans` | Trung Quốc, Singapore |
| 6 | Chinese (Traditional) | Tiếng Trung phồn thể | `zh-TW` | `zh-Hant` | Đài Loan, Hong Kong |
| 7 | Spanish | Tiếng Tây Ban Nha | `es-ES` | `es-ES` | Châu Mỹ La Tinh & Tây Ban Nha |
| 8 | French | Tiếng Pháp | `fr-FR` | `fr-FR` | Pháp, Canada |
| 9 | German | Tiếng Đức | `de-DE` | `de-DE` | Đức, Áo, Thụy Sĩ |
| 10 | Portuguese (Brazil) | Tiếng Bồ Đào Nha | `pt-BR` | `pt-BR` | Brazil, Bồ Đào Nha |

#### B. Cấu Trúc File & Giới Hạn Ký Tự Bắt Buộc:
1. **Android (`android/fastlane/metadata/android/<locale>/`)**:
   - `title.txt`: Tên ứng dụng (Tối đa **30 ký tự**).
   - `short_description.txt`: Tóm tắt ngắn gọn tính năng (Tối đa **80 ký tự**).
   - `full_description.txt`: Mô tả chi tiết (Tối đa **4000 ký tự**).
   - `changelogs/default.txt`: Ghi chú bản phát hành / tính năng mới.

2. **iOS (`ios/fastlane/metadata/<locale>/` & Metadata Chung)**:
   - File chung trong `ios/fastlane/metadata/`:
     - `primary_category.txt` (VD: `PRODUCTIVITY`, `EDUCATION`, `LIFESTYLE`).
     - `secondary_category.txt`
     - `copyright.txt` (VD: `2026 Developer Name`).
     - `privacy_url.txt` (Link chính sách bảo mật).
     - `support_url.txt` (Link hỗ trợ).
     - `marketing_url.txt` (Website sản phẩm).
   - File theo từng thư mục ngôn ngữ `<locale>/`:
     - `name.txt`: Tên ứng dụng trên App Store (Tối đa **30 ký tự**).
     - `subtitle.txt`: Phụ đề ứng dụng (Tối đa **30 ký tự**).
     - `description.txt`: Mô tả chi tiết (Tối đa **4000 ký tự**).
     - `keywords.txt`: Từ khóa tìm kiếm ASO (Tối đa **100 bytes**, phân cách bởi dấu phẩy, không chứa dấu cách thừa sau dấu phẩy).
     - `promotional_text.txt`: Đoạn giới thiệu khuyến mãi (Tối đa **170 ký tự**).
     - `release_notes.txt`: Nội dung What's New.

### 6. Quy Tắc Bắt Buộc Khi Tạo Description & Store Compliance

#### A. Bắt Buộc Chèn Privacy Policy & Terms of Use (EULA) Vào Cuối Description:
Mọi file `description.txt` (iOS) và `full_description.txt` (Android) ở tất cả ngôn ngữ **BẮT BUỘC** phải có khối liên kết pháp lý ở cuối cùng:
```text
---
Privacy Policy: <link_privacy_policy> (ví dụ: https://listen.phuongdan.io.vn/privacy.html)
Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```
*(Đối với Android có thể ghi `Terms of Service: <link>`)*.

#### B. Quy Tắc Ký Tự Tránh Bị Apple Reject:
- **Tuyệt đối KHÔNG sử dụng Emoji trong `description.txt` của iOS**: Tránh lỗi nghiêm trọng từ App Store Connect API: `An attribute value has invalid characters. Description can't contain the following character(s)`. Thay thế bullet bằng dấu gạch ngang `-`.
- **Độ dài Subtitle iOS**: Nghiêm ngặt **<= 30 ký tự**.
- **Dung lượng Keywords iOS**: Nghiêm ngặt **<= 100 bytes (UTF-8)**, dấu phẩy liền kề, không khoảng trắng dư, không lặp lại từ trong Title/Subtitle.

#### C. Thông Tin Liên Hệ App Review (Bắt Buộc Khi Submit Review):
Tạo đầy đủ các tệp trong `ios/fastlane/metadata/review_information/`:
- `first_name.txt`: `Dan`
- `last_name.txt`: `Nguyen Van`
- `phone_number.txt`: Định dạng quốc tế chuẩn (VD: `+84 355533893`)
- `email_address.txt`: `nguyenvandan868@gmail.com`
