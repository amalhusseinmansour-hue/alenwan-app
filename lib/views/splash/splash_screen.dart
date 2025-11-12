// lib/screens/splash/splash_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/professional_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Main Controllers
  late AnimationController _mainController;
  late AnimationController _breathingController;
  late AnimationController _waveController;
  late AnimationController _particleController;
  late AnimationController _logoSpinController;
  late AnimationController _glowController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoBlur;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titlePosition;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _loadingOpacity;
  late Animation<double> _waveAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _logoSpin;
  late Animation<double> _glowAnimation;
  late Animation<double> _logoShake;

  double _loadingProgress = 0.0;
  Timer? _progressTimer;
  final List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    // Show full splash screen with animations on all platforms
    _initializeAnimations();
    _startAnimationSequence();
    _generateParticles();
    // Shorter delay on web for faster loading
    final delay = kIsWeb ? Duration(milliseconds: 800) : Duration(milliseconds: 2500);
    Future.delayed(delay, _checkAndNavigate);
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _logoSpinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Logo Animations with dramatic entrance
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5),
    ));

    _logoRotation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    ));

    _logoBlur = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 10.0, end: 0.0),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4),
    ));

    // Title Animations
    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
    ));

    _titlePosition = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
    ));

    // Subtitle Animation
    _subtitleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
    ));

    // Loading Animation
    _loadingOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.7, 1.0),
    ));

    // Wave Animation
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);

    // Breathing Animation
    _breathingAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    // Logo Spin Animation
    _logoSpin = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _logoSpinController,
      curve: Curves.linear,
    ));

    // Glow Animation
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Logo Shake Animation
    _logoShake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 0.8, curve: Curves.easeInOut),
    ));
  }

  void _generateParticles() {
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        position: Offset(
          math.Random().nextDouble() * 400 - 200,
          math.Random().nextDouble() * 800 - 400,
        ),
        size: math.Random().nextDouble() * 3 + 1,
        speed: math.Random().nextDouble() * 0.5 + 0.2,
        opacity: math.Random().nextDouble() * 0.5,
      ));
    }
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mainController.forward();
    _breathingController.repeat(reverse: true);
    _waveController.repeat();
    _particleController.repeat();
    _logoSpinController.repeat();
    _glowController.repeat(reverse: true);

    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          if (_loadingProgress < 1.0) {
            _loadingProgress += 0.015;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _mainController.dispose();
    _breathingController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    _logoSpinController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _checkAndNavigate() async {
    if (!mounted) return;

    final fragment = Uri.base.fragment;
    final fragUri = Uri.parse(fragment.isEmpty ? '/' : fragment);
    final bool isResetRoute = fragUri.path == '/reset-password';
    final hasResetToken =
        isResetRoute && (fragUri.queryParameters['token']?.isNotEmpty ?? false);

    if (isResetRoute && hasResetToken) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.resetPassword,
        (route) => false,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language');
    final hasLanguage = savedLanguage != null && savedLanguage.isNotEmpty;

    // On web, set Arabic as default language if not set
    if (!hasLanguage && kIsWeb) {
      await prefs.setString('language', 'ar');
    }

    final token = prefs.getString('token') ?? prefs.getString('auth_token');
    final isGuestMode = prefs.getBool('guest_mode') ?? false;
    final hasToken = token != null && token.isNotEmpty;

    if (!mounted) return;

    // Skip language selection on web, go directly to login or home
    final target = (hasToken || isGuestMode) ? AppRoutes.home : AppRoutes.login;

    Navigator.of(context).pushNamedAndRemoveUntil(target, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ProfessionalTheme.backgroundPrimary,
      body: Stack(
        children: [
          // Animated Gradient Background
          _buildAnimatedBackground(size),

          // Wave Effect
          _buildWaveEffect(size),

          // Floating Particles
          _buildParticleField(size),

          // Glass Morphism Layer
          _buildGlassLayer(size),

          // Main Content
          _buildMainContent(size),

          // Vignette Effect
          _buildVignetteOverlay(size),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.cos(_waveAnimation.value) * 0.5,
                math.sin(_waveAnimation.value) * 0.5,
              ),
              radius: 2,
              colors: [
                ProfessionalTheme.primaryBrand.withOpacity(0.2),
                ProfessionalTheme.backgroundPrimary,
                ProfessionalTheme.backgroundSecondary,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveEffect(Size size) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: WavePainter(
            waveAnimation: _waveAnimation.value,
            waveColor: ProfessionalTheme.primaryBrand.withOpacity(0.1),
          ),
        );
      },
    );
  }

  Widget _buildParticleField(Size size) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: EnhancedParticlePainter(
            particles: particles,
            progress: _particleController.value,
            color: ProfessionalTheme.primaryBrand,
          ),
        );
      },
    );
  }

  Widget _buildGlassLayer(Size size) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
        child: Container(
          color: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildMainContent(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Section
          AnimatedBuilder(
            animation: Listenable.merge([
              _logoScale,
              _logoRotation,
              _logoBlur,
              _breathingAnimation,
              _logoSpin,
              _glowAnimation,
              _logoShake,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _logoScale.value * _breathingAnimation.value,
                child: Transform.rotate(
                  angle: _logoRotation.value + _logoShake.value,
                  child: Container(
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                    constraints:
                        const BoxConstraints(maxWidth: 200, maxHeight: 200),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow Effect with Animation
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: ProfessionalTheme.primaryBrand
                                    .withOpacity(0.6 * _glowAnimation.value),
                                blurRadius: 50 + (20 * _glowAnimation.value),
                                spreadRadius: 20 + (10 * _glowAnimation.value),
                              ),
                              BoxShadow(
                                color: ProfessionalTheme.secondaryBrand
                                    .withOpacity(0.3 * _glowAnimation.value),
                                blurRadius: 80,
                                spreadRadius: 30,
                              ),
                            ],
                          ),
                        ),

                        // Animated Rings
                        _buildAnimatedRings(size.width * 0.4),

                        // Logo with Blur
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: _logoBlur.value,
                            sigmaY: _logoBlur.value,
                          ),
                          child: Container(
                            width: size.width * 0.3,
                            height: size.width * 0.3,
                            constraints: const BoxConstraints(
                                maxWidth: 150, maxHeight: 150),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo-alenwan.jpeg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          ProfessionalTheme.primaryBrand,
                                          ProfessionalTheme.primaryBrandLight,
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      size: size.width * 0.15,
                                      color: ProfessionalTheme.textPrimary,
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
                ),
              );
            },
          ),

          const SizedBox(height: 50),

          // Title
          AnimatedBuilder(
            animation: Listenable.merge([_titleOpacity, _titlePosition]),
            builder: (context, child) {
              return SlideTransition(
                position: _titlePosition,
                child: FadeTransition(
                  opacity: _titleOpacity,
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              ProfessionalTheme.secondaryBrand,
                              ProfessionalTheme.primaryBrand,
                              ProfessionalTheme.primaryBrandLight,
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'ALENWAN',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                            color: ProfessionalTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalTheme.primaryBrand,
                              ProfessionalTheme.primaryBrandLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: ProfessionalTheme.primaryBrand.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Text(
                          'PLAY PLUS',
                          style: TextStyle(
                            color: ProfessionalTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Subtitle
          FadeTransition(
            opacity: _subtitleOpacity,
            child: Text(
              'Premium Entertainment Experience',
              style: TextStyle(
                color: ProfessionalTheme.textPrimary.withOpacity(0.7),
                fontSize: 16,
                letterSpacing: 2,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),

          const SizedBox(height: 60),

          // Loading Bar
          FadeTransition(
            opacity: _loadingOpacity,
            child: SizedBox(
              width: 250,
              child: Column(
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: ProfessionalTheme.textPrimary.withOpacity(0.1),
                    ),
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 250 * _loadingProgress,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [
                                ProfessionalTheme.primaryBrandLight,
                                ProfessionalTheme.primaryBrand,
                                ProfessionalTheme.secondaryBrand,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ProfessionalTheme.primaryBrand.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LOADING',
                    style: TextStyle(
                      color: ProfessionalTheme.textPrimary.withOpacity(0.5),
                      fontSize: 11,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedRings(double size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveAnimation, _logoSpin]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _logoSpin.value * 0.5,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(3, (index) {
              final delay = index * 0.3;
              final scale = 1.0 + (index * 0.15);
              final opacity = 0.3 - (index * 0.1);

              return Transform.rotate(
                angle: -_logoSpin.value * (index + 1) * 0.2,
                child: Transform.scale(
                  scale: scale + (0.1 * math.sin(_waveAnimation.value + delay)),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        transform: GradientRotation(_logoSpin.value),
                        colors: [
                          ProfessionalTheme.primaryBrand.withOpacity(opacity),
                          ProfessionalTheme.secondaryBrand.withOpacity(opacity * 0.5),
                          ProfessionalTheme.primaryBrand.withOpacity(opacity),
                        ],
                      ),
                      border: Border.all(
                        color: ProfessionalTheme.primaryBrand.withOpacity(opacity),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildVignetteOverlay(Size size) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.6),
              ],
              stops: const [0.5, 0.8, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

// Wave Painter
class WavePainter extends CustomPainter {
  final double waveAnimation;
  final Color waveColor;

  WavePainter({required this.waveAnimation, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.75);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.75 +
            math.sin((i / size.width * 2 * math.pi) + waveAnimation) * 30,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced Particle Painter
class EnhancedParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;

  EnhancedParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = color.withOpacity(particle.opacity * (1 - progress))
        ..style = PaintingStyle.fill;

      final y = (particle.position.dy - progress * 200 * particle.speed) %
          size.height;
      final x = particle.position.dx +
          math.sin(progress * 2 * math.pi * particle.speed) * 50 +
          size.width / 2;

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Particle Model
class Particle {
  final Offset position;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.position,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}
