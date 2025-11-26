import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/professional_theme.dart';

class PremiumMediaCard extends StatefulWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final double? rating;
  final String? year;
  final String? duration;
  final bool isPremium;
  final bool isNew;
  final bool isLive;
  final VoidCallback? onTap;
  final double width;
  final double aspectRatio;
  final List<String>? categories;
  final Widget? badge;

  const PremiumMediaCard({
    super.key,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.rating,
    this.year,
    this.duration,
    this.isPremium = false,
    this.isNew = false,
    this.isLive = false,
    this.onTap,
    this.width = 200,
    this.aspectRatio = 0.7,
    this.categories,
    this.badge,
  });

  @override
  State<PremiumMediaCard> createState() => _PremiumMediaCardState();
}

class _PremiumMediaCardState extends State<PremiumMediaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _overlayAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ProfessionalTheme.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.width / widget.aspectRatio;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
                  boxShadow: _isHovering
                      ? [
                          BoxShadow(
                            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                          const BoxShadow(
                            color: Colors.black87,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ]
                      : [
                          const BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Thumbnail
                      _buildThumbnail(),

                      // Gradient overlay
                      _buildGradientOverlay(),

                      // Hover overlay with details
                      _buildHoverOverlay(),

                      // Badges
                      _buildBadges(),

                      // Bottom info
                      _buildBottomInfo(),

                      // Play button on hover
                      if (_isHovering) _buildPlayButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return Container(
        color: ProfessionalTheme.surfaceCard,
        child: const Center(
          child: Icon(
            Icons.movie_outlined,
            size: 48,
            color: ProfessionalTheme.textTertiary,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: ProfessionalTheme.surfaceCard,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              ProfessionalTheme.primaryBrand.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: ProfessionalTheme.surfaceCard,
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: ProfessionalTheme.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildHoverOverlay() {
    return AnimatedOpacity(
      opacity: _overlayAnimation.value * 0.9,
      duration: ProfessionalTheme.durationFast,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
              ProfessionalTheme.primaryBrand.withValues(alpha: 0.4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadges() {
    return Positioned(
      top: ProfessionalTheme.space12,
      left: ProfessionalTheme.space12,
      right: ProfessionalTheme.space12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.badge != null)
            widget.badge!
          else
            Row(
              children: [
                if (widget.isPremium) ...[
                  ProfessionalTheme.premiumBadge(),
                  const SizedBox(width: ProfessionalTheme.space8),
                ],
                if (widget.isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ProfessionalTheme.space8,
                      vertical: ProfessionalTheme.space4,
                    ),
                    decoration: BoxDecoration(
                      color: ProfessionalTheme.accentRed,
                      borderRadius: BorderRadius.circular(ProfessionalTheme.radiusS),
                    ),
                    child: Text(
                      'جديد',
                      style: ProfessionalTheme.labelSmall(
                        color: ProfessionalTheme.textPrimary,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (widget.isLive) ProfessionalTheme.liveBadge(),
              ],
            ),
          if (widget.rating != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ProfessionalTheme.space8,
                vertical: ProfessionalTheme.space4,
              ),
              decoration: BoxDecoration(
                color: ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(ProfessionalTheme.radiusS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: ProfessionalTheme.accentGold,
                  ),
                  const SizedBox(width: ProfessionalTheme.space4),
                  Text(
                    widget.rating!.toStringAsFixed(1),
                    style: ProfessionalTheme.labelSmall(
                      color: ProfessionalTheme.textPrimary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(ProfessionalTheme.space12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: ProfessionalTheme.titleSmall(
                color: ProfessionalTheme.textPrimary,
                weight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: ProfessionalTheme.space4),
              Text(
                widget.subtitle!,
                style: ProfessionalTheme.bodySmall(
                  color: ProfessionalTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (widget.categories != null && widget.categories!.isNotEmpty) ...[
              const SizedBox(height: ProfessionalTheme.space8),
              Wrap(
                spacing: ProfessionalTheme.space4,
                runSpacing: ProfessionalTheme.space4,
                children: widget.categories!.take(2).map((category) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ProfessionalTheme.space8,
                      vertical: ProfessionalTheme.space2,
                    ),
                    decoration: BoxDecoration(
                      color: ProfessionalTheme.surfaceCard.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(ProfessionalTheme.radiusS),
                      border: Border.all(
                        color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      category,
                      style: ProfessionalTheme.labelSmall(
                        color: ProfessionalTheme.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (widget.year != null || widget.duration != null) ...[
              const SizedBox(height: ProfessionalTheme.space4),
              Row(
                children: [
                  if (widget.year != null) ...[
                    Text(
                      widget.year!,
                      style: ProfessionalTheme.labelSmall(
                        color: ProfessionalTheme.textTertiary,
                      ),
                    ),
                  ],
                  if (widget.year != null && widget.duration != null)
                    Text(
                      ' • ',
                      style: ProfessionalTheme.labelSmall(
                        color: ProfessionalTheme.textTertiary,
                      ),
                    ),
                  if (widget.duration != null)
                    Text(
                      widget.duration!,
                      style: ProfessionalTheme.labelSmall(
                        color: ProfessionalTheme.textTertiary,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return AnimatedOpacity(
      opacity: _overlayAnimation.value,
      duration: ProfessionalTheme.durationFast,
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: ProfessionalTheme.premiumGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}

// Skeleton loading version
class PremiumMediaCardSkeleton extends StatefulWidget {
  final double width;
  final double aspectRatio;

  const PremiumMediaCardSkeleton({
    super.key,
    this.width = 200,
    this.aspectRatio = 0.7,
  });

  @override
  State<PremiumMediaCardSkeleton> createState() => _PremiumMediaCardSkeletonState();
}

class _PremiumMediaCardSkeletonState extends State<PremiumMediaCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.width / widget.aspectRatio;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: height,
          decoration: BoxDecoration(
            color: ProfessionalTheme.surfaceCard,
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
          ),
          child: Stack(
            children: [
              // Shimmer effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
                    gradient: LinearGradient(
                      begin: Alignment(-2 + _shimmerController.value * 4, 0),
                      end: Alignment(-1 + _shimmerController.value * 4, 0),
                      colors: const [
                        ProfessionalTheme.surfaceCard,
                        ProfessionalTheme.surfaceHover,
                        ProfessionalTheme.surfaceCard,
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom placeholders
              Positioned(
                bottom: ProfessionalTheme.space12,
                left: ProfessionalTheme.space12,
                right: ProfessionalTheme.space12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: widget.width * 0.7,
                      height: 14,
                      decoration: BoxDecoration(
                        color: ProfessionalTheme.surfaceHover,
                        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusS),
                      ),
                    ),
                    const SizedBox(height: ProfessionalTheme.space8),
                    Container(
                      width: widget.width * 0.5,
                      height: 12,
                      decoration: BoxDecoration(
                        color: ProfessionalTheme.surfaceHover,
                        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusS),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}