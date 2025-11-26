// lib/views/favorites/favorites_screen.dart
import 'package:alenwan/core/utils/url_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../core/theme/professional_theme.dart';
import '../../controllers/favorites_controller.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _heartController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _heartAnimation;

  // Using centralized theme colors from ModernTheme

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _heartAnimation = CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
    _scaleController.forward();
    _heartController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesController>();

    return Scaffold(
      backgroundColor: ProfessionalTheme.backgroundColor,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // Modern header
                  _buildSliverAppBar(context),

                  // Content
                  SliverToBoxAdapter(
                    child: _buildContent(fav),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _heartController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ProfessionalTheme.backgroundColor,
                ProfessionalTheme.surfaceColor.withValues(alpha: 0.3),
                ProfessionalTheme.backgroundColor,
                ProfessionalTheme.primaryColor.withValues(alpha: 0.05),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: FavoritesPainter(_heartAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: ProfessionalTheme.backgroundColor.withValues(alpha: 0.9),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ProfessionalTheme.primaryColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'المفضلات',
          style: ProfessionalTheme.getTextStyle(
            context: context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ProfessionalTheme.primaryColor.withValues(alpha: 0.8),
                ProfessionalTheme.secondaryColor.withValues(alpha: 0.6),
                ProfessionalTheme.backgroundColor.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedBuilder(
                animation: _heartController,
                builder: (context, child) {
                  return Container(
                    width: 80 + _heartAnimation.value * 10,
                    height: 80 + _heartAnimation.value * 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ProfessionalTheme.primaryColor
                              .withValues(alpha: _heartAnimation.value * 0.5),
                          blurRadius: 20,
                          spreadRadius: _heartAnimation.value * 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 40,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(FavoritesController fav) {
    if (fav.isLoading) {
      return _buildLoadingState();
    }

    if (fav.items.isEmpty) {
      return _buildEmptyState();
    }

    return _buildFavoritesList(fav);
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: ProfessionalTheme.surfaceColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: ProfessionalTheme.primaryColor,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'جارٍ التحميل...',
                style: ProfessionalTheme.getTextStyle(
                  context: context,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 500,
      margin: const EdgeInsets.all(20),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: ProfessionalTheme.surfaceColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: ProfessionalTheme.primaryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _heartController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0,
                            math.sin(_heartAnimation.value * math.pi * 2) * 8),
                        child: Transform.scale(
                          scale: 1.0 + _heartAnimation.value * 0.2,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ProfessionalTheme.primaryColor
                                      .withValues(alpha: 0.8),
                                  ProfessionalTheme.secondaryColor
                                      .withValues(alpha: 0.6),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ProfessionalTheme.primaryColor
                                      .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'لا توجد مفضلات حتى الآن',
                    style: ProfessionalTheme.getTextStyle(
                      context: context,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ابدأ بإضافة المحتوى المفضل لديك\nلمشاهدته لاحقاً',
                    style: ProfessionalTheme.getTextStyle(
                      context: context,
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList(FavoritesController fav) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ProfessionalTheme.surfaceColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'المحتوى المفضل',
                  style: ProfessionalTheme.getTextStyle(
                    context: context,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${fav.items.length} عنصر',
                    style: ProfessionalTheme.getTextStyle(
                      context: context,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Favorites list
          ...fav.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: _scaleController,
                  curve: Interval(
                    index * 0.1,
                    1.0,
                    curve: Curves.elasticOut,
                  ),
                ),
              ),
              child: _buildFavoriteCard(item, fav),
            );
          }),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(dynamic item, FavoritesController fav) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ProfessionalTheme.surfaceColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ProfessionalTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate to details
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            ProfessionalTheme.primaryColor.withValues(alpha: 0.6),
                            ProfessionalTheme.secondaryColor.withValues(alpha: 0.4),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                ProfessionalTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: UrlUtils.normalize(item.image),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ProfessionalTheme.primaryColor
                                      .withValues(alpha: 0.6),
                                  ProfessionalTheme.secondaryColor
                                      .withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ProfessionalTheme.primaryColor
                                      .withValues(alpha: 0.6),
                                  ProfessionalTheme.secondaryColor
                                      .withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Content info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: ProfessionalTheme.getTextStyle(
                              context: context,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ProfessionalTheme.primaryColor
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.type,
                              style: ProfessionalTheme.getTextStyle(
                                context: context,
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _heartController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + _heartAnimation.value * 0.1,
                                    child: Icon(
                                      Icons.favorite,
                                      color: ProfessionalTheme.primaryColor,
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'مضاف للمفضلات',
                                style: ProfessionalTheme.getTextStyle(
                                  context: context,
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Remove button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => fav.toggle(
                            id: item.id,
                            type: item.type,
                            title: item.title,
                            image: item.image,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
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
  }
}

class FavoritesPainter extends CustomPainter {
  final double animationValue;

  FavoritesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ProfessionalTheme.primaryColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Draw animated hearts
    for (int i = 0; i < 15; i++) {
      final x = (size.width * (i * 0.15 + 0.08)) +
          math.sin(animationValue * math.pi * 2 + i * 0.8) * 30;
      final y = (size.height * (i * 0.08 + 0.1)) +
          math.cos(animationValue * math.pi * 2 + i * 0.6) * 25;

      // Heart shape
      final heartSize = 3 + math.sin(animationValue * math.pi * 4 + i) * 1.5;
      _drawHeart(canvas, Offset(x, y), heartSize, paint);
    }

    // Draw love waves
    final wavePaint = Paint()
      ..color = ProfessionalTheme.primaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int wave = 0; wave < 3; wave++) {
      final path = Path();
      for (double x = 0; x < size.width; x += 5) {
        final y = size.height * (0.3 + wave * 0.2) +
            math.sin((x / 60) + animationValue * math.pi * 2 + wave * 1.2) * 20;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    // Simple heart approximation using circles and triangle
    canvas.drawCircle(
      Offset(center.dx - size / 2, center.dy - size / 2),
      size,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + size / 2, center.dy - size / 2),
      size,
      paint,
    );

    final trianglePath = Path();
    trianglePath.moveTo(center.dx, center.dy + size);
    trianglePath.lineTo(center.dx - size, center.dy - size / 2);
    trianglePath.lineTo(center.dx + size, center.dy - size / 2);
    trianglePath.close();

    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
