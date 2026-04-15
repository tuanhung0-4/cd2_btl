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
                decoration: AppStyle.circleDecoration.copyWith(
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.coffee_rounded, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Text("LOGIN", style: AppStyle.heading.copyWith(fontSize: 40)),
              const SizedBox(height: 8),
              Text("Enter your credentials to continue", style: AppStyle.subHeading),
              const SizedBox(height: 40),
              _buildTextField(userCtrl, "Username", Icons.person_outline),
              const SizedBox(height: 20),
              _buildTextField(passCtrl, "Password", Icons.lock_outline, isPass: true),
              const SizedBox(height: 40),
              _isLoading
                  ? const CupertinoActivityIndicator(color: AppColors.primary)
                  : GestureDetector(
                      onTap: _handleLogin,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.textPrimary, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.textPrimary,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "SIGN IN",
                            style: AppStyle.buttonText.copyWith(letterSpacing: 2),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => RegisterScreen())),
                child: Text(
                  "Don't have an account? Sign Up", 
                  style: AppStyle.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isPass = false}) {
    return Container(
      decoration: AppStyle.cardDecoration.copyWith(
        boxShadow: const [
          BoxShadow(
            color: AppColors.textPrimary,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        style: AppStyle.body.copyWith(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppStyle.body.copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.textPrimary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}