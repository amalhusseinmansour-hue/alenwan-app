import 'package:flutter/material.dart';
import 'dart:math' as math;

class PremiumBanner extends StatefulWidget {
  final double height;

  const PremiumBanner({
    super.key,
    required this.height,
  });

  @override
  State<PremiumBanner> createState() => _PremiumBannerState();
}

class _PremiumBannerState extends State<PremiumBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF000000),
            Color(0xFF1a0a0f),
            Color(0xFF2d0a1a),
            Color(0xFF000000),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // الخلفية المتحركة
          _buildAnimatedBackground(),

          // طبقة التدرج
          _buildGradientOverlay(),

          // الخطوط الزخرفية
          _buildDecorativeLines(),

          // المحتوى الرئيسي
          _buildMainContent(),

          // الشارات العلوية
          _buildTopBadges(),

          // خط الحدود السفلي
          _buildBottomBorder(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _GeometricBackgroundPainter(
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withValues(alpha: 0.9),
              Colors.black.withValues(alpha: 0.5),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeLines() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _DecorativeLinesPainter(),
      ),
    );
  }

  Widget _buildMainContent() {
    return Positioned(
      right: 32,
      top: 0,
      bottom: 0,
      left: MediaQuery.of(context).size.width > 600
          ? MediaQuery.of(context).size.width * 0.4
          : 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // شعار المنصة
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE50914),
                        Color(0xFFB20710),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE50914).withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // العنوان الرئيسي
          _buildShimmerText(
            'ALENWAN',
            fontSize: 56,
            fontWeight: FontWeight.w900,
          ),

          _buildShimmerText(
            'PLAY',
            fontSize: 56,
            fontWeight: FontWeight.w900,
          ),

          const SizedBox(height: 16),

          // الوصف
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: const Text(
              'عالم لا محدود من الترفيه\nبجودة 4K وترجمة فورية',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.6,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // الأزرار
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                label: 'ابدأ المشاهدة',
                icon: Icons.play_circle_filled_rounded,
                isPrimary: true,
                onTap: () {},
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                label: 'اكتشف المزيد',
                icon: Icons.explore_rounded,
                isPrimary: false,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerText(String text, {
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.white,
                Colors.white.withValues(alpha: 0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_shimmerAnimation.value),
            ).createShader(bounds);
          },
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: Colors.white,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: const Color(0xFFE50914).withValues(alpha: 0.5),
                  blurRadius: 30,
                ),
                const Shadow(
                  color: Colors.black,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                gradient: isPrimary
                    ? const LinearGradient(
                        colors: [
                          Color(0xFFE50914),
                          Color(0xFFB20710),
                        ],
                      )
                    : null,
                color: isPrimary ? null : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
                border: isPrimary
                    ? null
                    : Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                boxShadow: isPrimary
                    ? [
                        BoxShadow(
                          color: const Color(0xFFE50914).withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBadges() {
    return Positioned(
      top: 32,
      left: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadge(
            icon: Icons.trending_up_rounded,
            label: 'الأكثر مشاهدة',
            colors: [const Color(0xFFE50914), const Color(0xFFB20710)],
          ),
          const SizedBox(height: 14),
          _buildBadge(
            icon: Icons.stars_rounded,
            label: 'محتوى حصري',
            colors: [const Color(0xFFFFB900), const Color(0xFFFF8C00)],
          ),
          const SizedBox(height: 14),
          _buildBadge(
            icon: Icons.high_quality_rounded,
            label: 'جودة فائقة',
            colors: [const Color(0xFF00C853), const Color(0xFF00A843)],
          ),
          const SizedBox(height: 14),
          _buildBadge(
            icon: Icons.translate_rounded,
            label: 'ترجمة فورية',
            colors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBorder() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.transparent,
              Color(0xFFE50914),
              Color(0xFFE50914),
              Colors.transparent,
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE50914).withValues(alpha: 0.5),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

// رسام الخلفية الهندسية المتحركة
class _GeometricBackgroundPainter extends CustomPainter {
  final double animationValue;

  _GeometricBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // رسم دوائر متحركة
    for (int i = 0; i < 3; i++) {
      final radius = 100.0 + (i * 80);
      final offset = animationValue * 2 * math.pi;

      paint.color = const Color(0xFFE50914).withValues(alpha: 0.1 - (i * 0.03));

      canvas.drawCircle(
        Offset(
          size.width * 0.75 + math.cos(offset + i) * 50,
          size.height * 0.5 + math.sin(offset + i) * 30,
        ),
        radius,
        paint,
      );
    }

    // رسم خطوط قطرية
    paint.color = Colors.white.withValues(alpha: 0.03);
    for (int i = 0; i < 5; i++) {
      final y = (size.height / 5) * i + (animationValue * 100).remainder(size.height / 5);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + size.height * 0.2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GeometricBackgroundPainter oldDelegate) => true;
}

// رسام الخطوط الزخرفية
class _DecorativeLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // رسم مربعات صغيرة عشوائية
    final random = math.Random(42);
    for (int i = 0; i < 20; i++) {
      paint.color = Colors.white.withValues(alpha: random.nextDouble() * 0.05);
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final rectSize = 2.0 + random.nextDouble() * 4;

      canvas.drawRect(
        Rect.fromLTWH(x, y, rectSize, rectSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DecorativeLinesPainter oldDelegate) => false;
}
