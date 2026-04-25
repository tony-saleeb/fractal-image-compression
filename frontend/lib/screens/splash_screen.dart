import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' as math;
import '../core/constants/app_durations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _controller = AnimationController(
      duration: AppDurations.splashAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // Continuous rotation animation
    _rotationController = AnimationController(
      duration: AppDurations.rotationCycle,
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _controller.forward();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    // Start auth check while splash is showing
    final authCheckFuture = Future.value(_authService.isLoggedIn);
    final prefsFuture = SharedPreferences.getInstance();

    // Wait for the minimal splash duration
    await Future.delayed(AppDurations.splashDelay);

    final results = await Future.wait([authCheckFuture, prefsFuture]);
    final bool isLoggedIn = results[0] as bool;
    final SharedPreferences prefs = results[1] as SharedPreferences;

    if (!mounted) return;

    // 1. Check if user is logged in -> Go Home
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    // 2. Check onboarding status for mobile
    if (!kIsWeb) {
      final bool onboardingComplete =
          prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
      if (!onboardingComplete) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        return;
      }
    }

    // 3. Otherwise, go to Auth screen
    Navigator.pushReplacementNamed(context, AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [


          // Main content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Creative fractal compression logo
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: SizedBox(
                          width: 280,
                          height: 280,
                          child: Center(
                            child: Image.asset(
                              AppConstants.logooPath,
                              width: 240,
                              height: 240,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),



                      // Modern loading dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < 3; i++)
                            AnimatedBuilder(
                              animation: _rotationController,
                              builder: (context, child) {
                                final delay = i * 0.33;
                                final progress =
                                    (_rotationAnimation.value / (2 * math.pi) +
                                        delay) %
                                    1.0;
                                final scale =
                                    1.0 +
                                    (math.sin(progress * 2 * math.pi) * 0.5);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primaryColor.withValues(
                                          alpha: (0.4 + (scale - 1.0) * 0.6)
                                              .clamp(0.0, 1.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
