import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../../core/theme/professional_theme.dart';
import '../../controllers/settings_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  SettingsController? _settingsCtrl;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  // Using centralized theme colors from ProfessionalTheme

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _rotateAnimation = CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
    _scaleController.forward();
    _rotateController.repeat(reverse: true);

    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _settingsCtrl = SettingsController(prefs: prefs);
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';

    if (_settingsCtrl == null) {
      return Scaffold(
        backgroundColor: ProfessionalTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ProfessionalTheme.primaryColor),
          ),
        ),
      );
    }

    return ChangeNotifierProvider<SettingsController>.value(
      value: _settingsCtrl!,
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundColor,
        body: Stack(
          children: [
            // Animated Background
            CustomPaint(
              painter: SettingsPainter(_rotateAnimation.value),
              size: Size.infinite,
            ),
            // Main Content
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: true,
                    leading: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ProfessionalTheme.surfaceColor.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(
                                isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Text(
                              'إعدادات التطبيق',
                              style: ProfessionalTheme.getTextStyle(
                                context: context,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Consumer<SettingsController>(
                              builder: (context, controller, child) {
                                if (controller.isLoading) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(ProfessionalTheme.primaryColor),
                                    ),
                                  );
                                }

                                final currentLanguage = context.locale.languageCode;

                                return Column(
                                  children: [
                                    // Logo Section
                                    _buildLogoSection(),
                                    const SizedBox(height: 32),

                                    // Account Settings Section
                                    _buildSectionTitle('إعدادات الحساب'),
                                    const SizedBox(height: 16),
                                    _buildModernSettingTile(
                                      'تغيير كلمة المرور',
                                      'تحديث كلمة المرور الخاصة بك',
                                      Icons.lock_outline,
                                      onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildModernSettingTile(
                                      'الأجهزة المتصلة',
                                      'إدارة الأجهزة المسجلة على حسابك',
                                      Icons.devices,
                                      onTap: () => Navigator.pushNamed(context, AppRoutes.devices),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDeleteAccountTile(),

                                    const SizedBox(height: 32),

                                    // Language Settings Section
                                    _buildSectionTitle('اللغة'),
                                    const SizedBox(height: 16),
                                    _buildModernLanguageOption(
                                      context,
                                      'العربية',
                                      'Arabic',
                                      currentLanguage == 'ar',
                                      () => controller.setLanguage(context, 'ar'),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildModernLanguageOption(
                                      context,
                                      'English',
                                      'الإنجليزية',
                                      currentLanguage == 'en',
                                      () => controller.setLanguage(context, 'en'),
                                    ),

                                    const SizedBox(height: 40),

                                    // Save Button
                                    _buildSaveButton(context),
                                    const SizedBox(height: 32),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
                  ProfessionalTheme.secondaryColor.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotateAnimation.value * 2 * math.pi * 0.1,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [ProfessionalTheme.primaryColor, ProfessionalTheme.secondaryColor],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'إعدادات التطبيق',
                      style: ProfessionalTheme.getTextStyle(
                        context: context,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: ProfessionalTheme.getTextStyle(
          context: context,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ProfessionalTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildModernSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ProfessionalTheme.surfaceColor.withValues(alpha: 0.8),
            ProfessionalTheme.surfaceColor.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ProfessionalTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ProfessionalTheme.primaryColor, ProfessionalTheme.secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
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
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: ProfessionalTheme.getTextStyle(
                              context: context,
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: ProfessionalTheme.primaryColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernLanguageOption(
    BuildContext context,
    String primaryText,
    String secondaryText,
    bool selected,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: selected
              ? [ProfessionalTheme.primaryColor.withValues(alpha: 0.3), ProfessionalTheme.secondaryColor.withValues(alpha: 0.2)]
              : [ProfessionalTheme.surfaceColor.withValues(alpha: 0.8), ProfessionalTheme.surfaceColor.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? ProfessionalTheme.primaryColor : ProfessionalTheme.primaryColor.withValues(alpha: 0.2),
          width: selected ? 2 : 1,
        ),
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ProfessionalTheme.primaryColor, ProfessionalTheme.secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.language,
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
                            primaryText,
                            style: ProfessionalTheme.getTextStyle(
                              context: context,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            secondaryText,
                            style: ProfessionalTheme.getTextStyle(
                              context: context,
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: ProfessionalTheme.primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.check,
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
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ProfessionalTheme.primaryColor, ProfessionalTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Center(
                  child: Text(
                    'حفظ الإعدادات',
                    style: ProfessionalTheme.getTextStyle(
                      context: context,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildDeleteAccountTile() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.1),
            Colors.red.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showDeleteAccountDialog,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حذف الحساب',
                        style: ProfessionalTheme.getTextStyle(
                          context: context,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'حذف حسابك نهائياً من التطبيق',
                        style: ProfessionalTheme.getTextStyle(
                          context: context,
                          fontSize: 14,
                          color: Colors.red.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red.withValues(alpha: 0.5),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProfessionalTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'تأكيد حذف الحساب',
              style: ProfessionalTheme.getTextStyle(
                context: context,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف حسابك؟\n\nسيتم حذف جميع بياناتك نهائياً ولا يمكن التراجع عن هذا الإجراء.',
          style: ProfessionalTheme.getTextStyle(
            context: context,
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: ProfessionalTheme.getTextStyle(
                context: context,
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'حذف الحساب',
              style: ProfessionalTheme.getTextStyle(
                context: context,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ProfessionalTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ProfessionalTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                'جاري حذف الحساب...',
                style: ProfessionalTheme.getTextStyle(
                  context: context,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Get user token
      final token = await ApiService.getToken();

      // Call API to delete account
      bool success = false;
      if (token != null) {
        success = await ApiService.deleteAccount(token);
      }

      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success || token == null) {
          // Navigate to login screen
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        } else {
          throw Exception('Failed to delete account from server');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حذف الحساب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Custom Painter for Settings Background
class SettingsPainter extends CustomPainter {
  final double animationValue;

  SettingsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Background gradient
    paint.shader = const LinearGradient(
      colors: [
        Color(0xFF0A0A0A),
        Color(0xFF1A1A1A),
        Color(0xFF0A0A0A),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Animated gears
    for (int i = 0; i < 8; i++) {
      final x = (size.width * 0.1) + (i * size.width * 0.12);
      final y = size.height * 0.1 + (i % 2) * size.height * 0.4;

      _drawGear(
        canvas,
        Offset(x, y),
        30 + (i * 5),
        animationValue + (i * 0.5),
        const Color(0xFFA20136).withValues(alpha: 0.15),
      );
    }

    // Settings icons
    for (int i = 0; i < 6; i++) {
      final x = size.width * 0.2 + (i * size.width * 0.15);
      final y = size.height * 0.6 + math.sin(animationValue * 2 + i) * 30;

      _drawSettingsIcon(
        canvas,
        Offset(x, y),
        15 + (i * 2),
        const Color(0xFF6B0024).withValues(alpha: 0.2),
      );
    }
  }

  void _drawGear(Canvas canvas, Offset center, double radius, double rotation, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Draw gear teeth
    final path = Path();
    final teethCount = 12;
    for (int i = 0; i < teethCount; i++) {
      final angle = (i * 2 * math.pi) / teethCount;
      final x1 = math.cos(angle) * radius;
      final y1 = math.sin(angle) * radius;
      final x2 = math.cos(angle) * (radius + 8);
      final y2 = math.sin(angle) * (radius + 8);

      if (i == 0) {
        path.moveTo(x1, y1);
      }
      path.lineTo(x2, y2);

      final nextAngle = ((i + 1) * 2 * math.pi) / teethCount;
      final x3 = math.cos(nextAngle) * (radius + 8);
      final y3 = math.sin(nextAngle) * (radius + 8);
      path.lineTo(x3, y3);

      final x4 = math.cos(nextAngle) * radius;
      final y4 = math.sin(nextAngle) * radius;
      path.lineTo(x4, y4);
    }
    path.close();

    canvas.drawPath(path, paint);

    // Draw center circle
    canvas.drawCircle(Offset.zero, radius * 0.3, paint);

    canvas.restore();
  }

  void _drawSettingsIcon(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw settings cog
    canvas.drawCircle(center, size, paint);
    canvas.drawCircle(center, size * 0.5, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
