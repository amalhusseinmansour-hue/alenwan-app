// lib/widgets/app_navigation_wrapper.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../core/theme/app_theme.dart';
import '../views/home/app_drawer.dart';
import '../views/common/custom_app_bar.dart';
import '../routes/app_routes.dart';

class AppNavigationWrapper extends StatefulWidget {
  final Widget child;
  final String? title;
  final bool showBottomNav;
  final int selectedIndex;
  final List<Widget>? actions;

  const AppNavigationWrapper({
    super.key,
    required this.child,
    this.title,
    this.showBottomNav = false,
    this.selectedIndex = 0,
    this.actions,
  });

  @override
  State<AppNavigationWrapper> createState() => _AppNavigationWrapperState();
}

class _AppNavigationWrapperState extends State<AppNavigationWrapper>
    with TickerProviderStateMixin {
  late AnimationController _navAnimationController;
  late Animation<double> _navFadeAnimation;
  late Animation<double> _navSlideAnimation;

  @override
  void initState() {
    super.initState();
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _navFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.easeInOut,
    ));

    _navSlideAnimation = Tween<double>(
      begin: 100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.easeOutBack,
    ));

    _navAnimationController.forward();
  }

  @override
  void dispose() {
    _navAnimationController.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.allSeries);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.allMovies);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.allSports);
        break;
      case 4:
        // Open drawer for "More" options
        Scaffold.of(context).openDrawer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 1100;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.backgroundColor,
      drawer: const AppDrawer(),  // Always show drawer for consistency
      appBar: CustomAppBar(
        title: widget.title,
        showSearch: widget.title == null,
        onMenuTap: () {
          final scaffold = Scaffold.of(context);
          if (scaffold.hasDrawer) {
            scaffold.openDrawer();
          }
        },
        actions: widget.actions,
      ),
      body: Stack(
        children: [
          // Main Content
          widget.child,

          // Modern Bottom Navigation with Burgundy Theme
          if (widget.showBottomNav && !isWide)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _navAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _navSlideAnimation.value),
                    child: FadeTransition(
                      opacity: _navFadeAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppTheme.backgroundColor.withOpacity(0.98),
                              AppTheme.backgroundColor.withOpacity(0.9),
                              AppTheme.backgroundColor.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              height: 75,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.surfaceColor.withOpacity(0.9),
                                    AppTheme.backgroundColor.withOpacity(0.85),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                border: Border(
                                  top: BorderSide(
                                    color: AppTheme.primaryColor.withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildNavItem(
                                    Icons.home_rounded,
                                    'الرئيسية',
                                    0,
                                    widget.selectedIndex == 0,
                                  ),
                                  _buildNavItem(
                                    Icons.tv_rounded,
                                    'مسلسلات',
                                    1,
                                    widget.selectedIndex == 1,
                                  ),
                                  _buildNavItem(
                                    Icons.movie_filter_rounded,
                                    'أفلام',
                                    2,
                                    widget.selectedIndex == 2,
                                  ),
                                  _buildNavItem(
                                    Icons.sports_soccer_rounded,
                                    'رياضة',
                                    3,
                                    widget.selectedIndex == 3,
                                  ),
                                  _buildNavItem(
                                    Icons.more_horiz_rounded,
                                    'المزيد',
                                    4,
                                    widget.selectedIndex == 4,
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool showBadge = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: AppTheme.glassDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
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
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.6),
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

  Widget _buildNavItem(IconData icon, String label, int index, bool isActive) {
    return GestureDetector(
      onTap: () => _navigateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(isActive ? 12 : 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.accentColor,
                        ],
                      )
                    : null,
                color: isActive ? null : Colors.white.withOpacity(0.05),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
                border: !isActive
                    ? Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : AppTheme.primaryColor.withOpacity(0.7),
                size: isActive ? 24 : 22,
                shadows: isActive
                    ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isActive ? 11 : 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withOpacity(0.6),
                fontFamily: 'Cairo',
                letterSpacing: isActive ? 0.5 : 0,
              ),
              child: Text(label),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 3),
              height: isActive ? 3 : 0,
              width: isActive ? 24 : 0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentColor,
                    AppTheme.primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}