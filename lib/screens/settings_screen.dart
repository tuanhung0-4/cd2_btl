// Màn hình cài đặt ứng dụng
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_style.dart';
import 'welcome_screen.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  final int userId;
  const SettingsScreen({super.key, required this.userId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Biến lưu ngôn ngữ hiện tại
  String _language = 'Tiếng Việt';

  // Hiển thị dialog giới thiệu về ứng dụng
  void _showAboutDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textPrimary.withAlpha(20), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text("VỀ CHÚNG TÔI", style: AppStyle.heading.copyWith(fontSize: 24)),
            const SizedBox(height: 16),
            Text(
              "Cafe Pro được thiết kế để quản lý quán cafe hiện đại. Giao diện Neo-Brutalist tối giản và tiện dụng.",
              textAlign: TextAlign.center,
              style: AppStyle.body,
            ),
            const SizedBox(height: 32),
            Text("© 2026 Cafe Pro Team", style: AppStyle.body.copyWith(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Xử lý đăng xuất tài khoản
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.textPrimary, width: 2),
        ),
        title: Text("ĐĂNG XUẤT?", style: AppStyle.heading.copyWith(fontSize: 20)),
        content: Text("Bạn có chắc chắn muốn đăng xuất không?", style: AppStyle.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("HỦY", style: AppStyle.body.copyWith(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text("ĐĂNG XUẤT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI chính của màn hình cài đặt
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("CÀI ĐẶT", style: AppStyle.heading.copyWith(fontSize: 28)),
            Text("Tùy chỉnh trải nghiệm của bạn", style: AppStyle.subHeading),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSettingsHeader("HỆ THỐNG"),
          // Chuyển đổi chế độ sáng/tối
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return _buildSettingsTile(
                icon: Icons.dark_mode_rounded,
                title: "CHẾ ĐỘ TỐI",
                subtitle: "Chuyển giao diện sang tông tối",
                trailing: Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (val) {
                    themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                  },
                  activeColor: AppColors.primary,
                ),
              );
            }
          ),
          // Chọn ngôn ngữ
          _buildSettingsTile(
            icon: Icons.language_rounded,
            title: "NGÔN NGỮ",
            subtitle: "Chọn ngôn ngữ hiển thị",
            trailing: DropdownButton<String>(
              value: _language,
              underline: const SizedBox(),
              items: ['Tiếng Việt', 'English'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: AppStyle.body.copyWith(fontWeight: FontWeight.bold)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _language = val);
              },
            ),
          ),
          const SizedBox(height: 32),
          _buildSettingsHeader("TÀI KHOẢN"),
          // Thông tin ứng dụng
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: "THÔNG TIN",
            subtitle: "Phiên bản và nhà phát triển",
            onTap: _showAboutDialog,
          ),
          // Đăng xuất tài khoản
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: "ĐĂNG XUẤT",
            subtitle: "Kết thúc phiên làm việc",
            onTap: _handleLogout,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  // Widget tiêu đề nhóm cài đặt
  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: AppStyle.body.copyWith(fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 2, fontSize: 12),
      ),
    );
  }

  // Widget tile cho từng mục cài đặt
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDanger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppStyle.cardDecoration.copyWith(
        boxShadow: const [
          BoxShadow(
            color: AppColors.textPrimary,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDanger ? AppColors.danger : AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textPrimary, width: 2),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          title, 
          style: AppStyle.heading.copyWith(fontSize: 18, color: isDanger ? AppColors.danger : AppColors.textPrimary)
        ),
        subtitle: Text(subtitle, style: AppStyle.subHeading.copyWith(fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
      ),
    );
  }
}
