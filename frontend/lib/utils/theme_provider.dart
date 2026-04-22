import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themeModeKey = 'theme_mode';
  bool _mounted = true;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    // Defer theme loading to avoid initialization issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadThemeMode();
    });
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeModeKey) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      if (_mounted) {
        notifyListeners();
      }
    } catch (e) {
      // Fallback to light theme if there's an error
      _themeMode = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    if (_mounted) {
      notifyListeners();
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeModeKey, _themeMode == ThemeMode.dark);
    } catch (e) {
      // Ignore storage errors
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    if (_mounted) {
      notifyListeners();
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeModeKey, mode == ThemeMode.dark);
    } catch (e) {
      // Ignore storage errors
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}

