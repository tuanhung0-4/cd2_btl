import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database/cafe_db_helper.dart';
import '../utils/app_style.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    String username = userCtrl.text.trim();
    String password = passCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    int result = await CafeDBHelper.register(username, password);
    setState(() => _isLoading = false);

    if (result != -1) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Thành công"),
          content: const Text("Tài khoản đã được tạo!"),
          actions: [
            CupertinoDialogAction(
              child: const Text("Đăng nhập ngay"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            )
          ],
        ),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Lỗi"),
          content: const Text("Tên đăng nhập đã tồn tại!"),
          actions: [
            CupertinoDialogAction(
              child: const Text("Thử lại"), 
              onPressed: () => Navigator.pop(context)
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppStyle.circleDecoration,
                child: const Icon(Icons.person_add_rounded, size: 60, color: AppColors.primary),
              ),
              const SizedBox(height: 30),
              Text("TẠO TÀI KHOẢN", style: AppStyle.heading.copyWith(fontSize: 26)),
              const SizedBox(height: 10),
              Text("Tham gia hệ thống quản lý Cafe Pro", style: AppStyle.subHeading),
              const SizedBox(height: 50),
              _buildTextField(userCtrl, "Tên đăng nhập mới", Icons.account_circle_outlined),
              const SizedBox(height: 20),
              _buildTextField(passCtrl, "Mật khẩu bảo mật", Icons.vpn_key_outlined, isPass: true),
              const SizedBox(height: 40),
              _isLoading
                  ? const CupertinoActivityIndicator(color: AppColors.primary)
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _handleRegister,
                        child: const Text("ĐĂNG KÝ NGAY", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Đã có tài khoản? Quay lại đăng nhập", style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isPass = false}) {
    return Container(
      decoration: AppStyle.cardDecoration,
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}