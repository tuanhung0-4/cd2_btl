import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'screens/welcome_screen.dart';
import 'utils/app_style.dart';

/// Notifier quản lý trạng thái nền (Sáng/Tối) của toàn ứng dụng
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

/// Hàm khởi chạy ứng dụng Flutter
void main() async {
  // Đảm bảo các cấu hình nền tảng flutter đã được gắn kết trước khi chạy
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo database cho các nền tảng đặc thù (Web tĩnh, Windows, Linux)
  // Vì SQLite mặc định trên điện thoại chạy trực tiếp, còn máy tính cần thư viện ffi
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfi;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Khởi chạy UI
  runApp(const MyApp());
}

/// Lớp chính bao bọc toàn bộ ứng dụng và thiết lập Cấu hình Giao diện (Theme)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder giúp tự động render lại toàn bộ màn hình khi người dùng đổi Theme Sáng/Tối
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Cafe Pro Manager',
          debugShowCheckedModeBanner: false, // Ẩn biểu ngữ debug
          themeMode: currentMode,
          
          // Mẫu giao diện cơ bản áp dụng toàn project
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.cardBackground,
              error: AppColors.danger,
            ),
            useMaterial3: true,
          ),
          
          // Mẫu giao diện màn hình Dark Mode (hiện không dùng nhiều do chưa set default UI)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              secondary: Colors.white,
              surface: Color(0xFF1E1E1E),
              error: AppColors.danger,
            ),
            useMaterial3: true,
          ),
          
          // Màn hình đầu tiên load khi bật app lên
          home: const WelcomeScreen(),
        );
      },
    );
  }
}