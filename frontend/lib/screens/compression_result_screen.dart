import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/compression_service.dart';
import '../utils/theme_provider.dart';
import '../utils/theme.dart';
import '../widgets/animated_theme_toggle.dart';
import '../widgets/premium_button.dart';

class CompressionResultScreen extends StatefulWidget {
  final CompressionMode mode;
  final File originalImage;
  final Uint8List? imageBytes;
  final Uint8List? decodedImageBytes;
  final String originalSize;
  final String compressedSize;
  final Duration compressionTime;
  final Uint8List? ficBytes;
  final String? compressionRatio;
  final String? psnr;
  final String? rmse;

  const CompressionResultScreen({
    super.key,
    required this.mode,
    required this.originalImage,
    this.imageBytes,
    this.decodedImageBytes,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionTime,
    this.ficBytes,
    this.compressionRatio,
    this.psnr,
    this.rmse,
  });

  @override
  State<CompressionResultScreen> createState() =>
      _CompressionResultScreenState();
}

class _CompressionResultScreenState extends State<CompressionResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Minimalist background matching home screens
          Container(color: theme.scaffoldBackgroundColor),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: _buildMobileLayout(context, isDark, primaryColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    return Column(
      children: [
        _buildMobileHeader(context, primaryColor),
        const SizedBox(height: 32),
        _buildImageHero(context, isDark),
        const SizedBox(height: 40),
        _buildModernHeader(context, isCenter: true),
        const SizedBox(height: 32),
        _buildStatsGlassPanel(context, isDark),
        const SizedBox(height: 40),
        _buildActionGrid(context),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
        const AnimatedThemeToggle(size: 24, padding: 8),
      ],
    );
  }

  Widget _buildModernHeader(BuildContext context, {bool isCenter = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment:
          isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback:
              (bounds) => AppTheme.premiumGradient(isDark).createShader(bounds),
          child: Text(
            'Processing Complete',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Neural weights applied successfully. Your image has been reconstructed with high precision.',
          textAlign: isCenter ? TextAlign.center : TextAlign.start,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            height: 1.5,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildImageHero(BuildContext context, bool isDark) {
    final displayBytes =
        widget.mode == CompressionMode.decompress
            ? widget.decodedImageBytes
            : (widget.imageBytes);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
            blurRadius: 60,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child:
            displayBytes != null
                ? Image.memory(displayBytes, fit: BoxFit.contain)
                : (widget.originalImage.path.isNotEmpty
                    ? Image.file(widget.originalImage, fit: BoxFit.contain)
                    : Container(
                      height: 400,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.broken_image_outlined, size: 64),
                    )),
      ),
    );
  }

  Widget _buildStatsGlassPanel(BuildContext context, bool isDark) {
    return Container(
      decoration: AppTheme.glassDecoration(isDark: isDark),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModernStat('ORIGINAL', widget.originalSize),
                _buildVerticalDivider(),
                _buildModernStat(
                  'RESULT',
                  widget.compressedSize,
                  isPrimary: true,
                ),
                if (widget.compressionRatio != null) ...[
                  _buildVerticalDivider(),
                  _buildModernStat('RATIO', widget.compressionRatio!),
                ],
                if (widget.psnr != null && widget.psnr != '0.00 dB') ...[
                  _buildVerticalDivider(),
                  _buildModernStat('PSNR', widget.psnr!),
                ],
                if (widget.rmse != null && widget.rmse != '0.00') ...[
                  _buildVerticalDivider(),
                  _buildModernStat('RMSE', widget.rmse!),
                ],
                _buildVerticalDivider(),
                _buildModernStat(
                  'TIME',
                  _formatDuration(widget.compressionTime),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernStat(
    String label,
    String value, {
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color:
                isPrimary
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1.5,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final isDecompress = widget.mode == CompressionMode.decompress;
    return Column(
      children: [
        PremiumButton(
          text: isDecompress ? 'EXPORT AS PNG' : 'EXPORT AS .FIC',
          icon: Icons.ios_share_rounded,
          onPressed:
              () =>
                  isDecompress ? _downloadPng(context) : _downloadFic(context),
          isPrimary: true,
          isFullWidth: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PremiumButton(
                text: 'SHARE',
                icon: Icons.share_rounded,
                onPressed: () => _shareImage(context),
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PremiumButton(
                text: 'NEW TASK',
                icon: Icons.refresh_rounded,
                onPressed:
                    () => Navigator.of(context).popUntil((r) => r.isFirst),
                isPrimary: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _downloadFic(BuildContext context) async {
    if (widget.ficBytes == null) return;
    final filename = 'fc_${DateTime.now().millisecondsSinceEpoch}.fic';
    try {
      debugPrint('[Export] Saving to temp for sharing...');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(widget.ficBytes!);

      debugPrint('[Export] Launching Share sheet for: $filename');
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Fractal Compressed Image (.fic)');
    } catch (e) {
      debugPrint('[Export] Error: $e');
      if (!context.mounted) return;
      _showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _downloadPng(BuildContext context) async {
    final bytes = widget.decodedImageBytes;
    if (bytes == null) return;
    final filename = 'dec_${DateTime.now().millisecondsSinceEpoch}.png';
    try {
      debugPrint('[Export] Saving PNG to temp for sharing...');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);

      debugPrint('[Export] Launching Share sheet for: $filename');
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Neural Reconstruction');
    } catch (e) {
      debugPrint('[Export] Error: $e');
      if (!context.mounted) return;
      _showErrorSnackBar(context, e.toString());
    }
  }

  void _showErrorSnackBar(BuildContext context, String e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export failed: $e'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      await Share.shareXFiles(
        [XFile(widget.originalImage.path)],
        text:
            'Neural Compression Results: ${widget.originalSize} ➔ ${widget.compressedSize}',
      );
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar(context, e.toString());
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 1) return '${duration.inMilliseconds}ms';
    return '${(duration.inMilliseconds / 1000).toStringAsFixed(2)}s';
  }
}
