// lib/views/language/language_selection_screen.dart
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/professional_theme.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _floatingController;

  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  String? _selectedLanguage;
  bool _isLoading = false;

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
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideUp = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
    ));

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _contentController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _selectLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
      _isLoading = true;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);

    if (mounted) {
      await context.setLocale(Locale(languageCode));
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundPrimary,
        body: Stack(
          children: [
            // Animated Background
            _buildAnimatedBackground(size),

            // Glass Effect
            _buildGlassEffect(),

            // Floating Elements
            _buildFloatingElements(size),

            // Main Content
            _buildMainContent(size),
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
              radius: 1.5,
              colors: [
                ProfessionalTheme.primaryBrand.withOpacity(0.3),
                ProfessionalTheme.backgroundPrimary,
                ProfessionalTheme.backgroundSecondary,
              ],
            ),
          ),
          child: CustomPaint(
            size: size,
            painter: GeometricBackgroundPainter(
              animation: _backgroundController.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassEffect() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          color: ProfessionalTheme.backgroundPrimary.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildFloatingElements(Size size) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: size.height * 0.1 + _floatingAnimation.value,
              left: size.width * 0.1,
              child: _buildFloatingShape(30, 0.2),
            ),
            Positioned(
              top: size.height * 0.7 - _floatingAnimation.value,
              right: size.width * 0.15,
              child: _buildFloatingShape(40, 0.15),
            ),
            Positioned(
              bottom: size.height * 0.2 + _floatingAnimation.value * 0.5,
              left: size.width * 0.6,
              child: _buildFloatingShape(25, 0.25),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingShape(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            ProfessionalTheme.primaryBrand.withOpacity(opacity),
            ProfessionalTheme.primaryBrand.withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(Size size) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: Listenable.merge([_fadeIn, _slideUp, _scaleAnimation]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeIn.value,
            child: Transform.translate(
              offset: Offset(0, _slideUp.value),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Logo with glow
                    _buildLogo(),

                    const SizedBox(height: 30),

                    // Title
                    _buildTitle(),

                    const SizedBox(height: 40),

                    // Language Cards
                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLanguageCard(
                                  language: 'العربية',
                                  languageCode: 'ar',
                                  icon: '🇸🇦',
                                  gradient: [
                                    ProfessionalTheme.primaryBrand,
                                    ProfessionalTheme.primaryBrand.withOpacity(0.8),
                                  ],
                                  delay: 0,
                                ),
                                const SizedBox(height: 20),
                                _buildLanguageCard(
                                  language: 'English',
                                  languageCode: 'en',
                                  icon: '🇬🇧',
                                  gradient: [
                                    ProfessionalTheme.primaryBrand.withOpacity(0.8),
                                    ProfessionalTheme.primaryBrand,
                                  ],
                                  delay: 100,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Footer
                    _buildFooter(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    final screenHeight = MediaQuery.of(context).size.height;
    final logoSize = screenHeight < 600 ? 80.0 : 100.0;

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ProfessionalTheme.primaryBrand.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: ProfessionalTheme.premiumGradient,
              border: Border.all(
                color: ProfessionalTheme.textPrimary.withOpacity(0.2),
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.language,
              size: 45,
              color: ProfessionalTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleSize = screenWidth < 350 ? 24.0 : 28.0;
    final subtitleSize = screenWidth < 350 ? 14.0 : 16.0;

    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                ProfessionalTheme.accentColor,
                ProfessionalTheme.primaryBrand,
                ProfessionalTheme.primaryBrand.withOpacity(0.8),
              ],
            ).createShader(bounds);
          },
          child: Text(
            'welcome_to_alenwan'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: ProfessionalTheme.textPrimary,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'choose_language'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            color: ProfessionalTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard({
    required String language,
    required String languageCode,
    required String icon,
    required List<Color> gradient,
    required int delay,
  }) {
    final isSelected = _selectedLanguage == languageCode;
    final isProcessing = isSelected && _isLoading;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 350 ? screenWidth - 80 : 280.0;
    final cardHeight = screenWidth < 350 ? 80.0 : 100.0;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: isProcessing ? null : () => _selectLanguage(languageCode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? gradient
                      : [
                          ProfessionalTheme.surfaceCard.withOpacity(0.3),
                          ProfessionalTheme.surfaceCard.withOpacity(0.1),
                        ],
                ),
                border: Border.all(
                  color: isSelected
                      ? ProfessionalTheme.primaryBrand.withOpacity(0.5)
                      : ProfessionalTheme.textSecondary.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: gradient[0].withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: isSelected ? 0 : 10,
                    sigmaY: isSelected ? 0 : 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Flag Icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: ProfessionalTheme.surfaceCard.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: ProfessionalTheme.primaryBrand.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  icon,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Language Text
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language,
                                  style: TextStyle(
                                    color: isSelected
                                        ? ProfessionalTheme.textPrimary
                                        : ProfessionalTheme.textSecondary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  languageCode.toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? ProfessionalTheme.textSecondary
                                        : ProfessionalTheme.textTertiary,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Arrow or Loading
                        if (isProcessing)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(ProfessionalTheme.textPrimary),
                            ),
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: isSelected
                                ? ProfessionalTheme.textPrimary
                                : ProfessionalTheme.textTertiary,
                            size: 20,
                          ),
                      ],
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

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          height: 1,
          width: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                ProfessionalTheme.textSecondary.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'You can change this later in settings',
          style: TextStyle(
            color: ProfessionalTheme.textTertiary,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// Geometric Background Painter
class GeometricBackgroundPainter extends CustomPainter {
  final double animation;

  GeometricBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw animated geometric patterns
    for (int i = 0; i < 5; i++) {
      final progress = (animation + i * 0.2) % 1.0;
      final opacity = (1.0 - progress) * 0.1;

      paint.color = ProfessionalTheme.primaryBrand.withOpacity(opacity);

      final center = Offset(
        size.width * 0.5 + math.cos(animation * 2 * math.pi + i) * 50,
        size.height * 0.5 + math.sin(animation * 2 * math.pi + i) * 50,
      );

      final radius = size.width * 0.3 * progress;

      // Draw hexagon
      final path = Path();
      for (int j = 0; j < 6; j++) {
        final angle = (j * 60) * math.pi / 180;
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}