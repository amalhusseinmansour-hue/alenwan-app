import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/subscription_controller.dart';
import '../../models/subscription_plan.dart';
import '../../core/theme/professional_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with TickerProviderStateMixin {
  static const Color primaryColor = Color(0xFFA20136);
  static const Color secondaryColor = Color(0xFF6B0024);
  static const Color surfaceColor = Color(0xFF1A1A1A);

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _sparkleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkleAnimation;

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
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.linear),
    );

    _fadeController.forward();
    _scaleController.forward();
    _sparkleController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubscriptionController()..load(),
      child: AnimatedBuilder(
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
                      painter: SubscriptionPainter(
                        animation: _sparkleAnimation,
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
                                      icon: const Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'الاشتراك',
                                  style: ProfessionalTheme.getTextStyle(
                                    context: context,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Premium icon with animation
                              AnimatedBuilder(
                                animation: _sparkleAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _sparkleAnimation.value * 0.1,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [primaryColor, secondaryColor],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.workspace_premium,
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
                          child: Center(
                            child: Consumer<SubscriptionController>(
                              builder: (context, c, _) {
                                if (c.isLoading) {
                                  return Container(
                                    padding: const EdgeInsets.all(40),
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
                                        child: const CircularProgressIndicator(color: Color(0xFFA20136)),
                                      ),
                                    ),
                                  );
                                }

                                if (c.error != null) {
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    margin: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      c.error!,
                                      style: ProfessionalTheme.getTextStyle(
                                        context: context,
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }

                                final width = MediaQuery.of(context).size.width;
                                return AnimatedBuilder(
                                  animation: _scaleAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _scaleAnimation.value,
                                      child: Container(
                                        width: width > 600 ? 520 : double.infinity,
                                        margin: const EdgeInsets.all(16),
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: surfaceColor.withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(25),
                                          border: Border.all(
                                            color: primaryColor.withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryColor.withValues(alpha: 0.2),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(25),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                            child: SingleChildScrollView(
                                              physics: const BouncingScrollPhysics(),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                // Header section
                                                if (c.hasActive) ...[
                                                  Container(
                                                    padding: const EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.green.withValues(alpha: 0.2),
                                                          Colors.green.withValues(alpha: 0.1),
                                                        ],
                                                      ),
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.check_circle,
                                                          color: Colors.green,
                                                          size: 24,
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            'لديك اشتراك فعّال',
                                                            style: ProfessionalTheme.getTextStyle(
                                                              context: context,
                                                              color: Colors.green,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                ],

                                                // Title
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.workspace_premium,
                                                      color: primaryColor,
                                                      size: 28,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      'اختر خطة اشتراك',
                                                      style: ProfessionalTheme.getTextStyle(
                                                        context: context,
                                                        color: Colors.white,
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 24),

                                                // Plans
                                                ...c.availablePlans.asMap().entries.map((entry) {
                                                  final index = entry.key;
                                                  final plan = entry.value;
                                                  return _buildPlanTile(c, plan, index);
                                                }),

                                                const SizedBox(height: 24),

                                                // Subscribe button
                                                _buildSubscribeButton(c),

                                                if (c.hasActive) ...[
                                                  const SizedBox(height: 16),
                                                  _buildCancelButton(c),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  },
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
      ),
    );
  }

  Widget _buildPlanTile(SubscriptionController c, SubscriptionPlan plan, int index) {
    final selected = c.selectedPlan?.id == plan.id;
    final isPremium = plan.type == SubscriptionPlanType.premium;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () => c.selectPlan(plan),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: selected
                      ? LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.3),
                            secondaryColor.withValues(alpha: 0.2),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            surfaceColor.withValues(alpha: 0.6),
                            surfaceColor.withValues(alpha: 0.4),
                          ],
                        ),
                  border: Border.all(
                    color: selected
                        ? primaryColor
                        : primaryColor.withValues(alpha: 0.2),
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isPremium
                                        ? [Colors.amber, Colors.orange]
                                        : [primaryColor, secondaryColor],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isPremium ? Icons.diamond : Icons.star,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  plan.title,
                                  style: ProfessionalTheme.getTextStyle(
                                    context: context,
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (selected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            plan.description,
                            style: ProfessionalTheme.getTextStyle(
                              context: context,
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                '${plan.price.toStringAsFixed(2)} AED',
                                style: ProfessionalTheme.getTextStyle(
                                  context: context,
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' / ${plan.period == SubscriptionPeriod.monthly ? 'شهر' : 'سنة'}',
                                style: ProfessionalTheme.getTextStyle(
                                  context: context,
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildSubscribeButton(SubscriptionController c) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: c.selectedPlan == null || c.isProcessingPayment
            ? null
            : () async {
                final paymentUrl = await c.subscribeSelected();
                if (!context.mounted) return;

                if (paymentUrl != null) {
                  // Open payment page in WebView
                  final result = await Navigator.pushNamed(
                    context,
                    '/payment-webview',
                    arguments: {'url': paymentUrl},
                  );

                  if (result == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم الاشتراك بنجاح')),
                    );
                    c.load(); // Reload subscription data
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(c.error ?? 'فشل إنشاء رابط الدفع')),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: c.isProcessingPayment
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.credit_card, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'اشترك الآن',
                    style: ProfessionalTheme.getTextStyle(
                      context: context,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCancelButton(SubscriptionController c) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: OutlinedButton(
            onPressed: c.isProcessingPayment
                ? null
                : () async {
                    final ok = await c.cancel();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(ok
                                ? 'تم إلغاء الاشتراك'
                                : (c.error ?? 'فشل الإلغاء'))));
                  },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cancel_outlined, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  'إلغاء الاشتراك',
                  style: ProfessionalTheme.getTextStyle(
                    context: context,
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;

  SubscriptionPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw floating premium symbols
    for (int i = 0; i < 5; i++) {
      final x = size.width * (0.1 + i * 0.2);
      final y = size.height * 0.3 + 40 * sin(animation.value * 2 * pi + i * pi / 3);

      // Diamond background
      paint.color = primaryColor.withValues(alpha: 0.1);
      canvas.drawCircle(Offset(x, y), 20, paint);

      // Diamond shape
      paint.color = secondaryColor.withValues(alpha: 0.2);
      final diamondPath = Path();
      diamondPath.moveTo(x, y - 12);
      diamondPath.lineTo(x + 8, y - 4);
      diamondPath.lineTo(x, y + 12);
      diamondPath.lineTo(x - 8, y - 4);
      diamondPath.close();
      canvas.drawPath(diamondPath, paint);
    }

    // Draw premium crown symbols
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      final centerX = size.width * (0.2 + i * 0.3);
      final centerY = size.height * 0.7;
      final rotation = animation.value * 2 * pi * 0.1;

      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(rotation);

      paint.color = primaryColor.withValues(alpha: 0.15);

      // Crown shape
      final crownPath = Path();
      crownPath.moveTo(-15, 5);
      crownPath.lineTo(-10, -10);
      crownPath.lineTo(-5, 0);
      crownPath.lineTo(0, -15);
      crownPath.lineTo(5, 0);
      crownPath.lineTo(10, -10);
      crownPath.lineTo(15, 5);
      crownPath.lineTo(-15, 5);
      canvas.drawPath(crownPath, paint);

      canvas.restore();
    }

    // Draw animated subscription waves
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    for (int i = 0; i < 4; i++) {
      paint.color = primaryColor.withValues(alpha: 0.08 - i * 0.02);
      final radius = 60.0 + i * 30 + (animation.value * 15);
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.15),
        radius,
        paint,
      );
    }

    // Draw floating coins/currency symbols
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final x = size.width * (0.05 + (i * 0.12));
      final y = size.height * 0.8 + 15 * sin(animation.value * 3 * pi + i);
      paint.color = primaryColor.withValues(alpha: 0.1 * (1 + sin(animation.value * 2 + i)));

      // Coin circle
      canvas.drawCircle(Offset(x, y), 8, paint);

      // Dollar sign
      paint.color = secondaryColor.withValues(alpha: 0.2);
      paint.strokeWidth = 1;
      paint.style = PaintingStyle.stroke;
      final dollarPath = Path();
      dollarPath.moveTo(x - 3, y - 4);
      dollarPath.quadraticBezierTo(x - 3, y - 6, x, y - 6);
      dollarPath.quadraticBezierTo(x + 3, y - 6, x + 3, y - 2);
      dollarPath.quadraticBezierTo(x + 3, y, x, y);
      dollarPath.quadraticBezierTo(x - 3, y, x - 3, y + 2);
      dollarPath.quadraticBezierTo(x - 3, y + 4, x, y + 4);
      dollarPath.quadraticBezierTo(x + 3, y + 4, x + 3, y + 6);
      canvas.drawPath(dollarPath, paint);
      paint.style = PaintingStyle.fill;
    }
  }

  @override
  bool shouldRepaint(covariant SubscriptionPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}