import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/theme/modern_theme.dart';
import '../routes/app_routes.dart';

/// Modern navigation bar for content screens
class ModernContentNavigation extends StatelessWidget {
  final String currentRoute;
  final bool isWide;

  const ModernContentNavigation({
    super.key,
    required this.currentRoute,
    this.isWide = false,
  });

  static const Map<String, String> navItems = {
    'الرئيسية': AppRoutes.home,
    'المسلسلات': AppRoutes.allSeries,
    'الأفلام': AppRoutes.allMovies,
    'الرياضة': AppRoutes.allSports,
    'الوثائقيات': AppRoutes.allDocumentaries,
    'الأطفال': AppRoutes.allCartoons,
    'البث المباشر': AppRoutes.liveStream,
  };

  static IconData getIconForRoute(String routeName) {
    switch (routeName) {
      case 'الرئيسية':
        return Icons.home_rounded;
      case 'المسلسلات':
        return Icons.tv_rounded;
      case 'الأفلام':
        return Icons.movie_rounded;
      case 'الرياضة':
        return Icons.sports_soccer_rounded;
      case 'الوثائقيات':
        return Icons.article_rounded;
      case 'الأطفال':
        return Icons.child_care_rounded;
      case 'البث المباشر':
        return Icons.live_tv_rounded;
      default:
        return Icons.play_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isWide) return Container();

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: ModernTheme.spacingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: navItems.entries.map((entry) {
          final isSelected = _isCurrentRoute(entry.value);
          return _buildNavItem(
            context,
            title: entry.key,
            route: entry.value,
            icon: getIconForRoute(entry.key),
            isSelected: isSelected,
          );
        }).toList(),
      ),
    );
  }

  bool _isCurrentRoute(String route) {
    return currentRoute == route ||
           (currentRoute.contains('movie') && route == AppRoutes.allMovies) ||
           (currentRoute.contains('series') && route == AppRoutes.allSeries) ||
           (currentRoute.contains('sport') && route == AppRoutes.allSports) ||
           (currentRoute.contains('documentar') && route == AppRoutes.allDocumentaries) ||
           (currentRoute.contains('cartoon') && route == AppRoutes.allCartoons) ||
           (currentRoute.contains('live') && route == AppRoutes.liveStream);
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String title,
    required String route,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
      borderRadius: BorderRadius.circular(ModernTheme.radiusXLarge),
      child: AnimatedContainer(
        duration: ModernTheme.animationFast,
        margin: EdgeInsets.symmetric(horizontal: ModernTheme.spacingXS),
        padding: EdgeInsets.symmetric(
          horizontal: ModernTheme.spacingM,
          vertical: ModernTheme.spacingS,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? ModernTheme.primaryGradient : null,
          color: !isSelected ? Colors.white.withOpacity(0.05) : null,
          borderRadius: BorderRadius.circular(ModernTheme.radiusXLarge),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: isSelected ? ModernTheme.glowShadow : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 18,
            ),
            SizedBox(width: ModernTheme.spacingS),
            Text(
              title,
              style: ModernTheme.body1(
                color: isSelected ? Colors.white : Colors.white70,
              ).copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern app bar with navigation
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String currentRoute;
  final bool isWide;
  final bool showBackButton;
  final List<Widget>? actions;

  const ModernAppBar({
    super.key,
    required this.title,
    required this.currentRoute,
    this.isWide = false,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    isWide ? kToolbarHeight + 80 : kToolbarHeight + 20,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ModernTheme.backgroundColor.withOpacity(0.98),
            ModernTheme.backgroundColor.withOpacity(0.8),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: showBackButton || !isWide
                    ? _buildGlassButton(
                        icon: showBackButton ? Icons.arrow_back : Icons.menu_rounded,
                        onPressed: () {
                          if (showBackButton) {
                            Navigator.of(context).pop();
                          } else {
                            Scaffold.of(context).openDrawer();
                          }
                        },
                      )
                    : null,
                title: Row(
                  children: [
                    // Animated Logo with Glow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            ModernTheme.primaryColor.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ModernTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo-alenwan.jpeg',
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: ModernTheme.spacingM),

                    // Title with Gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.white,
                          ModernTheme.primaryColor,
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        title,
                        style: ModernTheme.headline3(color: Colors.white),
                      ),
                    ),

                    const Spacer(),

                    // Action buttons
                    Row(
                      children: actions ?? [
                        _buildGlassButton(
                          icon: Icons.search_rounded,
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                        ),
                        SizedBox(width: ModernTheme.spacingS),
                        _buildGlassButton(
                          icon: Icons.person_rounded,
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
                          showBadge: true,
                        ),
                      ],
                    ),
                    SizedBox(width: ModernTheme.spacingM),
                  ],
                ),
              ),

              // Navigation items for wide screens
              if (isWide)
                ModernContentNavigation(
                  currentRoute: currentRoute,
                  isWide: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool showBadge = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ModernTheme.spacingXS),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
          child: Container(
            padding: EdgeInsets.all(ModernTheme.spacingS + 2),
            child: Stack(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
                if (showBadge)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: ModernTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ModernTheme.primaryColor.withOpacity(0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cinema effect background painter
class CinemaBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Animation<double>? sparkleAnimation;

  CinemaBackgroundPainter(this.animation, {this.sparkleAnimation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw film strip effect
    _drawFilmStrip(canvas, size, paint);

    // Draw animated gradient orbs
    for (int i = 0; i < 3; i++) {
      final progress = (animation.value + i * 0.3) % 1.0;
      final center = Offset(
        size.width * (0.2 + i * 0.3 + Math.sin(progress * Math.pi * 2) * 0.1),
        size.height * (0.3 + Math.cos(progress * Math.pi * 2) * 0.1),
      );

      paint.shader = RadialGradient(
        colors: [
          ModernTheme.primaryColor.withOpacity(0.06),
          ModernTheme.secondaryColor.withOpacity(0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: 250),
      );

      canvas.drawCircle(center, 250, paint);
    }

    // Draw sparkles if animation provided
    if (sparkleAnimation != null) {
      _drawSparkles(canvas, size, paint, sparkleAnimation!);
    }
  }

  void _drawFilmStrip(Canvas canvas, Size size, Paint paint) {
    final stripWidth = 30.0;
    final holeSize = 6.0;
    final holeSpacing = 18.0;

    // Film strip sides with opacity
    paint.color = ModernTheme.surfaceColor.withOpacity(0.2);

    // Left strip
    canvas.drawRect(Rect.fromLTWH(0, 0, stripWidth, size.height), paint);

    // Right strip
    canvas.drawRect(
      Rect.fromLTWH(size.width - stripWidth, 0, stripWidth, size.height),
      paint,
    );

    // Film holes
    paint.color = ModernTheme.backgroundColor.withOpacity(0.4);
    for (double y = 10; y < size.height; y += holeSpacing) {
      // Left holes
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(stripWidth / 2, y),
            width: holeSize,
            height: holeSize,
          ),
          Radius.circular(2),
        ),
        paint,
      );
      // Right holes
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width - stripWidth / 2, y),
            width: holeSize,
            height: holeSize,
          ),
          Radius.circular(2),
        ),
        paint,
      );
    }
  }

  void _drawSparkles(Canvas canvas, Size size, Paint paint, Animation<double> sparkle) {
    paint.style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final progress = (sparkle.value * 2 + i * 0.03) % 1.0;
      final opacity = Math.sin(progress * Math.pi);

      final x = size.width * ((i * 0.43) % 1.0);
      final y = size.height * ((i * 0.31) % 1.0);

      paint.color = Colors.amber.withOpacity(opacity * 0.02);

      canvas.drawCircle(Offset(x, y), 2 + opacity * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Math import
import 'dart:math' as Math;