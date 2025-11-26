import 'package:flutter/material.dart';
import '../../core/theme/professional_theme.dart';
import 'premium_media_card.dart';

class MediaSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<MediaItem> items;
  final VoidCallback? onSeeAllPressed;
  final bool showSkeleton;
  final double cardWidth;
  final double cardAspectRatio;
  final bool autoScroll;
  final Color? accentColor;

  const MediaSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
    this.onSeeAllPressed,
    this.showSkeleton = false,
    this.cardWidth = 180,
    this.cardAspectRatio = 0.7,
    this.autoScroll = false,
    this.accentColor,
  });

  @override
  State<MediaSection> createState() => _MediaSectionState();
}

class _MediaSectionState extends State<MediaSection>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    if (widget.autoScroll) {
      _startAutoScroll();
    }

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          _scrollController.animateTo(
            _scrollOffset + widget.cardWidth + ProfessionalTheme.space16,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          if (_scrollOffset >= maxScroll) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDesktop),
          const SizedBox(height: ProfessionalTheme.space16),
          _buildContent(isDesktop, isTablet),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? ProfessionalTheme.space64 : ProfessionalTheme.space24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Accent bar
                    Container(
                      width: 4,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            widget.accentColor ?? ProfessionalTheme.primaryBrand,
                            (widget.accentColor ?? ProfessionalTheme.primaryBrand)
                                .withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: ProfessionalTheme.space12),
                    Text(
                      widget.title,
                      style: ProfessionalTheme.headlineMedium(
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: ProfessionalTheme.space8),
                  Text(
                    widget.subtitle!,
                    style: ProfessionalTheme.bodyLarge(
                      color: ProfessionalTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.onSeeAllPressed != null)
            _buildSeeAllButton(),
        ],
      ),
    );
  }

  Widget _buildSeeAllButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onSeeAllPressed,
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ProfessionalTheme.space16,
            vertical: ProfessionalTheme.space8,
          ),
          child: Row(
            children: [
              Text(
                'عرض الكل',
                style: ProfessionalTheme.labelLarge(
                  color: ProfessionalTheme.textSecondary,
                ),
              ),
              const SizedBox(width: ProfessionalTheme.space8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: ProfessionalTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDesktop, bool isTablet) {
    if (widget.showSkeleton) {
      return _buildSkeletonList(isDesktop);
    }

    if (widget.items.isEmpty) {
      return _buildEmptyState();
    }

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? ProfessionalTheme.space64 : ProfessionalTheme.space24,
          ),
          child: Row(
            children: [
              for (int i = 0; i < widget.items.length; i++) ...[
                TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (i * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: PremiumMediaCard(
                    imageUrl: widget.items[i].imageUrl,
                    title: widget.items[i].title,
                    subtitle: widget.items[i].subtitle,
                    rating: widget.items[i].rating,
                    year: widget.items[i].year,
                    duration: widget.items[i].duration,
                    isPremium: widget.items[i].isPremium,
                    isNew: widget.items[i].isNew,
                    isLive: widget.items[i].isLive,
                    categories: widget.items[i].categories,
                    width: widget.cardWidth,
                    aspectRatio: widget.cardAspectRatio,
                    onTap: widget.items[i].onTap,
                  ),
                ),
                if (i < widget.items.length - 1)
                  const SizedBox(width: ProfessionalTheme.space16),
              ],
            ],
          ),
        ),

        // Gradient fade edges
        if (isDesktop) ...[
          // Left fade
          if (_scrollOffset > 0)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        ProfessionalTheme.backgroundPrimary,
                        ProfessionalTheme.backgroundPrimary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Right fade
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      ProfessionalTheme.backgroundPrimary,
                      ProfessionalTheme.backgroundPrimary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSkeletonList(bool isDesktop) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? ProfessionalTheme.space64 : ProfessionalTheme.space24,
      ),
      child: Row(
        children: List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(right: ProfessionalTheme.space16),
            child: PremiumMediaCardSkeleton(
              width: widget.cardWidth,
              aspectRatio: widget.cardAspectRatio,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: ProfessionalTheme.space24),
      decoration: BoxDecoration(
        color: ProfessionalTheme.surfaceCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
        border: Border.all(
          color: ProfessionalTheme.textTertiary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_filter_outlined,
              size: 48,
              color: ProfessionalTheme.textTertiary,
            ),
            const SizedBox(height: ProfessionalTheme.space16),
            Text(
              'لا يوجد محتوى متاح',
              style: ProfessionalTheme.bodyLarge(
                color: ProfessionalTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaItem {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final double? rating;
  final String? year;
  final String? duration;
  final bool isPremium;
  final bool isNew;
  final bool isLive;
  final List<String>? categories;
  final VoidCallback? onTap;

  MediaItem({
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.rating,
    this.year,
    this.duration,
    this.isPremium = false,
    this.isNew = false,
    this.isLive = false,
    this.categories,
    this.onTap,
  });
}