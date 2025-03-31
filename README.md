# Mina - Ứng dụng Quản lý Tài chính Cá nhân

Mina là một ứng dụng Flutter được thiết kế để giúp người dùng quản lý tài chính cá nhân một cách hiệu quả và dễ dàng.

## Tính năng chính

- 📊 Theo dõi chi tiêu và thu nhập
- 📈 Biểu đồ thống kê trực quan
- 📱 Giao diện người dùng thân thiện
- 🔒 Bảo mật dữ liệu người dùng
- 💬 Tương tác với chatbot tài chính
- 📸 Quét hóa đơn tự động
- 🌐 Hỗ trợ đa ngôn ngữ

## Yêu cầu hệ thống

- Flutter SDK: ^3.6.0
- Dart SDK: ^3.6.0
- Android Studio / VS Code
- Android SDK (cho phát triển Android)
- iOS SDK (cho phát triển iOS)

## Cài đặt

1. Clone repository:
```bash
git clone [URL_REPOSITORY]
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Chạy ứng dụng:
```bash
flutter run
```

## Cấu trúc dự án

```
mina/
├── lib/
│   ├── main.dart
│   ├── screens/
│   ├── widgets/
│   ├── models/
│   ├── services/
│   └── utils/
├── assets/
│   ├── icons/
│   └── tessdata/
├── android/
├── ios/
└── pubspec.yaml
```

## Các dependencies chính

- persistent_bottom_nav_bar: Thanh điều hướng dưới cùng
- flutter_svg: Hỗ trợ hiển thị SVG
- fl_chart: Tạo biểu đồ
- http: Gọi API
- pinput: Nhập mã OTP
- intl: Định dạng ngày tháng
- provider: Quản lý state
- shared_preferences: Lưu trữ dữ liệu cục bộ
- google_ml_kit: Xử lý hình ảnh và OCR
- image_picker: Chọn ảnh từ thư viện hoặc camera
- speech_to_text: Chuyển đổi giọng nói thành văn bản
- permission_handler: Quản lý quyền truy cập
- flutter_dotenv: Quản lý biến môi trường
- sqflite: Cơ sở dữ liệu SQLite
- cached_network_image: Cache ảnh từ mạng

## Build APK

Để tạo file APK debug:

```bash
flutter build apk --debug
```

File APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-debug.apk`

## Đóng góp

Mọi đóng góp đều được chào đón. Vui lòng tạo issue hoặc pull request để đóng góp vào dự án.

## Giấy phép

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm thông tin.
