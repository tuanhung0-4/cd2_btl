import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_style.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative Geometric Shapes (Neo-Brutalist / Modern Material)
          Positioned(
            top: -size.width * 0.2,
            right: -size.width * 0.1,
            child: _buildCircle(size.width * 0.6, AppColors.primary),
          ),
          Positioned(
            top: size.height * 0.15,
            left: -size.width * 0.15,
            child: _buildOutlineCircle(size.width * 0.4),
          ),
          Positioned(
            bottom: size.height * 0.1,
            right: -size.width * 0.2,
            child: _buildCircle(size.width * 0.5, AppColors.secondary.withAlpha(50)),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  
                  // Label / App Name
                  Text(
                    'CAFE PRO'.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 4,
                    color: AppColors.primary,
                  ),

                  const Spacer(),

                  // Big Heading (Swiss Typography)
                  Text(
                    'Manage Your\nCoffee Shop\nWith Style.',
                    style: AppStyle.heading.copyWith(
                      fontSize: 48,
                      height: 1.0,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'A minimalist, powerful tool designed for modern cafe owners who value speed and aesthetics.',
                    style: AppStyle.subHeading.copyWith(
                      color: AppColors.textPrimary.withAlpha(180),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Action Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.textPrimary, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.textPrimary,
                            offset: Offset(6, 6),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'GET STARTED',
                              style: AppStyle.buttonText.copyWith(
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textPrimary, width: 2),
      ),
    );
  }

  Widget _buildOutlineCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textPrimary, width: 2),
      ),
    );
  }
}
