import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class AppTheme {
  static bool isDarkMode = false;

  // Sử dụng font hệ thống của iOS cho cả 2 platform
  static String get fontFamily =>
      Platform.isIOS ? '.SF Pro Display' : '.SF UI Display';

  // Colors for both modes
  static const Color primaryLight = Color(0xFFD61A3C);
  static const Color primaryDark = Color(0xFFE82B4B);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkBottomNav = Color(0xFF18181B);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color lightSurface = Color(0xFFFFFFFF);
  // Dark theme colors
  static const Color surfaceDark = Color(0xFF161A1D);
  static const Color backgroundDark = Color(0xFF111113);
  static const Color cardDark = Color(0xFF161A1D);

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
  static Color get textPrimary =>
      isDarkMode ? textPrimaryDark : textPrimaryLight;
  static Color get textSecondary =>
      isDarkMode ? textSecondaryDark : textSecondaryLight;
  static Color get divider => isDarkMode ? dividerDark : dividerLight;
  static Color get error => isDarkMode ? errorDark : errorLight;
  static Color get shadowColor => isDarkMode ? Colors.black54 : Colors.black12;
  static Color get borderColor => isDarkMode
      ? Colors.white.withOpacity(0.1)
      : Colors.black.withOpacity(0.08);

  // Toggle theme mode
  static void toggleTheme() {
    isDarkMode = !isDarkMode;
  }

  static ThemeData lightTheme = ThemeData(
    fontFamily: fontFamily,
    textTheme: TextTheme(
      displayLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      displayMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      displaySmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      headlineLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      headlineMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      headlineSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      titleLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      titleMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      titleSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      bodyMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      labelLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      labelMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      labelSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: fontFamily,
    textTheme: TextTheme(
      displayLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      displayMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      displaySmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      headlineLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      headlineMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      headlineSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      titleLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      titleMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      titleSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      bodyMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      labelLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      labelMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      labelSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
    ),
  );
}
