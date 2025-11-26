// lib/views/splash/animated_splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../core/theme/professional_theme.dart';
import '../../routes/app_routes.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _progressAnimation;

  final List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Logo animations
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotation = Tween<double>(
      begin: -math.pi / 4,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    // Text animations
    _textSlide = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutQuart,
    ));

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateParticles() {
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        size: math.Random().nextDouble() * 4 + 1,
        speed: math.Random().nextDouble() * 0.5 + 0.1,
        opacity: math.Random().nextDouble() * 0.3 + 0.1,
      ));
    }
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 3000));
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalTheme.backgroundColor,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(
                  animation: _particleController,
                  particles: particles,
                ),
                child: Container(),
              );
            },
          ),

          // Glass overlay
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              color: ProfessionalTheme.backgroundColor.withValues(alpha:0.3),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.rotate(
                        angle: _logoRotation.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  ProfessionalTheme.primaryColor.withValues(alpha:0.3),
                                  ProfessionalTheme.secondaryColor.withValues(alpha:0.1),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ProfessionalTheme.primaryColor.withValues(alpha:0.5),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Rotating rings
                                ...List.generate(3, (index) {
                                  return AnimatedBuilder(
                                    animation: _particleController,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _particleController.value *
                                               math.pi * 2 * (index + 1) * 0.3,
                                        child: Container(
                                          width: 160 - (index * 30),
                                          height: 160 - (index * 30),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: ProfessionalTheme.primaryColor
                                                  .withValues(alpha:0.3 - index * 0.1),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                                // Logo image
                                Image.asset(
                                  'assets/images/logo-alenwan.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Animated text
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Opacity(
                        opacity: _textOpacity.value,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  ProfessionalTheme.primaryColor,
                                  ProfessionalTheme.accentColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Text(
                                'ALENWAN',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 6,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Premium Streaming Experience',
                              style: TextStyle(
                                fontSize: 16,
                                color: ProfessionalTheme.textSecondary,
                                letterSpacing: 2,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 80),

                // Animated progress indicator
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return Container(
                      width: 200,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: ProfessionalTheme.surfaceColor,
                      ),
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 200 * _progressAnimation.value,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: ProfessionalTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: ProfessionalTheme.primaryColor.withValues(alpha:0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Version info
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value,
                  child: const Text(
                    'Version 2.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ProfessionalTheme.textTertiary,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Background painter for particles
class BackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Particle> particles;

  BackgroundPainter({
    required this.animation,
    required this.particles,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw gradient background
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ProfessionalTheme.backgroundColor,
        ProfessionalTheme.surfaceColor.withValues(alpha:0.5),
        ProfessionalTheme.backgroundColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw animated particles
    for (var particle in particles) {
      final progress = (animation.value + particle.speed) % 1.0;
      final y = size.height * (1.0 - progress);
      final x = size.width * particle.x;

      paint.shader = null;
      paint.color = ProfessionalTheme.primaryColor.withValues(alpha:
        particle.opacity * (1.0 - progress),
      );

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }

    // Draw glowing orbs
    for (int i = 0; i < 3; i++) {
      final center = Offset(
        size.width * (0.2 + i * 0.3),
        size.height * (0.3 + math.sin(animation.value * math.pi * 2 + i) * 0.1),
      );

      paint.shader = RadialGradient(
        colors: [
          ProfessionalTheme.primaryColor.withValues(alpha:0.1),
          ProfessionalTheme.secondaryColor.withValues(alpha:0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: 150),
      );

      canvas.drawCircle(center, 150, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Particle class
class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}