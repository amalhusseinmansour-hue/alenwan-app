// lib/views/podcasts/podcasts_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/podcast_controller.dart';
import '../../models/podcast_model.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/professional_theme.dart';

class HoverMediaCardPodcast extends StatefulWidget {
  final String imageUrl;
  final String title;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double gap;
  final String? badge;
  final double badgeOpacity;

  const HoverMediaCardPodcast({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.width,
    required this.height,
    this.onTap,
    this.gap = 14,
    this.badge,
    this.badgeOpacity = .65,
  });

  @override
  State<HoverMediaCardPodcast> createState() => _HoverMediaCardPodcastState();
}

class _HoverMediaCardPodcastState extends State<HoverMediaCardPodcast> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetW = (widget.width * dpr).round();
    final targetH = (widget.height * dpr).round();

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        margin: EdgeInsets.symmetric(horizontal: widget.gap / 2),
        transform: _hover
            ? Matrix4.diagonal3Values(1.06, 1.06, 1.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const [],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: widget.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          memCacheWidth: targetW,
                          memCacheHeight: targetH,
                          filterQuality: FilterQuality.low,
                          placeholder: (_, __) => Container(
                            color: ProfessionalTheme.surfaceCard,
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  ProfessionalTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: ProfessionalTheme.surfaceCard,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.podcasts,
                              size: 40,
                              color: ProfessionalTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      if (widget.badge != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ProfessionalTheme.primaryColor
                                  .withValues(alpha: widget.badgeOpacity),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.gap / 2),
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ProfessionalTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PodcastsContent extends StatelessWidget {
  const PodcastsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PodcastController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation(ProfessionalTheme.primaryColor),
            ),
          );
        }

        if (controller.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'حدث خطأ أثناء تحميل البودكاست',
                  style: TextStyle(
                    color: ProfessionalTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.error!,
                  style: const TextStyle(
                    color: ProfessionalTheme.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProfessionalTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.podcasts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.podcasts,
                  size: 64,
                  color: ProfessionalTheme.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'لا توجد بودكاست متاحة حالياً',
                  style: TextStyle(
                    color: ProfessionalTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.podcasts,
                      color: ProfessionalTheme.primaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'البودكاست',
                      style: TextStyle(
                        color: ProfessionalTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'استمع إلى أفضل البودكاست',
                  style: TextStyle(
                    color: ProfessionalTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),

                // Featured Podcasts
                if (controller.featuredPodcasts.isNotEmpty) ...[
                  _buildSection(
                    context,
                    title: 'بودكاست مميزة',
                    icon: Icons.star,
                    podcasts: controller.featuredPodcasts,
                  ),
                  const SizedBox(height: 40),
                ],

                // All Podcasts
                _buildSection(
                  context,
                  title: 'جميع البودكاست',
                  icon: Icons.grid_view,
                  podcasts: controller.podcasts,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Podcast> podcasts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: ProfessionalTheme.primaryColor, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: ProfessionalTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${podcasts.length} بودكاست',
              style: const TextStyle(
                color: ProfessionalTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth / 5).clamp(150.0, 200.0);
            final cardHeight = cardWidth * 1.5;

            return Wrap(
              spacing: 14,
              runSpacing: 20,
              children: podcasts.map((podcast) {
                return HoverMediaCardPodcast(
                  imageUrl: podcast.imageUrl ?? '',
                  title: podcast.title,
                  width: cardWidth,
                  height: cardHeight,
                  badge: podcast.isPremium ? 'Premium' : null,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.podcastDetails,
                      arguments: podcast.id,
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
