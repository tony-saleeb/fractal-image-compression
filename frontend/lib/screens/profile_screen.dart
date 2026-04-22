import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/theme_provider.dart';
import '../utils/theme.dart';
import '../widgets/theme_switcher.dart';
import '../widgets/animated_background.dart';

/// Premium profile screen with modern Apple-inspired design.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Show web-specific design on web platform (simplified unified logic)
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      body: Stack(
        children: [
          // Global Animated Background
          const AnimatedBackground(),

          SafeArea(
            child: Column(
              children: [
                // Top Nav Bar
                _buildModernNavbar(context),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 60 : 20,
                      vertical: 30,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: isDesktop 
                          ? _buildDesktopLayout(context) 
                          : _buildMobileLayout(context),
                      ),
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

  Widget _buildModernNavbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildCircleButton(
            context,
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildCircleButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: AppTheme.glassDecoration(isDark: isDark, opacity: 0.1),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildIdentityPanel(context)),
        const SizedBox(width: 32),
        Expanded(flex: 3, child: _buildSettingsPanel(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildIdentityPanel(context),
        const SizedBox(height: 24),
        _buildSettingsPanel(context),
      ],
    );
  }

  Widget _buildIdentityPanel(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: AppTheme.glassDecoration(isDark: isDark),
      child: Column(
        children: [
          // Pulsing Avatar
          _buildPulsingAvatar(context, user, primary),
          const SizedBox(height: 28),

          // Username with Gradient
          ShaderMask(
            shaderCallback: (bounds) => AppTheme.premiumGradient.createShader(bounds),
            child: Text(
              user?.displayName ?? 'DeepFract User',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'user@deepfract.ai',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),

          const SizedBox(height: 32),
          
          // Tactical Stats Tiles
          _buildStatsRow(context, isDark, primary),

          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Text(
            'DeepFract v1.0.0 Stable',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingAvatar(BuildContext context, User? user, Color primary) {
    const String defaultAvatarUrl = 'https://images.unsplash.com/photo-1675271591211-126ad94e495d?q=80&w=200&auto=format&fit=crop';
    final photoUrl = user?.photoURL;
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primary.withValues(alpha: 0.2), width: 2),
      ),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primary.withValues(alpha: 0.1),
        ),
        child: ClipOval(
          child: photoUrl != null
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to premium default if network image fails (CORS error)
                  return Image.network(
                    defaultAvatarUrl,
                    fit: BoxFit.cover,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    ),
                  );
                },
              )
            : Image.network(
                defaultAvatarUrl,
                fit: BoxFit.cover,
              ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isDark, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatTile(context, '12', 'Tasks', Icons.auto_graph_rounded),
        _buildStatTile(context, '140MB', 'Saved', Icons.bolt_rounded),
        _buildStatTile(context, 'Pro', 'Level', Icons.verified_user_rounded),
      ],
    );
  }

  Widget _buildStatTile(BuildContext context, String value, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: _HoverScale(
        child: Column(
          children: [
            Icon(icon, color: primary, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.glassDecoration(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 24),
          
          _buildSettingsGroup(
            context,
            title: 'Appearance',
            children: [
              _buildSettingTile(
                context,
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                title: 'Dark Aesthetic',
                trailing: Switch(
                  value: isDark,
                  onChanged: (val) {
                    ThemeSwitcher.of(context).changeTheme(() {
                      themeProvider.toggleTheme();
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),

          _buildSettingsGroup(
            context,
            title: 'Account',
            children: [
              _buildSettingTile(
                context,
                icon: Icons.security_rounded,
                title: 'Privacy & Security',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.history_rounded,
                title: 'Compression History',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                titleColor: Colors.redAccent,
                onTap: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Colors.grey),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingTile(BuildContext context, {required IconData icon, required String title, Color? titleColor, Widget? trailing, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _HoverScale(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: isDark ? 0.05 : 0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: titleColor ?? Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              trailing ?? Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? Colors.white38 : Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverScale extends StatefulWidget {
  final Widget child;
  const _HoverScale({required this.child});

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
