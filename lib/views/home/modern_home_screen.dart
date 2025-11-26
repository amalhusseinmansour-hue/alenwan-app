import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../core/theme/modern_theme.dart';
import '../../widgets/app_navigation_wrapper.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with TickerProviderStateMixin {
  // Controllers
  final ScrollController _scrollController = ScrollController();
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _particleController;
  late AnimationController _logoAnimationController;
  late AnimationController _backgroundController;

  // Animations
  // ignore: unused_field
  late Animation<double> _fadeAnimation;
  // ignore: unused_field
  late Animation<double> _slideAnimation;
  // ignore: unused_field
  late Animation<double> _scaleAnimation;
  // ignore: unused_field
  late Animation<double> _logoRotation;
  // ignore: unused_field
  late Animation<double> _logoPulse;

  // State
  double _scrollOffset = 0.0;
  int _currentBannerIndex = 0;
  bool _isLoading = true;
  // ignore: unused_field
  bool _showAppBarBackground = false;

  // Content Lists
  List<dynamic> _featuredContent = [];
  List<dynamic> _continueWatching = [];
  List<dynamic> _trending = [];
  List<dynamic> _newReleases = [];
  List<dynamic> _forYou = [];
  Map<String, List<dynamic>> _categorizedContent = {};

  // Colors
  final Color primaryColor = const Color(0xFFA20136);
  final Color secondaryColor = const Color(0xFF6B0024);
  final Color backgroundColor = const Color(0xFF0A0A0A);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _initializeAnimations();
    _loadContent();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _logoRotation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));
    _logoPulse = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
        _showAppBarBackground = _scrollOffset > 100;
      });
    });
  }

  Future<void> _loadContent() async {
    try {
      setState(() => _isLoading = true);

      // Simulate API calls with delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock data for demonstration
      setState(() {
        _featuredContent = List.generate(
            5,
            (i) => {
                  'id': i,
                  'title': 'Featured Movie ${i + 1}',
                  'thumbnail': 'assets/images/logo-alenwan.jpeg',
                  'type': i % 2 == 0 ? 'movie' : 'series',
                  'rating': (4.0 + (i * 0.2)).toString(),
                  'year': (2020 + i).toString(),
                });

        _continueWatching = List.generate(
            3,
            (i) => {
                  'id': i,
                  'title': 'Continue Watching ${i + 1}',
                  'thumbnail': 'assets/images/logo-alenwan.jpeg',
                  'progress': 0.3 + (i * 0.2),
                  'duration': '${45 + i * 5} min',
                });

        _trending = List.generate(
            8,
            (i) => {
                  'id': i,
                  'title': 'Trending ${i + 1}',
                  'thumbnail': 'assets/images/logo-alenwan.jpeg',
                  'type': 'movie',
                  'views': '${(i + 1) * 1000}',
                });

        _newReleases = List.generate(
            6,
            (i) => {
                  'id': i,
                  'title': 'New Release ${i + 1}',
                  'thumbnail': 'assets/images/logo-alenwan.jpeg',
                  'type': 'series',
                  'episodes': i + 8,
                });

        _forYou = List.generate(
            10,
            (i) => {
                  'id': i,
                  'title': 'For You ${i + 1}',
                  'thumbnail': 'assets/images/logo-alenwan.jpeg',
                  'type': i % 3 == 0 ? 'movie' : 'series',
                });

        _categorizedContent = {
          'action'.tr():
              List.generate(5, (i) => {'id': i, 'title': 'Action ${i + 1}'}),
          'drama'.tr():
              List.generate(5, (i) => {'id': i, 'title': 'Drama ${i + 1}'}),
          'comedy'.tr():
              List.generate(5, (i) => {'id': i, 'title': 'Comedy ${i + 1}'}),
        };

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading content: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _particleController.dispose();
    _logoAnimationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppNavigationWrapper(
      showBottomNav: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        extendBodyBehindAppBar: false,
        body: Stack(
          children: [
            // Animated background
            _buildAnimatedBackground(),

            // Particle effect
            _buildParticleEffect(),

            // Main content
            _buildMainContent(),

            // Floating action buttons
            _buildFloatingActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.cos(_backgroundController.value * 2 * math.pi) * 0.5,
                math.sin(_backgroundController.value * 2 * math.pi) * 0.5,
              ),
              radius: 2,
              colors: [
                primaryColor.withValues(alpha: 0.05),
                backgroundColor,
                Colors.black,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleEffect() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: ParticlePainter(
            animation: _particleController.value,
            color: primaryColor.withValues(alpha: 0.1),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Hero Banner
        SliverToBoxAdapter(
          child: _buildHeroBanner(),
        ),

        // Continue Watching
        if (_continueWatching.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'Continue Watching',
              items: _continueWatching,
              builder: (item) => _buildContinueWatchingCard(item),
            ),
          ),

        // Trending Now
        SliverToBoxAdapter(
          child: _buildSection(
            title: 'Trending Now',
            icon: Icons.local_fire_department,
            items: _trending,
            builder: (item) => _buildContentCard(item, showRank: true),
          ),
        ),

        // New Releases
        SliverToBoxAdapter(
          child: _buildSection(
            title: 'New Releases',
            icon: Icons.new_releases,
            items: _newReleases,
            builder: (item) => _buildContentCard(item, isNew: true),
          ),
        ),

        // Categories
        ..._categorizedContent.entries.map((entry) => SliverToBoxAdapter(
              child: _buildSection(
                title: entry.key,
                items: entry.value,
                builder: (item) => _buildContentCard(item),
              ),
            )),

        // For You
        SliverToBoxAdapter(
          child: _buildSection(
            title: 'For You',
            icon: Icons.star,
            items: _forYou,
            builder: (item) => _buildContentCard(item),
          ),
        ),

        // Bottom padding
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildHeroBanner() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Stack(
        children: [
          // Carousel
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
            ),
            items: _featuredContent.map((item) {
              return _buildHeroSlide(item);
            }).toList(),
          ),

          // Gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    backgroundColor.withValues(alpha: 0.9),
                    backgroundColor,
                  ],
                ),
              ),
            ),
          ),

          // Content info
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  _featuredContent.isNotEmpty
                      ? _featuredContent[_currentBannerIndex]['title']
                      : '',
                  style: ModernTheme.getTextStyle(
                    context: context,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Metadata
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _featuredContent.isNotEmpty
                            ? _featuredContent[_currentBannerIndex]['type']
                                    ?.toUpperCase() ??
                                ''
                            : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _featuredContent.isNotEmpty
                          ? _featuredContent[_currentBannerIndex]['rating'] ??
                              ''
                          : '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _featuredContent.isNotEmpty
                          ? _featuredContent[_currentBannerIndex]['year'] ?? ''
                          : '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    _buildHeroButton(
                      icon: Icons.play_arrow,
                      label: 'Play',
                      primary: true,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 12),
                    _buildHeroButton(
                      icon: Icons.add,
                      label: 'My List',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 12),
                    _buildHeroButton(
                      icon: Icons.info_outline,
                      label: 'Info',
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Page indicators
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: List.generate(_featuredContent.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _currentBannerIndex ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: index == _currentBannerIndex
                        ? primaryColor
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSlide(Map<String, dynamic> item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withValues(alpha: 0.3), backgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Image.asset(
            'assets/images/logo-alenwan.jpeg',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.5),
          ),
        ),

        // Blur effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            color: Colors.black.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroButton({
    required IconData icon,
    required String label,
    bool primary = false,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: primary
                ? LinearGradient(colors: [primaryColor, secondaryColor])
                : null,
            color: primary ? null : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: primary
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    IconData? icon,
    required List<dynamic> items,
    required Widget Function(dynamic) builder,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: primaryColor, size: 24),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        title,
                        style: ModernTheme.getTextStyle(
                          context: context,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'view_all'.tr(),
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content list
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: builder(items[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentCard(Map<String, dynamic> item,
      {bool showRank = false, bool isNew = false}) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/logo-alenwan.jpeg',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Badges
              if (isNew)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            item['title'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingCard(Map<String, dynamic> item) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with progress
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/logo-alenwan.jpeg',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Play button
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),

              // Progress bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: item['progress'] ?? 0.0,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            item['title'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Duration
          Text(
            item['duration'] ?? '',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated logo
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
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
          const SizedBox(height: 30),

          // Loading indicator
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'loading'.tr(),
            style: ModernTheme.getTextStyle(
              context: context,
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        children: [
          // Filter button
          _buildFloatingActionButton(
            icon: Icons.filter_list,
            onPressed: () {
              HapticFeedback.lightImpact();
              // Show filter options
            },
          ),
          const SizedBox(height: 12),

          // Download button
          _buildFloatingActionButton(
            icon: Icons.download,
            onPressed: () {
              HapticFeedback.lightImpact();
              // Navigate to downloads
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// Particle Painter for background effect
class ParticlePainter extends CustomPainter {
  final double animation;
  final Color color;

  ParticlePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final progress = (animation + i * 0.033) % 1.0;
      final opacity = math.sin(progress * math.pi) * 0.5;

      paint.color = color.withValues(alpha: opacity);

      final x = size.width * (0.1 + (i * 0.27) % 0.8);
      final y = size.height * progress;
      final radius = 2 + math.sin(progress * math.pi) * 3;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
