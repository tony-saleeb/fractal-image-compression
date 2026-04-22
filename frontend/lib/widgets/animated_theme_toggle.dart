import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import 'theme_switcher.dart';

/// A reusable animated theme toggle button.
///
/// This widget provides a consistent theme toggle experience across the app
/// with smooth rotation and fade animations when switching between light
/// and dark modes.
///
/// Example usage:
/// ```dart
/// AnimatedThemeToggle(
///   size: 24,
///   useThemeSwitcherAnimation: true,
/// )
/// ```
class AnimatedThemeToggle extends StatelessWidget {
  /// Icon size. Defaults to 24.
  final double size;

  /// Whether to use the ThemeSwitcher circular reveal animation.
  /// Set to true for web/desktop, false for simpler mobile toggle.
  final bool useThemeSwitcherAnimation;

  /// Optional custom padding. Defaults to 12.
  final double padding;

  /// Whether to show a background container.
  final bool showBackground;

  /// Optional GlobalKey for tutorial/onboarding targeting.
  final GlobalKey? widgetKey;

  const AnimatedThemeToggle({
    super.key,
    this.size = 24,
    this.useThemeSwitcherAnimation = false,
    this.padding = 12,
    this.showBackground = true,
    this.widgetKey,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    void handleToggle() {
      if (useThemeSwitcherAnimation) {
        ThemeSwitcher.of(context).changeTheme(() {
          themeProvider.toggleTheme();
        });
      } else {
        themeProvider.toggleTheme();
      }
    }

    Widget iconWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return RotationTransition(
          turns: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Icon(
        isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
        key: ValueKey<bool>(isDark),
        color: primaryColor,
        size: size,
      ),
    );

    if (!showBackground) {
      return IconButton(
        key: widgetKey,
        icon: iconWidget,
        onPressed: handleToggle,
        tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      );
    }

    return Container(
      key: widgetKey,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.12),
            primaryColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: handleToggle,
          borderRadius: BorderRadius.circular(14),
          child: Padding(padding: EdgeInsets.all(padding), child: iconWidget),
        ),
      ),
    );
  }
}

/// A simpler version without the container background.
/// Useful for embedding in app bars or tight spaces.
class SimpleThemeToggle extends StatelessWidget {
  final double size;

  const SimpleThemeToggle({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return AnimatedThemeToggle(
      size: size,
      showBackground: false,
      useThemeSwitcherAnimation: false,
    );
  }
}
