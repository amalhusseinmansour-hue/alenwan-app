import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/app_colors.dart';

class PullToRefreshWrapper extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshText;
  final String? releaseText;
  final String? loadingText;
  final double refreshTriggerDistance;
  final Duration animationDuration;
  final bool enableCustomIndicator;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText = 'Pull to refresh',
    this.releaseText = 'Release to refresh',
    this.loadingText = 'Refreshing...',
    this.refreshTriggerDistance = 80.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enableCustomIndicator = true,
  });

  @override
  State<PullToRefreshWrapper> createState() => _PullToRefreshWrapperState();
}

class _PullToRefreshWrapperState extends State<PullToRefreshWrapper>
    with TickerProviderStateMixin {
  late AnimationController _indicatorController;
  late AnimationController _rippleController;
  late Animation<double> _indicatorAnimation;
  late Animation<double> _rippleAnimation;

  bool _isRefreshing = false;
  // ignore: unused_field
  final double _dragDistance = 0.0;

  @override
  void initState() {
    super.initState();

    _indicatorController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _indicatorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.elasticOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _indicatorController.forward();
    _rippleController.repeat();

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        _indicatorController.reverse();
        _rippleController.stop();
        _rippleController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableCustomIndicator) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: AppColors.primary,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: widget.child,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.transparent,
      backgroundColor: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_indicatorAnimation, _rippleAnimation]),
              builder: (context, child) {
                return BurgundyRefreshIndicator(
                  isRefreshing: _isRefreshing,
                  progress: _indicatorAnimation.value,
                  rippleProgress: _rippleAnimation.value,
                  refreshText: widget.refreshText ?? 'Pull to refresh',
                  releaseText: widget.releaseText ?? 'Release to refresh',
                  loadingText: widget.loadingText ?? 'Refreshing...',
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class BurgundyRefreshIndicator extends StatelessWidget {
  final bool isRefreshing;
  final double progress;
  final double rippleProgress;
  final String refreshText;
  final String releaseText;
  final String loadingText;

  const BurgundyRefreshIndicator({
    super.key,
    required this.isRefreshing,
    required this.progress,
    required this.rippleProgress,
    required this.refreshText,
    required this.releaseText,
    required this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRefreshing && progress == 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: isRefreshing ? 100 : progress * 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated indicator
            Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect
                if (isRefreshing)
                  Transform.scale(
                    scale: rippleProgress,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary
                              .withValues(alpha: 1 - rippleProgress),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                // Main indicator
                Transform.scale(
                  scale: progress,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.accent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isRefreshing
                        ? const _SpinningIcon()
                        : const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Status text
            Opacity(
              opacity: progress,
              child: Text(
                isRefreshing
                    ? loadingText
                    : (progress >= 1.0 ? releaseText : refreshText),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon();

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: const Icon(
            Icons.refresh,
            color: Colors.white,
            size: 20,
          ),
        );
      },
    );
  }
}

// Custom refresh indicator for specific use cases
class ElasticRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? accentColor;
  final double elasticFactor;

  const ElasticRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.accentColor,
    this.elasticFactor = 0.3,
  });

  @override
  State<ElasticRefreshIndicator> createState() =>
      _ElasticRefreshIndicatorState();
}

class _ElasticRefreshIndicatorState extends State<ElasticRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _elasticController;
  late Animation<double> _elasticAnimation;

  bool _isDragging = false;
  double _dragDistance = 0.0;

  @override
  void initState() {
    super.initState();

    _elasticController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _elasticAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0 + widget.elasticFactor,
    ).animate(CurvedAnimation(
      parent: _elasticController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _elasticController.dispose();
    super.dispose();
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _isDragging = true;
    } else if (notification is ScrollEndNotification) {
      _isDragging = false;
      _elasticController.reverse();
    } else if (notification is ScrollUpdateNotification && _isDragging) {
      if (notification.metrics.pixels < 0) {
        _dragDistance = -notification.metrics.pixels;
        final progress = (_dragDistance / 100).clamp(0.0, 1.0);
        _elasticController.value = progress;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: AnimatedBuilder(
        animation: _elasticAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _elasticAnimation.value,
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              color: widget.accentColor ?? AppColors.primary,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

// Premium refresh indicator with liquid effect
class LiquidRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? liquidColor;

  const LiquidRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.liquidColor,
  });

  @override
  State<LiquidRefreshIndicator> createState() => _LiquidRefreshIndicatorState();
}

class _LiquidRefreshIndicatorState extends State<LiquidRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _waveController.repeat();
    try {
      await widget.onRefresh();
    } finally {
      _waveController.stop();
      _waveController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.transparent,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 100),
                  painter: LiquidWavePainter(
                    waveProgress: _waveAnimation.value,
                    color: widget.liquidColor ?? AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LiquidWavePainter extends CustomPainter {
  final double waveProgress;
  final Color color;

  LiquidWavePainter({
    required this.waveProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveProgress == 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height -
          50 +
          math.sin((x / waveLength + waveProgress) * 2 * math.pi) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LiquidWavePainter oldDelegate) {
    return oldDelegate.waveProgress != waveProgress;
  }
}

// Simplified wrapper for common use cases
class SmartRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final RefreshIndicatorStyle style;

  const SmartRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.style = RefreshIndicatorStyle.burgundy,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case RefreshIndicatorStyle.burgundy:
        return PullToRefreshWrapper(
          onRefresh: onRefresh,
          child: child,
        );
      case RefreshIndicatorStyle.elastic:
        return ElasticRefreshIndicator(
          onRefresh: onRefresh,
          child: child,
        );
      case RefreshIndicatorStyle.liquid:
        return LiquidRefreshIndicator(
          onRefresh: onRefresh,
          child: child,
        );
      case RefreshIndicatorStyle.standard:
        return RefreshIndicator(
          onRefresh: onRefresh,
          color: AppColors.primary,
          child: child,
        );
    }
  }
}

enum RefreshIndicatorStyle {
  burgundy,
  elastic,
  liquid,
  standard,
}
