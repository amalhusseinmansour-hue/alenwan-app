import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/theme/professional_theme.dart';
import 'email_support_screen.dart';
import 'phone_support_screen.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen>
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
                'اتصل بنا',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: ProfessionalTheme.space20,
            vertical: ProfessionalTheme.space24,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: ProfessionalTheme.space32),
                  _buildContactOption(
                    title: 'البريد الإلكتروني',
                    subtitle: 'راسلنا عبر البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmailSupportScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: ProfessionalTheme.space16),
                  _buildContactOption(
                    title: 'الهاتف',
                    subtitle: 'اتصل بنا مباشرة',
                    icon: Icons.phone_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PhoneSupportScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: ProfessionalTheme.space32),
                  _buildFooterInfo(),
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
            Icons.support_agent,
            color: ProfessionalTheme.primaryBrand,
            size: 48,
          ),
          const SizedBox(height: ProfessionalTheme.space16),
          Text(
            'كيف يمكننا مساعدتك؟',
            style: ProfessionalTheme.titleLarge(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ProfessionalTheme.space8),
          Text(
            'اختر طريقة التواصل المناسبة لك',
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
          child: Container(
            padding: const EdgeInsets.all(ProfessionalTheme.space20),
            decoration: ProfessionalTheme.glassMorphism.copyWith(
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ProfessionalTheme.space12),
                  decoration: BoxDecoration(
                    color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: ProfessionalTheme.primaryBrand,
                    size: 24,
                  ),
                ),
                const SizedBox(width: ProfessionalTheme.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ProfessionalTheme.titleMedium(
                          color: ProfessionalTheme.textPrimary,
                          weight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: ProfessionalTheme.space4),
                      Text(
                        subtitle,
                        style: ProfessionalTheme.bodyMedium(
                          color: ProfessionalTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: ProfessionalTheme.textTertiary,
                  size: 16,
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
      padding: const EdgeInsets.all(ProfessionalTheme.space16),
      decoration: BoxDecoration(
        color: ProfessionalTheme.surfaceCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            color: ProfessionalTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(height: ProfessionalTheme.space8),
          Text(
            'نحن هنا لمساعدتك في أي وقت',
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ProfessionalTheme.space4),
          Text(
            'فريق الدعم متاح على مدار الساعة',
            style: ProfessionalTheme.bodySmall(
              color: ProfessionalTheme.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
