import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alenwan/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Services
import 'package:alenwan/core/services/api_client.dart';
import '../../core/theme/professional_theme.dart';

// Controllers
// import '../../controllers/platinum_controller.dart'; // ❌ REMOVED - Causing 500 error
import '../../controllers/recent_controller.dart';
import '../../controllers/live_controller.dart';
import '../../controllers/series_controller.dart';
import '../../controllers/sport_controller.dart';
import '../../controllers/documentary_controller.dart';
import '../../controllers/recommendation_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cartoon_controller.dart';

// Widgets
import 'shahid_style_banner.dart';

// Theme colors
const Color primaryColor = Color(0xFFA20136);
const Color secondaryColor = Color(0xFF6B0024);
const Color backgroundColor = Color(0xFF0A0A0A);
const Color surfaceColor = Color(0xFF1A1A1A);

/// Utilities
const String kPosterFallback = 'assets/images/placeholder_poster.png';

String normalizeImageUrl(String? path) {
  if (path == null || path.isEmpty) return kPosterFallback;
  var p = path.trim();
  if (p.startsWith('http')) {
    final filesBase = ApiClient().filesBaseUrl;
    final localhostRe = RegExp(r'^https?:\/\/(127\.0\.0\.1|localhost)(:\d+)?');
    if (localhostRe.hasMatch(p)) {
      final uri = Uri.parse(p);
      p = '$filesBase${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
    }
    return p.replaceAll(RegExp(r'-\d+x\d+(?=\.\w+$)'), '');
  }
  if (p.startsWith('/')) p = p.substring(1);
  if (!p.startsWith('storage/')) p = 'storage/$p';
  final base = ApiClient().filesBaseUrl;
  return '$base/$p';
}

class ContentItem {
  final int id;
  final String title;
  final String image;
  final String type;
  final String? badge;
  final String? subtitle;

  ContentItem({
    required this.id,
    required this.title,
    required this.image,
    required this.type,
    this.badge,
    this.subtitle,
  });
}

String translateType(String type) {
  switch (type) {
    case 'movie':
      return 'فيلم';
    case 'series':
      return 'مسلسل';
    case 'sport':
      return 'رياضة';
    case 'documentary':
      return 'وثائقي';
    case 'cartoon':
      return 'كرتون';
    default:
      return type;
  }
}

class HomeContentEnhanced extends StatefulWidget {
  const HomeContentEnhanced({super.key});

  @override
  State<HomeContentEnhanced> createState() => _HomeContentEnhancedState();
}

