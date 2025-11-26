import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../config.dart';
import '../../routes/app_routes.dart';
import '../../controllers/series_controller.dart';
import '../../models/series_model.dart';
import '../../core/theme/professional_theme.dart';

/// =============================
/// HoverMediaCard (Card Component)
class HoverMediaCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double gap;

  const HoverMediaCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.width,
    required this.height,
    this.onTap,
    this.gap = 16.0,
  });

  @override
  State<HoverMediaCard> createState() => _HoverMediaCardState();
}

class _HoverMediaCardState extends State<HoverMediaCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final transform =
        // ignore: deprecated_member_use
        _hover ? (Matrix4.identity()..scale(1.06)) : Matrix4.identity();

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        margin: EdgeInsets.symmetric(horizontal: widget.gap / 2),
        transform: transform,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    height: widget.height,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: widget.height,
                      color: ProfessionalTheme.surfaceCard,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ProfessionalTheme.primaryColor,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: widget.height,
                      color: ProfessionalTheme.surfaceCard,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image,
                        color: ProfessionalTheme.textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: ProfessionalTheme.labelMedium(
                      color: ProfessionalTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =============================
/// SeriesContent (Main Screen Section)
class SeriesContent extends StatelessWidget {
  const SeriesContent({super.key});

  List<SeriesModel> _getDemoSeries() {
    return [
      SeriesModel(
        id: 1,
        titleEn: 'Breaking Bad',
        titleAr: 'بريكنج باد',
        thumbnail: 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',
        description: 'مسلسل دراما جريمة أمريكي',
      ),
      SeriesModel(
        id: 2,
        titleEn: 'Game of Thrones',
        titleAr: 'صراع العروش',
        thumbnail: 'https://image.tmdb.org/t/p/w500/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
        description: 'مسلسل فانتازيا ملحمي',
      ),
      SeriesModel(
        id: 3,
        titleEn: 'The Last of Us',
        titleAr: 'آخرنا',
        thumbnail: 'https://image.tmdb.org/t/p/w500/uKvVjHNqB5VmOrdxqAt2F7J78ED.jpg',
        description: 'مسلسل رعب ودراما',
      ),
      SeriesModel(
        id: 4,
        titleEn: 'The Witcher',
        titleAr: 'الساحر',
        thumbnail: 'https://image.tmdb.org/t/p/w500/7vjaCdMw15FEbXyLQTVa04URsPm.jpg',
        description: 'مسلسل فانتازيا ومغامرات',
      ),
      SeriesModel(
        id: 5,
        titleEn: 'Stranger Things',
        titleAr: 'أشياء غريبة',
        thumbnail: 'https://image.tmdb.org/t/p/w500/x2LSRK2Cm7MZhjluni1msVJ3wDF.jpg',
        description: 'مسلسل خيال علمي ورعب',
      ),
      SeriesModel(
        id: 6,
        titleEn: 'Peaky Blinders',
        titleAr: 'بيكي بلايندرز',
        thumbnail: 'https://image.tmdb.org/t/p/w500/vUUqzWa2LnHIVqkaKVlVGkVcZIW.jpg',
        description: 'مسلسل دراما جريمة بريطاني',
      ),
    ];
  }

  String _normalizeImage(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/300x450?text=No+Image';
    }
    if (path.startsWith('http')) return path;
    if (path.startsWith('/storage') || path.startsWith('storage/')) {
      return '${AppConfig.domain}/$path';
    }
    return '${AppConfig.storageBaseUrl}/$path';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SeriesController>(
      builder: (context, controller, _) {
        if (controller.isLoadingList) {
          return Center(
            child: CircularProgressIndicator(
              color: ProfessionalTheme.primaryColor,
            ),
          );
        }
        if (controller.error != null) {
          return Center(
            child: Text(
              'حدث خطأ: ${controller.error}',
              style: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.errorColor,
              ),
            ),
          );
        }
        // Use demo data if no real data is available
        final displaySeries = controller.series.isNotEmpty
            ? controller.series
            : _getDemoSeries();

        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final double hPad = w >= 1400
                ? 32.0
                : w >= 1100
                    ? 24.0
                    : 16.0;
            final double gap = w >= 1200
                ? 18.0
                : w >= 900
                    ? 16.0
                    : 14.0;

            int cols;
            if (w >= 1600) {
              cols = 7;
            } else if (w >= 1400)
              // ignore: curly_braces_in_flow_control_structures
              cols = 6;
            else if (w >= 1200)
              // ignore: curly_braces_in_flow_control_structures
              cols = 5;
            else if (w >= 900)
              // ignore: curly_braces_in_flow_control_structures
              cols = 4;
            else if (w >= 700)
              // ignore: curly_braces_in_flow_control_structures
              cols = 3;
            else
              // ignore: curly_braces_in_flow_control_structures
              cols = 2;

            final double innerWidth = w - (hPad * 2);
            final double cardW = (innerWidth - (gap * (cols - 1))) / cols;
            final double cardH = cardW * 1.46;
            final double sliderHeight = (cardH * 1.08) + 48;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SeriesSection(
                    title: 'إصدارات جديدة',
                    items: displaySeries,
                    cardW: cardW,
                    cardH: cardH,
                    gap: gap,
                    sliderHeight: sliderHeight,
                    normalizeImage: _normalizeImage,
                  ),
                  SeriesSection(
                    title: 'دراما تركية لا تفوّت',
                    items: displaySeries.reversed.toList(),
                    cardW: cardW,
                    cardH: cardH,
                    gap: gap,
                    sliderHeight: sliderHeight,
                    normalizeImage: _normalizeImage,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class SeriesSection extends StatelessWidget {
  final String title;
  final List<SeriesModel> items;
  final double cardW;
  final double cardH;
  final double gap;
  final double sliderHeight;
  final String Function(String?) normalizeImage;

  const SeriesSection({
    super.key,
    required this.title,
    required this.items,
    required this.cardW,
    required this.cardH,
    required this.gap,
    required this.sliderHeight,
    required this.normalizeImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(title),
          const SizedBox(height: 12),
          SizedBox(
            height: sliderHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(width: gap),
              itemBuilder: (context, i) {
                final s = items[i];
                final img = normalizeImage(s.thumbnail ?? s.coverImage);
                final t = s.titleAr ?? s.titleEn;
                return HoverMediaCard(
                  imageUrl: img,
                  title: t,
                  width: cardW,
                  height: cardH,
                  gap: gap,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.seriesDetails,
                    arguments: s.id,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: ProfessionalTheme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
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
