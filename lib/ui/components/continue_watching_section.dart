import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/professional_theme.dart';

class ContinueWatchingSection extends StatefulWidget {
  final List<ContinueWatchingItem> items;
  final Function(ContinueWatchingItem)? onItemTap;
  final Function(ContinueWatchingItem)? onRemove;
  final VoidCallback? onSeeAll;

  const ContinueWatchingSection({
    super.key,
    required this.items,
    this.onItemTap,
    this.onRemove,
    this.onSeeAll,
  });

  @override
  State<ContinueWatchingSection> createState() =>
      _ContinueWatchingSectionState();
}

class _ContinueWatchingSectionState extends State<ContinueWatchingSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scrollController = ScrollController();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? ProfessionalTheme.space64 : ProfessionalTheme.space24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ProfessionalTheme.accentRed,
                            ProfessionalTheme.accentRed.withValues(alpha: 0.3),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: ProfessionalTheme.space12),
                    Text(
                      'متابعة المشاهدة',
                      style: ProfessionalTheme.headlineMedium(
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (widget.onSeeAll != null)
                  TextButton.icon(
                    onPressed: widget.onSeeAll,
                    icon: Text(
                      'عرض الكل',
                      style: ProfessionalTheme.labelLarge(
                        color: ProfessionalTheme.textSecondary,
                      ),
                    ),
                    label: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: ProfessionalTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: ProfessionalTheme.space20),

          // Content
          SizedBox(
            height: 280,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? ProfessionalTheme.space64 : ProfessionalTheme.space24,
              ),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: ProfessionalTheme.space16,
                          ),
                          child: ContinueWatchingCard(
                            item: widget.items[index],
                            onTap: () => widget.onItemTap?.call(widget.items[index]),
                            onRemove: () => widget.onRemove?.call(widget.items[index]),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ContinueWatchingCard extends StatefulWidget {
  final ContinueWatchingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const ContinueWatchingCard({
    super.key,
    required this.item,
    this.onTap,
    this.onRemove,
  });

  @override
  State<ContinueWatchingCard> createState() => _ContinueWatchingCardState();
}

class _ContinueWatchingCardState extends State<ContinueWatchingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovering = false;
  bool _showOptions = false;

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
        setState(() {
          _isHovering = false;
          _showOptions = false;
        });
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () => setState(() => _showOptions = true),
        child: AnimatedScale(
          scale: _isHovering ? 1.02 : 1.0,
          duration: ProfessionalTheme.durationFast,
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              color: ProfessionalTheme.surfaceCard,
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
              boxShadow: _isHovering
                  ? [
                      BoxShadow(
                        color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with progress
                _buildThumbnail(),

                // Content
                Padding(
                  padding: const EdgeInsets.all(ProfessionalTheme.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and episode
                      Text(
                        widget.item.title,
                        style: ProfessionalTheme.titleMedium(
                          weight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.item.episodeInfo != null) ...[
                        const SizedBox(height: ProfessionalTheme.space4),
                        Text(
                          widget.item.episodeInfo!,
                          style: ProfessionalTheme.bodySmall(
                            color: ProfessionalTheme.textSecondary,
                          ),
                        ),
                      ],

                      const SizedBox(height: ProfessionalTheme.space8),

                      // Time remaining
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: ProfessionalTheme.textTertiary,
                          ),
                          const SizedBox(width: ProfessionalTheme.space4),
                          Text(
                            '${widget.item.remainingMinutes} دقيقة متبقية',
                            style: ProfessionalTheme.labelSmall(
                              color: ProfessionalTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        // Thumbnail image
        Container(
          height: 180,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ProfessionalTheme.radiusL),
            ),
            color: ProfessionalTheme.surfaceHover,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(ProfessionalTheme.radiusL),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.item.thumbnail != null)
                  CachedNetworkImage(
                    imageUrl: widget.item.thumbnail!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: ProfessionalTheme.surfaceHover,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: ProfessionalTheme.surfaceHover,
                      child: const Icon(
                        Icons.movie_outlined,
                        size: 48,
                        color: ProfessionalTheme.textTertiary,
                      ),
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
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ],
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
              color: ProfessionalTheme.surfaceActive.withValues(alpha: 0.3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widget.item.progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: ProfessionalTheme.premiumGradient,
                  boxShadow: [
                    BoxShadow(
                      color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Play button overlay
        if (_isHovering)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _isHovering ? 1.0 : 0.0,
              duration: ProfessionalTheme.durationFast,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(ProfessionalTheme.radiusL),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: ProfessionalTheme.premiumGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.5),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Options button
        if (_showOptions || _isHovering)
          Positioned(
            top: ProfessionalTheme.space8,
            right: ProfessionalTheme.space8,
            child: AnimatedOpacity(
              opacity: _showOptions || _isHovering ? 1.0 : 0.0,
              duration: ProfessionalTheme.durationFast,
              child: Container(
                decoration: BoxDecoration(
                  color: ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: ProfessionalTheme.textPrimary,
                        size: 20,
                      ),
                      onPressed: widget.onRemove,
                      tooltip: 'إزالة من القائمة',
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Episode badge
        if (widget.item.episodeNumber != null)
          Positioned(
            top: ProfessionalTheme.space12,
            left: ProfessionalTheme.space12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ProfessionalTheme.space8,
                vertical: ProfessionalTheme.space4,
              ),
              decoration: BoxDecoration(
                color: ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(ProfessionalTheme.radiusS),
              ),
              child: Text(
                'الحلقة ${widget.item.episodeNumber}',
                style: ProfessionalTheme.labelSmall(
                  color: ProfessionalTheme.textPrimary,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ContinueWatchingItem {
  final String id;
  final String title;
  final String? thumbnail;
  final double progress;
  final int remainingMinutes;
  final String? episodeInfo;
  final int? episodeNumber;
  final int? seasonNumber;
  final DateTime lastWatched;

  ContinueWatchingItem({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.progress,
    required this.remainingMinutes,
    this.episodeInfo,
    this.episodeNumber,
    this.seasonNumber,
    required this.lastWatched,
  });
}