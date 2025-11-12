import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration period;
  final ShimmerDirection direction;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.enabled = true,
    this.period = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.period,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    ));

    if (widget.enabled) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: widget.direction == ShimmerDirection.ltr
                  ? Alignment.centerLeft
                  : widget.direction == ShimmerDirection.rtl
                      ? Alignment.centerRight
                      : widget.direction == ShimmerDirection.ttb
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
              end: widget.direction == ShimmerDirection.ltr
                  ? Alignment.centerRight
                  : widget.direction == ShimmerDirection.rtl
                      ? Alignment.centerLeft
                      : widget.direction == ShimmerDirection.ttb
                          ? Alignment.bottomCenter
                          : Alignment.topCenter,
              colors: [
                Colors.transparent,
                AppColors.primary.withOpacity(0.1),
                AppColors.accent.withOpacity(0.3),
                AppColors.primary.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: [
                0.0,
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

enum ShimmerDirection { ltr, rtl, ttb, btt }

// Predefined shimmer placeholders
class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool enabled;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 200,
    this.borderRadius,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      enabled: enabled,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class ShimmerListItem extends StatelessWidget {
  final bool enabled;
  final bool hasImage;
  final double? height;

  const ShimmerListItem({
    super.key,
    this.enabled = true,
    this.hasImage = true,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? Colors.grey[800] : Colors.grey[300];

    return ShimmerLoading(
      enabled: enabled,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (hasImage) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final double aspectRatio;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final bool enabled;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.aspectRatio = 0.7,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerCard(
          enabled: enabled,
          borderRadius: BorderRadius.circular(12),
        );
      },
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double? width;
  final double height;
  final bool enabled;

  const ShimmerText({
    super.key,
    this.width,
    this.height = 16,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      enabled: enabled,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class ShimmerButton extends StatelessWidget {
  final double? width;
  final double height;
  final bool enabled;

  const ShimmerButton({
    super.key,
    this.width = 120,
    this.height = 48,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      enabled: enabled,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

// Premium content card shimmer
class ShimmerContentCard extends StatelessWidget {
  final bool enabled;

  const ShimmerContentCard({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? Colors.grey[800] : Colors.grey[300];

    return ShimmerLoading(
      enabled: enabled,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: shimmerColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Container(
                    height: 16,
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(
                    children: [
                      Container(
                        height: 36,
                        width: 80,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 36,
                        width: 100,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(18),
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
    );
  }
}