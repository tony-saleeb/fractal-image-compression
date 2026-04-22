import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize bubbles
    for (int i = 0; i < 5; i++) {
      _bubbles.add(Bubble(_random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Base background color
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      children: [
        // Solid background
        Container(color: backgroundColor),

        // Animated bubbles
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: BubblePainter(
                bubbles: _bubbles,
                controllerValue: _controller.value,
                primaryColor: colorScheme.primary,
                secondaryColor: colorScheme.secondary,
                isDark: isDark,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Glass overlay pattern (optional subtle grid or noise)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor.withValues(alpha: 0.3),
                backgroundColor.withValues(alpha: 0.7),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class Bubble {
  late double x;
  late double y;
  late double radius;
  late double speed;
  late double theta;
  late double originalRadius;

  Bubble(Random random) {
    reset(random);
    // Randomize initial position
    x = random.nextDouble();
    y = random.nextDouble();
  }

  void reset(Random random) {
    x = random.nextDouble();
    y = random.nextDouble();
    originalRadius = random.nextDouble() * 300 + 200; // Large blobs
    radius = originalRadius;
    speed = random.nextDouble() * 0.05 + 0.01;
    theta = random.nextDouble() * 2 * pi;
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double controllerValue;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  BubblePainter({
    required this.bubbles,
    required this.controllerValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < bubbles.length; i++) {
      final bubble = bubbles[i];

      // Calculate movement
      final dx = cos(bubble.theta) * bubble.speed * size.width * 0.01;
      final dy = sin(bubble.theta) * bubble.speed * size.height * 0.01;

      bubble.x += dx / size.width;
      bubble.y += dy / size.height;

      // Wrap around
      if (bubble.x < -0.2) bubble.x = 1.2;
      if (bubble.x > 1.2) bubble.x = -0.2;
      if (bubble.y < -0.2) bubble.y = 1.2;
      if (bubble.y > 1.2) bubble.y = -0.2;

      // Pulse effect
      final pulse = sin(controllerValue * 2 * pi + i) * 0.1 + 0.9;
      final currentRadius = bubble.radius * pulse;

      final paint =
          Paint()
            ..shader = RadialGradient(
              colors: [
                (i % 2 == 0 ? primaryColor : secondaryColor).withValues(
                  alpha: isDark ? 0.15 : 0.08,
                ),
                (i % 2 == 0 ? primaryColor : secondaryColor).withValues(
                  alpha: 0.0,
                ),
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(bubble.x * size.width, bubble.y * size.height),
                radius: currentRadius,
              ),
            )
            ..blendMode = BlendMode.srcOver;

      canvas.drawCircle(
        Offset(bubble.x * size.width, bubble.y * size.height),
        currentRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) => true;
}
