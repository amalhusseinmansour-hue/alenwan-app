// lib/views/auth/login_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/professional_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authController = context.read<AuthController>();
      await authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted && authController.user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسجيل الدخول: $e'),
            backgroundColor: ProfessionalTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authController = context.read<AuthController>();
      final success = await authController.signInWithGoogle();

      if (mounted) {
        if (success && authController.user != null) {
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل تسجيل الدخول بحساب Google'),
              backgroundColor: ProfessionalTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: ProfessionalTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundPrimary,
        body: Stack(
          children: [
            // Animated Background
            _buildAnimatedBackground(),

            // Main Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildLoginForm(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              ProfessionalTheme.backgroundPrimary,
              ProfessionalTheme.backgroundSecondary,
              ProfessionalTheme.primaryBrand.withOpacity(0.1),
            ],
          ),
        ),
        child: CustomPaint(
          painter: _LoginBackgroundPainter(),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalTheme.surfaceCard.withOpacity(0.9),
            ProfessionalTheme.surfaceCard.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusXL),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: ProfessionalTheme.cardShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo and Title
            _buildHeader(),

            const SizedBox(height: 32),

            // Email Field
            _buildEmailField(),

            const SizedBox(height: 20),

            // Password Field
            _buildPasswordField(),

            const SizedBox(height: 16),

            // Forgot Password
            _buildForgotPassword(),

            const SizedBox(height: 32),

            // Login Button
            _buildLoginButton(),

            const SizedBox(height: 24),

            // Social Login
            _buildSocialLogin(),

            const SizedBox(height: 24),

            // Sign Up Link
            _buildSignUpLink(),

            const SizedBox(height: 16),

            // Guest Login Button
            _buildGuestLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: ProfessionalTheme.premiumGradient,
            shape: BoxShape.circle,
            boxShadow: ProfessionalTheme.glowShadow,
          ),
          child: const Icon(
            Icons.play_circle_filled,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'مرحباً بك',
          style: ProfessionalTheme.displaySmall(
            color: ProfessionalTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'قم بتسجيل الدخول للمتابعة',
          style: ProfessionalTheme.bodyLarge(
            color: ProfessionalTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال البريد الإلكتروني';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'بريد إلكتروني غير صحيح';
        }
        return null;
      },
      style: ProfessionalTheme.bodyLarge(color: ProfessionalTheme.textPrimary),
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني',
        labelStyle: ProfessionalTheme.bodyMedium(
          color: ProfessionalTheme.textSecondary,
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: ProfessionalTheme.primaryBrand,
        ),
        filled: true,
        fillColor: ProfessionalTheme.backgroundElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
          borderSide: BorderSide(
            color: ProfessionalTheme.primaryBrand,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
          borderSide: BorderSide(
            color: ProfessionalTheme.errorColor,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _login(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال كلمة المرور';
        }
        if (value.length < 6) {
          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        }
        return null;
      },
      style: ProfessionalTheme.bodyLarge(color: ProfessionalTheme.textPrimary),
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        labelStyle: ProfessionalTheme.bodyMedium(
          color: ProfessionalTheme.textSecondary,
        ),
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: ProfessionalTheme.primaryBrand,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: ProfessionalTheme.textTertiary,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        filled: true,
        fillColor: ProfessionalTheme.backgroundElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
          borderSide: BorderSide(
            color: ProfessionalTheme.primaryBrand,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
          borderSide: BorderSide(
            color: ProfessionalTheme.errorColor,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.forgotPassword);
        },
        child: Text(
          'نسيت كلمة المرور؟',
          style: ProfessionalTheme.bodyMedium(
            color: ProfessionalTheme.primaryBrand,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: ProfessionalTheme.primaryBrand,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            Colors.white.withOpacity(0.1),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'تسجيل الدخول',
                style: ProfessionalTheme.titleMedium(
                  color: Colors.white,
                  weight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: ProfessionalTheme.textTertiary)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'أو',
                style: ProfessionalTheme.bodySmall(
                  color: ProfessionalTheme.textTertiary,
                ),
              ),
            ),
            Expanded(child: Divider(color: ProfessionalTheme.textTertiary)),
          ],
        ),
        const SizedBox(height: 16),

        // Google Sign-In Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: Image.asset(
              'assets/images/google_logo.png',
              height: 22,
              width: 22,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.g_mobiledata, size: 30);
              },
            ),
            label: const Text('تسجيل الدخول بحساب Google'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟ ',
          style: ProfessionalTheme.bodyMedium(
            color: ProfessionalTheme.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.register);
          },
          child: Text(
            'إنشاء حساب',
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.primaryBrand,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestLoginButton() {
    return OutlinedButton(
      onPressed: _handleGuestLogin,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
          color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            color: ProfessionalTheme.primaryBrand,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'الدخول كضيف',
            style: ProfessionalTheme.bodyLarge(
              color: ProfessionalTheme.primaryBrand,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGuestLogin() async {
    // Enable guest mode immediately without loading state
    try {
      final authController = context.read<AuthController>();
      await authController.loginAsGuest();

      // Navigate to home as guest without authentication
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: ProfessionalTheme.errorColor,
          ),
        );
      }
    }
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = ProfessionalTheme.primaryBrand.withOpacity(0.05);

    // Draw floating circles
    for (int i = 0; i < 5; i++) {
      final radius = 40.0 + (i * 20);
      final center = Offset(
        size.width * (0.1 + i * 0.2),
        size.height * (0.2 + i * 0.15),
      );
      canvas.drawCircle(center, radius, paint);
    }

    // Draw gradient overlay
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        ProfessionalTheme.primaryBrand.withOpacity(0.1),
        Colors.transparent,
        ProfessionalTheme.primaryBrand.withOpacity(0.05),
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
