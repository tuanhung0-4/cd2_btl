import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Cozy Cafe Palette
  static const Color background = Color(0xFFF1DECB); // Warm Beige
  static const Color cardBackground = Color(0xFFE8D3C0); // Slightly darker beige for cards
  
  static const Color primary = Color(0xFF3E2723); // Dark Brown
  static const Color secondary = Color(0xFF5D4037); // Medium Brown
  static const Color accent = Color(0xFF8D6E63); // Light Brown
  static const Color danger = Color(0xFFD32F2F); 
  
  static const Color textPrimary = Color(0xFF3E2723); // Dark brown text
  static const Color textSecondary = Color(0xFF5D4037);
  static const Color textWhite = Colors.white;

  // Shapes
  static const double borderRadius = 20.0;
}

class AppStyle {
  // Soft, continuous look (Glass/Soft UI inspired from image)
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(AppColors.borderRadius),
    border: Border.all(color: AppColors.primary, width: 1.5),
    boxShadow: [],
  );

  static BoxDecoration filledCardDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(AppColors.borderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: const Offset(0, 4),
        blurRadius: 10,
      ),
    ],
  );

  static BoxDecoration circleDecoration = BoxDecoration(
    color: AppColors.background,
    shape: BoxShape.circle,
    border: Border.all(color: AppColors.primary, width: 1.5),
  );

  // Typography focus
  static TextStyle titleFont = GoogleFonts.pacifico(
    fontSize: 28,
    color: AppColors.textPrimary,
  );

  static TextStyle heading = GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle subHeading = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );
}
