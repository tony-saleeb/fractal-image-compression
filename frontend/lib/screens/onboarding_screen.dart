import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utils/routes.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/animated_theme_toggle.dart';
import '../widgets/premium_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(color: theme.scaffoldBackgroundColor),
          
          SafeArea(
            child: Column(
              children: [
                // Top Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AnimatedThemeToggle(size: 24, padding: 8),
                      if (_currentPage < 2)
                        TextButton(
                          onPressed: () => _pageController.animateToPage(2, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic),
                          child: Text(
                            'SKIP',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    children: const [
                      OnboardingPage(
                        title: 'Neural Precision',
                        description: 'State-of-the-art fractal weights engineered for maximum image fidelity at minimum size.',
                        imagePath: '',
                      ),
                      OnboardingPage(
                        title: 'Instant Delivery',
                        description: 'Parallelized decoding pipelines ensure your high-res assets are reconstructed in milliseconds.',
                        imagePath: '',
                      ),
                      OnboardingPage(
                        title: 'Ready for Launch',
                        description: 'Join the next generation of cloud imaging. Secure, scalable, and beautifully efficient.',
                        imagePath: '',
                      ),
                    ],
                  ),
                ),

                // Bottom Interface
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: 3,
                        effect: ExpandingDotsEffect(
                          activeDotColor: theme.colorScheme.primary,
                          dotColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          dotHeight: 6,
                          dotWidth: 6,
                          expansionFactor: 4,
                          spacing: 8,
                        ),
                      ),
                      const SizedBox(height: 48),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _currentPage == 2
                            ? PremiumButton(
                                key: const ValueKey('start'),
                                text: 'GET STARTED',
                                onPressed: _completeOnboarding,
                                isPrimary: true,
                                isFullWidth: true,
                              )
                            : Row(
                                key: const ValueKey('next'),
                                children: [
                                  if (_currentPage > 0)
                                    IconButton(
                                      onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
                                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.3), size: 18),
                                    )
                                  else
                                    const SizedBox(width: 48),
                                  const Spacer(),
                                  PremiumButton(
                                    text: 'CONTINUE',
                                    onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
                                    isPrimary: true,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

