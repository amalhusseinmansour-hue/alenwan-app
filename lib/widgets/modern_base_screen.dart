import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/modern_theme.dart';
import '../widgets/app_navigation_wrapper.dart';

/// Base screen widget with modern theme styling
/// All content screens should extend this for consistent look and feel
class ModernBaseScreen extends StatefulWidget {
  final String title;
  final Widget body;
  final bool showBackButton;
  final bool showBottomNav;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? customAppBar;
  final bool extendBodyBehindAppBar;

  const ModernBaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = true,
    this.showBottomNav = true,
    this.actions,
    this.floatingActionButton,
    this.customAppBar,
    this.extendBodyBehindAppBar = false,
  });

  @override
  State<ModernBaseScreen> createState() => _ModernBaseScreenState();
}

class _ModernBaseScreenState extends State<ModernBaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setSystemUI();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: ModernTheme.animationSlow,
      vsync: this,
    )..forward();
  }

  void _setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: ModernTheme.backgroundColor,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      appBar: widget.customAppBar ?? _buildAppBar(),
      body: Stack(
        children: [
          // Animated background
          ModernTheme.animatedBackground(controller: _backgroundController),

          // Particle effect
          ModernTheme.particleOverlay(controller: _particleController),

          // Main content with fade animation
          FadeTransition(
            opacity: _fadeController,
            child: widget.body,
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );

    return widget.showBottomNav
        ? AppNavigationWrapper(
            showBottomNav: true,
            child: scaffold,
          )
        : scaffold;
  }

  PreferredSizeWidget? _buildAppBar() {
    return AppBar(
      backgroundColor: ModernTheme.backgroundColor.withOpacity(0.9),
      elevation: 0,
      title: Text(
        widget.title,
        style: ModernTheme.headline3(),
      ),
      centerTitle: true,
      leading: widget.showBackButton
          ? IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: ModernTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
                ),
                child:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: widget.actions ?? _buildDefaultActions(),
    );
  }

  List<Widget> _buildDefaultActions() {
    return [
      Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: ModernTheme.primaryGradient,
          borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
        ),
        child: IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Navigate to search
          },
        ),
      ),
    ];
  }
}

/// Modern content grid screen for movies, series, etc.
class ModernContentScreen extends StatefulWidget {
  final String title;
  final String contentType; // 'movies', 'series', 'documentaries', 'cartoons'
  final Future<List<dynamic>> Function() fetchContent;
  final Widget Function(dynamic item) buildCard;
  final Function(dynamic item)? onItemTap;

  const ModernContentScreen({
    super.key,
    required this.title,
    required this.contentType,
    required this.fetchContent,
    required this.buildCard,
    this.onItemTap,
  });

  @override
  State<ModernContentScreen> createState() => _ModernContentScreenState();
}

class _ModernContentScreenState extends State<ModernContentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<dynamic> _content = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  final List<String> _filters = [
    'all',
    'trending',
    'new',
    'popular',
    'recommended',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernTheme.animationNormal,
      vsync: this,
    );
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      setState(() => _isLoading = true);
      final content = await widget.fetchContent();
      setState(() {
        _content = content;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('Error loading content: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernBaseScreen(
      title: widget.title,
      body: Column(
        children: [
          const SizedBox(height: 80), // Space for app bar
          _buildFilterChips(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildContentGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(vertical: ModernTheme.spacingM),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ModernTheme.spacingL),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
              HapticFeedback.lightImpact();
            },
            child: Container(
              margin: EdgeInsets.only(right: ModernTheme.spacingM),
              padding: EdgeInsets.symmetric(
                horizontal: ModernTheme.spacingL,
                vertical: ModernTheme.spacingM,
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? ModernTheme.primaryGradient : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ModernTheme.radiusXLarge),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: isSelected ? ModernTheme.glowShadow : null,
              ),
              child: Center(
                child: Text(
                  filter.toUpperCase(),
                  style: ModernTheme.body1(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentGrid() {
    return RefreshIndicator(
      color: ModernTheme.primaryColor,
      backgroundColor: ModernTheme.surfaceColor,
      onRefresh: _loadContent,
      child: GridView.builder(
        padding: EdgeInsets.all(ModernTheme.spacingL),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _content.length,
        itemBuilder: (context, index) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.1,
                1.0,
                curve: Curves.easeOutCubic,
              ),
            )),
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  index * 0.1,
                  1.0,
                  curve: Curves.easeOut,
                ),
              )),
              child: GestureDetector(
                onTap: () {
                  if (widget.onItemTap != null) {
                    widget.onItemTap!(_content[index]);
                  }
                },
                child: widget.buildCard(_content[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: ModernTheme.animationSlow,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: ModernTheme.primaryGradient,
                    boxShadow: ModernTheme.glowShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo-alenwan.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: ModernTheme.spacingXL),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor:
                  AlwaysStoppedAnimation<Color>(ModernTheme.primaryColor),
            ),
          ),
          SizedBox(height: ModernTheme.spacingL),
          Text(
            'Loading ${widget.contentType}...',
            style: ModernTheme.subtitle2(),
          ),
        ],
      ),
    );
  }
}

/// Modern content card widget
class ModernContentCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? localImage;
  final double? rating;
  final String? badge;
  final bool isNew;
  final VoidCallback? onTap;

  const ModernContentCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.localImage,
    this.rating,
    this.badge,
    this.isNew = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernTheme.modernCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(ModernTheme.radiusLarge),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ModernTheme.primaryGradient,
                    ),
                    child: localImage != null
                        ? Image.asset(
                            localImage!,
                            fit: BoxFit.cover,
                          )
                        : imageUrl != null
                            ? Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder();
                                },
                              )
                            : _buildPlaceholder(),
                  ),
                ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(ModernTheme.radiusLarge),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),

                // Badges
                if (isNew || badge != null)
                  Positioned(
                    top: ModernTheme.spacingS,
                    left: ModernTheme.spacingS,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ModernTheme.spacingS,
                        vertical: ModernTheme.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        gradient: ModernTheme.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(ModernTheme.radiusSmall),
                      ),
                      child: Text(
                        badge ?? 'NEW',
                        style: ModernTheme.caption(color: Colors.white),
                      ),
                    ),
                  ),

                // Rating
                if (rating != null)
                  Positioned(
                    top: ModernTheme.spacingS,
                    right: ModernTheme.spacingS,
                    child: Container(
                      padding: EdgeInsets.all(ModernTheme.spacingXS),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius:
                            BorderRadius.circular(ModernTheme.radiusSmall),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          SizedBox(width: ModernTheme.spacingXS),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: ModernTheme.caption(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Play icon
                Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: EdgeInsets.all(ModernTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ModernTheme.subtitle2(color: Colors.white),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: ModernTheme.spacingXS),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ModernTheme.caption(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: ModernTheme.primaryGradient,
      ),
      child: const Icon(
        Icons.movie,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}
