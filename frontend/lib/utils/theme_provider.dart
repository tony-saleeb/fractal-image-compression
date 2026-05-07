import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _mounted = true;

  ThemeMode get themeMode => _themeMode;

  /// In system mode, we check the platform brightness
  bool get isDarkMode =>
      _themeMode == ThemeMode.system
          ? (WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark)
          : _themeMode == ThemeMode.dark;

  ThemeProvider();

  void toggleTheme() {
    // If it's system, we toggle based on current actual brightness
    if (_themeMode == ThemeMode.system) {
      final isCurrentlyDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
      _themeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    } else {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }

    if (_mounted) {
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    if (_mounted) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
