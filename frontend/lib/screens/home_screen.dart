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
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final isProcessing = context.watch<CompressionController>().isProcessing;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
        child: Column(
          children: [
            // --- Premium Apple-style Header ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback:
                                (bounds) => AppTheme.premiumGradient
                                    .createShader(bounds),
                            child: Text(
                              AppConstants.appName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontSize: 22,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Text(
                            'AI-POWERED CODEC',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: primary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const AnimatedThemeToggle(size: 24, padding: 8),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.person_4_outlined,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Precision Compression',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your neural operation',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 48),

                    _ModeCard(
                      icon: Icons.compress_rounded,
                      label: 'Compress',
                      subtitle: 'IMAGE TO FIC',
                      description: 'Full neural encoding with learned entropy.',
                      gradientColors: [primary, secondary],
                      isDark: isDark,
                      isLoading: isProcessing,
                      onTap: isProcessing ? null : _handleCompress,
                    ),
                    const SizedBox(height: 24),

                    _ModeCard(
                      icon: Icons.zoom_out_map_rounded,
                      label: 'Decompress',
                      subtitle: 'FIC TO IMAGE',
                      description:
                          'Neural reconstruction with super-resolution.',
                      gradientColors: [secondary, AppTheme.accentIndigo],
                      isDark: isDark,
                      isLoading: isProcessing,
                      onTap: isProcessing ? null : _handleDecompress,
                    ),

                    const SizedBox(height: 60),
                    Container(
                      height: 1.5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'FRACTAL IMAGE COMPRESSION ENGINE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String description;
  final List<Color> gradientColors;
  final bool isDark;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.description,
    required this.gradientColors,
    required this.isDark,
    required this.isLoading,
    this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: AppTheme.glassDecoration(isDark: widget.isDark).copyWith(
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors[0].withValues(
                  alpha: widget.isDark ? 0.1 : 0.05,
                ),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
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
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradientColors[0].withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child:
                          widget.isLoading
                              ? const Padding(
                                padding: EdgeInsets.all(18),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                              : Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 30,
                              ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: widget.gradientColors[0],
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
