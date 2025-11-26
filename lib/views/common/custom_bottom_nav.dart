import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alenwan/core/theme/professional_theme.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedIcon({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required String label,
    bool isSpecial = false,
  }) {
    final isActive = widget.currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSpecial && isActive)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: ProfessionalTheme.premiumGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      activeIcon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            )
          else if (isActive && !isSpecial)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                activeIcon,
                size: 22,
                color: ProfessionalTheme.primaryBrand,
              ),
            )
          else
            Icon(
              icon,
              size: isSpecial ? 24 : 22,
              color: ProfessionalTheme.textTertiary,
            ),
          const SizedBox(height: 2),
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: isActive ? 11 : 10,
                color: isActive
                    ? ProfessionalTheme.primaryBrand
                    : ProfessionalTheme.textTertiary,
              ),
              overflow: TextOverflow.ellipsis,
              child: Text(label.tr()),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(
          color: ProfessionalTheme.surfaceCard,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => widget.onTap(0),
              child: _buildAnimatedIcon(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                index: 0,
                label: 'home',
              ),
            ),
            GestureDetector(
              onTap: () => widget.onTap(1),
              child: _buildAnimatedIcon(
                icon: Icons.download_outlined,
                activeIcon: Icons.download,
                index: 1,
                label: 'downloads',
              ),
            ),
            GestureDetector(
              onTap: () => widget.onTap(2),
              child: _buildAnimatedIcon(
                icon: Icons.play_circle_outline,
                activeIcon: Icons.play_circle_filled,
                index: 2,
                label: 'Live',
                isSpecial: true,
              ),
            ),
            GestureDetector(
              onTap: () => widget.onTap(3),
              child: _buildAnimatedIcon(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                index: 3,
                label: 'discover',
              ),
            ),
            GestureDetector(
              onTap: () => widget.onTap(4),
              child: _buildAnimatedIcon(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                index: 4,
                label: 'profile',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
