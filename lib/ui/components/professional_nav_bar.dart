import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/professional_theme.dart';

class ProfessionalNavBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(String)? onSearch;
  final Function(String)? onCategorySelected;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;
  final String? currentCategory;
  final String? userName;
  final String? userAvatar;
  final bool hasNotifications;

  const ProfessionalNavBar({
    super.key,
    this.onSearch,
    this.onCategorySelected,
    this.onProfileTap,
    this.onNotificationsTap,
    this.currentCategory,
    this.userName,
    this.userAvatar,
    this.hasNotifications = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  State<ProfessionalNavBar> createState() => _ProfessionalNavBarState();
}

class _ProfessionalNavBarState extends State<ProfessionalNavBar>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late AnimationController _scrollController;
  late TextEditingController _searchTextController;
  late FocusNode _searchFocus;

  bool _isSearchExpanded = false;
  final bool _isScrolled = false;
  bool _showProfileDropdown = false;

  final List<NavCategory> _categories = [
    NavCategory('الرئيسية', 'home', Icons.home_rounded),
    NavCategory('المسلسلات', 'series', Icons.tv_rounded),
    NavCategory('الأفلام', 'movies', Icons.movie_rounded),
    NavCategory('مباشر', 'live', Icons.sensors_rounded, isLive: true),
    NavCategory('الرياضة', 'sports', Icons.sports_soccer_rounded),
    NavCategory('وثائقيات', 'documentary', Icons.explore_rounded),
    NavCategory('أطفال', 'kids', Icons.child_care_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: ProfessionalTheme.durationMedium,
      vsync: this,
    );
    _scrollController = AnimationController(
      duration: ProfessionalTheme.durationFast,
      vsync: this,
    );
    _searchTextController = TextEditingController();
    _searchFocus = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchTextController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _searchController.forward();
        _searchFocus.requestFocus();
      } else {
        _searchController.reverse();
        _searchFocus.unfocus();
        _searchTextController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: _isScrolled
            ? ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.95)
            : ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : (isTablet ? 24 : 16),
            ),
            child: Row(
              children: [
                // Logo
                _buildLogo(),

                // Categories (Desktop/Tablet only)
                if (isTablet) ...[
                  const SizedBox(width: ProfessionalTheme.space32),
                  if (isDesktop) _buildCategories(),
                ],

                // Spacer
                const Spacer(),

                // Right section
                _buildRightSection(isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return GestureDetector(
      onTap: () => widget.onCategorySelected?.call('home'),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Image.asset(
          'assets/images/logo-alenwan.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            final isSelected = widget.currentCategory == category.id;
            return _NavCategoryButton(
              category: category,
              isSelected: isSelected,
              onTap: () => widget.onCategorySelected?.call(category.id),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRightSection(bool isDesktop) {
    return Row(
      children: [
        // Search
        AnimatedContainer(
          duration: ProfessionalTheme.durationMedium,
          width: _isSearchExpanded ? (isDesktop ? 300 : 200) : 48,
          height: 40,
          decoration: BoxDecoration(
            color: _isSearchExpanded
                ? ProfessionalTheme.surfaceCard.withValues(alpha: 0.8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusRound),
            border: Border.all(
              color: _isSearchExpanded
                  ? ProfessionalTheme.primaryBrand.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: _buildSearchField(),
        ),

        const SizedBox(width: ProfessionalTheme.space12),

        // Notifications
        _buildNotificationButton(),

        const SizedBox(width: ProfessionalTheme.space12),

        // Profile
        _buildProfileButton(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isSearchExpanded ? Icons.close_rounded : Icons.search_rounded,
            color: ProfessionalTheme.textSecondary,
            size: 22,
          ),
          onPressed: _toggleSearch,
        ),
        if (_isSearchExpanded)
          Expanded(
            child: TextField(
              controller: _searchTextController,
              focusNode: _searchFocus,
              style: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'ابحث عن أفلام، مسلسلات...',
                hintStyle: ProfessionalTheme.bodyMedium(
                  color: ProfessionalTheme.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: ProfessionalTheme.space12,
                ),
              ),
              onSubmitted: widget.onSearch,
              onChanged: (value) {
                if (value.length > 2) {
                  widget.onSearch?.call(value);
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: ProfessionalTheme.textSecondary,
            size: 24,
          ),
          onPressed: widget.onNotificationsTap,
        ),
        if (widget.hasNotifications)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: ProfessionalTheme.accentRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ProfessionalTheme.accentRed.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _showProfileDropdown = true),
      onExit: (_) => setState(() => _showProfileDropdown = false),
      child: GestureDetector(
        onTap: widget.onProfileTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ProfessionalTheme.premiumGradient,
                border: Border.all(
                  color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: widget.userAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        widget.userAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                      ),
                    )
                  : _buildDefaultAvatar(),
            ),
            if (_showProfileDropdown)
              Positioned(
                top: 50,
                right: -20,
                child: _ProfileDropdown(
                  userName: widget.userName,
                  onProfileTap: widget.onProfileTap,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        widget.userName?.substring(0, 1).toUpperCase() ?? 'U',
        style: ProfessionalTheme.titleMedium(
          color: ProfessionalTheme.textPrimary,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

class NavCategory {
  final String label;
  final String id;
  final IconData icon;
  final bool isLive;

  NavCategory(this.label, this.id, this.icon, {this.isLive = false});
}

class _NavCategoryButton extends StatefulWidget {
  final NavCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavCategoryButton({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavCategoryButton> createState() => _NavCategoryButtonState();
}

class _NavCategoryButtonState extends State<_NavCategoryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: ProfessionalTheme.durationFast,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: ProfessionalTheme.durationFast,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(
            horizontal: ProfessionalTheme.space16,
            vertical: ProfessionalTheme.space8,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? ProfessionalTheme.primaryBrand.withValues(alpha: 0.1)
                : (_isHovering
                    ? ProfessionalTheme.surfaceCard.withValues(alpha: 0.5)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
            border: Border.all(
              color: widget.isSelected
                  ? ProfessionalTheme.primaryBrand.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.category.icon,
                size: 20,
                color: widget.isSelected
                    ? ProfessionalTheme.primaryBrand
                    : (_isHovering
                        ? ProfessionalTheme.textPrimary
                        : ProfessionalTheme.textSecondary),
              ),
              const SizedBox(width: ProfessionalTheme.space8),
              Text(
                widget.category.label,
                style: ProfessionalTheme.labelLarge(
                  color: widget.isSelected
                      ? ProfessionalTheme.primaryBrand
                      : (_isHovering
                          ? ProfessionalTheme.textPrimary
                          : ProfessionalTheme.textSecondary),
                  weight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (widget.category.isLive) ...[
                const SizedBox(width: ProfessionalTheme.space8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: ProfessionalTheme.accentRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ProfessionalTheme.accentRed.withValues(alpha: 0.8),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  final String? userName;
  final VoidCallback? onProfileTap;

  const _ProfileDropdown({
    this.userName,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: ProfessionalTheme.surfaceCard,
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User info
              Container(
                padding: const EdgeInsets.all(ProfessionalTheme.space16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ProfessionalTheme.textTertiary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: ProfessionalTheme.premiumGradient,
                      ),
                      child: Center(
                        child: Text(
                          userName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: ProfessionalTheme.titleLarge(
                            color: ProfessionalTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ProfessionalTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName ?? 'المستخدم',
                            style: ProfessionalTheme.titleSmall(
                              color: ProfessionalTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: ProfessionalTheme.premiumGradient,
                              borderRadius: BorderRadius.circular(
                                ProfessionalTheme.radiusS,
                              ),
                            ),
                            child: Text(
                              'PREMIUM',
                              style: ProfessionalTheme.labelSmall(
                                color: ProfessionalTheme.textPrimary,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu items
              _DropdownMenuItem(
                icon: Icons.account_circle_outlined,
                label: 'الملف الشخصي',
                onTap: onProfileTap,
              ),
              _DropdownMenuItem(
                icon: Icons.bookmark_outline,
                label: 'قائمتي',
                onTap: () {},
              ),
              _DropdownMenuItem(
                icon: Icons.settings_outlined,
                label: 'الإعدادات',
                onTap: () {},
              ),
              _DropdownMenuItem(
                icon: Icons.help_outline,
                label: 'المساعدة',
                onTap: () {},
              ),
              Container(
                height: 1,
                color: ProfessionalTheme.textTertiary.withValues(alpha: 0.1),
              ),
              _DropdownMenuItem(
                icon: Icons.logout_rounded,
                label: 'تسجيل الخروج',
                onTap: () {},
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _DropdownMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ProfessionalTheme.space16,
            vertical: ProfessionalTheme.space12,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDestructive
                    ? ProfessionalTheme.errorColor
                    : ProfessionalTheme.textSecondary,
              ),
              const SizedBox(width: ProfessionalTheme.space12),
              Text(
                label,
                style: ProfessionalTheme.bodyMedium(
                  color: isDestructive
                      ? ProfessionalTheme.errorColor
                      : ProfessionalTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
