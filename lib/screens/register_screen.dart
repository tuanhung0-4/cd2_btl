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
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textPrimary, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.textPrimary,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text("ĐĂNG KÝ", style: AppStyle.heading.copyWith(fontSize: 40)),
              const SizedBox(height: 8),
              Text("Tham gia vào quá trình quản lí ngay", style: AppStyle.subHeading),
              const SizedBox(height: 40),
              _buildTextField(userCtrl, "Tên đăng nhập mới", Icons.account_circle_outlined),
              const SizedBox(height: 20),
              _buildTextField(passCtrl, "Mật khẩu bảo mật", Icons.vpn_key_outlined, isPass: true),
              const SizedBox(height: 40),
              _isLoading
                  ? const CupertinoActivityIndicator(color: AppColors.primary)
                  : GestureDetector(
                      onTap: _handleRegister,
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
                            "TẠO TÀI KHOẢN",
                            style: AppStyle.buttonText.copyWith(letterSpacing: 2),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Đã có tài khoản? Đăng nhập", 
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
