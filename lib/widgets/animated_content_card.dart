import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/app_colors.dart';

class AnimatedContentCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final bool enableHover;
  final bool enableGlassMorphism;
  final String? imageUrl;
  final Widget? overlay;
  final Duration animationDuration;
  final bool enableShadow;

  const AnimatedContentCard({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.borderRadius,
    this.backgroundColor,
    this.enableHover = true,
    this.enableGlassMorphism = true,
    this.imageUrl,
    this.overlay,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableShadow = true,
  });

  @override
  State<AnimatedContentCard> createState() => _AnimatedContentCardState();
}

class _AnimatedContentCardState extends State<AnimatedContentCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _imageController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _imageOpacityAnimation;
  late Animation<double> _pressScaleAnimation;

  bool _isHovered = false;
  bool _isPressed = false;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _imageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _pressScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _imageOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent details) {
    if (!widget.enableHover || !kIsWeb) return;
    setState(() {
      _isHovered = true;
    });
    _hoverController.forward();
  }

  void _onExit(PointerEvent details) {
    if (!widget.enableHover || !kIsWeb) return;
    setState(() {
      _isHovered = false;
    });
    _hoverController.reverse();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _pressController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _pressController.reverse();
  }

  void _onImageLoaded() {
    if (!_imageLoaded) {
      setState(() {
        _imageLoaded = true;
      });
      _imageController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderRadius = widget.borderRadius ?? BorderRadius.circular(16);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _hoverController,
        _pressController,
        _imageController,
      ]),
      builder: (context, child) {
        return Container(
          margin: widget.margin,
          child: MouseRegion(
            onEnter: _onEnter,
            onExit: _onExit,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap,
              child: Transform.scale(
                scale: _scaleAnimation.value * _pressScaleAnimation.value,
                child: AnimatedContainer(
                  duration: widget.animationDuration,
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: defaultBorderRadius,
                    boxShadow: widget.enableShadow
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              offset: Offset(0, _elevationAnimation.value / 2),
                              blurRadius: _elevationAnimation.value,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.05),
                              offset: Offset(0, _elevationAnimation.value),
                              blurRadius: _elevationAnimation.value * 2,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: defaultBorderRadius,
                    child: Stack(
                      children: [
                        // Background image if provided
                        if (widget.imageUrl != null)
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: _imageOpacityAnimation.value,
                              duration: const Duration(milliseconds: 300),
                              child: Image.network(
                                widget.imageUrl!,
                                fit: BoxFit.cover,
                                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded || frame != null) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _onImageLoaded();
                                    });
                                    return child;
                                  }
                                  return Container(
                                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey[600],
                                      size: 48,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        // Glass morphism effect
                        if (widget.enableGlassMorphism)
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: _isHovered ? 0.5 : 0,
                                sigmaY: _isHovered ? 0.5 : 0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: defaultBorderRadius,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary.withOpacity(_isHovered ? 0.1 : 0.05),
                                      AppColors.accent.withOpacity(_isHovered ? 0.15 : 0.08),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(_isHovered ? 0.3 : 0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Background color
                        if (!widget.enableGlassMorphism)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: defaultBorderRadius,
                                color: widget.backgroundColor ??
                                    (isDark
                                        ? Colors.grey[900]?.withOpacity(0.8)
                                        : Colors.white.withOpacity(0.9)),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(_isHovered ? 0.3 : 0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),

                        // Content
                        Positioned.fill(
                          child: Container(
                            padding: widget.padding,
                            child: widget.child,
                          ),
                        ),

                        // Overlay if provided
                        if (widget.overlay != null)
                          Positioned.fill(
                            child: widget.overlay!,
                          ),

                        // Hover effect overlay
                        if (_isHovered && widget.enableHover)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: defaultBorderRadius,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary.withOpacity(0.05),
                                    AppColors.accent.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Press effect overlay
                        if (_isPressed)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: defaultBorderRadius,
                                color: AppColors.primary.withOpacity(0.1),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Specialized content card variations
class PremiumContentCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final bool isPremium;
  final Widget? badge;

  const PremiumContentCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.actions,
    this.isPremium = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContentCard(
      onTap: onTap,
      imageUrl: imageUrl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badge
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) badge!,
              if (isPremium && badge == null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const Spacer(),
          if (actions != null) ...[
            const SizedBox(height: 16),
            Row(
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}

class MediaCard extends StatelessWidget {
  final String title;
  final String? duration;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;
  final bool isWatched;
  final double? progress;

  const MediaCard({
    super.key,
    required this.title,
    this.duration,
    this.imageUrl,
    this.onTap,
    this.onPlayTap,
    this.isWatched = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContentCard(
      onTap: onTap,
      imageUrl: imageUrl,
      height: 200,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Gradient overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
          ),

          // Play button
          if (onPlayTap != null)
            Center(
              child: GestureDetector(
                onTap: onPlayTap,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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

          // Bottom info
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (progress != null)
                  Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.5),
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1.5),
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (duration != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (isWatched)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 20,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}