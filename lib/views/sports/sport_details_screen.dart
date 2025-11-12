// lib/views/sports/sport_details_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/sport_model.dart';
import '../../core/services/sport_service.dart';
import '../../core/services/dub_service.dart';
import '../../common/video_player_screen.dart';
import '../../widgets/vimeo_player_widget.dart';
import '../../core/utils/url_utils.dart';
import '../../core/theme/professional_theme.dart';

class SportDetailsScreen extends StatefulWidget {
  final SportModel sport;
  const SportDetailsScreen({super.key, required this.sport});

  @override
  State<SportDetailsScreen> createState() => _SportDetailsScreenState();
}

class _SportDetailsScreenState extends State<SportDetailsScreen> {
  final _service = SportService();
  final _dubService = DubService();

  SportModel? _sport;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final s = await _service.fetchSportDetails(widget.sport.id);
      if (!mounted) return;
      setState(() {
        _sport = s;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تحميل التفاصيل: $e')));
    }
  }

  String _bestPlayable(SportModel s) {
    // Check video_url first (direct video link)
    final videoUrl = (s.videoUrl ?? '').trim();
    if (videoUrl.isNotEmpty) {
      return videoUrl;
    }

    // Check stream_url (for live streams)
    final streamUrl = (s.streamUrl ?? '').trim();
    if (streamUrl.isNotEmpty) {
      return streamUrl;
    }

    // Fallback to playback object
    final hls = (s.playback?['hls'] ?? '').toString().trim();
    final mp4 = (s.playback?['mp4'] ?? '').toString().trim();
    final candidates = kIsWeb ? [mp4, hls] : [hls, mp4];
    return candidates.firstWhere((u) => u.isNotEmpty, orElse: () => '');
  }

  void _play(SportModel sport) {
    final url = _bestPlayable(sport);
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا يوجد فيديو متاح')));
      return;
    }

    // Check if it's a Vimeo URL
    if (url.contains('vimeo.com')) {
      final vimeoId = _extractVimeoId(url);
      if (vimeoId != null) {
        // Use VimeoPlayerWidget for Vimeo videos
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: Text(sport.title),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Center(
                child: VimeoPlayerWidget(
                  vimeoId: vimeoId,
                  contentId: 'sport_${sport.id}',
                  title: sport.title,
                ),
              ),
            ),
          ),
        );
        return;
      }
    }

    // For other video URLs, use VideoPlayerScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          url: UrlUtils.normalize(url),
          title: sport.title,
          audioDubs: const [],
          dubLoader: () => _dubService.list(type: 'sport', id: sport.id),
        ),
      ),
    );
  }

  String? _extractVimeoId(String url) {
    // Extract Vimeo ID from URL
    // Example: https://vimeo.com/1066229677 -> 1066229677
    final RegExp vimeoRegex = RegExp(r'vimeo\.com/(\d+)');
    final match = vimeoRegex.firstMatch(url);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: ProfessionalTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: ProfessionalTheme.primaryColor,
          ),
        ),
      );
    }

    if (_sport == null) {
      return Scaffold(
        backgroundColor: ProfessionalTheme.backgroundColor,
        body: Center(
          child: Text(
            'تعذر تحميل الرياضة',
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.errorColor,
            ),
          ),
        ),
      );
    }

    final sport = _sport!;
    final banner = UrlUtils.normalize(
      sport.bannerUrl?.isNotEmpty == true ? sport.bannerUrl! : sport.posterUrl ?? '',
    );
    final poster = UrlUtils.normalize(
      sport.posterUrl?.isNotEmpty == true ? sport.posterUrl! : sport.bannerUrl ?? '',
    );
    final hasVideo = _bestPlayable(sport).isNotEmpty;

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              stretch: true,
              backgroundColor: ProfessionalTheme.surfaceColor,
              expandedHeight: _getHeroHeight(context),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _HeroSection(
                  bannerUrl: banner,
                  title: sport.title,
                  description: sport.description ?? '',
                  hasVideo: hasVideo,
                  onPlay: () => _play(sport),
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: ProfessionalTheme.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoSection(sport: sport, posterUrl: poster),
                const SizedBox(height: 32),
                _DetailsSection(sport: sport),
                const SizedBox(height: 32),
                _MetadataSection(sport: sport),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getHeroHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width >= 1200) return 500;
    if (size.width >= 900) return 450;
    if (size.width >= 600) return 400;
    return 350;
  }
}

