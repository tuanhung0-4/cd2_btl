import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database/cafe_db_helper.dart';
import '../utils/app_style.dart';
import 'main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    String username = userCtrl.text.trim();
    String password = passCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    var user = await CafeDBHelper.login(username, password);
    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => MainNavigation(userId: user['id'], username: user['username'])),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Đăng nhập thất bại"),
          content: const Text("Tài khoản hoặc mật khẩu không chính xác."),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppStyle.circleDecoration, // Dùng decoration riêng cho hình tròn
                child: const Icon(Icons.coffee_rounded, size: 60, color: AppColors.primary),
              ),
              const SizedBox(height: 30),
              Text("CAFE MANAGER", style: AppStyle.heading.copyWith(fontSize: 28)),
              const SizedBox(height: 10),
              Text("Hệ thống quản lý chuyên nghiệp", style: AppStyle.subHeading),
              const SizedBox(height: 50),
              _buildTextField(userCtrl, "Tên đăng nhập", Icons.person_outline),
              const SizedBox(height: 20),
              _buildTextField(passCtrl, "Mật khẩu", Icons.lock_outline, isPass: true),
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
                          elevation: 0,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _handleLogin,
                        child: const Text("ĐĂNG NHẬP", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => RegisterScreen())),
                child: const Text("Chưa có tài khoản? Đăng ký ngay", style: TextStyle(color: AppColors.primary)),
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