import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/premium_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() { _errorMessage = null; });
      }
    });
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    if (_authService.isLoggedIn && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      if (_tabController.index == 0) {
        await _authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw 'Passwords do not match';
        }
        await _authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() { _errorMessage = e.toString(); });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final result = _tabController.index == 0
          ? await _authService.signInWithGoogle()
          : await _authService.signUpWithGoogle();
      if (result != null && mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() { _errorMessage = e.toString(); });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          Container(color: theme.scaffoldBackgroundColor),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- App Branding ---
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.premiumGradient(isDark),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 25, spreadRadius: 1,
                          )],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.premiumGradient(isDark).createShader(bounds),
                      child: Text(
                        'DeepFract',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SECURE NEURAL GATEWAY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // --- Glassmorphic Container ---
                    Container(
                      decoration: AppTheme.glassDecoration(isDark: isDark),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                // Custom Segmented Tab
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: TabBar(
                                    controller: _tabController,
                                    indicator: BoxDecoration(
                                      color: isDark ? Colors.white : Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 4, offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    labelColor: isDark ? Colors.black : Colors.white,
                                    unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    dividerColor: Colors.transparent,
                                    labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                    tabs: const [Tab(text: 'LOGIN'), Tab(text: 'JOIN')],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      _buildField(
                                        controller: _emailController,
                                        label: 'Email Identity',
                                        icon: Icons.alternate_email_rounded,
                                        isDark: isDark,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildField(
                                        controller: _passwordController,
                                        label: 'Access Key',
                                        icon: Icons.key_rounded,
                                        obscure: _obscurePassword,
                                        isDark: isDark,
                                        suffix: IconButton(
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                            size: 20,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                          ),
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                      ),
                                      
                                      AnimatedBuilder(
                                        animation: _tabController,
                                        builder: (ctx, _) => _tabController.index == 1 
                                          ? Padding(
                                              padding: const EdgeInsets.only(top: 20),
                                              child: _buildField(
                                                controller: _confirmPasswordController,
                                                label: 'Verify Key',
                                                icon: Icons.verified_user_rounded,
                                                obscure: _obscurePassword,
                                                isDark: isDark,
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),

                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 20),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.redAccent.shade100, fontSize: 13, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                ],

                                const SizedBox(height: 32),
                                
                                PremiumButton(
                                  text: _isLoading ? 'CONNECTING...' : (_tabController.index == 0 ? 'LOGIN' : 'CREATE ACCOUNT'),
                                  onPressed: _isLoading ? null : _handleEmailAuth,
                                  isPrimary: true,
                                  isFullWidth: true,
                                ),
                                
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text('OR', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                                    ),
                                    Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                // Modern Social Auth
                                OutlinedButton(
                                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 56),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.g_mobiledata_rounded, size: 32),
                                      const SizedBox(width: 8),
                                      Text('CONTINUE WITH GOOGLE', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    if (!kIsWeb) ...[
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                        child: Text(
                          'CONTINUE AS GUEST',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
        suffixIcon: suffix,
        filled: true,
        fillColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}

