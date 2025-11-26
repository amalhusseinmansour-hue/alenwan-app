import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/theme/professional_theme.dart';

class TroubleshootingScreen extends StatefulWidget {
  const TroubleshootingScreen({super.key});

  @override
  State<TroubleshootingScreen> createState() => _TroubleshootingScreenState();
}

class _TroubleshootingScreenState extends State<TroubleshootingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ProfessionalTheme.durationMedium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildTroubleshootingItem(
      String title, String solution, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: ProfessionalTheme.space16),
      decoration: ProfessionalTheme.glassMorphism.copyWith(
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: color,
            collapsedIconColor: color,
            textColor: ProfessionalTheme.textPrimary,
            collapsedTextColor: ProfessionalTheme.textPrimary,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: ProfessionalTheme.space20,
            vertical: ProfessionalTheme.space12,
          ),
          childrenPadding: const EdgeInsets.only(
            left: ProfessionalTheme.space20,
            right: ProfessionalTheme.space20,
            bottom: ProfessionalTheme.space20,
          ),
          leading: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: ProfessionalTheme.titleMedium(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.w600,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ProfessionalTheme.space16),
              decoration: BoxDecoration(
                color: ProfessionalTheme.surfaceCard.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: ProfessionalTheme.space8),
                      Text(
                        'الحل:',
                        style: ProfessionalTheme.titleSmall(
                          color: color,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ProfessionalTheme.space12),
                  Text(
                    solution,
                    style: ProfessionalTheme.bodyMedium(
                      color: ProfessionalTheme.textSecondary,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
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
        body: Container(
          decoration: BoxDecoration(
            gradient: ProfessionalTheme.darkGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: ProfessionalTheme.space16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ProfessionalTheme.surfaceCard.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: ProfessionalTheme.textPrimary,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'حل المشكلات',
                style: ProfessionalTheme.headlineSmall(
                  color: ProfessionalTheme.textPrimary,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.symmetric(
                horizontal: ProfessionalTheme.space16,
                vertical: ProfessionalTheme.space24,
              ),
              child: Column(
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: ProfessionalTheme.space32),
                  _buildTroubleshootingItem(
                    'مشاكل في تشغيل الفيديو',
                    'تأكد من اتصالك بالإنترنت وسرعته. جرب تغيير جودة الفيديو إلى جودة أقل. قم بإعادة تشغيل التطبيق إذا استمرت المشكلة.',
                    Icons.video_settings,
                    ProfessionalTheme.accentRed,
                  ),
                  _buildTroubleshootingItem(
                    'مشاكل في التنزيل',
                    'تأكد من وجود مساحة كافية على جهازك وأن اتصالك بالإنترنت مستقر. حاول حذف بعض الملفات المنزلة القديمة لتوفير مساحة.',
                    Icons.download_outlined,
                    ProfessionalTheme.accentBlue,
                  ),
                  _buildTroubleshootingItem(
                    'مشاكل في تسجيل الدخول',
                    'تأكد من صحة بيانات تسجيل الدخول. إذا نسيت كلمة المرور، استخدم خيار استعادة كلمة المرور. تأكد من تحديث التطبيق إلى أحدث إصدار.',
                    Icons.login_outlined,
                    ProfessionalTheme.accentGold,
                  ),
                  _buildTroubleshootingItem(
                    'مشاكل في الصوت',
                    'تأكد من رفع مستوى الصوت في جهازك. جرب استخدام سماعات مختلفة. تأكد من عدم كتم الصوت في التطبيق.',
                    Icons.volume_up_outlined,
                    ProfessionalTheme.accentGreen,
                  ),
                  _buildTroubleshootingItem(
                    'تطبيق بطيء أو متوقف',
                    'قم بإغلاق التطبيق وإعادة تشغيله. تأكد من وجود مساحة كافية على جهازك. حاول مسح ذاكرة التخزين المؤقت للتطبيق.',
                    Icons.speed_outlined,
                    ProfessionalTheme.accentCyan,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(ProfessionalTheme.space20),
      decoration: ProfessionalTheme.glassMorphism.copyWith(
        color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.build_outlined,
            color: ProfessionalTheme.primaryBrand,
            size: 48,
          ),
          const SizedBox(height: ProfessionalTheme.space16),
          Text(
            'حل المشكلات',
            style: ProfessionalTheme.titleLarge(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ProfessionalTheme.space8),
          Text(
            'حلول سريعة للمشاكل الشائعة',
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
