// lib/views/auth/login_screen.dart
import 'dart:ui' as ui;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/professional_theme.dart';
import '../../models/auth_settings_model.dart';
import '../../core/services/app_settings_service.dart';
import 'social_login_buttons.dart';

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
  AuthSettingsModel? _authSettings;
  bool _isLoadingSettings = true;

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
    _loadAuthSettings();
  }

  Future<void> _loadAuthSettings() async {
    try {
      final settings = await AppSettingsService().getAuthSettings();
      if (mounted) {
        setState(() {
          _authSettings = settings;
          _isLoadingSettings = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading auth settings: $e');
      if (mounted) {
        setState(() {
          _authSettings = AuthSettingsModel.defaultSettings();
          _isLoadingSettings = false;
        });
      }
    }
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
      final success = await authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success && authController.user != null) {
          // Show success message briefly before navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'مرحباً ${authController.user?['name'] ?? ''}! تم تسجيل الدخول بنجاح',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate after a brief delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.main);
            }
          });
        } else {
          // Get the error message from the controller
          final errorMessage =
              authController.error ?? 'بيانات الدخول غير صحيحة';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'خطأ في تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          errorMessage,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: ProfessionalTheme.errorColor,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'إغلاق',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );

          // Clear the error after showing it
          authController.clearError();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'حدث خطأ غير متوقع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: ProfessionalTheme.errorColor,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'إغلاق',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ignore: unused_element
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authController = context.read<AuthController>();
      final success = await authController.signInWithGoogle();

      if (mounted) {
        if (success && authController.user != null) {
          // Show success message briefly before navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'مرحباً ${authController.user?['name'] ?? ''}! تم تسجيل الدخول بنجاح',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate after a brief delay to show the success message
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.main);
            }
          });
        } else {
          // Get the error message from the controller
          final errorMessage =
              authController.error ?? 'فشل تسجيل الدخول بحساب Google';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'خطأ في تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          errorMessage,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: ProfessionalTheme.errorColor,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'إغلاق',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );

          // Clear the error after showing it
          authController.clearError();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'حدث خطأ غير متوقع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: ProfessionalTheme.errorColor,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'إغلاق',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
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
              ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
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
            ProfessionalTheme.surfaceCard.withValues(alpha: 0.9),
            ProfessionalTheme.surfaceCard.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusXL),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
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

            // Sign Up Link
            _buildSignUpLink(),

            const SizedBox(height: 16),

            // Guest Login Button
            _buildGuestLoginButton(),

            const SizedBox(height: 24),

            // Social Login Buttons
            _buildSocialLogins(),
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
        prefixIcon: const Icon(
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
          borderSide: const BorderSide(
            color: ProfessionalTheme.primaryBrand,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
          borderSide: const BorderSide(
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
        prefixIcon: const Icon(
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
          borderSide: const BorderSide(
            color: ProfessionalTheme.primaryBrand,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
          borderSide: const BorderSide(
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
            Colors.white.withValues(alpha: 0.1),
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
    // Check if guest mode is enabled (default to true if settings not loaded yet)
    final bool isGuestEnabled = _authSettings?.enableGuestMode ?? true;

    if (!isGuestEnabled) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGuestLogin,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.5),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ProfessionalTheme.primaryBrand,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: ProfessionalTheme.primaryBrand,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'الدخول كضيف',
                    style: ProfessionalTheme.titleMedium(
                      color: ProfessionalTheme.primaryBrand,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSocialLogins() {
    // Check if any social login is enabled
    final bool googleEnabled = _authSettings?.enableGoogleLogin ?? true;
    final bool appleEnabled = _authSettings?.enableAppleLogin ?? true;

    // If both are disabled, don't show the widget
    if (!googleEnabled && !appleEnabled) {
      return const SizedBox.shrink();
    }

    return SocialLoginRow(
      onGoogle: googleEnabled ? _handleGoogleSignIn : null,
      onApple: appleEnabled && (!kIsWeb && Platform.isIOS || kIsWeb)
          ? _handleAppleSignIn
          : null,
      onPhoneOrWhatsApp: null, // يمكن إضافة OTP لاحقاً
    );
  }

  void _handleGoogleSignIn() async {
    final authController = context.read<AuthController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final success = await authController.signInWithGoogle();

      if (!mounted) return;

      if (success) {
        navigator.pushReplacementNamed(AppRoutes.home);
      } else if (authController.error != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(authController.error!),
            backgroundColor: ProfessionalTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('فشل تسجيل الدخول عبر Google: $e'),
          backgroundColor: ProfessionalTheme.errorColor,
        ),
      );
    }
  }

  void _handleAppleSignIn() async {
    final authController = context.read<AuthController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final success = await authController.signInWithApple();

      if (!mounted) return;

      if (success) {
        navigator.pushReplacementNamed(AppRoutes.home);
      } else if (authController.error != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(authController.error!),
            backgroundColor: ProfessionalTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('فشل تسجيل الدخول عبر Apple: $e'),
          backgroundColor: ProfessionalTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _handleGuestLogin() async {
    if (_isLoading) return; // منع النقرات المتعددة

    setState(() => _isLoading = true);

    try {
      final authController = context.read<AuthController>();

      debugPrint('🔵 [LoginScreen] Starting guest login...');

      // تفعيل وضع الضيف
      await authController.loginAsGuest();

      if (!mounted) return;

      // التحقق من تفعيل وضع الضيف مباشرة من الذاكرة
      if (authController.isGuestMode) {
        debugPrint('✅ [LoginScreen] Guest mode enabled successfully');
        
        // عرض رسالة نجاح سريعة
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مرحباً بك! جاري الدخول...'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1000),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // التوجيه فوراً إلى الشاشة الرئيسية
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.main,
          (route) => false,
        );
      } else {
        throw Exception('فشل تفعيل وضع الضيف');
      }
    } catch (e) {
      debugPrint('❌ [LoginScreen] Guest login error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: ProfessionalTheme.errorColor,
            behavior: SnackBarBehavior.floating,
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
      ..color = ProfessionalTheme.primaryBrand.withValues(alpha: 0.05);

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
        ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
        Colors.transparent,
        ProfessionalTheme.primaryBrand.withValues(alpha: 0.05),
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
