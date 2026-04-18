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
- `lib/screens/` - Các màn hình chính (welcome, login, home, menu, table, revenue...)
- `lib/widgets/` - Các widget tái sử dụng (item, button, sheet...)
- `lib/models/` - Định nghĩa model dữ liệu (Food, Category, Order...)
- `lib/utils/` - Style, màu sắc, font, tiện ích chung
- `lib/database/` - Xử lý database (SQLite)



## Bản quyền
- Dự án mã nguồn mở, sử dụng cho mục đích học tập, phi thương mại.
