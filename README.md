# Quản Lý Quán Cafe (Cafe Pro Manager)

Ứng dụng Flutter quản lý quán cafe với giao diện hiện đại, tối giản, lấy cảm hứng từ phong cách Neo-Brutalism và Material Design 3.

## Tính năng nổi bật
- Quản lý thực đơn (món ăn, đồ uống) kèm hình ảnh, danh mục.
- Quản lý bàn, trạng thái bàn, thời gian phục vụ.
- Đặt món, thêm món vào hóa đơn, quản lý hóa đơn.
- Thống kê doanh thu, tổng hóa đơn, số đơn/ngày, biểu đồ cột trực quan.
- Giao diện đẹp, bo góc lớn, màu nâu kem, font hiện đại, icon sinh động.
- Đăng nhập, đăng ký, bảo mật tài khoản.

## Hình ảnh giao diện
![Demo UI](demo_ui.jpg)

## Hướng dẫn cài đặt
1. Cài đặt Flutter SDK: https://docs.flutter.dev/get-started/install
2. Clone dự án:
   ```sh
   git clone <repo-url>
   ```
3. Cài đặt dependencies:
   ```sh
   flutter pub get
   ```
4. Chạy ứng dụng:
   ```sh
   flutter run
   ```

## Cấu trúc thư mục


## Thông tin tự động thu thập
- **Ngôn ngữ:** Dart (SDK >=3.0.0 <4.0.0) và Flutter
- **Thư viện chính (từ `pubspec.yaml`):**
   - `sqflite` ^2.3.0
   - `sqflite_common_ffi` ^2.3.3 (hỗ trợ Windows/Linux/desktop)
   - `path` ^1.9.0
   - `intl` ^0.19.0
   - `image_picker` ^1.1.2
   - `google_fonts` ^8.0.2
   - `cupertino_icons` ^1.0.8
- **Cơ sở dữ liệu:** SQLite (được thao tác qua `sqflite`). Trên desktop dùng `sqflite_common_ffi`.
- **Bảng/Schema chính (thu thập từ `lib/database/`):**
   - `users(id, username, password)`
   - `products(id, name, price, description, imagePath, category, userId)`
   - `tables(id, name, status, openedAt, guestCount, userId)`
   - `bills(id, tableId, totalAmount, status, createdAt, paidAt, userId)`
   - `bill_details(id, billId, productId, quantity, price)`
   - `items(id, name, note, parentId, price, status, userId)`
- **Các màn hình (screens) chính:** 10 màn hình
   - `welcome_screen.dart` (Welcome)
   - `login_screen.dart` (Đăng nhập)
   - `register_screen.dart` (Đăng ký)
   - `home_screen.dart` (Trang chính)
   - `main_navigation.dart` (Điều hướng chính)
   - `add_task_screen.dart` (Thêm nhiệm vụ / mục)
   - `product_screen.dart` (Quản lý sản phẩm)
   - `table_screen.dart` (Quản lý bàn)
   - `revenue_screen.dart` (Thống kê / doanh thu)
   - `settings_screen.dart` (Cài đặt)
- **Chức năng chính (tổng quát):**
   1. Xác thực: đăng ký, đăng nhập (`users`)
   2. Quản lý sản phẩm: thêm, xoá, lấy danh sách (`products`)
   3. Quản lý bàn: thêm, cập nhật trạng thái, lấy danh sách (`tables`)
   4. Quản lý hóa đơn / đặt món: tạo hóa đơn, thêm/xoá món, đóng hóa đơn (`bills`, `bill_details`)
   5. Lịch sử & báo cáo: lấy hóa đơn đã thanh toán, doanh thu, số đơn/ngày
   6. Quản lý mục / nhiệm vụ (`items` trong `task_helper.dart`)
   7. Hỗ trợ ảnh cho sản phẩm (qua `image_picker`)
   8. Theme (sáng/tối) và giao diện tuỳ chỉnh (Google Fonts)
## Bản quyền
- Dự án mã nguồn mở, sử dụng cho mục đích học tập, phi thương mại.
