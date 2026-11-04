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
