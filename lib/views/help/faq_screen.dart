import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/theme/professional_theme.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with TickerProviderStateMixin {
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
                'الأسئلة الشائعة',
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
                  _buildFAQItem(
                    'كيف يمكنني إنشاء حساب جديد؟',
                    'يمكنك إنشاء حساب جديد عن طريق النقر على زر "تسجيل" في الصفحة الرئيسية، ثم اتبع الخطوات البسيطة لإدخال معلوماتك.',
                    Icons.person_add_outlined,
                  ),
                  const SizedBox(height: ProfessionalTheme.space16),
                  _buildFAQItem(
                    'كيف يمكنني تغيير لغة التطبيق؟',
                    'يمكنك تغيير لغة التطبيق من خلال الذهاب إلى الإعدادات، ثم اختيار "إعدادات اللغة" واختيار اللغة المفضلة لديك.',
                    Icons.language_outlined,
                  ),
                  const SizedBox(height: ProfessionalTheme.space16),
                  _buildFAQItem(
                    'كيف يمكنني تنزيل المحتوى لمشاهدته لاحقاً؟',
                    'يمكنك تنزيل المحتوى للمشاهدة دون اتصال بالإنترنت عن طريق النقر على زر التنزيل الموجود بجانب المحتوى الذي تريد تنزيله.',
                    Icons.download_outlined,
                  ),
                  const SizedBox(height: ProfessionalTheme.space16),
                  _buildFAQItem(
                    'ما هي متطلبات تشغيل التطبيق؟',
                    'يتطلب التطبيق اتصالاً بالإنترنت للبث المباشر، ومساحة تخزين كافية للتنزيلات. يعمل التطبيق على أجهزة Android و iOS الحديثة.',
                    Icons.system_update_outlined,
                  ),
                  const SizedBox(height: ProfessionalTheme.space16),
                  _buildFAQItem(
                    'كيف يمكنني إلغاء اشتراكي؟',
                    'يمكنك إلغاء اشتراكك في أي وقت من خلال الذهاب إلى إعدادات الحساب، ثم اختيار "إدارة الاشتراك" والنقر على "إلغاء الاشتراك".',
                    Icons.cancel_outlined,
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
            Icons.quiz_outlined,
            color: ProfessionalTheme.primaryBrand,
            size: 48,
          ),
          const SizedBox(height: ProfessionalTheme.space16),
          Text(
            'الأسئلة الشائعة',
            style: ProfessionalTheme.titleLarge(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ProfessionalTheme.space8),
          Text(
            'جميع الإجابات على أسئلتك الشائعة',
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: ProfessionalTheme.space8),
      decoration: ProfessionalTheme.glassMorphism.copyWith(
        boxShadow: [
          BoxShadow(
            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: ProfessionalTheme.primaryBrand,
            collapsedIconColor: ProfessionalTheme.primaryBrand,
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
            padding: const EdgeInsets.all(ProfessionalTheme.space8),
            decoration: BoxDecoration(
              color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: ProfessionalTheme.primaryBrand,
              size: 20,
            ),
          ),
          title: Text(
            question,
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
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Text(
                answer,
                style: ProfessionalTheme.bodyMedium(
                  color: ProfessionalTheme.textSecondary,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
