import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Apple-inspired Minimal Color Palette ---
  static const Color primaryColor = Color(0xFF007AFF); // San Francisco Blue
  static const Color secondaryColor = Color(0xFF5856D6); // Deep Iris
  static const Color lightBackground = Color(0xFFFBFBFD); // Off-white
  static const Color darkBackground = Color(0xFF000000); // True Black
  
  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1C1C1E); // Elevated Dark
  
  static const Color accentIndigo = Color(0xFF5E5CE6);
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

  static LinearGradient premiumGradient = const LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        onSurface: Colors.black,
        primaryContainer: primaryColor.withValues(alpha: 0.1),
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
          backgroundColor: primaryColor,
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
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurface,
        onSurface: Colors.white,
        primaryContainer: Colors.white.withValues(alpha: 0.05),
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
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
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


