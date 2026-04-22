import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'premium_button.dart';

class HeroSection extends StatelessWidget {
  final File? selectedImage;
  final Uint8List? imageBytes;
  final bool isProcessing;
  final VoidCallback onSelectImage;
  final VoidCallback onCompressImage;
  final GlobalKey? uploadKey;

  const HeroSection({
    super.key,
    required this.selectedImage,
    required this.imageBytes,
    required this.isProcessing,
    required this.onSelectImage,
    required this.onCompressImage,
    this.uploadKey,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    // Responsive padding
    final horizontalPadding =
        isMobile ? 24.0 : (screenWidth < 1200 ? 40.0 : 60.0);
    final verticalPadding = isMobile ? 40.0 : 80.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child:
          isMobile
              ? _buildMobileHeroLayout(context, primaryColor)
              : _buildDesktopHeroLayout(context, primaryColor),
    );
  }

  Widget _buildDesktopHeroLayout(BuildContext context, Color primaryColor) {
    return Row(
      children: [
        // Left side - Content
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'AI-Powered Technology',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Main heading
              Text(
                'Compress Images\nWith AI Power',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 20),

              // Subheading
              Text(
                'Experience extreme compression ratios using advanced fractal compression algorithms powered by artificial intelligence.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  height: 1.6,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 40),

              // Stats - Cohesive cards (equal width)
              Row(
                children: [
                  Expanded(
                    child: _buildStat(context, 'High', 'Compression Ratio'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStat(
                      context,
                      'Ultra Fast',
                      'Processing Speed',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStat(context, 'Perfect', 'Image Quality'),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // CTA Button
              PremiumButton(
                text: 'Upload Image to Compress',
                onPressed: selectedImage == null ? onSelectImage : null,
                icon: Icons.upload_file,
                isPrimary: true,
              ),
            ],
          ),
        ),

        const SizedBox(width: 80),

        // Right side - Upload Area
        Expanded(flex: 1, child: _buildUploadArea(context)),
      ],
    );
  }

  Widget _buildMobileHeroLayout(BuildContext context, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 16, color: primaryColor),
              const SizedBox(width: 6),
              Text(
                'AI-Powered Technology',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Main heading
        Text(
          'Compress Images\nWith AI Power',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 16),

        // Subheading
        Text(
          'Experience extreme compression ratios using advanced fractal compression algorithms powered by artificial intelligence.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            height: 1.6,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),

        const SizedBox(height: 32),

        // Stats - cohesive cards stacked on mobile
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStat(context, 'High', 'Compression Ratio'),
            const SizedBox(height: 16),
            _buildStat(context, 'Ultra Fast', 'Processing Speed'),
            const SizedBox(height: 16),
            _buildStat(context, 'Perfect', 'Image Quality'),
          ],
        ),

        const SizedBox(height: 40),

        // Upload Area
        _buildUploadArea(context),
      ],
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    final primaryColor = Theme.of(context).colorScheme.primary; // Blue
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Assign icons based on the stat - all use same blue style for symmetry
    IconData icon;

    if (label.contains('Compression')) {
      icon = Icons.compress_rounded;
    } else if (label.contains('Speed')) {
      icon = Icons.flash_on_rounded;
    } else {
      icon = Icons.verified_rounded;
    }

    // Symmetric design - all cards use blue/white/black/yellow palette
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF1E1E1E) // Black
                : Colors.white, // White
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2), // Blue border
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with blue background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor, // Blue
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),

          const SizedBox(height: 20),

          // Value - black in light mode, white in dark mode
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 6),

          // Label - black in light mode, white in dark mode
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (selectedImage != null) {
      // Show selected image with actions
      return Container(
        key: uploadKey,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Image Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child:
                  kIsWeb && imageBytes != null
                      ? Image.memory(
                        imageBytes!,
                        height: 400,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : Image.file(
                        selectedImage!,
                        height: 400,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: PremiumButton(
                    text: isProcessing ? 'Compressing...' : 'Compress Now',
                    onPressed: isProcessing ? null : onCompressImage,
                    icon: Icons.compress,
                    isPrimary: true,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(width: 20),
                PremiumButton(
                  text: 'Change',
                  onPressed: onSelectImage,
                  icon: Icons.refresh,
                  isPrimary: false,
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Upload dropzone
    return GestureDetector(
      onTap: onSelectImage,
      child: Container(
        key: uploadKey,
        height: 500,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.2),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 50,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Drop your image here',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Text(
              'or click to browse',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Supports: JPG, PNG, WebP',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
