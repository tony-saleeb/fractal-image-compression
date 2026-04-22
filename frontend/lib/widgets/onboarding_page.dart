import 'package:flutter/material.dart';
import 'dart:math' as math;

class OnboardingPage extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final Widget? actionButton;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.actionButton,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _continuousController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    // Entrance animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Continuous animation controller for internal animations
    _continuousController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _continuousController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _continuousController,
        curve: Curves.linear,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _continuousController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Modern Creative Illustration with entrance animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildModernIllustration(context),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Title with slide animation
              Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description with slide animation
              Transform.translate(
                offset: Offset(0, _slideAnimation.value * 1.5),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Optional action button (for the last page) with fade
              if (widget.actionButton != null)
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: widget.actionButton!,
                ),
              
              const Spacer(flex: 3),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernIllustration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (widget.title.contains('Compression') || widget.title.contains('High')) {
      return _buildCompressionIllustration(context, isDark);
    } else if (widget.title.contains('Fast') || widget.title.contains('AI')) {
      return _buildSpeedAIIllustration(context, isDark);
    } else {
      return _buildUploadIllustration(context, isDark);
    }
  }

  // Page 1: High Compression Power - File transformation visualization
  Widget _buildCompressionIllustration(BuildContext context, bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    return SizedBox(
      width: 350,
      height: 350,
      child: AnimatedBuilder(
        animation: _continuousController,
        builder: (context, child) {
          final compressProgress = (_continuousController.value * 0.5);
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background radial gradient
              Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Large file (left side) - fading
              Positioned(
                left: 5,
                child: AnimatedBuilder(
                  animation: _continuousController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 - (compressProgress * 0.3),
                      child: Opacity(
                        opacity: (1.0 - compressProgress).clamp(0.3, 1.0),
                        child: Column(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  width: 2.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 50,
                                    color: primaryColor.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '10MB',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Compression particles flowing
              for (int i = 0; i < 15; i++)
                AnimatedBuilder(
                  animation: _continuousController,
                  builder: (context, child) {
                    final particleProgress = (_continuousController.value + (i * 0.065)) % 1.0;
                    final startX = -70.0;
                    final endX = 70.0;
                    final currentX = startX + (endX - startX) * particleProgress;
                    final currentY = math.sin(particleProgress * math.pi) * -40;
                    
                    return Transform.translate(
                      offset: Offset(currentX, currentY),
                      child: Opacity(
                        opacity: (math.sin(particleProgress * math.pi) * 0.7).clamp(0.0, 1.0),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                secondaryColor,
                                primaryColor.withValues(alpha: 0.5),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: secondaryColor.withValues(alpha: 0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              
              // Center compression icon
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 25,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.compress,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Small file (right side) - appearing
              Positioned(
                right: 5,
                child: AnimatedBuilder(
                  animation: _continuousController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.7 + (compressProgress * 0.3),
                      child: Opacity(
                        opacity: (0.3 + compressProgress).clamp(0.3, 1.0),
                        child: Container(
                          width: 95,
                          height: 95,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '1MB',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Compression percentage badge
              Positioned(
                bottom: 15,
                child: Transform.scale(
                  scale: 0.95 + (math.sin(_continuousController.value * 2 * math.pi) * 0.05),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 18,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.compress, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '90% Smaller',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Page 2: Lightning Fast AI - Speed gauge with AI chip
  Widget _buildSpeedAIIllustration(BuildContext context, bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    return SizedBox(
      width: 350,
      height: 350,
      child: AnimatedBuilder(
        animation: _continuousController,
        builder: (context, child) {
          final speedNeedle = _continuousController.value;
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background glow
              Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Speed gauge arc background
              SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(
                  painter: _SpeedGaugePainter(
                    progress: speedNeedle,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                  ),
                ),
              ),
              
              // Central AI chip
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 25,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circuit pattern
                      for (int i = 0; i < 4; i++)
                        Positioned(
                          left: i == 0 || i == 3 ? 10 : null,
                          right: i == 1 || i == 2 ? 10 : null,
                          top: i < 2 ? 10 : null,
                          bottom: i >= 2 ? 10 : null,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      
                      // AI icon
                      const Icon(
                        Icons.memory,
                        size: 40,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Speed lightning bolts
              for (int i = 0; i < 3; i++)
                Positioned(
                  right: 30 + (i * 15.0),
                  top: 60 + (i * 20.0),
                  child: AnimatedBuilder(
                    animation: _continuousController,
                    builder: (context, child) {
                      final flash = math.sin(_continuousController.value * 2 * math.pi * 3 + i);
                      final isFlashing = flash > 0.7;
                      
                      return Transform.scale(
                        scale: isFlashing ? 1.3 : 1.0,
                        child: Icon(
                          Icons.bolt,
                          size: 28 - (i * 4.0),
                          color: Colors.amber.withValues(
                            alpha: (isFlashing ? 1.0 : 0.5).clamp(0.0, 1.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              // Timer/Speed indicator
              Positioned(
                bottom: 80,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 24,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(speedNeedle * 100).toInt()}%',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // "AI Powered" badge
              Positioned(
                bottom: 15,
                child: Transform.scale(
                  scale: 0.95 + (math.sin(_continuousController.value * 2 * math.pi) * 0.05),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 18,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ultra Fast',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Page 3: Simple & Powerful - Rocket launch (ready to start)
  Widget _buildUploadIllustration(BuildContext context, bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    return SizedBox(
      width: 350,
      height: 350,
      child: AnimatedBuilder(
        animation: _continuousController,
        builder: (context, child) {
          final bounce = math.sin(_continuousController.value * 2 * math.pi * 0.5);
          final rocketY = -20 + (bounce * 15);
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background energy rings (expanding)
              for (int i = 0; i < 4; i++)
                Transform.scale(
                  scale: 0.5 + ((_continuousController.value + i * 0.25) % 1.0) * 0.8,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withValues(
                          alpha: ((1.0 - ((_continuousController.value + i * 0.25) % 1.0)) * 0.3).clamp(0.0, 1.0),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              
              // Stars around
              for (int i = 0; i < 8; i++)
                Transform.rotate(
                  angle: (i * math.pi / 4) + (_rotateAnimation.value * 0.1),
                  child: Transform.translate(
                    offset: Offset(0, -140),
                    child: AnimatedBuilder(
                      animation: _continuousController,
                      builder: (context, child) {
                        final twinkle = math.sin(_continuousController.value * 4 * math.pi + i);
                        return Transform.scale(
                          scale: 0.8 + (twinkle * 0.4).abs(),
                          child: Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber.withValues(
                              alpha: (0.6 + twinkle.abs() * 0.4).clamp(0.0, 1.0),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              
              // Rocket
              Transform.translate(
                offset: Offset(0, rocketY),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rocket body
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 100,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.4),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Window
                            Positioned(
                              top: 30,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.rocket_launch,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            // Stripes
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                children: [
                                  Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Rocket flames (animated)
                    AnimatedBuilder(
                      animation: _continuousController,
                      builder: (context, child) {
                        final flameScale = 0.8 + (math.sin(_continuousController.value * 8 * math.pi) * 0.3);
                        return Transform.scale(
                          scaleY: flameScale,
                          child: Container(
                            width: 60,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.orange,
                                  Colors.deepOrange,
                                  Colors.red.withValues(alpha: 0.0),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // "Ready to Launch" badge
              Positioned(
                bottom: 15,
                child: Transform.scale(
                  scale: 0.95 + (math.sin(_continuousController.value * 2 * math.pi) * 0.05),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 18,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ready to Start',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}

// Custom painter for speed gauge arc
class _SpeedGaugePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  _SpeedGaugePainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background arc
    final bgPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Progress arc (animated)
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      progressPaint,
    );

    // Speed notches
    for (int i = 0; i <= 10; i++) {
      final angle = -math.pi * 0.75 + (math.pi * 1.5 * i / 10);
      final startRadius = radius - 6;
      final endRadius = radius + (i % 2 == 0 ? 8 : 4);
      
      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);

      final notchPaint = Paint()
        ..color = primaryColor.withValues(alpha: i <= (progress * 10) ? 0.6 : 0.2)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), notchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

