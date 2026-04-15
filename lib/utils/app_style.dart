import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Neo-Brutalist Palette
  static const Color background = Color(0xFFFBEFE3); // Light Beige / Cream
  static const Color cardBackground = Colors.white;
  
  static const Color primary = Color(0xFFFF4D4D); // Bright Red/Coral
  static const Color secondary = Color(0xFF1A1A1A); // Black/Dark Gray
  static const Color accent = Color(0xFFFFD93D); // Warm yellow for contrast if needed
  static const Color danger = Color(0xFFE74A3B); 
  
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textWhite = Colors.white;

  // Shapes
  static const double borderRadius = 24.0;
}

class AppStyle {
  // Neo-Brutalist Card (Flat, usually with sharp or slightly rounded corners and strong borders)
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(AppColors.borderRadius),
    border: Border.all(color: AppColors.textPrimary, width: 2),
    // Material Design 3 shadow alternative: flat offset
    boxShadow: const [
      BoxShadow(
        color: AppColors.textPrimary,
        offset: Offset(4, 4),
        blurRadius: 0,
      ),
    ],
  );

  static BoxDecoration circleDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    shape: BoxShape.circle,
    border: Border.all(color: AppColors.textPrimary, width: 2),
    boxShadow: const [
      BoxShadow(
        color: AppColors.textPrimary,
        offset: Offset(4, 4),
        blurRadius: 0,
      ),
    ],
  );

  // Swiss Typography focus (Sans Serif, Clean, High Contrast)
  static TextStyle heading = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle subHeading = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static TextStyle buttonText = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );
}

