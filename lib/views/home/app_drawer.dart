import 'package:alenwan/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../../routes/app_routes.dart';
import '../../core/theme/professional_theme.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Using ProfessionalTheme colors for consistency

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ProfessionalTheme.backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ProfessionalTheme.backgroundColor,
              ProfessionalTheme.surfaceColor.withValues(alpha: 0.8),
              ProfessionalTheme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                children: [
                  // Modern Header with Glass Effect
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value * 0.5),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ProfessionalTheme.primaryColor
                                  .withValues(alpha: 0.2),
                              ProfessionalTheme.secondaryColor
                                  .withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ProfessionalTheme.primaryColor
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Animated Logo
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    ProfessionalTheme.primaryColor
                                        .withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/logo-alenwan.jpeg',
                                height: 50,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.movie,
                                    size: 50,
                                    color: ProfessionalTheme.primaryBrand,
                                  );
                                },
                              ),
                            ),
                            const Spacer(),
                            // Modern Close Button
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    ProfessionalTheme.primaryColor
                                        .withValues(alpha: 0.2),
                                    ProfessionalTheme.secondaryColor
                                        .withValues(alpha: 0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: ProfessionalTheme.primaryColor
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close,
                                    color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Premium Subscribe Button with Animation
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                                context, AppRoutes.subscription);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [
                                  ProfessionalTheme.primaryBrand,
                                  ProfessionalTheme.primaryBrand.withValues(alpha: 0.8)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ProfessionalTheme.primaryColor
                                      .withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter:
                                    ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.white,
                                      size: 24,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.5),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'اشترك الآن',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Cairo',
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Menu Items with Staggered Animation
                  Expanded(
                    child: ListView(
                      children: [
                        _buildAnimatedDrawerItem(
                          Icons.home_rounded,
                          'الرئيسية',
                          0,
                          onTap: () => _go(context, AppRoutes.home),
                        ),
                        _buildAnimatedDrawerItem(
                          Icons.tv_rounded,
                          'مسلسلات',
                          1,
                          onTap: () => _go(context, AppRoutes.allSeries),
                        ),
                        _buildAnimatedDrawerItem(
                          Icons.movie_rounded,
                          'أفلام',
                          2,
                          onTap: () => _go(context, AppRoutes.allMovies),
                        ),
                        _buildAnimatedDrawerItem(
                          Icons.sports_soccer_rounded,
                          'رياضة',
                          3,
                          onTap: () => _go(context, AppRoutes.allSports),
                        ),
                        _buildAnimatedDrawerItem(
                          Icons.movie_creation_rounded,
                          'الوثائقيات',
                          4,
                          onTap: () => _go(context, AppRoutes.allDocumentaries),
                        ),
                        _buildAnimatedDrawerItem(
                          Icons.child_care_rounded,
                          'أطفال',
                          5,
                          onTap: () => _go(context, AppRoutes.allCartoons),
                        ),
                        _buildAnimatedDrawerItem(
                          Icons.mic_rounded,
                          'بودكاست',
                          6,
                          onTap: () => _go(context, AppRoutes.allPodcasts),
                        ),
                        _buildDivider(7),
                        _buildAnimatedDrawerItem(
                          Icons.person_rounded,
                          'الملف الشخصي',
                          8,
                          onTap: () => _go(context, AppRoutes.profile),
                        ),
                        _buildAnimatedDrawerItem(
                          Icons.bookmark_rounded,
                          'قائمتي',
                          9,
                          onTap: () => _go(context, AppRoutes.favorites),
                        ),
                        _buildAnimatedDrawerItem(
                          Icons.language_rounded,
                          'اللغة',
                          10,
                          onTap: () =>
                              _go(context, AppRoutes.languageSelection),
                        ),
                        _buildAnimatedDrawerItem(
                          Icons.settings_rounded,
                          'إعدادات الحساب',
                          11,
                          onTap: () => _go(context, AppRoutes.settings),
                        ),
                        _buildDivider(12),
                        _buildAnimatedDrawerItem(
                          Icons.devices_rounded,
                          'إدارة الأجهزة',
                          13,
                          onTap: () => _go(context, AppRoutes.devices),
                        ),
                        // Only show logout button if not in guest mode
                        Consumer<AuthController>(
                          builder: (context, authController, _) {
                            if (authController.isGuestMode) {
                              return const SizedBox.shrink();
                            }
                            return _buildAnimatedDrawerItem(
                              Icons.logout_rounded,
                              'خروج',
                              14,
                              isLogout: true,
                              onTap: () async {
                                Navigator.pop(context);
                                final authController =
                                    context.read<AuthController>();
                                await authController.logout();
                                if (context.mounted) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    AppRoutes.login,
                                    (route) => false,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Footer with Animation
                  Transform.translate(
                    offset: Offset(0, -_slideAnimation.value * 0.3),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              ProfessionalTheme.primaryColor
                                  .withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    ProfessionalTheme.primaryColor
                                        .withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/images/logo-alenwan.jpeg',
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'العنوان',
                                  style: TextStyle(
                                    color: ProfessionalTheme.primaryBrand,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    ProfessionalTheme.primaryColor
                                        .withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDrawerItem(
    IconData icon,
    String title,
    int index, {
    VoidCallback? onTap,
    bool isLogout = false,
  }) {
    final delay = index * 50.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final progress =
            (_animationController.value * 1000 - delay).clamp(0, 300) / 300;

        return Transform.translate(
          offset: Offset(-50 * (1 - progress), 0),
          child: Opacity(
            opacity: progress,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isLogout
                    ? LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.red.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      )
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isLogout
                                  ? [
                                      Colors.red.withValues(alpha: 0.3),
                                      Colors.red.withValues(alpha: 0.1),
                                    ]
                                  : [
                                      ProfessionalTheme.primaryColor
                                          .withValues(alpha: 0.2),
                                      ProfessionalTheme.secondaryColor
                                          .withValues(alpha: 0.1),
                                    ],
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isLogout ? Colors.red[300] : Colors.white70,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          title,
                          style: TextStyle(
                            color: isLogout ? Colors.red[300] : Colors.white,
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: isLogout
                              ? Colors.red.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.2),
                          size: 14,
                        ),
                      ],
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

  Widget _buildDivider(int index) {
    final delay = index * 50.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final progress =
            (_animationController.value * 1000 - delay).clamp(0, 300) / 300;

        return Opacity(
          opacity: progress,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  ProfessionalTheme.primaryColor.withValues(alpha: 0.2),
                  ProfessionalTheme.primaryColor.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }
}
