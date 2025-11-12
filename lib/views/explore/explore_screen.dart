import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../widgets/content_card.dart';
import '../../views/home/enhanced_home_screen.dart';
import '../../core/theme/professional_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _searchController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _searchAnimation;

  final TextEditingController _searchTextController = TextEditingController();

  // Theme colors
  static const Color primaryColor = Color(0xFFA20136);
  static const Color secondaryColor = Color(0xFF6B0024);
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF1A1A1A);

  final List<String> _categories = [
    'الكل',
    'أفلام',
    'مسلسلات',
    'وثائقيات',
    'أنمي',
    'أطفال',
    'رياضة',
  ];

  final List<String> _genres = [
    'أكشن',
    'مغامرة',
    'كوميدي',
    'دراما',
    'رعب',
    'رومانسي',
    'خيال علمي',
    'إثارة',
  ];

  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  List<dynamic> _categoryContent = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _searchController = AnimationController(
      duration: const Duration(seconds: 2),
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
    _searchAnimation = CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
    _scaleController.forward();
    _searchController.repeat(reverse: true);

    _loadCategoryContent(0);
  }

  void _loadCategoryContent(int index) {
    // Load content based on category
    setState(() {
      _categoryContent = []; // Load from API
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // Modern header with search
                  _buildSliverAppBar(context),

                  // Search suggestions
                  if (_isSearching) ...[
                    _buildSearchSuggestions(),
                  ] else ...[
                    // Category tabs
                    _buildCategoryTabs(),

                    // Content sections
                    _buildContentSections(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _searchController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor,
                surfaceColor.withValues(alpha: 0.3),
                backgroundColor,
                primaryColor.withValues(alpha: 0.05),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: SearchPainter(_searchAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: backgroundColor.withValues(alpha: 0.9),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '\u0627\u0633\u062a\u0643\u0634\u0627\u0641',
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
                primaryColor.withValues(alpha: 0.8),
                secondaryColor.withValues(alpha: 0.6),
                backgroundColor.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
            child: Column(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedBuilder(
                    animation: _searchController,
                    builder: (context, child) {
                      return Container(
                        width: 60 + _searchAnimation.value * 8,
                        height: 60 + _searchAnimation.value * 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(
                                  alpha: _searchAnimation.value * 0.4),
                              blurRadius: 20,
                              spreadRadius: _searchAnimation.value * 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildModernSearchBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: _searchTextController,
            style: ProfessionalTheme.getTextStyle(
              context: context,
              fontSize: 16,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText:
                  '\u0628\u062d\u062b \u0639\u0646 \u0627\u0644\u0623\u0641\u0644\u0627\u0645 \u0648\u0627\u0644\u0645\u0633\u0644\u0633\u0644\u0627\u062a...',
              hintStyle: ProfessionalTheme.getTextStyle(
                context: context,
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.search,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              suffixIcon: _isSearching
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _isSearching = false;
                              _searchTextController.clear();
                              _searchResults.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _isSearching = true;
                });
                _performSearch(value);
              } else {
                setState(() {
                  _isSearching = false;
                  _searchResults.clear();
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.red,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: _categories.map((category) => Tab(text: category)).toList(),
        onTap: _loadCategoryContent,
      ),
    );
  }

  Widget _buildCategoryContent() {
    return TabBarView(
      controller: _tabController,
      children: _categories.map((category) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Genre filters
              _buildGenreFilters(),

              // Featured section
              _buildFeaturedSection(),

              // Content grid
              _buildContentGrid(),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenreFilters() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _genres.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_genres[index]),
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.grey.shade900,
              selectedColor: Colors.red,
              onSelected: (selected) {
                // Handle genre filter
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.red.shade900, Colors.orange.shade900],
        ),
      ),
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: 'https://example.com/featured.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Content
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Featured Collection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Handpicked content just for you',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return ContentCard(
          title: 'Content ${index + 1}',
          imageUrl: 'https://example.com/poster.jpg',
          rating: '8.5',
          isPremium: index % 3 == 0,
          cardType: ContentCardType.poster,
          onTap: () {
            // Navigate to details
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade700),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return ContentCard(
          title: item['title'] ?? '',
          imageUrl: item['thumbnail'] ?? '',
          rating: item['rating']?.toString(),
          cardType: ContentCardType.poster,
          onTap: () {
            // Navigate to details
          },
        );
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: _searchResults.isEmpty
            ? _buildNoSearchResults()
            : _buildSearchResultsGrid(),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: surfaceColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _searchController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + _searchAnimation.value * 0.1,
                  child: Icon(
                    Icons.search_off,
                    size: 64,
                    color: primaryColor.withValues(alpha: 0.7),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: ProfessionalTheme.getTextStyle(
                context: context,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمات مختلفة',
              style: ProfessionalTheme.getTextStyle(
                context: context,
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: _scaleController,
              curve: Interval(
                index * 0.1,
                1.0,
                curve: Curves.elasticOut,
              ),
            ),
          ),
          child: ContentCard(
            title: item['title'] ?? '',
            imageUrl: item['thumbnail'] ?? '',
            rating: item['rating']?.toString(),
            cardType: ContentCardType.poster,
            onTap: () {
              // Navigate to details
            },
          ),
        );
      },
    );
  }

  Widget _buildContentSections() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildFeaturedSection(),
            const SizedBox(height: 24),
            _buildGenreFilters(),
            const SizedBox(height: 24),
            _buildContentGrid(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    // Implement search API call
    setState(() {
      _searchResults = []; // Update with search results
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchTextController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class SearchPainter extends CustomPainter {
  final double animationValue;

  SearchPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA20136).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Draw animated search indicators
    for (int i = 0; i < 18; i++) {
      final x = (size.width * (i * 0.12 + 0.08)) +
          math.sin(animationValue * math.pi * 2 + i * 0.7) * 35;
      final y = (size.height * (i * 0.08 + 0.12)) +
          math.cos(animationValue * math.pi * 2 + i * 0.5) * 30;

      // Main search dot
      canvas.drawCircle(
        Offset(x, y),
        2.5 + math.sin(animationValue * math.pi * 3 + i) * 1.2,
        paint,
      );

      // Search lens effect
      if (i % 5 == 0) {
        final lensPaint = Paint()
          ..color = const Color(0xFFA20136).withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        final lensRadius = 12 + math.sin(animationValue * math.pi * 2 + i) * 3;
        canvas.drawCircle(Offset(x, y), lensRadius, lensPaint);

        // Search handle
        final handlePaint = Paint()
          ..color = const Color(0xFFA20136).withValues(alpha: 0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

        final angle = animationValue * math.pi * 2 + i;
        final handleStart = Offset(
          x + lensRadius * math.cos(angle),
          y + lensRadius * math.sin(angle),
        );
        final handleEnd = Offset(
          x + (lensRadius + 8) * math.cos(angle),
          y + (lensRadius + 8) * math.sin(angle),
        );

        canvas.drawLine(handleStart, handleEnd, handlePaint);
      }
    }

    // Draw search waves
    final wavePaint = Paint()
      ..color = const Color(0xFFA20136).withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int wave = 0; wave < 4; wave++) {
      final path = Path();
      for (double x = 0; x < size.width; x += 4) {
        final y = size.height * (0.2 + wave * 0.2) +
            math.sin((x / 40) + animationValue * math.pi * 3 + wave * 1.5) * 25;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
