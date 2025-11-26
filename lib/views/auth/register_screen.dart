import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/professional_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  String _selectedCountryCode = '+966';

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _formController;
  late AnimationController _particleController;
  late AnimationController _floatingController;

  // Animations
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  // Focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

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
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _floatingAnimation = Tween<double>(
      begin: -15.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _formController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _backgroundController.dispose();
    _formController.dispose();
    _particleController.dispose();
    _floatingController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    final authController = context.read<AuthController>();

    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!_agreeToTerms) {
      HapticFeedback.mediumImpact();
      messenger.showSnackBar(
        SnackBar(
          content: Text('agree_terms'.tr()),
          backgroundColor: ProfessionalTheme.errorColor,
        ),
      );
      return;
    }

    if (authController.isLoading) return;

    HapticFeedback.mediumImpact();
    await authController.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _selectedCountryCode + _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (authController.error != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(authController.error!),
          backgroundColor: ProfessionalTheme.errorColor,
        ),
      );
      authController.clearError();
    } else {
      navigator.pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundPrimary,
        body: Stack(
          children: [
            // Animated gradient background
            _buildAnimatedBackground(size),

            // Particles
            _buildParticles(size),

            // Glass layer
            _buildGlassLayer(),

            // Floating orbs
            _buildFloatingOrbs(size),

            // Main content
            _buildMainContent(size, authController),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.cos(_backgroundController.value * 2 * math.pi) * 0.3,
                math.sin(_backgroundController.value * 2 * math.pi) * 0.3,
              ),
              radius: 1.8,
              colors: [
                ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                ProfessionalTheme.backgroundPrimary,
                ProfessionalTheme.backgroundPrimary,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            size: size,
            painter: RegisterBackgroundPainter(
              animation: _backgroundController.value,
              primaryColor: ProfessionalTheme.primaryBrand,
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticles(Size size) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: StarParticlesPainter(
            animation: _particleController.value,
            color: ProfessionalTheme.primaryBrand,
          ),
        );
      },
    );
  }

  Widget _buildGlassLayer() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          color: ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Widget _buildFloatingOrbs(Size size) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: size.height * 0.05 + _floatingAnimation.value,
              right: size.width * 0.1,
              child: _buildOrb(45, 0.08),
            ),
            Positioned(
              bottom: size.height * 0.1 - _floatingAnimation.value * 0.7,
              left: size.width * 0.08,
              child: _buildOrb(55, 0.06),
            ),
            Positioned(
              top: size.height * 0.5 + _floatingAnimation.value * 0.5,
              right: size.width * 0.85,
              child: _buildOrb(35, 0.1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrb(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            ProfessionalTheme.primaryBrand.withValues(alpha: opacity),
            ProfessionalTheme.primaryBrand.withValues(alpha: 0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ProfessionalTheme.primaryBrand.withValues(alpha: opacity * 0.7),
            blurRadius: 25,
            spreadRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(Size size, AuthController authController) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _fadeInAnimation,
              _slideAnimation,
              _scaleAnimation,
            ]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeInAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: size.width > 600 ? 480 : size.width * 0.9,
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Logo
                            _buildLogo(),
                            const SizedBox(height: 30),

                            // Title
                            _buildTitle(),
                            const SizedBox(height: 35),

                            // Form card
                            _buildFormCard(authController),
                            const SizedBox(height: 24),

                            // Login link
                            _buildLoginLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
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
          scale: 0.7 + (0.3 * value),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.4 * value),
                  blurRadius: 35,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                        ProfessionalTheme.secondaryBrand.withValues(alpha: 0.2),
                      ],
                    ),
                    border: Border.all(
                      color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      'assets/images/logo-alenwan.jpeg',
                      fit: BoxFit.contain,
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

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              ProfessionalTheme.accentBrand,
              ProfessionalTheme.primaryBrand,
              ProfessionalTheme.secondaryBrand,
            ],
          ).createShader(bounds),
          child: Text(
            'create_account'.tr(),
            style: ProfessionalTheme.headlineMedium(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'join_us'.tr(),
          style: ProfessionalTheme.bodyMedium(
            color: ProfessionalTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(AuthController authController) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ProfessionalTheme.surfaceCard.withValues(alpha: 0.6),
                ProfessionalTheme.surfaceCard.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
            border: Border.all(
              color: ProfessionalTheme.textTertiary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Name field
              _buildModernTextField(
                controller: _nameController,
                focusNode: _nameFocus,
                hint: 'full_name'.tr(),
                icon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'enter_name'.tr() : null,
              ),
              const SizedBox(height: 14),

              // Email field
              _buildModernTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                hint: 'email'.tr(),
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'enter_email'.tr();
                  }
                  final r = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!r.hasMatch(v.trim())) {
                    return 'invalid_email'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Phone field with country code
              _buildPhoneField(),
              const SizedBox(height: 14),

              // Password field
              _buildPasswordField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                hint: 'password'.tr(),
                obscureText: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: (v) =>
                    (v == null || v.length < 8) ? 'min_8_chars'.tr() : null,
              ),
              const SizedBox(height: 14),

              // Confirm password field
              _buildPasswordField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                hint: 'confirm_password'.tr(),
                obscureText: _obscureConfirmPassword,
                onToggle: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (v) => (v != _passwordController.text)
                    ? 'password_mismatch'.tr()
                    : null,
              ),
              const SizedBox(height: 16),

              // Terms checkbox
              _buildTermsCheckbox(),
              const SizedBox(height: 20),

              // Register button
              _buildRegisterButton(authController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
                  : ProfessionalTheme.textTertiary.withValues(alpha: 0.1),
              width: isFocused ? 2 : 1,
            ),
            color: isFocused
                ? ProfessionalTheme.surfaceHover
                : ProfessionalTheme.surfaceCard,
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
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
                icon,
                color: isFocused
                    ? ProfessionalTheme.primaryBrand
                    : ProfessionalTheme.textSecondary,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
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

  Widget _buildPhoneField() {
    return AnimatedBuilder(
      animation: _phoneFocus,
      builder: (context, child) {
        final isFocused = _phoneFocus.hasFocus;
        return Row(
          children: [
            AnimatedContainer(
              duration: ProfessionalTheme.durationFast,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                border: Border.all(
                  color: isFocused
                      ? ProfessionalTheme.primaryBrand
                      : ProfessionalTheme.textTertiary.withValues(alpha: 0.1),
                  width: isFocused ? 2 : 1,
                ),
                color: isFocused
                    ? ProfessionalTheme.surfaceHover
                    : ProfessionalTheme.surfaceCard,
              ),
              child: CountryCodePicker(
                onChanged: (cc) => _selectedCountryCode = cc.dialCode ?? '+966',
                initialSelection: 'SA',
                favorite: const ['+966', 'SA', '+971', 'AE', '+20', 'EG'],
                textStyle: ProfessionalTheme.bodyMedium(color: ProfessionalTheme.textPrimary),
                dialogTextStyle: ProfessionalTheme.bodyMedium(color: ProfessionalTheme.textInverse),
                showFlagDialog: true,
                showDropDownButton: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AnimatedContainer(
                duration: ProfessionalTheme.durationFast,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                  border: Border.all(
                    color: isFocused
                        ? ProfessionalTheme.primaryBrand
                        : ProfessionalTheme.textTertiary.withValues(alpha: 0.1),
                    width: isFocused ? 2 : 1,
                  ),
                  color: isFocused
                      ? ProfessionalTheme.surfaceHover
                      : ProfessionalTheme.surfaceCard,
                ),
                child: TextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  style: ProfessionalTheme.bodyMedium(color: ProfessionalTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'phone_number'.tr(),
                    hintStyle: ProfessionalTheme.bodyMedium(
                      color: ProfessionalTheme.textTertiary,
                    ),
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: isFocused
                          ? ProfessionalTheme.primaryBrand
                          : ProfessionalTheme.textSecondary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
                  : ProfessionalTheme.textTertiary.withValues(alpha: 0.1),
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
            style: ProfessionalTheme.bodyMedium(color: ProfessionalTheme.textPrimary),
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
                size: 20,
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
                vertical: 14,
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

  Widget _buildTermsCheckbox() {
    return InkWell(
      onTap: () {
        setState(() => _agreeToTerms = !_agreeToTerms);
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _agreeToTerms
                      ? ProfessionalTheme.primaryBrand
                      : ProfessionalTheme.textTertiary,
                  width: 2,
                ),
                color: _agreeToTerms
                    ? ProfessionalTheme.primaryBrand.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: _agreeToTerms
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: ProfessionalTheme.primaryBrand,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'agree_terms'.tr(),
                style: ProfessionalTheme.bodyMedium(
                  color: ProfessionalTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton(AuthController authController) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 1.0, end: authController.isLoading ? 0.95 : 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
              gradient: ProfessionalTheme.premiumGradient,
              boxShadow: ProfessionalTheme.buttonShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                onTap: authController.isLoading
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        _register();
                      },
                child: Center(
                  child: authController.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: ProfessionalTheme.textPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'register'.tr(),
                          style: ProfessionalTheme.titleMedium(
                            color: ProfessionalTheme.textPrimary,
                            weight: FontWeight.bold,
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

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      },
      child: RichText(
        text: TextSpan(
          style: ProfessionalTheme.bodyMedium(
            color: ProfessionalTheme.textSecondary,
          ),
          children: [
            TextSpan(text: '${'already_have_account'.tr()} '),
            TextSpan(
              text: 'login'.tr(),
              style: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.primaryBrand,
                weight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Background Painter
class RegisterBackgroundPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;

  RegisterBackgroundPainter({
    required this.animation,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw animated diamond grid
    for (int i = 0; i < 10; i++) {
      final progress = (animation + i * 0.1) % 1.0;
      final opacity = (1.0 - progress) * 0.12;

      paint.color = primaryColor.withValues(alpha: opacity);

      final center = Offset(
        size.width * 0.5 + math.cos(animation * 2 * math.pi + i * 0.5) * 80,
        size.height * 0.5 + math.sin(animation * 2 * math.pi + i * 0.5) * 80,
      );

      final radius = size.width * 0.35 * progress;

      // Draw diamond shape
      final path = Path();
      path.moveTo(center.dx, center.dy - radius);
      path.lineTo(center.dx + radius * 0.7, center.dy);
      path.lineTo(center.dx, center.dy + radius);
      path.lineTo(center.dx - radius * 0.7, center.dy);
      path.close();

      canvas.drawPath(path, paint);

      // Draw inner lines
      if (i % 2 == 0) {
        paint.strokeWidth = 0.5;
        canvas.drawLine(
          Offset(center.dx - radius * 0.5, center.dy),
          Offset(center.dx + radius * 0.5, center.dy),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - radius * 0.5),
          Offset(center.dx, center.dy + radius * 0.5),
          paint,
        );
        paint.strokeWidth = 1.0;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Star Particles Painter
class StarParticlesPainter extends CustomPainter {
  final double animation;
  final Color color;

  StarParticlesPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 25; i++) {
      final progress = (animation + i * 0.04) % 1.0;
      final opacity = math.sin(progress * math.pi) * 0.25;

      paint.color = color.withValues(alpha: opacity);

      final x = size.width * (0.05 + (i * 0.13) % 0.9);
      final y = size.height * (1.0 - progress);

      // Draw star shape
      final starPath = Path();
      const starPoints = 5;
      const innerRadius = 2.0;
      const outerRadius = 5.0;

      for (int j = 0; j < starPoints * 2; j++) {
        final angle = (j * math.pi) / starPoints;
        final radius = j.isEven ? outerRadius : innerRadius;
        final px = x + radius * math.cos(angle - math.pi / 2);
        final py = y + radius * math.sin(angle - math.pi / 2);

        if (j == 0) {
          starPath.moveTo(px, py);
        } else {
          starPath.lineTo(px, py);
        }
      }
      starPath.close();

      canvas.drawPath(starPath, paint);

      // Draw glow
      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      glowPaint.color = color.withValues(alpha: opacity * 0.2);
      canvas.drawCircle(Offset(x, y), 8, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}