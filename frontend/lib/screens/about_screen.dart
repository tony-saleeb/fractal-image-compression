import 'package:flutter/material.dart';

/// About screen explaining DeepFract's fractal compression technology.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [
                      primaryColor.withValues(alpha: 0.15),
                      Theme.of(context).scaffoldBackgroundColor,
                    ]
                    : [
                      primaryColor.withValues(alpha: 0.08),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _buildBackButton(context, isDark),
                      const Expanded(
                        child: Text(
                          'About',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // App Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        primaryColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.compress,
                    color: Colors.white,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 20),

                // App Name
                Text(
                  'DeepFract',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'AI-Powered Fractal Image Compression',
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 32),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // What is Fractal Compression
                      _buildSectionCard(
                        context,
                        isDark,
                        icon: Icons.auto_awesome,
                        iconColor: Colors.purple,
                        title: 'What is Fractal Compression?',
                        content:
                            'Fractal image compression is a revolutionary technique that '
                            'exploits self-similarity within images. Unlike traditional methods, '
                            'it identifies patterns that repeat at different scales, achieving '
                            'exceptional compression ratios while preserving image quality.\n\n'
                            'This approach is particularly effective for natural images '
                            'containing textures, landscapes, and complex visual patterns.',
                      ),

                      const SizedBox(height: 16),

                      // Neural Network Optimization
                      _buildSectionCard(
                        context,
                        isDark,
                        icon: Icons.psychology,
                        iconColor: Colors.blue,
                        title: 'Neural Network Optimization',
                        content:
                            'DeepFract leverages advanced neural networks to intelligently '
                            'optimize the compression process. Our AI engine simultaneously '
                            'considers three critical parameters to deliver the best results:',
                      ),

                      const SizedBox(height: 16),

                      // Three Parameters
                      _buildParameterCard(
                        context,
                        isDark,
                        primaryColor,
                        parameters: [
                          _ParameterInfo(
                            icon: Icons.high_quality,
                            color: Colors.green,
                            title: 'Fidelity (Quality)',
                            description:
                                'Preserves visual quality and fine details. '
                                'The neural network learns to minimize perceptual loss, '
                                'ensuring compressed images look nearly identical to originals.',
                          ),
                          _ParameterInfo(
                            icon: Icons.speed,
                            color: Colors.orange,
                            title: 'Time Complexity',
                            description:
                                'Optimizes processing speed without sacrificing quality. '
                                'Our model finds the fastest encoding path while maintaining '
                                'compression efficiency.',
                          ),
                          _ParameterInfo(
                            icon: Icons.compress,
                            color: Colors.red,
                            title: 'Image Size',
                            description:
                                'Achieves maximum compression ratios. The AI balances '
                                'aggressive size reduction with quality preservation, '
                                'often reducing images by up to 90%.',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // How it Works
                      _buildSectionCard(
                        context,
                        isDark,
                        icon: Icons.architecture,
                        iconColor: Colors.teal,
                        title: 'How It Works',
                        content:
                            '1. The image is divided into range blocks\n'
                            '2. Domain blocks are searched for self-similar patterns\n'
                            '3. Neural networks predict optimal transformations\n'
                            '4. Only transformation parameters are stored\n'
                            '5. Images can be reconstructed at any resolution\n\n'
                            'This approach means extremely small file sizes with '
                            'resolution-independent quality.',
                      ),

                      const SizedBox(height: 32),

                      // Footer
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Made with ❤️ for better compression',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '© 2024 DeepFract',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white24 : Colors.black26,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
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

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.arrow_back_ios_new, size: 20),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(
    BuildContext context,
    bool isDark,
    Color primaryColor, {
    required List<_ParameterInfo> parameters,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [
                    primaryColor.withValues(alpha: 0.15),
                    primaryColor.withValues(alpha: 0.05),
                  ]
                  : [
                    primaryColor.withValues(alpha: 0.08),
                    primaryColor.withValues(alpha: 0.02),
                  ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.tune, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 14),
              const Text(
                'Three Key Parameters',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...parameters.map(
            (param) => _buildParameterItem(context, isDark, param),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterItem(
    BuildContext context,
    bool isDark,
    _ParameterInfo param,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: param.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(param.icon, color: param.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  param.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: param.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  param.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? Colors.white60 : Colors.black54,
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

class _ParameterInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  _ParameterInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
