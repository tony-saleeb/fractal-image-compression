/// Centralized duration constants for consistent animations and delays
/// across the application.
class AppDurations {
  AppDurations._(); // Private constructor to prevent instantiation

  // Splash & Loading
  static const Duration splashDelay = Duration(milliseconds: 3500);
  static const Duration compressionSimulation = Duration(seconds: 3);

  // Animations - Short
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);

  // Animations - Long
  static const Duration animationLong = Duration(milliseconds: 500);
  static const Duration animationSlow = Duration(milliseconds: 1000);

  // Page Transitions
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration fadeTransition = Duration(milliseconds: 400);

  // Complex Animations
  static const Duration entranceAnimation = Duration(milliseconds: 1000);
  static const Duration splashAnimation = Duration(milliseconds: 1800);
  static const Duration rotationCycle = Duration(milliseconds: 4000);
  static const Duration particleAnimation = Duration(seconds: 30);
}
