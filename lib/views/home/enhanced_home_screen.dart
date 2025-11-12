import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui' as ui;
import 'dart:ui';
import '../../widgets/content_card.dart';
import '../../widgets/continue_watching_card.dart';
import '../../core/services/vimeo_service.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/professional_theme.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final VimeoService _vimeoService = VimeoService();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _showAppBarBackground = false;
  List<dynamic> _featuredContent = [];
  List<dynamic> _continueWatching = [];
  List<dynamic> _trending = [];
  List<dynamic> _newReleases = [];
  List<dynamic> _forYou = [];
  Map<String, List<dynamic>> _categorizedContent = {};

  bool _isLoading = true;
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadContent();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final showBackground = _scrollController.offset > 100;
      if (showBackground != _showAppBarBackground) {
        setState(() {
          _showAppBarBackground = showBackground;
        });
      }
    });
  }

  Future<void> _loadContent() async {
    try {
      setState(() => _isLoading = true);

      // Load all content in parallel
      final results = await Future.wait([
        ApiClient().dio.get('/api/content/featured'),
        _vimeoService.getContinueWatching(),
        ApiClient().dio.get('/api/content/trending'),
        ApiClient().dio.get('/api/content/new-releases'),
        ApiClient().dio.get('/api/content/recommendations'),
        ApiClient().dio.get('/api/content/by-categories'),
      ]);

      setState(() {
        _featuredContent = results[0].data['data'] ?? [];
        _continueWatching = results[1];
        _trending = results[2].data['data'] ?? [];
        _newReleases = results[3].data['data'] ?? [];
        _forYou = results[4].data['data'] ?? [];
        _categorizedContent =
            Map<String, List<dynamic>>.from(results[5].data['data'] ?? {});
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading content: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundPrimary,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _showAppBarBackground
          ? ProfessionalTheme.backgroundPrimary.withOpacity(0.95)
          : Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: ProfessionalTheme.textPrimary),
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo-alenwan.jpeg',
            height: 35,
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.search, size: 28, color: ProfessionalTheme.textPrimary),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, size: 28, color: ProfessionalTheme.textPrimary),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [ProfessionalTheme.primaryBrand, ProfessionalTheme.accentBrand],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.person, size: 20, color: ProfessionalTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadContent,
        backgroundColor: ProfessionalTheme.primaryBrand,
        color: ProfessionalTheme.textPrimary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Hero Banner
            SliverToBoxAdapter(
              child: _buildHeroBanner(),
            ),

            // Continue Watching
            if (_continueWatching.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildContinueWatchingSection(),
              ),

            // Trending Now
            SliverToBoxAdapter(
              child: _buildContentSection(
                title: 'Trending Now',
                icon: Icons.local_fire_department,
                items: _trending,
                cardType: ContentCardType.poster,
              ),
            ),

            // New Releases
            SliverToBoxAdapter(
              child: _buildContentSection(
                title: 'New Releases',
                icon: Icons.new_releases,
                items: _newReleases,
                cardType: ContentCardType.backdrop,
              ),
            ),

            // For You
            SliverToBoxAdapter(
              child: _buildContentSection(
                title: 'Recommended For You',
                icon: Icons.star,
                items: _forYou,
                cardType: ContentCardType.poster,
              ),
            ),

            // Categories
            ..._categorizedContent.entries.map(
              (entry) => SliverToBoxAdapter(
                child: _buildContentSection(
                  title: entry.key,
                  items: entry.value,
                  cardType: ContentCardType.poster,
                ),
              ),
            ),

            // Bottom padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    if (_featuredContent.isEmpty) {
      return const SizedBox(height: 500);
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Stack(
        children: [
          // Background carousel
          CarouselSlider(
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 6),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
            ),
            items: _featuredContent.map((item) {
              return _buildHeroBannerItem(item);
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
                    ProfessionalTheme.backgroundPrimary.withOpacity(0.7),
                    ProfessionalTheme.backgroundPrimary,
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
            child: _buildBannerInfo(_featuredContent[_currentBannerIndex]),
          ),

          // Page indicators
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: List.generate(
                _featuredContent.length,
                (index) => Container(
                  width: index == _currentBannerIndex ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: index == _currentBannerIndex
                        ? ProfessionalTheme.primaryBrand
                        : ProfessionalTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBannerItem(dynamic item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: item['poster'] ?? item['thumbnail'] ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade900,
            child: Center(
              child: CircularProgressIndicator(color: ProfessionalTheme.primaryBrand),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade900,
            child: Icon(Icons.error, color: ProfessionalTheme.primaryBrand),
          ),
        ),

        // Blur effect at edges
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  ProfessionalTheme.backgroundPrimary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerInfo(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags
        Row(
          children: [
            if (item['is_trending'] == true)
              _buildTag('TRENDING', ProfessionalTheme.accentBrand),
            if (item['is_featured'] == true) _buildTag('FEATURED', ProfessionalTheme.primaryBrand),
            if (item['imdb_rating'] != null)
              _buildTag('IMDb ${item['imdb_rating']}', ProfessionalTheme.warningColor),
          ],
        ),
        const SizedBox(height: 12),

        // Title
        Text(
          item['title'] ?? '',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ProfessionalTheme.textPrimary,
            shadows: [
              Shadow(
                color: ProfessionalTheme.backgroundPrimary.withOpacity(0.8),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          item['description'] ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: ProfessionalTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [ProfessionalTheme.primaryBrand, ProfessionalTheme.primaryBrand.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _playContent(item),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: ProfessionalTheme.textPrimary,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ProfessionalTheme.surfaceCard.withOpacity(0.3),
                border: Border.all(color: ProfessionalTheme.textSecondary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: OutlinedButton.icon(
                onPressed: () => _showContentDetails(item),
                icon: const Icon(Icons.info_outline),
                label: const Text('More Info'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ProfessionalTheme.textPrimary,
                  side: BorderSide.none,
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContinueWatchingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              Icon(Icons.history, color: ProfessionalTheme.primaryBrand, size: 24),
              const SizedBox(width: 8),
              Text(
                'Continue Watching',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ProfessionalTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: _continueWatching.length,
            itemBuilder: (context, index) {
              final item = _continueWatching[index];
              return ContinueWatchingCard(
                title: item.title,
                thumbnail: item.thumbnail ?? '',
                progress: item.percentage / 100,
                remainingTime: item.remainingTime,
                onTap: () => _resumeContent(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection({
    required String title,
    IconData? icon,
    required List<dynamic> items,
    ContentCardType cardType = ContentCardType.poster,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: ProfessionalTheme.primaryBrand, size: 24),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ProfessionalTheme.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _viewAllContent(title, items),
                child: Text(
                  'See All',
                  style: TextStyle(color: ProfessionalTheme.primaryBrand),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: cardType == ContentCardType.backdrop ? 180 : 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: items.length.clamp(0, 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return ContentCard(
                title: item['title'] ?? '',
                imageUrl: item['thumbnail'] ?? '',
                rating: item['imdb_rating']?.toString(),
                year: item['release_date']?.substring(0, 4),
                isPremium: item['is_premium'] ?? false,
                cardType: cardType,
                onTap: () => _showContentDetails(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: ProfessionalTheme.surfaceCard,
      highlightColor: ProfessionalTheme.surfaceCard.withOpacity(0.7),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner skeleton
            Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: ProfessionalTheme.surfaceCard,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ProfessionalTheme.surfaceCard,
                    ProfessionalTheme.surfaceCard.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Section skeletons
            ...List.generate(
                3,
                (index) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 20,
                            decoration: BoxDecoration(
                              color: ProfessionalTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: List.generate(
                                3,
                                (i) => Container(
                                      width: 120,
                                      height: 180,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: ProfessionalTheme.surfaceCard,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    )),
                          ),
                        ],
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  void _playContent(dynamic content) {
    Navigator.pushNamed(
      context,
      '/player',
      arguments: {
        'vimeoId': content['vimeo_id'],
        'contentId': content['id'],
        'title': content['title'],
      },
    );
  }

  void _resumeContent(ContinueWatching item) {
    Navigator.pushNamed(
      context,
      '/player',
      arguments: {
        'vimeoId': item.vimeoId,
        'contentId': item.contentId,
        'title': item.title,
        'startPosition': item.position,
      },
    );
  }

  void _showContentDetails(dynamic content) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: content,
    );
  }

  void _viewAllContent(String title, List<dynamic> items) {
    Navigator.pushNamed(
      context,
      '/content-list',
      arguments: {
        'title': title,
        'items': items,
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

enum ContentCardType {
  poster,
  backdrop,
  square,
}
