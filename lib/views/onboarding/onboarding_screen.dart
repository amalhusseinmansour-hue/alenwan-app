// lib/views/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/professional_theme.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _particleController;
  late List<AnimationController> _slideControllers;

  // ignore: unused_field
  late Animation<double> _fadeAnimation;
  // ignore: unused_field
  late Animation<double> _slideAnimation;

  int _currentPage = 0;
  final int _totalPages = 3;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'مرحباً بك في علنوان',
      subtitle: 'أفضل منصة للمحتوى المرئي العربي',
      description:
          'استمتع بآلاف الأفلام والمسلسلات والبرامج الحصرية بجودة عالية',
      icon: Icons.play_circle_filled_rounded,
      lottieAsset: 'assets/animations/welcome.json',
    ),
    OnboardingData(
      title: 'محتوى حصري وعالي الجودة',
      subtitle: 'مكتبة ضخمة من المحتوى المتنوع',
      description:
          'أفلام، مسلسلات، وثائقيات، رياضة، وبرامج الأطفال - كل ما تحتاجه في مكان واحد',
      icon: Icons.high_quality_rounded,
      lottieAsset: 'assets/animations/content.json',
    ),
    OnboardingData(
      title: 'شاهد أينما كنت',
      subtitle: 'تجربة مشاهدة متميزة على جميع الأجهزة',
      description:
          'استمتع بالمشاهدة على الهاتف، التابلت، أو التلفزيون مع إمكانية التحميل للمشاهدة بدون إنترنت',
      icon: Icons.devices_rounded,
      lottieAsset: 'assets/animations/devices.json',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _pageController = PageController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _slideControllers = List.generate(
      _totalPages,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    _slideControllers[0].forward();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _slideControllers[_currentPage].forward();
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _slideControllers[_currentPage].reset();
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _particleController.dispose();
    for (var controller in _slideControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalTheme.backgroundColor,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: OnboardingBackgroundPainter(
                  animation: _particleController,
                  currentPage: _currentPage,
                ),
                child: Container(),
              );
            },
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ProfessionalTheme.backgroundColor.withValues(alpha: 0.8),
                  ProfessionalTheme.backgroundColor.withValues(alpha: 0.9),
                  ProfessionalTheme.backgroundColor,
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _slideControllers[index].forward();
                    },
                    itemCount: _totalPages,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _slideControllers[index],
                        builder: (context, child) {
                          return _buildPageContent(_pages[index], index);
                        },
                      );
                    },
                  ),
                ),

                // Bottom navigation
                _buildBottomNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Image.asset(
                  'assets/images/logo-alenwan.png',
                  height: 40,
                ),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) =>
                    ProfessionalTheme.primaryGradient.createShader(bounds),
                child: const Text(
                  'ALENWAN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),

          // Skip button
          TextButton(
            onPressed: _skipOnboarding,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'تخطي',
              style: TextStyle(
                color: ProfessionalTheme.textSecondary,
                fontSize: 16,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingData data, int index) {
    final slideAnimation = _slideControllers[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon/illustration
          AnimatedBuilder(
            animation: slideAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: slideAnimation.value,
                child: Transform.rotate(
                  angle: (1 - slideAnimation.value) * 0.5,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ProfessionalTheme.primaryColor.withValues(alpha: 0.2),
                          ProfessionalTheme.secondaryColor
                              .withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ProfessionalTheme.primaryColor
                              .withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      data.icon,
                      size: 80,
                      color: ProfessionalTheme.primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 60),

          // Title
          AnimatedBuilder(
            animation: slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - slideAnimation.value)),
                child: Opacity(
                  opacity: slideAnimation.value,
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                      height: 1.2,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Subtitle
          AnimatedBuilder(
            animation: slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - slideAnimation.value)),
                child: Opacity(
                  opacity: slideAnimation.value * 0.9,
                  child: Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: ProfessionalTheme.primaryColor,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Description
          AnimatedBuilder(
            animation: slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 10 * (1 - slideAnimation.value)),
                child: Opacity(
                  opacity: slideAnimation.value * 0.8,
                  child: Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ProfessionalTheme.textSecondary,
                      fontFamily: 'Cairo',
                      height: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentPage == index
                      ? ProfessionalTheme.primaryColor
                      : ProfessionalTheme.surfaceColor,
                  boxShadow: _currentPage == index
                      ? [
                          BoxShadow(
                            color: ProfessionalTheme.primaryColor
                                .withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),

          const SizedBox(height: 40),

          // Navigation buttons
          Row(
            children: [
              // Previous button
              if (_currentPage > 0)
                Expanded(
                  child: _buildNavigationButton(
                    text: 'السابق',
                    isSecondary: true,
                    onPressed: _previousPage,
                  ),
                ),

              if (_currentPage > 0) const SizedBox(width: 16),

              // Next/Complete button
              Expanded(
                flex: _currentPage == 0 ? 1 : 1,
                child: _buildNavigationButton(
                  text:
                      _currentPage == _totalPages - 1 ? 'ابدأ الآن' : 'التالي',
                  isSecondary: false,
                  onPressed: _nextPage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required String text,
    required bool isSecondary,
    required VoidCallback onPressed,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: isSecondary
              ? ProfessionalTheme.glassDecoration(
                  borderRadius: BorderRadius.circular(25),
                )
              : BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ProfessionalTheme.primaryBrand,
                      ProfessionalTheme.accentCyan,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color:
                          ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSecondary ? ProfessionalTheme.textPrimary : Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }
}

// Data class for onboarding pages
class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String lottieAsset;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.lottieAsset,
  });
}

// Background painter for animated effects
class OnboardingBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final int currentPage;

  OnboardingBackgroundPainter({
    required this.animation,
    required this.currentPage,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw page-specific background patterns
    switch (currentPage) {
      case 0:
        _drawWelcomePattern(canvas, size, paint);
        break;
      case 1:
        _drawContentPattern(canvas, size, paint);
        break;
      case 2:
        _drawDevicesPattern(canvas, size, paint);
        break;
    }

    // Draw common floating elements
    _drawFloatingElements(canvas, size, paint);
  }

  void _drawWelcomePattern(Canvas canvas, Size size, Paint paint) {
    // Draw welcome circles
    for (int i = 0; i < 3; i++) {
      final center = Offset(
        size.width * (0.2 + i * 0.3),
        size.height *
            (0.3 + math.sin(animation.value * math.pi * 2 + i) * 0.05),
      );

      paint.shader = RadialGradient(
        colors: [
          ProfessionalTheme.primaryColor.withValues(alpha: 0.15),
          ProfessionalTheme.primaryColor.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 120));

      canvas.drawCircle(center, 120, paint);
    }
  }

  void _drawContentPattern(Canvas canvas, Size size, Paint paint) {
    // Draw content grid pattern
    final gridSize = 40.0;
    paint.shader = null;
    paint.color = ProfessionalTheme.primaryColor.withValues(alpha: 0.1);

    for (double x = 0; x < size.width; x += gridSize) {
      for (double y = 0; y < size.height; y += gridSize) {
        final rect = Rect.fromLTWH(x, y, 2, 2);
        canvas.drawRect(rect, paint);
      }
    }
  }

  void _drawDevicesPattern(Canvas canvas, Size size, Paint paint) {
    // Draw device icons pattern
    final progress = animation.value;

    for (int i = 0; i < 8; i++) {
      final angle = (progress * 2 * math.pi) + (i * math.pi / 4);
      final center = Offset(
        size.width * 0.5 + math.cos(angle) * 100,
        size.height * 0.4 + math.sin(angle) * 50,
      );

      paint.shader = RadialGradient(
        colors: [
          ProfessionalTheme.accentColor.withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 30));

      canvas.drawCircle(center, 30, paint);
    }
  }

  void _drawFloatingElements(Canvas canvas, Size size, Paint paint) {
    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final progress = (animation.value + i * 0.1) % 1.0;
      final x = size.width * (i * 0.05) + 30 * math.sin(progress * math.pi * 2);
      final y = size.height * (1.0 - progress);

      paint.shader = null;
      paint.color = ProfessionalTheme.primaryColor.withValues(
        alpha: 0.05 + (1.0 - progress) * 0.1,
      );

      canvas.drawCircle(
        Offset(x, y),
        1 + (1.0 - progress) * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
