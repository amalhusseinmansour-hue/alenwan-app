import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/professional_theme.dart';

class HeroBanner extends StatefulWidget {
  final String? backgroundImage;
  final String? videoUrl;
  final String title;
  final String? subtitle;
  final String? description;
  final List<String>? categories;
  final double? rating;
  final String? year;
  final String? duration;
  final bool isPremium;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onInfoPressed;
  final VoidCallback? onAddToListPressed;

  const HeroBanner({
    super.key,
    this.backgroundImage,
    this.videoUrl,
    required this.title,
    this.subtitle,
    this.description,
    this.categories,
    this.rating,
    this.year,
    this.duration,
    this.isPremium = false,
    this.onPlayPressed,
    this.onInfoPressed,
    this.onAddToListPressed,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 768;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              height: isDesktop ? 600 : (isTablet ? 500 : 400),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  _buildBackground(),

                  // Multiple gradient overlays for depth
                  _buildGradientOverlays(),

                  // Content
                  _buildContent(context, isDesktop, isTablet),

                  // Animated particles/effects
                  if (isDesktop) _buildParticles(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    if (widget.backgroundImage == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
              ProfessionalTheme.backgroundPrimary,
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: widget.backgroundImage!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: ProfessionalTheme.surfaceCard,
          ),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                  ProfessionalTheme.backgroundPrimary,
                ],
              ),
            ),
          ),
        ),
        // Blur effect on background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  Widget _buildGradientOverlays() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Bottom to top gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.5),
                ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.95),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Left to right gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.9),
                ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.7],
            ),
          ),
        ),
        // Vignette effect
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isDesktop, bool isTablet) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
          vertical: isDesktop ? 60 : 40,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium badge
            if (widget.isPremium)
              Padding(
                padding:
                    const EdgeInsets.only(bottom: ProfessionalTheme.space16),
                child: ProfessionalTheme.premiumBadge(text: 'حصري'),
              ),

            // Title with animation
            _buildAnimatedTitle(isDesktop),

            if (widget.subtitle != null) ...[
              const SizedBox(height: ProfessionalTheme.space8),
              Text(
                widget.subtitle!,
                style: ProfessionalTheme.headlineSmall(
                  color: ProfessionalTheme.textSecondary,
                ),
              ),
            ],

            // Metadata row
            if (widget.rating != null ||
                widget.year != null ||
                widget.duration != null ||
                widget.categories != null) ...[
              const SizedBox(height: ProfessionalTheme.space16),
              _buildMetadata(),
            ],

            // Description
            if (widget.description != null) ...[
              const SizedBox(height: ProfessionalTheme.space16),
              Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 600 : double.infinity,
                ),
                child: Text(
                  widget.description!,
                  style: ProfessionalTheme.bodyLarge(
                    color: ProfessionalTheme.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Action buttons
            const SizedBox(height: ProfessionalTheme.space24),
            _buildActionButtons(isDesktop),

            const SizedBox(height: ProfessionalTheme.space40),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle(bool isDesktop) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          ProfessionalTheme.textPrimary,
          ProfessionalTheme.textPrimary.withValues(alpha: 0.9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        widget.title,
        style: isDesktop
            ? ProfessionalTheme.displayMedium()
            : ProfessionalTheme.displaySmall(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMetadata() {
    return Wrap(
      spacing: ProfessionalTheme.space16,
      runSpacing: ProfessionalTheme.space8,
      children: [
        if (widget.rating != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: ProfessionalTheme.accentGold,
                size: 20,
              ),
              const SizedBox(width: ProfessionalTheme.space4),
              Text(
                widget.rating!.toStringAsFixed(1),
                style: ProfessionalTheme.bodyLarge(
                  color: ProfessionalTheme.textPrimary,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        if (widget.year != null)
          Text(
            widget.year!,
            style: ProfessionalTheme.bodyLarge(
              color: ProfessionalTheme.textSecondary,
            ),
          ),
        if (widget.duration != null)
          Text(
            widget.duration!,
            style: ProfessionalTheme.bodyLarge(
              color: ProfessionalTheme.textSecondary,
            ),
          ),
        if (widget.categories != null)
          ...widget.categories!.take(3).map(
                (category) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ProfessionalTheme.space12,
                    vertical: ProfessionalTheme.space4,
                  ),
                  decoration: BoxDecoration(
                    color: ProfessionalTheme.surfaceCard.withValues(alpha: 0.8),
                    borderRadius:
                        BorderRadius.circular(ProfessionalTheme.radiusM),
                    border: Border.all(
                      color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category,
                    style: ProfessionalTheme.labelMedium(
                      color: ProfessionalTheme.textSecondary,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDesktop) {
    return Wrap(
      spacing: ProfessionalTheme.space12,
      runSpacing: ProfessionalTheme.space12,
      children: [
        // Play button
        _PremiumButton(
          onPressed: widget.onPlayPressed,
          isPrimary: true,
          icon: Icons.play_arrow_rounded,
          label: 'تشغيل',
          width: isDesktop ? 160 : 140,
        ),

        // Add to list button
        _PremiumButton(
          onPressed: widget.onAddToListPressed,
          isPrimary: false,
          icon: Icons.add_rounded,
          label: 'قائمتي',
          width: isDesktop ? 160 : 140,
        ),

        // Info button
        if (isDesktop)
          _PremiumButton(
            onPressed: widget.onInfoPressed,
            isPrimary: false,
            icon: Icons.info_outline_rounded,
            label: 'المزيد',
            isIconOnly: true,
          ),
      ],
    );
  }

  Widget _buildParticles() {
    return IgnorePointer(
      child: CustomPaint(
        painter: FloatingParticlesPainter(
          animation: _animationController,
          particleColor: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
        ),
        child: Container(),
      ),
    );
  }
}

class _PremiumButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData icon;
  final String label;
  final double? width;
  final bool isIconOnly;

  const _PremiumButton({
    this.onPressed,
    required this.isPrimary,
    required this.icon,
    required this.label,
    this.width,
    this.isIconOnly = false,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ProfessionalTheme.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius:
                    BorderRadius.circular(ProfessionalTheme.radiusRound),
                child: Container(
                  width: widget.isIconOnly ? 48 : widget.width,
                  height: 48,
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        widget.isIconOnly ? 0 : ProfessionalTheme.space20,
                  ),
                  decoration: BoxDecoration(
                    gradient: widget.isPrimary
                        ? ProfessionalTheme.premiumGradient
                        : null,
                    color: widget.isPrimary
                        ? null
                        : ProfessionalTheme.surfaceCard.withValues(alpha: 0.8),
                    borderRadius:
                        BorderRadius.circular(ProfessionalTheme.radiusRound),
                    border: Border.all(
                      color: widget.isPrimary
                          ? Colors.transparent
                          : ProfessionalTheme.textTertiary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: widget.isPrimary
                        ? ProfessionalTheme.buttonShadow
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize:
                        widget.isIconOnly ? MainAxisSize.min : MainAxisSize.max,
                    children: [
                      Icon(
                        widget.icon,
                        color: ProfessionalTheme.textPrimary,
                        size: 24,
                      ),
                      if (!widget.isIconOnly) ...[
                        const SizedBox(width: ProfessionalTheme.space8),
                        Text(
                          widget.label,
                          style: ProfessionalTheme.labelLarge(
                            color: ProfessionalTheme.textPrimary,
                          ),
                        ),
                      ],
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
}

class FloatingParticlesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color particleColor;

  FloatingParticlesPainter({
    required this.animation,
    required this.particleColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = particleColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final progress = (animation.value + i * 0.05) % 1.0;
      final x = size.width * (0.1 + (i * 0.13) % 0.8);
      final y = size.height * (1.0 - progress);
      final opacity = (1.0 - progress) * 0.5;
      final radius = 1 + (i % 3);

      paint.color = particleColor.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius.toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
