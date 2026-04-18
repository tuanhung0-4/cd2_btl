import 'package:flutter/material.dart';
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
          // Soft decorative shapes
          Positioned(
            top: -size.width * 0.2,
            right: -size.width * 0.1,
            child: _buildCircle(size.width * 0.6, AppColors.cardBackground),
          ),
          Positioned(
            top: size.height * 0.15,
            left: -size.width * 0.15,
            child: _buildCircle(size.width * 0.4, AppColors.accent.withAlpha(50)),
          ),
          Positioned(
            bottom: size.height * 0.1,
            right: -size.width * 0.2,
            child: _buildCircle(size.width * 0.5, AppColors.secondary.withAlpha(30)),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  
                  // Label / App Name
                  Center(
                    child: Text(
                      'CupfulCanvas',
                      style: AppStyle.titleFont.copyWith(
                        fontSize: 42,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Big Heading
                  Text(
                    'Your daily dose of joy and coffee.',
                    textAlign: TextAlign.center,
                    style: AppStyle.heading.copyWith(
                      fontSize: 36,
                      height: 1.2,
                      color: AppColors.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Discover the best coffee blends, perfectly crafted just for you.',
                    textAlign: TextAlign.center,
                    style: AppStyle.subHeading.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),

                  const SizedBox(height: 60),

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
                      height: 65,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            offset: const Offset(0, 8),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Get Started',
                          style: AppStyle.buttonText.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
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
      ),
    );
  }
}
