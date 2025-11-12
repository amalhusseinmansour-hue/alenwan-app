import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import '../../core/theme/professional_theme.dart';

class PhoneSupportScreen extends StatefulWidget {
  const PhoneSupportScreen({super.key});

  @override
  State<PhoneSupportScreen> createState() => _PhoneSupportScreenState();
}

class _PhoneSupportScreenState extends State<PhoneSupportScreen>
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
              color: ProfessionalTheme.surfaceCard.withOpacity(0.6),
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
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
                'الدعم الهاتفي',
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
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: ProfessionalTheme.space20,
            vertical: ProfessionalTheme.space24,
          ),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: ProfessionalTheme.space32),
            _buildPhoneCard(
              title: 'الدعم الفني',
              phoneNumber: '800-123-4567',
              description: 'للمساعدة في حل المشاكل التقنية والاستفسارات الفنية',
              workingHours: 'متاح 24/7',
              icon: Icons.computer_outlined,
              color: ProfessionalTheme.accentBlue,
            ),
            const SizedBox(height: ProfessionalTheme.space16),
            _buildPhoneCard(
              title: 'خدمة العملاء',
              phoneNumber: '800-234-5678',
              description: 'للاستفسارات العامة وخدمات ما بعد البيع',
              workingHours: '8 صباحاً - 10 مساءً',
              icon: Icons.support_agent_outlined,
              color: ProfessionalTheme.accentGreen,
            ),
            const SizedBox(height: ProfessionalTheme.space16),
            _buildPhoneCard(
              title: 'قسم الاشتراكات',
              phoneNumber: '800-345-6789',
              description: 'للاستفسار عن الاشتراكات والفواتير والعروض',
              workingHours: '9 صباحاً - 6 مساءً',
              icon: Icons.card_membership_outlined,
              color: ProfessionalTheme.accentGold,
            ),
            const SizedBox(height: ProfessionalTheme.space32),
            _buildFooterInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(ProfessionalTheme.space20),
      decoration: ProfessionalTheme.glassMorphism.copyWith(
        color: ProfessionalTheme.primaryBrand.withOpacity(0.1),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.phone_outlined,
            color: ProfessionalTheme.primaryBrand,
            size: 48,
          ),
          const SizedBox(height: ProfessionalTheme.space16),
          Text(
            'الدعم الهاتفي',
            style: ProfessionalTheme.titleLarge(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ProfessionalTheme.space8),
          Text(
            'يمكنك الاتصال بنا على الأرقام التالية للحصول على المساعدة الفورية',
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneCard({
    required String title,
    required String phoneNumber,
    required String description,
    required String workingHours,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _callNumber(phoneNumber),
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
          child: Container(
            padding: const EdgeInsets.all(ProfessionalTheme.space20),
            decoration: ProfessionalTheme.glassMorphism.copyWith(
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(ProfessionalTheme.space12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: ProfessionalTheme.space16),
                    Expanded(
                      child: Text(
                        title,
                        style: ProfessionalTheme.titleMedium(
                          color: ProfessionalTheme.textPrimary,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.phone,
                      color: ProfessionalTheme.textTertiary,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: ProfessionalTheme.space16),
                Container(
                  padding: const EdgeInsets.all(ProfessionalTheme.space12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: ProfessionalTheme.space8),
                      Expanded(
                        child: Text(
                          phoneNumber,
                          style: ProfessionalTheme.titleMedium(
                            color: color,
                            weight: FontWeight.w600,
                          ),
                          textDirection: ui.TextDirection.ltr,
                        ),
                      ),
                      InkWell(
                        onTap: () => _copyToClipboard(phoneNumber),
                        child: Container(
                          padding: const EdgeInsets.all(ProfessionalTheme.space4),
                          child: Icon(
                            Icons.copy,
                            color: color,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ProfessionalTheme.space12),
                Text(
                  description,
                  style: ProfessionalTheme.bodyMedium(
                    color: ProfessionalTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: ProfessionalTheme.space12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: ProfessionalTheme.textTertiary,
                      size: 16,
                    ),
                    const SizedBox(width: ProfessionalTheme.space8),
                    Text(
                      workingHours,
                      style: ProfessionalTheme.bodySmall(
                        color: ProfessionalTheme.textTertiary,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      padding: const EdgeInsets.all(ProfessionalTheme.space20),
      decoration: BoxDecoration(
        color: ProfessionalTheme.surfaceCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
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
                color: ProfessionalTheme.primaryBrand,
                size: 20,
              ),
              const SizedBox(width: ProfessionalTheme.space8),
              Text(
                'ملاحظات مهمة',
                style: ProfessionalTheme.titleMedium(
                  color: ProfessionalTheme.textPrimary,
                  weight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: ProfessionalTheme.space16),
          _buildInfoPoint('المكالمات مجانية من جميع أنحاء البلاد'),
          _buildInfoPoint('يرجى تجهيز رقم حسابك قبل الاتصال'),
          _buildInfoPoint('أوقات الانتظار قد تختلف حسب ضغط المكالمات'),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ProfessionalTheme.space8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: ProfessionalTheme.primaryBrand,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: ProfessionalTheme.space12),
          Expanded(
            child: Text(
              text,
              style: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _callNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showSnackBar('لا يمكن إجراء المكالمة', false);
    }
  }

  void _copyToClipboard(String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    _showSnackBar('تم نسخ رقم الهاتف', true);
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(
            vertical: ProfessionalTheme.space8,
          ),
          child: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess
                    ? ProfessionalTheme.accentGreen
                    : ProfessionalTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: ProfessionalTheme.space12),
              Expanded(
                child: Text(
                  message,
                  style: ProfessionalTheme.bodyMedium(
                    color: ProfessionalTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: ProfessionalTheme.surfaceCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
        ),
        margin: const EdgeInsets.all(ProfessionalTheme.space16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
