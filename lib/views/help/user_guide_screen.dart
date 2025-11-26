import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/theme/professional_theme.dart';

class UserGuideScreen extends StatefulWidget {
  const UserGuideScreen({super.key});

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen>
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

  Widget _buildGuideSection(String title, String description, IconData icon, Color color) {
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
                        Icons.info_outline,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: ProfessionalTheme.space8),
                      Text(
                        'التفاصيل:',
                        style: ProfessionalTheme.titleSmall(
                          color: color,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ProfessionalTheme.space12),
                  Text(
                    description,
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
                'دليل المستخدم',
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
                  _buildGuideSection(
                    'البدء باستخدام التطبيق',
                    'تعرف على كيفية تسجيل الدخول وإعداد حسابك الشخصي. يمكنك استخدام بريدك الإلكتروني أو حساباتك على مواقع التواصل الاجتماعي للتسجيل.',
                    Icons.login_outlined,
                    ProfessionalTheme.accentGreen,
                  ),
                  _buildGuideSection(
                    'تصفح المحتوى',
                    'اكتشف كيفية البحث عن المحتوى المفضل لديك وتصفح الفئات المختلفة. يمكنك استخدام شريط البحث أو تصفح الفئات المتاحة.',
                    Icons.explore_outlined,
                    ProfessionalTheme.accentBlue,
                  ),
                  _buildGuideSection(
                    'تنزيل المحتوى',
                    'تعلم كيفية تنزيل المحتوى لمشاهدته لاحقاً بدون إنترنت. تأكد من وجود مساحة كافية على جهازك.',
                    Icons.download_outlined,
                    ProfessionalTheme.accentCyan,
                  ),
                  _buildGuideSection(
                    'إدارة قائمة المشاهدة',
                    'تعرف على كيفية إضافة المحتوى إلى قائمة المشاهدة الخاصة بك وتنظيمها.',
                    Icons.playlist_add_outlined,
                    ProfessionalTheme.accentGold,
                  ),
                  _buildGuideSection(
                    'الإعدادات والتخصيص',
                    'اكتشف كيفية تخصيص إعدادات التطبيق حسب تفضيلاتك، بما في ذلك اللغة وجودة الفيديو والإشعارات.',
                    Icons.settings_outlined,
                    ProfessionalTheme.accentPink,
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
            Icons.menu_book_outlined,
            color: ProfessionalTheme.primaryBrand,
            size: 48,
          ),
          const SizedBox(height: ProfessionalTheme.space16),
          Text(
            'دليل المستخدم',
            style: ProfessionalTheme.titleLarge(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ProfessionalTheme.space8),
          Text(
            'تعلم كيفية استخدام جميع ميزات التطبيق',
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
