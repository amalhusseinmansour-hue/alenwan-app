import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../core/theme/modern_theme.dart';

/// Modern details screen for movies, series, documentaries, etc.
class ModernDetailsScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final String? localImage;
  final String? videoUrl;
  final double? rating;
  final String? year;
  final String? duration;
  final List<String>? genres;
  final List<String>? cast;
  final String contentType;
  final Widget? customContent;
  final VoidCallback? onPlay;
  final VoidCallback? onAddToList;
  final VoidCallback? onShare;
  final List<dynamic>? relatedContent;
  final Widget Function(dynamic)? relatedItemBuilder;

  const ModernDetailsScreen({
    super.key,
    required this.title,
    required this.contentType,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.localImage,
    this.videoUrl,
    this.rating,
    this.year,
    this.duration,
    this.genres,
    this.cast,
    this.customContent,
    this.onPlay,
    this.onAddToList,
    this.onShare,
    this.relatedContent,
    this.relatedItemBuilder,
  });

  @override
  State<ModernDetailsScreen> createState() => _ModernDetailsScreenState();
}

class _ModernDetailsScreenState extends State<ModernDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _heroController;
  late ScrollController _scrollController;

  double _scrollOffset = 0;
  bool _showPlayButton = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupScrollListener();
    _setSystemUI();
  }

  void _initializeControllers() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: ModernTheme.animationSlow,
      vsync: this,
    )..forward();

    _heroController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scrollController = ScrollController();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
        _showPlayButton = _scrollOffset < 200;
      });
    });
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
    _contentController.dispose();
    _heroController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ModernTheme.backgroundColor,
      body: Stack(
        children: [
          // Animated background
          ModernTheme.animatedBackground(),

          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero section with parallax effect
              SliverToBoxAdapter(
                child: _buildHeroSection(screenSize),
              ),

              // Content details
              SliverToBoxAdapter(
                child: _buildContentDetails(),
              ),

              // Custom content if provided
              if (widget.customContent != null)
                SliverToBoxAdapter(
                  child: widget.customContent!,
                ),

              // Related content
              if (widget.relatedContent != null &&
                  widget.relatedContent!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildRelatedContent(),
                ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),

          // Floating app bar
          _buildFloatingAppBar(),

          // Floating play button
          if (_showPlayButton && widget.onPlay != null)
            _buildFloatingPlayButton(),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Size screenSize) {
    return SizedBox(
      height: screenSize.height * 0.7,
      child: Stack(
        children: [
          // Background image with parallax
          Transform.translate(
            offset: Offset(0, _scrollOffset * 0.5),
            child: Container(
              height: screenSize.height * 0.7,
              decoration: BoxDecoration(
                image: widget.localImage != null
                    ? DecorationImage(
                        image: AssetImage(widget.localImage!),
                        fit: BoxFit.cover,
                      )
                    : widget.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(widget.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                gradient: widget.localImage == null && widget.imageUrl == null
                    ? ModernTheme.primaryGradient
                    : null,
              ),
              child: widget.localImage == null && widget.imageUrl == null
                  ? Center(
                      child: Icon(
                        _getIconForContentType(),
                        size: 100,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    )
                  : null,
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  ModernTheme.backgroundColor.withValues(alpha: 0.7),
                  ModernTheme.backgroundColor,
                ],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Hero content
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: FadeTransition(
              opacity: _contentController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: ModernTheme.headline1(),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle!,
                      style: ModernTheme.subtitle1(
                        color: ModernTheme.textSecondary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Metadata row
                  _buildMetadataRow(),

                  const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        if (widget.rating != null)
          _buildMetadataChip(
            icon: Icons.star,
            text: widget.rating!.toStringAsFixed(1),
            color: Colors.amber,
          ),
        if (widget.year != null)
          _buildMetadataChip(
            icon: Icons.calendar_today,
            text: widget.year!,
          ),
        if (widget.duration != null)
          _buildMetadataChip(
            icon: Icons.access_time,
            text: widget.duration!,
          ),
        if (widget.genres != null && widget.genres!.isNotEmpty)
          ...widget.genres!.take(3).map(
                (genre) => _buildMetadataChip(
                  text: genre,
                  isPrimary: true,
                ),
              ),
      ],
    );
  }

  Widget _buildMetadataChip({
    IconData? icon,
    required String text,
    Color? color,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ModernTheme.spacingM,
        vertical: ModernTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        gradient: isPrimary ? ModernTheme.primaryGradient : null,
        color: isPrimary ? null : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
        border: Border.all(
          color: isPrimary
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: color ?? Colors.white,
            ),
            const SizedBox(width: ModernTheme.spacingXS),
          ],
          Text(
            text,
            style: ModernTheme.caption(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.onPlay != null)
          ModernTheme.gradientButton(
            label: 'شاهد الآن',
            icon: Icons.play_arrow,
            onPressed: widget.onPlay!,
            isPrimary: true,
          ),
        const SizedBox(width: ModernTheme.spacingM),
        if (widget.onAddToList != null)
          ModernTheme.gradientButton(
            label: 'قائمتي',
            icon: Icons.add,
            onPressed: widget.onAddToList!,
            isPrimary: false,
          ),
        const SizedBox(width: ModernTheme.spacingM),
        if (widget.onShare != null)
          _buildCircularButton(
            icon: Icons.share,
            onPressed: widget.onShare!,
          ),
      ],
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(ModernTheme.spacingM),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentDetails() {
    return Padding(
      padding: const EdgeInsets.all(ModernTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (widget.description != null) ...[
            Text(
              'القصة',
              style: ModernTheme.headline3(),
            ),
            const SizedBox(height: ModernTheme.spacingM),
            Text(
              widget.description!,
              style: ModernTheme.body1(color: ModernTheme.textSecondary),
            ),
            const SizedBox(height: ModernTheme.spacingXL),
          ],

          // Cast
          if (widget.cast != null && widget.cast!.isNotEmpty) ...[
            Text(
              'طاقم العمل',
              style: ModernTheme.headline3(),
            ),
            const SizedBox(height: ModernTheme.spacingM),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.cast!.length,
                itemBuilder: (context, index) {
                  return _buildCastCard(widget.cast![index]);
                },
              ),
            ),
            const SizedBox(height: ModernTheme.spacingXL),
          ],
        ],
      ),
    );
  }

  Widget _buildCastCard(String name) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: ModernTheme.spacingM),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: ModernTheme.primaryGradient,
              boxShadow: ModernTheme.primaryShadow,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: ModernTheme.spacingS),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ModernTheme.caption(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ModernTheme.spacingL),
          child: Text(
            'محتوى مشابه',
            style: ModernTheme.headline3(),
          ),
        ),
        const SizedBox(height: ModernTheme.spacingM),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: ModernTheme.spacingL),
            itemCount: widget.relatedContent!.length,
            itemBuilder: (context, index) {
              final item = widget.relatedContent![index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: ModernTheme.spacingM),
                child: widget.relatedItemBuilder != null
                    ? widget.relatedItemBuilder!(item)
                    : _buildDefaultRelatedCard(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultRelatedCard(dynamic item) {
    return InkWell(
      onTap: () {
        // Navigate to related content
      },
      child: Container(
        decoration: ModernTheme.modernCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(ModernTheme.radiusLarge),
                  ),
                  gradient: ModernTheme.primaryGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ModernTheme.spacingS),
              child: Text(
                item.toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ModernTheme.body2(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingAppBar() {
    final opacity = (_scrollOffset / 200).clamp(0.0, 1.0);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: ModernTheme.animationFast,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernTheme.backgroundColor.withValues(alpha: 0.9 * opacity),
              ModernTheme.backgroundColor.withValues(alpha: 0.7 * opacity),
              Colors.transparent,
            ],
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10 * opacity,
              sigmaY: 10 * opacity,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(ModernTheme.spacingM),
                child: Row(
                  children: [
                    _buildCircularButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    if (opacity > 0.5)
                      Expanded(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: ModernTheme.subtitle1(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const Spacer(),
                    _buildCircularButton(
                      icon: Icons.more_vert,
                      onPressed: () {
                        // Show more options
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingPlayButton() {
    return AnimatedPositioned(
      duration: ModernTheme.animationFast,
      bottom: _showPlayButton ? 30 : -100,
      right: 30,
      child: AnimatedBuilder(
        animation: _heroController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_heroController.value * 0.1),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ModernTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: ModernTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20 + (_heroController.value * 10),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPlay,
                  customBorder: const CircleBorder(),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForContentType() {
    switch (widget.contentType.toLowerCase()) {
      case 'movie':
      case 'movies':
        return Icons.movie;
      case 'series':
        return Icons.tv;
      case 'documentary':
      case 'documentaries':
        return Icons.article;
      case 'cartoon':
      case 'cartoons':
        return Icons.child_care;
      case 'sport':
      case 'sports':
        return Icons.sports_soccer;
      case 'live':
      case 'livestream':
        return Icons.live_tv;
      default:
        return Icons.play_circle_outline;
    }
  }
}