class _HeroSection extends StatelessWidget {
  final String bannerUrl;
  final String title;
  final String description;
  final bool hasVideo;
  final VoidCallback onPlay;

  const _HeroSection({
    required this.bannerUrl,
    required this.title,
    required this.description,
    required this.hasVideo,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        CachedNetworkImage(
          imageUrl: bannerUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: ProfessionalTheme.surfaceCard,
            child: Center(
              child: CircularProgressIndicator(
                color: ProfessionalTheme.primaryColor,
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            color: ProfessionalTheme.surfaceCard,
            child: Icon(
              Icons.broken_image,
              color: ProfessionalTheme.textTertiary,
              size: 64,
            ),
          ),
        ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),

        // Content
        Positioned(
          left: 24,
          right: 24,
          bottom: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ProfessionalTheme.displaySmall(
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  style: ProfessionalTheme.bodyLarge(
                    color: Colors.white70,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: hasVideo ? onPlay : null,
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: const Text('شاهد الآن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfessionalTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Add to favorites functionality
                    },
                    icon: const Icon(Icons.favorite_border, size: 20),
                    label: const Text('إضافة للمفضلة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final SportModel sport;
  final String posterUrl;

  const _InfoSection({
    required this.sport,
    required this.posterUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poster
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: posterUrl,
            width: 160,
            height: 240,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 160,
              height: 240,
              color: ProfessionalTheme.surfaceCard,
              child: Center(
                child: CircularProgressIndicator(
                  color: ProfessionalTheme.primaryColor,
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 160,
              height: 240,
              color: ProfessionalTheme.surfaceCard,
              child: Icon(
                Icons.broken_image,
                color: ProfessionalTheme.textTertiary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                sport.title,
                style: ProfessionalTheme.headlineMedium(
                  color: ProfessionalTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Rating
              if (sport.rating != null && sport.rating! > 0) ...[
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${sport.rating}/10',
                      style: ProfessionalTheme.bodyLarge(
                        color: ProfessionalTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Type
              _InfoRow(
                icon: Icons.sports_soccer,
                label: 'النوع',
                value: 'رياضة',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final SportModel sport;

  const _DetailsSection({required this.sport});

  @override
  Widget build(BuildContext context) {
    final description = sport.description ?? '';
    if (description.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('نبذة عن المحتوى الرياضي'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ProfessionalTheme.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ProfessionalTheme.surfaceColor,
            ),
          ),
          child: Text(
            description,
            style: ProfessionalTheme.bodyLarge(
              color: ProfessionalTheme.textSecondary,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}

class _MetadataSection extends StatelessWidget {
  final SportModel sport;

  const _MetadataSection({required this.sport});

  @override
  Widget build(BuildContext context) {
    final metadata = <Map<String, String>>[];

    if (sport.rating != null) {
      metadata.add({'icon': 'star', 'label': 'التقييم', 'value': sport.rating!.toString()});
    }
    if (sport.releaseYear != null) {
      metadata.add({'icon': 'date_range', 'label': 'سنة الإصدار', 'value': sport.releaseYear!.toString()});
    }

    if (metadata.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('معلومات إضافية'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ProfessionalTheme.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ProfessionalTheme.surfaceColor,
            ),
          ),
          child: Column(
            children: metadata.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _InfoRow(
                icon: _getIconData(item['icon']!),
                label: item['label']!,
                value: item['value']!,
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'category': return Icons.category;
      case 'tag': return Icons.tag;
      default: return Icons.info;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: ProfessionalTheme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: ProfessionalTheme.headlineSmall(
            color: ProfessionalTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: ProfessionalTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: ProfessionalTheme.bodyMedium(
            color: ProfessionalTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
