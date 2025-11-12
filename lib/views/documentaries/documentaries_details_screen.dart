// lib/views/documentaries/documentary_details_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/documentary_model.dart';
import '../../core/services/documentary_service.dart';
import '../../core/services/dub_service.dart';
import '../../common/video_player_screen.dart';
import '../../core/utils/url_utils.dart';
import '../../core/theme/professional_theme.dart';

class DocumentaryDetailsScreen extends StatefulWidget {
  final int documentaryId;
  const DocumentaryDetailsScreen({super.key, required this.documentaryId});

  @override
  State<DocumentaryDetailsScreen> createState() =>
      _DocumentaryDetailsScreenState();
}

class _DocumentaryDetailsScreenState extends State<DocumentaryDetailsScreen> {
  final _service = DocumentaryService();
  final _dubService = DubService();

  Documentary? _doc;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final d = await _service.fetchDocumentaryDetails(widget.documentaryId);
      if (!mounted) return;
      setState(() {
        _doc = d;
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

  String _bestPlayable(Documentary d) {
    final raw = d.videoPath.trim();
    final hls = (d.playback?['hls'] ?? '').toString().trim();
    final mp4 = (d.playback?['mp4'] ?? '').toString().trim();
    final candidates = kIsWeb ? [mp4, raw, hls] : [hls, mp4, raw];
    return candidates.firstWhere((u) => u.isNotEmpty, orElse: () => '');
  }

  void _play(Documentary doc) {
    final url = _bestPlayable(doc);
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا يوجد فيديو متاح')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          url: UrlUtils.normalize(url),
          title: doc.title,
          audioDubs: const [],
          dubLoader: () => _dubService.list(type: 'documentary', id: doc.id),
        ),
      ),
    );
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

    if (_doc == null) {
      return Scaffold(
        backgroundColor: ProfessionalTheme.backgroundColor,
        body: Center(
          child: Text(
            'تعذر تحميل الوثائقي',
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.errorColor,
            ),
          ),
        ),
      );
    }

    final doc = _doc!;
    final banner = UrlUtils.normalize(
      doc.bannerPath.isNotEmpty ? doc.bannerPath : doc.posterPath,
    );
    final poster = UrlUtils.normalize(
      doc.posterPath.isNotEmpty ? doc.posterPath : doc.bannerPath,
    );
    final hasVideo = _bestPlayable(doc).isNotEmpty;

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
                  title: doc.title,
                  description: doc.description,
                  hasVideo: hasVideo,
                  onPlay: () => _play(doc),
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
                _InfoSection(doc: doc, posterUrl: poster),
                const SizedBox(height: 32),
                _DetailsSection(doc: doc),
                const SizedBox(height: 32),
                _MetadataSection(doc: doc),
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
  final Documentary doc;
  final String posterUrl;

  const _InfoSection({
    required this.doc,
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
                doc.title,
                style: ProfessionalTheme.headlineMedium(
                  color: ProfessionalTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Rating
              if (doc.rating > 0) ...[
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${doc.rating}/10',
                      style: ProfessionalTheme.bodyLarge(
                        color: ProfessionalTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Release Year
              if (doc.releaseYear != 0) ...[
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'سنة الإصدار',
                  value: doc.releaseYear.toString(),
                ),
                const SizedBox(height: 12),
              ],

              // Type
              _InfoRow(
                icon: Icons.movie,
                label: 'النوع',
                value: 'وثائقي',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final Documentary doc;

  const _DetailsSection({required this.doc});

  @override
  Widget build(BuildContext context) {
    if (doc.description.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('نبذة عن الوثائقي'),
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
            doc.description,
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
  final Documentary doc;

  const _MetadataSection({required this.doc});

  @override
  Widget build(BuildContext context) {
    final metadata = <Map<String, String>>[];

    if (doc.presenter != null && doc.presenter!.isNotEmpty) {
      metadata.add({'icon': 'person', 'label': 'المقدّم', 'value': doc.presenter!});
    }
    if (doc.director != null && doc.director!.isNotEmpty) {
      metadata.add({'icon': 'movie_creation', 'label': 'المخرج', 'value': doc.director!});
    }
    if (doc.producer != null && doc.producer!.isNotEmpty) {
      metadata.add({'icon': 'business', 'label': 'المنتج', 'value': doc.producer!});
    }

    if (metadata.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('فريق العمل'),
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
      case 'person': return Icons.person;
      case 'movie_creation': return Icons.movie_creation;
      case 'business': return Icons.business;
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
