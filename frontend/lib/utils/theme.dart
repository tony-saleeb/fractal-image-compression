import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Custom DeepFract Color Palette ---
  // Shared
  static const Color primaryBlue = Color(0xFF3B82F6);
  
  // Light Theme (Blues & White)
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF4F8FD); // Very light blue tint
  static const Color lightPrimary = Color(0xFF005BB5); // Strong deep blue
  static const Color lightSecondary = Color(0xFF007AFF); // Bright blue
  
  // Dark Theme (Blues & Blacks)
  static const Color darkBackground = Color(0xFF020617); // Ultra dark blue/black
  static const Color darkSurface = Color(0xFF0F172A); // Deep slate blue
  static const Color darkPrimary = Color(0xFF3B82F6); // Bright blue
  static const Color darkSecondary = Color(0xFF60A5FA); // Lighter blue

  static const Color glassWhite = Color(0x99FFFFFF);
  static const Color glassBlack = Color(0x66000000);

  // --- Design System Utilities ---
  static BoxDecoration glassDecoration({required bool isDark, double opacity = 0.7}) {
    return BoxDecoration(
      color: isDark 
          ? Colors.white.withValues(alpha: 0.05) 
          : Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.1) 
            : Colors.white.withValues(alpha: 0.2),
        width: 1.5,
      ),
    );
  }

  static LinearGradient premiumGradient(bool isDark) {
    return LinearGradient(
      colors: isDark ? [darkPrimary, darkSecondary] : [lightPrimary, lightSecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        onSurface: Color(0xFF001E3C), // Deep blue-black for text
        primaryContainer: lightPrimary.withValues(alpha: 0.1),
      ),
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: -1.0
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: -0.8
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black, letterSpacing: -0.5
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16, color: Colors.black87
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: Colors.black54
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.all(0),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        onSurface: Color(0xFFE2E8F0), // Off-white with slight blue tint
        primaryContainer: darkPrimary.withValues(alpha: 0.1),
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1.0
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.8
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.5
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16, color: Colors.white70
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: Colors.white54
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.all(0),
      ),
    );
  }
}


