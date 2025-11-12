import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../../core/theme/professional_theme.dart';

class EmailSupportScreen extends StatefulWidget {
  const EmailSupportScreen({super.key});

  @override
  State<EmailSupportScreen> createState() => _EmailSupportScreenState();
}

class _EmailSupportScreenState extends State<EmailSupportScreen>
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
                'راسلنا عبر البريد الإلكتروني',
                style: ProfessionalTheme.titleLarge(
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
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.symmetric(
              horizontal: ProfessionalTheme.space20,
              vertical: ProfessionalTheme.space24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: ProfessionalTheme.space32),
                Expanded(
                  child: ListView(
                    children: [
                      _buildEmailCard(
                        title: 'الدعم الفني',
                        email: 'info@alenwan.app',
                        description: 'للمساعدة في المشاكل التقنية',
                        icon: Icons.computer_outlined,
                        color: ProfessionalTheme.accentBlue,
                      ),
                      const SizedBox(height: ProfessionalTheme.space16),
                      _buildEmailCard(
                        title: 'خدمة العملاء',
                        email: 'customer.service@alenwan.app',
                        description: 'للاستفسارات العامة وخدمات العملاء',
                        icon: Icons.support_agent_outlined,
                        color: ProfessionalTheme.accentGreen,
                      ),
                      const SizedBox(height: ProfessionalTheme.space16),
                      _buildEmailCard(
                        title: 'الاشتراكات',
                        email: 'subscriptions@alenwan.app',
                        description: 'للاستفسار عن الاشتراكات والفواتير',
                        icon: Icons.card_membership_outlined,
                        color: ProfessionalTheme.accentGold,
                      ),
                    ],
                  ),
                ),
              ],
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
        color: ProfessionalTheme.primaryBrand.withOpacity(0.1),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.email_outlined,
            color: ProfessionalTheme.primaryBrand,
            size: 48,
          ),
          const SizedBox(height: ProfessionalTheme.space16),
          Text(
            'يمكنك مراسلتنا على عناوين البريد الإلكتروني التالية:',
            style: ProfessionalTheme.titleMedium(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  Widget _buildEmailCard({
    required String title,
    required String email,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _copyToClipboard(email),
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
                      Icons.copy,
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
                        Icons.email,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: ProfessionalTheme.space8),
                      Expanded(
                        child: Text(
                          email,
                          style: ProfessionalTheme.bodyMedium(
                            color: color,
                            weight: FontWeight.w600,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String email) {
    Clipboard.setData(ClipboardData(text: email));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(
            vertical: ProfessionalTheme.space8,
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: ProfessionalTheme.accentGreen,
                size: 20,
              ),
              const SizedBox(width: ProfessionalTheme.space12),
              Expanded(
                child: Text(
                  'تم نسخ البريد الإلكتروني',
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
