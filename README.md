# Verb360 AI - Ứng Dụng Học 360 Động Từ Bất Quy Tắc

> Ứng dụng đa nền tảng (iOS, Android, Web) học trọn bộ 360 động từ bất quy tắc tiếng Anh khoa học, kết hợp thuật toán **Lặp lại ngắt quãng (Spaced Repetition SM-2)**, phân loại quy luật hình thái ($A-A-A$, $A-B-A$, $A-B-B$, $A-B-C$), **Gia sư AI chấm/sửa câu tức thì** và kho phát âm âm thanh chất lượng cao.

---

## 🌟 Tính Năng Nổi Bật

1. **Kho dữ liệu chuẩn 360 Động Từ Bất Quy Tắc**:
   - Đầy đủ 3 thể $V_1$ (Infinitive), $V_2$ (Past Simple), $V_3$ (Past Participle).
   - Ký hiệu phiên âm quốc tế chuẩn IPA cho cả 3 thể.
   - Nghĩa tiếng Việt chính xác và câu ví dụ song ngữ thực tế.
   - Phân loại theo hình thái: Nhóm $A-A-A$, $A-B-A$, $A-B-B$, $A-B-C$ và cấp độ CEFR ($A_1 \to C_2$).
2. **Gia Sư Ngữ Cảnh AI (Google Gemini Gateway)**:
   - **AI Context Generator**: Tự động sinh ví dụ thực tế theo chủ đề tùy chọn (đời sống, du lịch, công việc, công nghệ).
   - **AI Writing & Grammar Feedback**: Chấm điểm (1-10), phân tích thì sử dụng, nhận xét chi tiết, giải thích ngữ pháp và gợi ý câu viết tự nhiên hơn.
   - **Semantic Caching**: Bộ đệm SQLite lưu kết quả câu chấm giúp tối ưu hóa chi phí token và tốc độ phản hồi.
3. **Thuật toán Spaced Repetition (SM-2)**:
   - Hệ thống tự động tính toán hệ số dễ nhớ ($EF \ge 1.3$), số lần lặp và khoảng cách ngày ôn tập tiếp theo.
   - Nhắc nhở danh sách từ cần ôn mỗi ngày ngay trên trang chủ.
4. **4 Chế độ Luyện tập**:
   - **Flashcard SRS**: Lật thẻ 2 mặt tương tác kèm 4 mức đánh giá (Quên, Khó, Tốt, Dễ).
   - **Điền khuyết**: Thử thách chia đúng dạng $V_2$ và $V_3$.
   - **Phản xạ 60 giây (Speed Quiz)**: Đếm ngược thời gian, trả lời nhanh các câu hỏi trắc nghiệm, tích lũy chuỗi Combo.
   - **AI Writing Challenge**: Thử thách viết câu hoàn chỉnh có chứa từ chỉ định và nhận phản hồi trực tiếp từ AI.
5. **Gamification & Offline First**:
   - Streak đếm chuỗi ngày học liên tục, điểm kinh nghiệm XP, thăng hạng cấp độ, bộ sưu tập huy hiệu.
   - Toàn bộ dữ liệu từ điển và flashcard hoạt động **ngoại tuyến 100%**, tự động đồng bộ PocketBase khi trực tuyến.
   - Giao diện Material 3 Responsive: Tự thích ứng `NavigationBar` (Mobile) và `NavigationRail` (Web / Desktop).

---

## 🏗️ Cấu Trúc Dự Án

```
360_verb/
├── backend/                       # Golang & PocketBase Backend
│   ├── cmd/
│   │   ├── server/main.go        # Entrypoint chạy server PocketBase & AI routes
│   │   └── seeder/main.go        # CLI tool nạp 360 động từ & sinh MP3 TTS
│   ├── data/
│   │   └── verbs_360.json        # Dataset chuẩn 360 động từ
│   ├── internal/
│   │   ├── ai/gemini.go          # Tích hợp Google Gemini REST API & Semantic Cache
│   │   ├── srs/sm2.go            # Thuật toán SM-2 trong Go (+ Unit tests)
│   │   ├── tts/tts.go            # Engine sinh file âm thanh MP3 TTS
│   │   └── hooks/api_routes.go   # Custom API endpoints (/api/ai/evaluate, /api/ai/examples)
│   └── migrations/               # Go migrations (verbs, user_verb_progress, cache...)
│
└── app/                          # Flutter Multiplatform App (Riverpod)
    ├── lib/
    │   ├── core/                 # SM-2 calculator, Material 3 Theme
    │   ├── data/                 # Models, repositories, PocketBase & TTS services
    │   ├── logic/                # Riverpod Notifiers (Verb, SRS, AI, Gamification)
    │   └── presentation/         # Adaptive UI & 4 Practice Screens
    ├── assets/data/              # Dataset offline nhúng sẵn
    └── test/                     # Unit & Widget Tests đạt 100% PASS
```

---

## 🚀 Hướng Dẫn Cài Đặt & Khởi Chạy

### 1. Khởi chạy Backend Go PocketBase

```bash
cd backend

# Nạp 360 động từ vào CSDL PocketBase (chạy 1 lần ban đầu)
go run ./cmd/seeder --json data/verbs_360.json

# Chạy Server Backend (cung cấp API Gateway AI & PocketBase Admin)
export GEMINI_API_KEY="<YOUR_GEMINI_API_KEY>" # (Tùy chọn, có sẵn bộ giả lập thông minh khi offline)
go run ./cmd/server serve
```
- Dashboard quản trị PocketBase: `http://127.0.0.1:8090/_/`
- Health check API: `http://127.0.0.1:8090/api/health`

### 2. Khởi chạy Ứng dụng Flutter (iOS / Android / Web)

```bash
cd app

# Cài đặt dependencies
flutter pub get

# Kiểm tra chất lượng mã nguồn
flutter analyze

# Chạy toàn bộ Unit & Widget Tests
flutter test

# Khởi chạy ứng dụng
flutter run -d chrome     # Chạy trên Web
flutter run -d macos      # Chạy trên macOS
flutter run               # Chạy trên máy ảo / thiết bị thật
```

---

## 🧪 Kết Quả Kiểm Thử (DoD Verification)

- **Backend Go**: 
  - `go test -v ./...` -> **100% PASS** (internal/srs, internal/ai, internal/tts).
  - `go vet ./...` -> **0 warnings, sạch sẽ**.
- **Flutter Multiplatform**:
  - `flutter analyze` -> **0 errors, 0 warnings (No issues found!)**.
  - `flutter test` -> **100% PASS** (SM-2 calculations, Models serialization, Widget navigation).
