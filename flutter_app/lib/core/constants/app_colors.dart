import 'package:flutter/material.dart';

class AppColors {
  // Primary colors from your logo
  static const Color primaryBlue = Color(0xFF2E86AB);
  static const Color primaryTeal = Color(0xFF00BCD4);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color primaryPink = Color(0xFFE91E63);
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color primaryYellow = Color(0xFFFFC107);

  // Background gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryTeal, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient childishGradient = LinearGradient(
    colors: [
      Color(0xFF00E676),
      Color(0xFF00BCD4),
      Color(0xFF2196F3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [primaryOrange, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);
  static const Color black = Color(0xFF212121);

  // Card colors
  static const Color cardBackground = Color(0xFFFAFAFA);
  static const Color cardShadow = Color(0x1A000000);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Tree/nature colors from logo
  static const Color leafGreen = Color(0xFF8BC34A);
  static const Color treeOrange = Color(0xFFFF8A65);
  static const Color skyBlue = Color(0xFF81D4FA);
  static const Color sunYellow = Color(0xFFFFD54F);
}