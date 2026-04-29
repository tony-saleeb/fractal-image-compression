import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class CompressionLoadingOverlay extends StatefulWidget {
  final File imageFile;
  final Uint8List? imageBytes;
  final VoidCallback onComplete;
  final Future<void>? task;
  final bool isDecompress;

  const CompressionLoadingOverlay({
    super.key,
    required this.imageFile,
    this.imageBytes,
    required this.onComplete,
    this.task,
    this.isDecompress = false,
  });

  @override
  State<CompressionLoadingOverlay> createState() =>
      _CompressionLoadingOverlayState();
}

class _CompressionLoadingOverlayState extends State<CompressionLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  
  int _currentStep = 0;

  final List<String> _steps = [
    'Initializing Neural Engine',
    'Analyzing Fractal Density',
    'Encoding Entropy Layers',
    'Optimizing Weights',
    'Finalizing Stream',
  ];

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.linear),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _startFlow();
  }

  Future<void> _startFlow() async {
    debugPrint('[Overlay] _startFlow: Starting animation and task');
    _mainController.repeat();
    
    // Animate steps (non-blocking)
    _simulateSteps();

    try {
      // Run real task
      if (widget.task != null) {
        debugPrint('[Overlay] Awaiting real task...');
        await widget.task;
        debugPrint('[Overlay] Real task completed.');
      } else {
        debugPrint('[Overlay] No task provided, waiting for simulation...');
        await Future.delayed(const Duration(seconds: 3));
      }
    } catch (e) {
      debugPrint('[Overlay] Task error caught in overlay: $e');
    } finally {
      if (mounted) {
        debugPrint('[Overlay] Finally block reached. Synchronizing UI...');
        // Enforce a minimum display time to ensure Navigator transition is stable
        // and user sees the "Processing" logic.
        await Future.delayed(const Duration(milliseconds: 600));
        
        if (mounted) {
          debugPrint('[Overlay] Calling onComplete callback.');
          widget.onComplete();
        }
      }
    }
  }

  Future<void> _simulateSteps() async {
    for (int i = 0; i < _steps.length; i++) {
       // Stop simulation immediately if task finished or widget disposed
       if (!mounted) break;
       setState(() => _currentStep = i);
       
       // Slower steps for a more professional "neural feel"
       await Future.delayed(const Duration(milliseconds: 1000));
       
       // If the real task finished, we might want to speed up or stop
       if (_currentStep >= _steps.length - 1) break;
    }
  }

  @override
  void dispose() {
    debugPrint('[Overlay] Disposing controller resources');
    _mainController.status == AnimationStatus.dismissed ? null : _mainController.stop();
    _pulseController.status == AnimationStatus.dismissed ? null : _pulseController.stop();
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Glass Blur Background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.6),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Neural Ring
                _buildNeuralRing(theme),
                const SizedBox(height: 60),
                
                // Progress Info
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    key: ValueKey(_currentStep),
                    children: [
                      Text(
                        _steps[_currentStep].toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Processing Neural Weights...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w500,
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

  Widget _buildNeuralRing(ThemeData theme) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _pulseController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Outer Glow
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15 * _scaleAnimation.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            
            // Rotating Dashed Ring
            Transform.rotate(
              angle: _rotationAnimation.value,
              child: CustomPaint(
                size: const Size(140, 140),
                painter: _DashedRingPainter(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
            ),
            
            // Rotating Logo
            Transform.rotate(
              angle: _rotationAnimation.value,
              child: Image.asset(
                AppConstants.logoPath,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            
            // Orbiting Node
            Transform.rotate(
              angle: _rotationAnimation.value * 1.5,
              child: Transform.translate(
                offset: const Offset(70, 0),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary,
                        blurRadius: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  final Color color;
  _DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final radius = size.width / 2;
    const dashCount = 20;
    const dashLength = 0.1;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        (i * 2 * math.pi / dashCount),
        dashLength,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

