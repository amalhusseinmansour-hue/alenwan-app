// lib/views/profile/profile_screen.dart
import 'package:alenwan/views/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/subscription_controller.dart';
import '../../routes/app_routes.dart';
import '../help/help_center_screen.dart';
import '../../core/theme/professional_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late ProfileController _profileController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  // Using centralized theme colors from ProfessionalTheme

  // used to break cache after updating the avatar
  String? _imgBust;

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController();

    // Load subscription status when profile is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionController>().load();
    });

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _floatingController = AnimationController(
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
    _floatingAnimation = CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _floatingController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  String _countryFromPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return '—';
    const Map<String, String> map = {
      '+966': 'السعودية',
      '+971': 'الإمارات',
      '+20': 'مصر',
      '+965': 'الكويت',
      '+973': 'البحرين',
      '+968': 'عُمان',
      '+962': 'الأردن',
      '+961': 'لبنان',
      '+212': 'المغرب',
      '+218': 'ليبيا',
      '+249': 'السودان',
      '+964': 'العراق',
      '+963': 'سوريا',
      '+216': 'تونس',
      '+213': 'الجزائر',
    };
    for (final code in map.keys) {
      if (phone.startsWith(code)) return map[code]!;
    }
    return '—';
  }

  String _formatJoinDate(dynamic createdAt) {
    if (createdAt == null) return '—';
    try {
      final dt = DateTime.parse(createdAt.toString());
      const months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر'
      ];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);

    return ChangeNotifierProvider.value(
      value: _profileController,
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundColor,
        body: Stack(
          children: [
            // Animated background
            _buildAnimatedBackground(),

            // Main content
            SafeArea(
              child: RefreshIndicator(
                color: ProfessionalTheme.primaryColor,
                onRefresh: () => context.read<ProfileController>().refresh(),
                child: Consumer<ProfileController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading) {
                      return _buildLoadingState();
                    }

                    if (controller.error == 'unauthorized') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (r) => false,
                        );
                      });
                      return _buildLoadingState();
                    }

                    final user = controller.user;
                    final name = (user?['name'] as String?)?.trim();
                    final email = (user?['email'] as String?)?.trim();
                    final phone = (user?['phone'] as String?)?.trim();

                    final rawPhoto =
                        (user?['profileImage'] ?? user?['photo_url']) as String?;
                    final basePhoto =
                        (rawPhoto == null || rawPhoto.isEmpty) ? '' : rawPhoto;
                    final photoUrl = basePhoto.isEmpty
                        ? ''
                        : (_imgBust == null
                            ? basePhoto
                            : '$basePhoto?cb=$_imgBust');

                    final createdAt = user?['created_at'];

                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // Modern header
                          _buildSliverAppBar(context),

                          // Profile content
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  // Profile card
                                  _buildProfileCard(
                                    name: name,
                                    email: email,
                                    phone: phone,
                                    photoUrl: photoUrl,
                                    createdAt: createdAt,
                                    user: user,
                                    context: context,
                                  ),

                                  const SizedBox(height: 24),

                                  // Subscription section
                                  _buildSubscriptionSection(context),

                                  const SizedBox(height: 24),

                                  // Settings section
                                  _buildSettingsSection(context),

                                  const SizedBox(height: 24),

                                  // Delete Account button
                                  _buildDeleteAccountButton(authController, context),

                                  // Logout button
                                  _buildLogoutButton(authController, context),

                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ProfessionalTheme.backgroundColor,
                ProfessionalTheme.surfaceColor.withValues(alpha: 0.3),
                ProfessionalTheme.backgroundColor,
                ProfessionalTheme.primaryColor.withValues(alpha: 0.05),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: ParticlesPainter(_floatingAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: ProfessionalTheme.surfaceColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: ProfessionalTheme.primaryColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'جارٍ التحميل...',
              style: ProfessionalTheme.getTextStyle(
                context: context,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: ProfessionalTheme.backgroundColor.withValues(alpha: 0.9),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'my_account'.tr(),
          style: ProfessionalTheme.getTextStyle(
            context: context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ProfessionalTheme.primaryColor.withValues(alpha: 0.8),
                ProfessionalTheme.secondaryColor.withValues(alpha: 0.6),
                ProfessionalTheme.backgroundColor.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String? name,
    required String? email,
    required String? phone,
    required String photoUrl,
    required dynamic createdAt,
    required Map<String, dynamic>? user,
    required BuildContext context,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ProfessionalTheme.surfaceColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ProfessionalTheme.primaryColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                // Profile photo with floating animation
                AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, math.sin(_floatingAnimation.value * math.pi * 2) * 5),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalTheme.primaryColor.withValues(alpha: 0.8),
                              ProfessionalTheme.secondaryColor.withValues(alpha: 0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ProfessionalTheme.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ProfessionalTheme.surfaceColor,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: (photoUrl.isNotEmpty)
                                ? CachedNetworkImage(
                                    imageUrl: photoUrl,
                                    width: 94,
                                    height: 94,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      width: 94,
                                      height: 94,
                                      color: ProfessionalTheme.surfaceColor,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Name
                Text(
                  name?.isNotEmpty == true ? name! : 'user'.tr(),
                  style: ProfessionalTheme.getTextStyle(
                    context: context,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Email
                if (email != null && email.isNotEmpty) ...[
                  Text(
                    email,
                    style: ProfessionalTheme.getTextStyle(
                      context: context,
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],

                // Country & Join date row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoChip(
                      icon: Icons.location_on,
                      text: _countryFromPhone(phone),
                      context: context,
                    ),
                    _buildInfoChip(
                      icon: Icons.calendar_today,
                      text: _formatJoinDate(createdAt),
                      context: context,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Edit profile button
                _buildGradientButton(
                  onPressed: () async {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(user: user),
                      ),
                    );

                    if (changed == true && mounted) {
                      setState(() => _imgBust = DateTime.now()
                          .millisecondsSinceEpoch
                          .toString());
                      // ignore: use_build_context_synchronously
                      context.read<ProfileController>().refresh();
                    }
                  },
                  text: 'تعديل الملف الشخصي',
                  icon: Icons.edit,
                  context: context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ProfessionalTheme.primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: ProfessionalTheme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: ProfessionalTheme.getTextStyle(
              context: context,
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, subscriptionController, _) {
        final hasActiveSubscription = subscriptionController.hasActive;
        final currentSubscription = subscriptionController.currentSubscription;
        final daysRemaining = subscriptionController.daysRemaining;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: hasActiveSubscription
                ? LinearGradient(
                    colors: [
                      ProfessionalTheme.primaryColor.withValues(alpha: 0.8),
                      ProfessionalTheme.secondaryColor.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      ProfessionalTheme.surfaceColor.withValues(alpha: 0.6),
                      ProfessionalTheme.surfaceColor.withValues(alpha: 0.8),
                    ],
                  ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: hasActiveSubscription
                  ? ProfessionalTheme.primaryColor.withValues(alpha: 0.5)
                  : ProfessionalTheme.primaryColor.withValues(alpha: 0.2),
              width: hasActiveSubscription ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: hasActiveSubscription
                    ? ProfessionalTheme.primaryColor.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: hasActiveSubscription ? 25 : 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          hasActiveSubscription
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: hasActiveSubscription
                              ? Colors.amber
                              : Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasActiveSubscription ? 'اشتراك نشط' : 'لا يوجد اشتراك',
                              style: ProfessionalTheme.getTextStyle(
                                context: context,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (hasActiveSubscription && currentSubscription != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'خطة ${currentSubscription.plan.name ?? "Platinum"}',
                                style: ProfessionalTheme.getTextStyle(
                                  context: context,
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (hasActiveSubscription)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'نشط',
                                style: ProfessionalTheme.getTextStyle(
                                  context: context,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  if (hasActiveSubscription && daysRemaining > 0) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الأيام المتبقية',
                                  style: ProfessionalTheme.getTextStyle(
                                    context: context,
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$daysRemaining يوم',
                                  style: ProfessionalTheme.getTextStyle(
                                    context: context,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (daysRemaining <= 7)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'قارب على الانتهاء',
                                style: ProfessionalTheme.getTextStyle(
                                  context: context,
                                  fontSize: 11,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  if (!hasActiveSubscription) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white.withValues(alpha: 0.6),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'احصل على وصول غير محدود للمحتوى المميز',
                              style: ProfessionalTheme.getTextStyle(
                                context: context,
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Subscribe/Manage button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hasActiveSubscription
                            ? [
                                Colors.white.withValues(alpha: 0.2),
                                Colors.white.withValues(alpha: 0.1),
                              ]
                            : [
                                ProfessionalTheme.primaryColor,
                                ProfessionalTheme.secondaryColor,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: hasActiveSubscription
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.subscription);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasActiveSubscription
                                    ? Icons.settings
                                    : Icons.rocket_launch,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                hasActiveSubscription
                                    ? 'إدارة الاشتراك'
                                    : 'اشترك الآن',
                                style: ProfessionalTheme.getTextStyle(
                                  context: context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ProfessionalTheme.surfaceColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ProfessionalTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الإعدادات',
                style: ProfessionalTheme.getTextStyle(
                  context: context,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              _buildModernSettingTile(
                icon: Icons.favorite_border,
                title: 'المفضلات',
                subtitle: 'مشاهدة المحتوى المفضل',
                onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
                context: context,
              ),

              _buildModernSettingTile(
                icon: Icons.download_rounded,
                title: 'التنزيلات',
                subtitle: 'إدارة الملفات المحملة',
                onTap: () => Navigator.pushNamed(context, AppRoutes.downloads),
                context: context,
              ),

              _buildModernSettingTile(
                icon: Icons.settings_rounded,
                title: 'الإعدادات',
                subtitle: 'إعدادات التطبيق',
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                context: context,
              ),

              _buildModernSettingTile(
                icon: Icons.help_outline_rounded,
                title: 'مركز المساعدة',
                subtitle: 'الدعم والمساعدة',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HelpCenterScreen(),
                  ),
                ),
                context: context,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required BuildContext context,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ProfessionalTheme.primaryColor.withValues(alpha: 0.8),
                          ProfessionalTheme.secondaryColor.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: ProfessionalTheme.getTextStyle(
                            context: context,
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withValues(alpha: 0.1),
            height: 1,
            thickness: 0.5,
            indent: 66,
          ),
      ],
    );
  }

  Widget _buildLogoutButton(AuthController authController, BuildContext context) {
    return _buildGradientButton(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => _buildLogoutDialog(context),
        );

        if (confirm == true) {
          await authController.logout();
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            AppRoutes.login,
            (r) => false,
          );
        }
      },
      text: 'تسجيل الخروج',
      icon: Icons.logout,
      context: context,
      isDestructive: true,
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required BuildContext context,
    bool isDestructive = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDestructive
              ? [
                  Colors.red.withValues(alpha: 0.8),
                  Colors.red.shade700.withValues(alpha: 0.6),
                ]
              : [
                  ProfessionalTheme.primaryColor.withValues(alpha: 0.8),
                  ProfessionalTheme.secondaryColor.withValues(alpha: 0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDestructive ? Colors.red : ProfessionalTheme.primaryColor).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: ProfessionalTheme.getTextStyle(
                    context: context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: ProfessionalTheme.surfaceColor.withValues(alpha:0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      title: Text(
        'logout'.tr(),
        style: ProfessionalTheme.getTextStyle(
          context: context,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: Text(
        'logout_confirmation'.tr(),
        style: ProfessionalTheme.getTextStyle(
          context: context,
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'cancel'.tr(),
            style: ProfessionalTheme.getTextStyle(
              context: context,
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withValues(alpha: 0.8),
                Colors.red.shade700.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context, true),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'تأكيد',
                  style: ProfessionalTheme.getTextStyle(
                    context: context,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Delete Account Methods
  Widget _buildDeleteAccountButton(AuthController authController, BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDeleteAccountDialog(authController),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
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
                        'حذف الحساب نهائياً',
                        style: ProfessionalTheme.getTextStyle(
                          context: context,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'سيتم حذف جميع بياناتك بشكل دائم',
                        style: ProfessionalTheme.getTextStyle(
                          context: context,
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
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

  void _showDeleteAccountDialog(AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProfessionalTheme.surfaceColor.withValues(alpha:0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.red.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من حذف حسابك نهائياً؟',
              style: ProfessionalTheme.getTextStyle(
                context: context,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'سيتم حذف:',
              style: ProfessionalTheme.getTextStyle(
                context: context,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 8),
            _buildDeleteItem('جميع بياناتك الشخصية'),
            _buildDeleteItem('اشتراكاتك الحالية'),
            _buildDeleteItem('سجل المشاهدة'),
            _buildDeleteItem('التعليقات والتفاعلات'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لا يمكن التراجع عن هذا الإجراء!',
                      style: ProfessionalTheme.getTextStyle(
                        context: context,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: ProfessionalTheme.getTextStyle(
                context: context,
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withValues(alpha: 0.8),
                  Colors.red.shade700.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _performDeleteAccount(authController);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'حذف نهائياً',
                    style: ProfessionalTheme.getTextStyle(
                      context: context,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, right: 8),
      child: Row(
        children: [
          const Icon(Icons.close, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: ProfessionalTheme.getTextStyle(
              context: context,
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _performDeleteAccount(AuthController authController) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          color: ProfessionalTheme.surfaceColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Colors.red,
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
      ),
    );

    try {
      final authService = authController.authService;
      final result = await authService.deleteAccount();

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (result['success'] == true) {
        // Logout and navigate to home
        await authController.logout();

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(result['message'] ?? 'تم حذف حسابك بنجاح'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(result['message'] ?? 'فشل حذف الحساب'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA20136).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i * 0.1 + 0.05)) +
          math.sin(animationValue * math.pi * 2 + i) * 20;
      final y = (size.height * (i * 0.05 + 0.1)) +
          math.cos(animationValue * math.pi * 2 + i) * 15;

      canvas.drawCircle(
        Offset(x, y),
        2 + math.sin(animationValue * math.pi * 4 + i) * 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
