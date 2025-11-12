import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

import '../../controllers/auth_controller.dart';
import '../../core/theme/professional_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _loading = false;

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
    _emailController.dispose();
    _emailFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('enter_email'.tr(), isError: true);
      return;
    }

    setState(() => _loading = true);
    final auth = context.read<AuthController>();

    try {
      final res = await auth.forgotPassword(email);

      if (!mounted) return;

      _showSnackBar(
        res
            ? 'password_reset_sent'.tr()
            : 'password_reset_failed'.tr(),
        isError: !res,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('password_reset_failed'.tr(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        icon: Icon(
          Icons.arrow_back,
          color: ProfessionalTheme.textPrimary,
        ),
      ),
      title: Text(
        'forgot_password'.tr(),
        style: ProfessionalTheme.titleLarge(
          color: ProfessionalTheme.textPrimary,
          weight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
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
                      // Icon
                      _buildIcon(),
                      const SizedBox(height: 32),

                      // Title and description
                      _buildTitleSection(),
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

  Widget _buildIcon() {
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
              gradient: ProfessionalTheme.premiumGradient,
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.primaryBrand.withOpacity(0.3 * value),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.lock_reset_outlined,
              size: 60,
              color: ProfessionalTheme.textPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'forgot_password'.tr(),
          style: ProfessionalTheme.headlineMedium(
            color: ProfessionalTheme.textPrimary,
            weight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'forgot_password_description'.tr(),
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
          // Email field
          _buildEmailField(),
          const SizedBox(height: 24),

          // Submit button
          _buildSubmitButton(),
          const SizedBox(height: 16),

          // Back to login link
          _buildBackToLoginLink(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return AnimatedBuilder(
      animation: _emailFocus,
      builder: (context, child) {
        final isFocused = _emailFocus.hasFocus;
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
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'email'.tr(),
              hintStyle: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.textTertiary,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: isFocused
                    ? ProfessionalTheme.primaryBrand
                    : ProfessionalTheme.textSecondary,
                size: 22,
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'enter_email'.tr();
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'invalid_email'.tr();
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 1.0, end: _loading ? 0.95 : 1.0),
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
                onTap: _loading
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        _submit();
                      },
                child: Center(
                  child: _loading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: ProfessionalTheme.textPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'send_reset_link'.tr(),
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

  Widget _buildBackToLoginLink() {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: ProfessionalTheme.bodyMedium(
            color: ProfessionalTheme.textSecondary,
          ),
          children: [
            TextSpan(text: '${'remember_password'.tr()} '),
            TextSpan(
              text: 'back_to_login'.tr(),
              style: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.primaryBrand,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}