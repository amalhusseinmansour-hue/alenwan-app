import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/professional_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthController>();
    final ok = await auth.resetPassword(
      token: widget.token,
      email: widget.email,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (ok) {
      _showSnackBar('password_reset_success'.tr(), isError: false);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } else {
      _showSnackBar(
        auth.error ?? 'password_reset_failed'.tr(),
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: ProfessionalTheme.bodyMedium(
            color: ProfessionalTheme.textPrimary,
          ),
        ),
        backgroundColor: isError
            ? ProfessionalTheme.errorColor
            : ProfessionalTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundPrimary,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      _buildLogo(),
                      const SizedBox(height: 32),

                      // Title
                      _buildTitle(),
                      const SizedBox(height: 40),

                      // Form card
                      _buildFormCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.primaryBrand.withOpacity(0.3 * value),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ProfessionalTheme.primaryBrand.withOpacity(0.2),
                      ProfessionalTheme.secondaryBrand.withOpacity(0.2),
                    ],
                  ),
                  border: Border.all(
                    color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/logo-alenwan.jpeg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'reset_password'.tr(),
          style: ProfessionalTheme.headlineMedium(
            color: ProfessionalTheme.textPrimary,
            weight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'reset_password_description'.tr(),
          style: ProfessionalTheme.bodyLarge(
            color: ProfessionalTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: ProfessionalTheme.glassMorphism,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Password field
          _buildPasswordField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            hint: 'new_password'.tr(),
            obscureText: _obscure1,
            onToggle: () => setState(() => _obscure1 = !_obscure1),
            validator: (v) => (v == null || v.length < 6)
                ? 'min_6_chars'.tr()
                : null,
          ),
          const SizedBox(height: 16),

          // Confirm password field
          _buildPasswordField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            hint: 'confirm_password'.tr(),
            obscureText: _obscure2,
            onToggle: () => setState(() => _obscure2 = !_obscure2),
            validator: (v) => v != _passwordController.text
                ? 'password_mismatch'.tr()
                : null,
          ),
          const SizedBox(height: 24),

          // Reset button
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: ProfessionalTheme.durationFast,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
            border: Border.all(
              color: isFocused
                  ? ProfessionalTheme.primaryBrand
                  : ProfessionalTheme.textTertiary.withOpacity(0.2),
              width: isFocused ? 2 : 1,
            ),
            color: isFocused
                ? ProfessionalTheme.surfaceHover
                : ProfessionalTheme.surfaceCard,
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            validator: validator,
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.textTertiary,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: isFocused
                    ? ProfessionalTheme.primaryBrand
                    : ProfessionalTheme.textSecondary,
                size: 22,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  onToggle();
                  HapticFeedback.lightImpact();
                },
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: ProfessionalTheme.textSecondary,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorStyle: ProfessionalTheme.bodySmall(
                color: ProfessionalTheme.errorColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResetButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 1.0, end: _isLoading ? 0.95 : 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
              gradient: ProfessionalTheme.premiumGradient,
              boxShadow: ProfessionalTheme.buttonShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                onTap: _isLoading
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        _resetPassword();
                      },
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: ProfessionalTheme.textPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'reset_password'.tr(),
                          style: ProfessionalTheme.titleMedium(
                            color: ProfessionalTheme.textPrimary,
                            weight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}