class _HomeContentEnhancedState extends State<HomeContentEnhanced>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scrollController = ScrollController();
    _fadeController.forward();
    _scaleController.forward();
    _shimmerController.repeat();

    // Load data sequentially with delays to prevent main thread blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Load most important content first
      // context.read<PlatinumController>().load(); // ❌ REMOVED - Causing 500 error

      // Stagger other loads to reduce initial burden
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) context.read<RecentController>().load();
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) context.read<LiveController>().loadStreams();
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) context.read<SeriesController>().loadSeries();
      });

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) context.read<SportController>().loadSports();
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.read<DocumentaryController>().loadDocumentaries();
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) context.read<CartoonController>().loadCartoons();
      });

      final authC = context.read<AuthController>();
      final userId = authC.user?['id'];
      if (userId != null) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) context.read<RecommendationController>().loadRecommendations(userId);
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Demo content removed - content loaded from backend only
  List<ContentItem> _getDemoContent() {
    return [];
  }

  void _openContent(BuildContext context, ContentItem item) {
    switch (item.type) {
      case 'movie':
        Navigator.pushNamed(context, AppRoutes.movieDetails,
            arguments: item.id);
        break;
      case 'series':
        Navigator.pushNamed(context, AppRoutes.seriesDetails,
            arguments: item.id);
        break;
      case 'sport':
        Navigator.pushNamed(context, AppRoutes.sportDetails,
            arguments: item.id);
        break;
      case 'documentary':
        Navigator.pushNamed(context, AppRoutes.documentaryDetails,
            arguments: item.id);
        break;
      case 'cartoon':
        Navigator.pushNamed(context, AppRoutes.cartoonDetails,
            arguments: item.id);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final platinumC = context.watch<PlatinumController>(); // ❌ REMOVED - Causing 500 error
    final recentC = context.watch<RecentController>();
    final seriesC = context.watch<SeriesController>();
    final sportC = context.watch<SportController>();
    final docC = context.watch<DocumentaryController>();
    final cartoonC = context.watch<CartoonController>();
    final recC = context.watch<RecommendationController>();

    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const ShahidStyleBanner(),

            // Gradient Background Container
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    backgroundColor,
                    surfaceColor.withValues(alpha: 0.5),
                    backgroundColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recommendations
                  if (!recC.isLoading && recC.recommendations.isNotEmpty)
                    ModernContentRow(
                      title: 'اخترنا لك خصيصاً',
                      icon: Icons.star,
                      items: recC.recommendations
                          .map((it) => ContentItem(
                                id: it['id'],
                                title: it['title'] ?? '',
                                image: normalizeImageUrl(
                                    it['poster'] ?? it['posterUrl'] ?? ''),
                                badge: translateType(it['type']),
                                type: it['type'] ?? 'movie',
                              ))
                          .toList(),
                      onTap: (item) => _openContent(context, item),
                      animationDelay: 0,
                    ),

                  // Platinum Content - ❌ REMOVED (Causing 500 error on server)
                  // ModernContentRow(
                  //   title: 'platinum_exclusives'.tr(),
                  //   icon: Icons.workspace_premium,
                  //   isPremium: true,
                  //   items: platinumC.platinumMovies.isNotEmpty
                  //       ? platinumC.platinumMovies
                  //           .map((m) => ContentItem(
                  //                 id: m.id,
                  //                 title: m.title,
                  //                 image: normalizeImageUrl(m.posterUrl),
                  //                 badge: 'vip'.tr().toUpperCase(),
                  //                 type: 'movie',
                  //               ))
                  //           .toList()
                  //       : _getDemoContent(),
                  //   onTap: (item) => _openContent(context, item),
                  //   animationDelay: 100,
                  // ),

                  // Recent Content
                  ModernContentRow(
                    title: 'جديد على المنصة',
                    icon: Icons.new_releases,
                    items: recentC.items.isNotEmpty
                        ? recentC.items
                            .map((it) => ContentItem(
                                  id: it.id,
                                  title: it.title,
                                  image:
                                      normalizeImageUrl(it.posterUrl ?? it.image),
                                  badge: translateType(it.type),
                                  type: it.type,
                                ))
                            .toList()
                        : _getDemoContent(),
                    onTap: (item) => _openContent(context, item),
                    animationDelay: 200,
                  ),

                  // Series
                  ModernContentRow(
                    title: 'أحدث المسلسلات المشوقة',
                    icon: Icons.tv,
                    items: seriesC.series.isNotEmpty
                        ? seriesC.series
                            .map((s) => ContentItem(
                                  id: s.id,
                                  title: s.titleAr ?? s.titleEn,
                                  image: normalizeImageUrl(s.thumbnail ?? ''),
                                  badge: translateType('series'),
                                  type: 'series',
                                ))
                            .toList()
                        : _getDemoContent(),
                    onTap: (item) => _openContent(context, item),
                    animationDelay: 300,
                  ),

                  // Cartoons
                  ModernContentRow(
                    title: 'أجمل أفلام الكرتون',
                    icon: Icons.child_care,
                    items: cartoonC.cartoons.isNotEmpty
                        ? cartoonC.cartoons
                            .map((c) => ContentItem(
                                  id: c.id,
                                  title: c.title,
                                  image: normalizeImageUrl(c.posterPath),
                                  badge: translateType('cartoon'),
                                  type: 'cartoon',
                                ))
                            .toList()
                        : _getDemoContent(),
                    onTap: (item) => _openContent(context, item),
                    animationDelay: 400,
                  ),

                  // Sports
                  ModernContentRow(
                    title: 'الأحداث الرياضية',
                    icon: Icons.sports_soccer,
                    items: sportC.sports.isNotEmpty
                        ? sportC.sports
                            .map((s) => ContentItem(
                                  id: s.id,
                                  title: s.title,
                                  image: normalizeImageUrl(s.posterUrl ?? ''),
                                  badge: translateType('sport'),
                                  type: 'sport',
                                ))
                            .toList()
                        : _getDemoContent(),
                    onTap: (item) => _openContent(context, item),
                    animationDelay: 500,
                  ),

                  // Documentaries
                  ModernContentRow(
                    title: 'وثائقيات مذهلة',
                    icon: Icons.explore,
                    items: docC.documentaries.isNotEmpty
                        ? docC.documentaries
                            .map((d) => ContentItem(
                                  id: d.id,
                                  title: d.title,
                                  image: normalizeImageUrl(d.posterPath),
                                  badge: translateType('documentary'),
                                  type: 'documentary',
                                ))
                            .toList()
                        : _getDemoContent(),
                    onTap: (item) => _openContent(context, item),
                    animationDelay: 600,
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Content Row Widget
class ModernContentRow extends StatefulWidget {
  final String title;
  final IconData? icon;
  final bool isPremium;
  final List<ContentItem> items;
  final Function(ContentItem)? onTap;
  final int animationDelay;

  const ModernContentRow({
    super.key,
    required this.title,
    required this.items,
    this.icon,
    this.isPremium = false,
    this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<ModernContentRow> createState() => _ModernContentRowState();
}

class _ModernContentRowState extends State<ModernContentRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800 + widget.animationDelay),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  // Animated Icon
                  if (widget.icon != null)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(seconds: 2),
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: widget.isPremium ? value * 2 * math.pi : 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.isPremium
                                    ? [
                                        const Color(0xFFFFD700),
                                        const Color(0xFFFFA500)
                                      ]
                                    : [primaryColor, secondaryColor],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.isPremium
                                      ? const Color(0xFFFFD700)
                                          .withValues(alpha: 0.4)
                                      : primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  if (widget.icon != null) const SizedBox(width: 12),

                  // Title with gradient
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: widget.isPremium
                            ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                            : [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.9)
                              ],
                      ).createShader(bounds),
                      child: Text(
                        widget.title,
                        style: ProfessionalTheme.getTextStyle(
                          context: context,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // View All Button
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'عرض الكل',
                          style: ProfessionalTheme.getTextStyle(
                            context: context,
                            fontSize: 14,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios,
                            size: 14, color: primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Cards
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ModernContentCard(
                      item: item,
                      onTap: () => widget.onTap?.call(item),
                      isPremium: widget.isPremium,
                      animationDelay: index * 50,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Content Card
class ModernContentCard extends StatefulWidget {
  final ContentItem item;
  final VoidCallback? onTap;
  final bool isPremium;
  final int animationDelay;

  const ModernContentCard({
    super.key,
    required this.item,
    this.onTap,
    this.isPremium = false,
    this.animationDelay = 0,
  });

  @override
  State<ModernContentCard> createState() => _ModernContentCardState();
}

class _ModernContentCardState extends State<ModernContentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + _hoverController.value * 0.05,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(
                        alpha: _isHovered ? 0.4 : 0.2,
                      ),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: Offset(0, _isHovered ? 8 : 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Image
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: widget.item.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [surfaceColor, backgroundColor],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: surfaceColor,
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),

                      // Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                backgroundColor.withValues(alpha: 0.8),
                                backgroundColor.withValues(alpha: 0.95),
                              ],
                              stops: const [0.0, 0.5, 0.8, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Premium Badge
                      if (widget.isPremium)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'VIP',
                                  style: ProfessionalTheme.getTextStyle(
                                    context: context,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Category Badge
                      if (widget.item.badge != null)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.item.badge!,
                              style: ProfessionalTheme.getTextStyle(
                                context: context,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Title and Actions
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: ProfessionalTheme.getTextStyle(
                                  context: context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Action Buttons
                              AnimatedOpacity(
                                opacity: _isHovered ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Row(
                                  children: [
                                    _buildActionButton(
                                      icon: Icons.play_circle_fill,
                                      onTap: widget.onTap,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildActionButton(
                                      icon: Icons.favorite_border,
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 8),
                                    _buildActionButton(
                                      icon: Icons.add,
                                      onTap: () {},
                                    ),
                                  ],
                                ),
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
        },
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
