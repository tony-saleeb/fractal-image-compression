import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/compression_service.dart';
import '../utils/constants.dart';
import '../utils/file_size_extension.dart';
import '../utils/theme_provider.dart';
import '../utils/theme.dart';
import '../widgets/animated_theme_toggle.dart';
import '../widgets/compression_loading_overlay.dart';
import '../widgets/animated_background.dart';
import 'compression_result_screen.dart';
import '../services/compression_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileHomeScreen();
  }
}

class _MobileHomeScreen extends StatefulWidget {
  const _MobileHomeScreen();

  @override
  State<_MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<_MobileHomeScreen> {
  Future<void> _handleCompress() async {
    final controller = context.read<CompressionController>();
    if (controller.isProcessing) return;

    debugPrint('[MobileHome] _handleCompress triggered');
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    final picked = result.files.first;
    final File imageFile = File(picked.path!);
    final Uint8List imageBytes = picked.bytes ?? await imageFile.readAsBytes();

    final ok = await controller.checkServerStatus();
    if (!ok && mounted) {
      _showServerError();
      return;
    }

    try {
      final completer = Completer<void>();
      
      final taskFuture = controller.performCompression(
        pickedFile: picked,
        imageBytes: imageBytes,
      );
      
      taskFuture.whenComplete(() {
        if (!completer.isCompleted) completer.complete();
      });

      if (!mounted) return;
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          pageBuilder:
              (ctx, anim, _) => FadeTransition(
                opacity: anim,
                child: CompressionLoadingOverlay(
                  imageFile: imageFile,
                  imageBytes: imageBytes,
                  task: completer.future,
                  isDecompress: false,
                  onComplete: () {
                    debugPrint('[MobileHome] Overlay requested pop');
                    if (Navigator.of(ctx).canPop()) {
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
              ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );

      if (!mounted) return;

      if (controller.errorMessage != null) {
        _showError(controller.errorMessage!);
        return;
      }

      final res = controller.lastCompressResult;
      if (res != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CompressionResultScreen(
                  mode: CompressionMode.compress,
                  originalImage: imageFile,
                  imageBytes: imageBytes,
                  originalSize: res.formattedOriginalSize,
                  compressedSize: res.formattedCompressedSize,
                  compressionTime: Duration(
                    milliseconds: (res.elapsedSeconds * 1000).round(),
                  ),
                  ficBytes: res.ficBytes,
                  compressionRatio: res.formattedRatio,
                  psnr: res.formattedPsnr,
                  rmse: res.formattedRmse,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted && controller.errorMessage != null) {
        _showError(controller.errorMessage!);
      }
    } finally {
      if (mounted) controller.setProcessing(false);
    }
  }

  Future<void> _handleDecompress() async {
    final controller = context.read<CompressionController>();
    if (controller.isProcessing) return;

    debugPrint('[MobileHome] _handleDecompress triggered');
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
    } catch (e) {
      _showError('Explorer Error: $e');
      return;
    }
    
    if (result == null || result.files.isEmpty || !mounted) return;

    final picked = result.files.first;
    if (!picked.name.toLowerCase().endsWith('.fic')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a .fic file'),
        backgroundColor: Colors.orange,
      ));
    }
    final Uint8List ficBytes =
        picked.bytes ?? await File(picked.path!).readAsBytes();
    final int ficSize = ficBytes.length;

    final ok = await controller.checkServerStatus();
    if (!ok && mounted) {
      _showServerError();
      return;
    }

    try {
      final completer = Completer<void>();
      
      final taskFuture = controller.performDecompression(
        pickedFile: picked,
        ficBytes: ficBytes,
      );
      
      taskFuture.whenComplete(() {
        if (!completer.isCompleted) completer.complete();
      });

      if (!mounted) return;
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          pageBuilder:
              (ctx, anim, _) => FadeTransition(
                opacity: anim,
                child: CompressionLoadingOverlay(
                  imageFile: File(''),
                  task: completer.future,
                  isDecompress: true,
                  onComplete: () {
                    debugPrint('[MobileHome] Decompress overlay requested pop');
                    if (Navigator.of(ctx).canPop()) {
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
              ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );

      if (!mounted) return;

      if (controller.errorMessage != null) {
        _showError(controller.errorMessage!);
        return;
      }

      final decRes = controller.lastDecompressResult;
      if (decRes != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CompressionResultScreen(
                  mode: CompressionMode.decompress,
                  originalImage: File(''),
                  originalSize: ficSize.toHumanReadableSize(),
                  compressedSize:
                      (decRes.imageBytes.length).toHumanReadableSize(),
                  compressionTime: Duration(
                    milliseconds: (decRes.elapsedSeconds * 1000).round(),
                  ),
                  decodedImageBytes: decRes.imageBytes,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted && controller.errorMessage != null) {
        _showError(controller.errorMessage!);
      }
    } finally {
      if (mounted) controller.setProcessing(false);
    }
  }

  void _showServerError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Backend server not running.\nRun: py server.py',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final isProcessing = context.watch<CompressionController>().isProcessing;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Background Mesh
          const AnimatedBackground(),
          
          // 2. Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Transparent Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(8),
                            decoration: AppTheme.glassDecoration(isDark: isDark, opacity: 0.1),
                            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => AppTheme.premiumGradient(isDark).createShader(bounds),
                                child: Text(
                                  AppConstants.appName,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 24,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              Text(
                                'SECURE NEURAL GATEWAY',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const AnimatedThemeToggle(size: 24, padding: 8),
                    ],
                  ),
                ),

                // Main Dashboard Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Operations',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select a neural processing pathway.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 48),

                        _ModernActionCard(
                          icon: Icons.compress_rounded,
                          title: 'Compress Image',
                          subtitle: 'Neural Encoding',
                          description: 'Convert standard images into highly optimized fractal representations with learned entropy.',
                          gradientColors: [AppTheme.primaryBlue, AppTheme.darkSecondary],
                          isDark: isDark,
                          isLoading: isProcessing,
                          onTap: isProcessing ? null : _handleCompress,
                        ),
                        
                        const SizedBox(height: 24),

                        _ModernActionCard(
                          icon: Icons.zoom_out_map_rounded,
                          title: 'Decompress FIC',
                          subtitle: 'Neural Reconstruction',
                          description: 'Restore stunning visual fidelity from fractal representations using super-resolution.',
                          gradientColors: [AppTheme.darkSecondary, AppTheme.primaryBlue],
                          isDark: isDark,
                          isLoading: isProcessing,
                          onTap: isProcessing ? null : _handleDecompress,
                        ),
                        
                        const SizedBox(height: 60),
                        Center(
                          child: Container(
                            height: 1.5,
                            width: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _ModernActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> gradientColors;
  final bool isDark;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ModernActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradientColors,
    required this.isDark,
    required this.isLoading,
    this.onTap,
  });

  @override
  State<_ModernActionCard> createState() => _ModernActionCardState();
}

class _ModernActionCardState extends State<_ModernActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        decoration: AppTheme.glassDecoration(isDark: widget.isDark).copyWith(
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: widget.gradientColors.first.withValues(alpha: widget.isDark ? 0.15 : 0.08),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Stack(
              children: [
                // Subtle background glowing orb
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.gradientColors.first.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.gradientColors.first.withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: widget.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(18),
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : Icon(widget.icon, color: Colors.white, size: 32),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.subtitle.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: widget.gradientColors.first,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
