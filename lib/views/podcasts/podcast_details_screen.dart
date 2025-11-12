// lib/views/podcasts/podcast_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../controllers/podcast_controller.dart';
import '../../models/podcast_model.dart';
import '../../core/theme/professional_theme.dart';

class PodcastDetailsScreen extends StatelessWidget {
  final int podcastId;

  const PodcastDetailsScreen({
    super.key,
    required this.podcastId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PodcastController>(
      builder: (context, controller, _) {
        final podcast = controller.getPodcastById(podcastId);

        if (podcast == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('تفاصيل البودكاست'),
              backgroundColor: ProfessionalTheme.surfaceColor,
            ),
            backgroundColor: ProfessionalTheme.backgroundColor,
            body: const Center(
              child: Text('البودكاست غير موجود'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: ProfessionalTheme.backgroundColor,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, podcast),
              SliverToBoxAdapter(
                child: _buildContent(context, podcast),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, Podcast podcast) {
    final isArabic = context.locale.languageCode == 'ar';

    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: ProfessionalTheme.surfaceColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: podcast.imageUrl ?? '',
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: ProfessionalTheme.surfaceCard,
                child: Icon(
                  Icons.podcasts,
                  size: 80,
                  color: ProfessionalTheme.textSecondary,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    ProfessionalTheme.backgroundColor.withOpacity(0.7),
                    ProfessionalTheme.backgroundColor,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (podcast.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ProfessionalTheme.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    podcast.getLocalizedTitle(isArabic ? 'ar' : 'en'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                        ),
                      ],
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

  Widget _buildContent(BuildContext context, Podcast podcast) {
    final isArabic = context.locale.languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Play Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Play podcast
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تشغيل البودكاست قريباً')),
                );
              },
              icon: Icon(Icons.play_arrow, size: 28),
              label: const Text(
                'تشغيل',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfessionalTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info Row
          Row(
            children: [
              if (podcast.rating != null) ...[
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  podcast.rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    color: ProfessionalTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              if (podcast.duration != null) ...[
                Icon(
                  Icons.access_time,
                  color: ProfessionalTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  podcast.formattedDuration,
                  style: TextStyle(
                    color: ProfessionalTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Icon(
                Icons.remove_red_eye,
                color: ProfessionalTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${podcast.viewsCount} مشاهدة',
                style: TextStyle(
                  color: ProfessionalTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Host
          if (podcast.host != null || podcast.hostAr != null) ...[
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: ProfessionalTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'المقدم:',
                  style: TextStyle(
                    color: ProfessionalTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  podcast.getLocalizedHost(isArabic ? 'ar' : 'en') ?? '',
                  style: const TextStyle(
                    color: ProfessionalTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Episode Info
          if (podcast.episodeLabel.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: ProfessionalTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  podcast.episodeLabel,
                  style: const TextStyle(
                    color: ProfessionalTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Description
          if (podcast.description != null ||
              podcast.descriptionAr != null) ...[
            const Text(
              'الوصف',
              style: TextStyle(
                color: ProfessionalTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              podcast.getLocalizedDescription(isArabic ? 'ar' : 'en') ?? '',
              style: TextStyle(
                color: ProfessionalTheme.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Release Date
          if (podcast.releaseDate != null) ...[
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: ProfessionalTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'تاريخ النشر: ${podcast.releaseDate}',
                  style: TextStyle(
                    color: ProfessionalTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
