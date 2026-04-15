import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF0F2F5);
  static const Color cardBackground = Colors.white;
  
  static const Color primary = Color(0xFF4E73DF); 
  static const Color secondary = Color(0xFF1CC88A); 
  static const Color accent = Color(0xFFF6C23E); 
  static const Color danger = Color(0xFFE74A3B); 
  
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
}

class AppStyle {
  // Decoration for normal cards
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        // replaced deprecated withOpacity() with withAlpha()
        color: Colors.black.withAlpha((0.05 * 255).round()),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );

  // Separate decoration for circular items to avoid "borderRadius with circle" error
  static BoxDecoration circleDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        // replaced deprecated withOpacity() with withAlpha()
        color: Colors.black.withAlpha((0.05 * 255).round()),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static TextStyle heading = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle subHeading = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1,
  );
}
