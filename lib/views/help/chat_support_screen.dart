import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/theme/professional_theme.dart';
import 'live_chat_screen.dart';

class ChatSupportScreen extends StatefulWidget {
  const ChatSupportScreen({super.key});

  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen>
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
                'الدردشة المباشرة',
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
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.symmetric(
              horizontal: ProfessionalTheme.space20,
              vertical: ProfessionalTheme.space24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusCard(),
                const SizedBox(height: ProfessionalTheme.space32),
                _buildChatOption(
                  title: 'رسالة نصية',
                  description: 'تحدث مع ممثل خدمة العملاء عبر الرسائل النصية',
                  icon: Icons.chat_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LiveChatScreen(),
                      ),
                    );
                  },
                ),
                const Spacer(),
                _buildFooterInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(ProfessionalTheme.space20),
      decoration: ProfessionalTheme.glassMorphism.copyWith(
        color: ProfessionalTheme.accentGreen.withOpacity(0.1),
        border: Border.all(
          color: ProfessionalTheme.accentGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: ProfessionalTheme.accentGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.accentGreen.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: ProfessionalTheme.space16),
          Expanded(
            child: Text(
              'فريق الدعم متواجد الآن',
              style: ProfessionalTheme.titleMedium(
                color: ProfessionalTheme.textPrimary,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildChatOption({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: ProfessionalTheme.space20),
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
                  color: ProfessionalTheme.primaryBrand.withOpacity(0.1),
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
                    color: ProfessionalTheme.primaryBrand.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
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
                        description,
                        style: ProfessionalTheme.bodyMedium(
                          color: ProfessionalTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(ProfessionalTheme.space16),
          decoration: BoxDecoration(
            color: ProfessionalTheme.surfaceCard.withOpacity(0.3),
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    color: ProfessionalTheme.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: ProfessionalTheme.space8),
                  Text(
                    'ساعات العمل: 24/7',
                    style: ProfessionalTheme.bodyMedium(
                      color: ProfessionalTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ProfessionalTheme.space8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: ProfessionalTheme.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: ProfessionalTheme.space8),
                  Text(
                    'متوسط وقت الانتظار: 2-5 دقائق',
                    style: ProfessionalTheme.bodyMedium(
                      color: ProfessionalTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
