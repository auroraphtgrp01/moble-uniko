import 'package:flutter/material.dart';

class AppTheme {
  static bool isDarkMode = false;

  // Colors for both modes
  static const Color primaryLight = Color(0xFFD61A3C);
  static const Color primaryDark = Color(0xFFE82B4B);
  
  // Dark theme colors
  static const Color surfaceDark = Color(0xFF0E0E11);
  static const Color backgroundDark = Color(0xFF09090B);
  static const Color cardDark = Color(0xFF1A1A1F);
  
  // Light theme colors
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color backgroundLight = Colors.white;
  static const Color cardLight = Colors.white;
  
  static const Color textPrimaryLight = Color(0xFF1F1F1F);
  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  static const Color dividerLight = Color(0xFFEEEEEE);
  static const Color dividerDark = Color(0xFF2C2C2C);

  static const Color errorLight = Color(0xFFE53935);
  static const Color errorDark = Color(0xFFFF5252);

  // Getters that return colors based on current mode
  static Color get primary => isDarkMode ? primaryDark : primaryLight;
  static Color get surface => isDarkMode ? surfaceDark : surfaceLight;
  static Color get background => isDarkMode ? backgroundDark : backgroundLight;
  static Color get cardBackground => isDarkMode ? cardDark : cardLight;
  static Color get textPrimary => isDarkMode ? textPrimaryDark : textPrimaryLight;
  static Color get textSecondary => isDarkMode ? textSecondaryDark : textSecondaryLight;
  static Color get divider => isDarkMode ? dividerDark : dividerLight;
  static Color get error => isDarkMode ? errorDark : errorLight;
  static Color get shadowColor => isDarkMode ? Colors.black54 : Colors.black12;
  static Color get borderColor => isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);

  // Toggle theme mode
  static void toggleTheme() {
    isDarkMode = !isDarkMode;
  }

  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontWeight: FontWeight.w600),
      // ... các text style khác
    ),
    // ... các cấu hình theme khác
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontWeight: FontWeight.w600),
      // ... các text style khác
    ),
    // ... các cấu hình theme khác
  );
}