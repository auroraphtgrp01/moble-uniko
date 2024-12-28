import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.config.dart';

class ThemeProvider with ChangeNotifier {
  static const String THEME_KEY = 'theme_mode';
  late bool _isDarkMode;

  ThemeProvider() {
    _isDarkMode = AppTheme.isDarkMode;
    _loadThemeFromPrefs();
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    AppTheme.isDarkMode = _isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(THEME_KEY) ?? true;
    AppTheme.isDarkMode = _isDarkMode;
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(THEME_KEY, _isDarkMode);
  }
}
