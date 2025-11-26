import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'faq_screen.dart';
import 'contact_support_screen.dart';
import 'user_guide_screen.dart';
import 'troubleshooting_screen.dart';
import '../../core/theme/professional_theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> with TickerProviderStateMixin {
  static const Color primaryColor = Color(0xFFA20136);
  static const Color secondaryColor = Color(0xFF6B0024);
  static const Color surfaceColor = Color(0xFF1A1A1A);

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _helpIconController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _helpIconAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _helpIconController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _helpIconAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _helpIconController, curve: Curves.linear),
    );

    _fadeController.forward();
    _scaleController.forward();
    _helpIconController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _helpIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // Animated background
                Positioned.fill(
                  child: CustomPaint(
                    painter: HelpCenterPainter(
                      animation: _helpIconAnimation,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                    ),
                  ),
                ),
                // Content
                SafeArea(
                  child: Column(
                    children: [
                      // Custom App Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: surfaceColor.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: IconButton(
                                    icon: Icon(
                                      isRTL ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'مركز المساعدة',
                                style: ProfessionalTheme.getTextStyle(
                                  context: context,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Help icon with animation
                            AnimatedBuilder(
                              animation: _helpIconAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _helpIconAnimation.value * 0.1,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [primaryColor, secondaryColor],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.help_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Main content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Center(
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 420),
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                      // Logo section
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 30),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: surfaceColor.withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: primaryColor.withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                            child: Column(
                                              children: [
                                                const Icon(
                                                  Icons.support_agent,
                                                  size: 48,
                                                  color: primaryColor,
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'كيف يمكننا مساعدتك؟',
                                                  style: ProfessionalTheme.getTextStyle(
                                                    context: context,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Help options
                                      _buildHelpTile(
                                        context,
                                        icon: Icons.question_answer_outlined,
                                        title: 'الأسئلة الشائعة',
                                        subtitle: 'إجابات على الأسئلة المتكررة',
                                        delay: 0,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const FAQScreen()),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildHelpTile(
                                        context,
                                        icon: Icons.support_agent_outlined,
                                        title: 'اتصل بنا',
                                        subtitle: 'تواصل مع فريق الدعم',
                                        delay: 100,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const ContactSupportScreen()),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildHelpTile(
                                        context,
                                        icon: Icons.menu_book_outlined,
                                        title: 'دليل المستخدم',
                                        subtitle: 'تعرف على كيفية استخدام التطبيق',
                                        delay: 200,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const UserGuideScreen()),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildHelpTile(
                                        context,
                                        icon: Icons.build_outlined,
                                        title: 'حل المشكلات',
                                        subtitle: 'حلول للمشاكل التقنية الشائعة',
                                        delay: 300,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const TroubleshootingScreen()),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    surfaceColor.withValues(alpha: 0.9),
                    surfaceColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(20),
                      splashColor: primaryColor.withValues(alpha: 0.2),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: ProfessionalTheme.getTextStyle(
                                      context: context,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    subtitle,
                                    style: ProfessionalTheme.getTextStyle(
                                      context: context,
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
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

class HelpCenterPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;

  HelpCenterPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw floating help icons
    for (int i = 0; i < 4; i++) {
      final x = size.width * (0.15 + i * 0.25);
      final y = size.height * 0.2 + 30 * sin(animation.value * 2 * pi + i * pi / 2);

      // Question mark background
      paint.color = primaryColor.withValues(alpha: 0.1);
      canvas.drawCircle(Offset(x, y), 25, paint);

      // Question mark shape
      paint.color = secondaryColor.withValues(alpha: 0.2);
      paint.strokeWidth = 3;
      paint.style = PaintingStyle.stroke;
      paint.strokeCap = StrokeCap.round;

      // Draw question mark path
      final path = Path();
      path.moveTo(x - 8, y - 10);
      path.quadraticBezierTo(x - 8, y - 15, x - 3, y - 15);
      path.quadraticBezierTo(x + 8, y - 15, x + 8, y - 5);
      path.quadraticBezierTo(x + 8, y, x, y);
      path.lineTo(x, y + 3);
      canvas.drawPath(path, paint);

      // Dot
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y + 8), 2, paint);
      paint.style = PaintingStyle.stroke;
    }

    // Draw animated support waves
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      paint.color = primaryColor.withValues(alpha: 0.1 - i * 0.03);
      final radius = 80.0 + i * 40 + (animation.value * 20);
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.7),
        radius,
        paint,
      );
    }

    // Draw gear/support symbols
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 2; i++) {
      final centerX = size.width * (0.2 + i * 0.6);
      final centerY = size.height * 0.8;
      final rotation = animation.value * 2 * pi * (i % 2 == 0 ? 1 : -1) * 0.1;

      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(rotation);

      // Draw gear teeth
      paint.color = primaryColor.withValues(alpha: 0.08);
      for (int j = 0; j < 8; j++) {
        final angle = j * pi / 4;
        final x1 = 20 * cos(angle);
        final y1 = 20 * sin(angle);
        final x2 = 30 * cos(angle);
        final y2 = 30 * sin(angle);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }

      // Gear center
      paint.color = secondaryColor.withValues(alpha: 0.1);
      canvas.drawCircle(Offset.zero, 15, paint);

      canvas.restore();
    }

    // Draw floating particles
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 10; i++) {
      final x = size.width * (0.1 + (i * 0.08));
      final y = size.height * 0.4 + 10 * sin(animation.value * 4 * pi + i);
      paint.color = primaryColor.withValues(alpha: 0.1 * (1 + sin(animation.value * 3 + i)));
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant HelpCenterPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}