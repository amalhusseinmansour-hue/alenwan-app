import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alenwan/routes/app_routes.dart';

// خدمات
import 'package:alenwan/core/services/api_client.dart';
import 'package:alenwan/core/services/sport_service.dart';

// كنترولرز
import '../../controllers/platinum_controller.dart';
import '../../controllers/recent_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/live_controller.dart';
import '../../controllers/series_controller.dart';
import '../../controllers/sport_controller.dart';
import '../../controllers/documentary_controller.dart';
import '../../controllers/recommendation_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cartoon_controller.dart'; // 🟢 جديد

// ويدجتس
import 'video_banner.dart';
import 'shahid_hover_card.dart';
import '../../widgets/live_stream_carousel.dart';

/// =============================
/// Utilities
const String kPosterFallback = 'assets/images/placeholder_poster.png';

String normalizeImageUrl(String? path) {
  if (path == null || path.isEmpty) return kPosterFallback;
  var p = path.trim();
  if (p.startsWith('http')) {
    final filesBase = ApiClient().filesBaseUrl;
    final localhostRe = RegExp(r'^https?:\/\/(127\.0\.0\.1|localhost)(:\d+)?');
    if (localhostRe.hasMatch(p)) {
      final uri = Uri.parse(p);
      p = '$filesBase${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
    }
    return p.replaceAll(RegExp(r'-\d+x\d+(?=\.\w+$)'), '');
  }
  if (p.startsWith('/')) p = p.substring(1);
  if (!p.startsWith('storage/')) p = 'storage/$p';
  final base = ApiClient().filesBaseUrl;
  return '$base/$p';
}

String bestLiveThumb(dynamic s) {
  final thumb = s.thumbnail?.toString() ?? '';

  if (thumb.isNotEmpty && thumb != 'default_youtube_thumbnail.jpg') {
    return normalizeImageUrl(thumb);
  }

  if (s.sourceType != null &&
      s.sourceType.toString().toLowerCase() == 'youtube') {
    final url =
        s.videoUrl?.isNotEmpty == true ? s.videoUrl! : s.streamUrl ?? '';
    final id = _youtubeIdFromUrl(url);
    if (id != null) {
      return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
    }
  }

  return 'https://via.placeholder.com/300x200.png?text=No+Thumbnail';
}

String? _youtubeIdFromUrl(String url) {
  final reg = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11})');
  final match = reg.firstMatch(url);
  return match?.group(1);
}

String normalizeSportUrl(String? path) {
  final origin = Uri.parse(SportService().baseUrl).origin;
  if (path == null || path.isEmpty) {
    return 'https://via.placeholder.com/300x450';
  }
  var p = path.trim();
  if (p.startsWith('//')) p = 'https:$p';
  if (p.startsWith('http')) {
    return p.replaceFirst(
      RegExp(r'^https?:\/\/(127\.0\.0\.1|localhost)(:\d+)?'),
      origin,
    );
  }
  if (!p.startsWith('/')) p = '/$p';
  final normalized = p.startsWith('/storage/') ? p : '/storage$p';
  return '$origin$normalized';
}

class _CardDims {
  final double w;
  final double h;
  const _CardDims(this.w, this.h);
}

_CardDims _stdDims(BuildContext ctx) {
  final sw = MediaQuery.of(ctx).size.width;
  final cardW = (sw / 5.2).clamp(160, 220).toDouble();
  final cardH = cardW * 0.56;
  return _CardDims(cardW, cardH);
}

/// =============================
/// عنصر موحّد للعرض
class ContentItem {
  final int id;
  final String title;
  final String image;
  final String badge;
  final String type;
  final String? subtitle;

  ContentItem({
    required this.id,
    required this.title,
    required this.image,
    required this.badge,
    required this.type,
    this.subtitle,
  });
}

String translateType(String? type) {
  if (type == null || type.isEmpty) return '';
  return 'type_${type.toLowerCase()}'.tr();
}

class ContentRow extends StatelessWidget {
  final String title;
  final List<ContentItem> items;
  final void Function(ContentItem)? onTap;
  final void Function(ContentItem)? onFav;

  const ContentRow({
    super.key,
    required this.title,
    required this.items,
    this.onTap,
    this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    final dims = _stdDims(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'no_content_currently'.tr(),
              style: const TextStyle(color: Colors.white54),
            ),
          )
        else
          SizedBox(
            height: dims.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final it = items[i];
                final isFav = context.watch<FavoritesController>().isFavorite(
                      it.id,
                      it.type,
                    );

                return ShahidHoverCard(
                  width: dims.w,
                  height: dims.h,
                  imageUrl: it.image,
                  title: it.title,
                  badge: it.badge,
                  subtitle: (it.subtitle ?? '').isEmpty ? null : it.subtitle,
                  isFavorite: isFav,
                  onTap: () => onTap?.call(it),
                  onPlay: () => onTap?.call(it),
                  onFav: () => onFav?.call(it),
                  onDownload: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري التحميل...')),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// =============================
/// HomeContent
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlatinumController>().load();
      context.read<RecentController>().load();
      context.read<SeriesController>().loadSeries();
      context.read<SportController>().loadSports();
      context.read<DocumentaryController>().loadDocumentaries();
      context.read<CartoonController>().loadCartoons(); // 🟢 تحميل الكرتون
      context.read<LiveController>().loadStreams();

      final authC = context.read<AuthController>();
      final userId = authC.user?['id'];
      if (userId != null) {
        context.read<RecommendationController>().loadRecommendations(userId);
      }
    });
  }

  void _openContent(BuildContext context, ContentItem item) {
    switch (item.type) {
      case 'movie':
        Navigator.pushNamed(
          context,
          AppRoutes.movieDetails,
          arguments: item.id,
        );
        break;
      case 'series':
        Navigator.pushNamed(
          context,
          AppRoutes.seriesDetails,
          arguments: item.id,
        );
        break;
      case 'sport':
        Navigator.pushNamed(
          context,
          AppRoutes.sportDetails,
          arguments: item.id,
        );
        break;
      case 'documentary':
        Navigator.pushNamed(
          context,
          AppRoutes.documentaryDetails,
          arguments: item.id,
        );
        break;
      case 'cartoon': // 🟢 دعم الكرتون
        Navigator.pushNamed(
          context,
          AppRoutes.cartoonDetails,
          arguments: item.id,
        );
        break;
      case 'livestream':
        final liveC = context.read<LiveController>();
        final stream = liveC.availableStreams.firstWhere(
          (x) => x.id == item.id,
        );
        Navigator.pushNamed(
          context,
          AppRoutes.liveStreamDetails,
          arguments: stream,
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('نوع غير معروف: ${item.type}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final platinumC = context.watch<PlatinumController>();
    final recentC = context.watch<RecentController>();
    final seriesC = context.watch<SeriesController>();
    final sportC = context.watch<SportController>();
    final docC = context.watch<DocumentaryController>();
    final cartoonC = context.watch<CartoonController>(); // 🟢
    final liveC = context.watch<LiveController>();
    final recC = context.watch<RecommendationController>();

    return SingleChildScrollView(
      child: Column(
        children: [
          const VideoBanner(),

          // ✅ سلايدر البث المباشر
          if (liveC.availableStreams.isNotEmpty)
            LiveStreamCarousel(
              streams: liveC.availableStreams,
              onStreamTap: (stream) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.liveStreamDetails,
                  arguments: stream,
                );
              },
            ),

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF121212)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recC.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (recC.recommendations.isNotEmpty)
                  ContentRow(
                    title: '✨ اخترنا لك خصيصاً - مقترحاتنا المميزة',
                    items: recC.recommendations
                        .map(
                          (it) => ContentItem(
                            id: it['id'],
                            title: it['title'] ?? '',
                            image: normalizeImageUrl(
                              it['poster'] ?? it['posterUrl'] ?? '',
                            ),
                            badge: translateType(it['type']),
                            type: it['type'] ?? 'movie',
                          ),
                        )
                        .toList(),
                    onTap: (item) => _openContent(context, item),
                  ),

                // 🔴 البث المباشر - أولوية عالية
                if (liveC.availableStreams.isNotEmpty)
                  ContentRow(
                    title: '🔴 البث المباشر - شاهد الآن مباشرة',
                    items: liveC.availableStreams
                        .map(
                          (s) => ContentItem(
                            id: s.id,
                            title: s.title,
                            image: bestLiveThumb(s),
                            badge: 'مباشر',
                            type: 'livestream',
                          ),
                        )
                        .toList(),
                    onTap: (item) => _openContent(context, item),
                  ),

                // 💎 البلاتينيوم
                if (platinumC.platinumMovies.isNotEmpty)
                  ContentRow(
                    title: '💎 ${'platinum_exclusives'.tr()} - ${'vip_exclusive_content'.tr()}',
                    items: platinumC.platinumMovies
                        .map(
                          (m) => ContentItem(
                            id: m.id,
                            title: m.title,
                            image: normalizeImageUrl(m.posterUrl),
                            badge: 'vip'.tr().toUpperCase(),
                            type: 'movie',
                          ),
                        )
                        .toList(),
                    onTap: (item) => _openContent(context, item),
                  ),

                // 📺 البرامج
                ContentRow(
                  title: '📺 البرامج الحصرية - برامج ترفيهية وثقافية',
                  items: recentC.items
                      .where((it) => it.type == 'program')
                      .map(
                        (it) => ContentItem(
                          id: it.id,
                          title: it.title,
                          image: normalizeImageUrl(it.posterUrl ?? it.image),
                          badge: 'برنامج',
                          type: it.type,
                        ),
                      )
                      .toList(),
                  onTap: (item) => _openContent(context, item),
                ),

                // 🎬 المسلسلات
                if (seriesC.series.isNotEmpty)
                  ContentRow(
                    title: '🎬 المسلسلات المشوقة - أحدث الحلقات',
                    items: seriesC.series
                        .map(
                          (s) => ContentItem(
                            id: s.id,
                            title: s.titleAr ?? s.titleEn,
                            image: normalizeImageUrl(s.thumbnail),
                            badge: 'مسلسل',
                            type: 'series',
                          ),
                        )
                        .toList(),
                    onTap: (item) => _openContent(context, item),
                  ),

                // 🎙️ البودكاست
                ContentRow(
                  title: '🎙️ البودكاست - استمع إلى محتوى صوتي ملهم',
                  items: recentC.items
                      .where((it) => it.type == 'podcast')
                      .map(
                        (it) => ContentItem(
                          id: it.id,
                          title: it.title,
                          image: normalizeImageUrl(it.posterUrl ?? it.image),
                          badge: 'بودكاست',
                          type: it.type,
                        ),
                      )
                      .toList(),
                  onTap: (item) => _openContent(context, item),
                ),

                // ⚽ الرياضة
                if (sportC.sports.isNotEmpty)
                  ContentRow(
                    title: '⚽ الرياضة - مباريات وأحداث رياضية حصرية',
                    items: sportC.sports
                        .map(
                          (s) => ContentItem(
                            id: s.id,
                            title: s.title,
                            image: normalizeSportUrl(s.posterUrl),
                            badge: 'رياضة',
                            type: 'sport',
                          ),
                        )
                        .toList(),
                    onTap: (item) => _openContent(context, item),
                  ),

                // 🏆 أكاديمية IFBB
                ContentRow(
                  title: '🏆 أكاديمية IFBB - تدريبات كمال الأجسام المحترفة',
                  items: recentC.items
                      .where((it) => it.type == 'ifbb_academy' || it.title.toLowerCase().contains('ifbb'))
                      .map(
                        (it) => ContentItem(
                          id: it.id,
                          title: it.title,
                          image: normalizeImageUrl(it.posterUrl ?? it.image),
                          badge: 'IFBB',
                          type: it.type,
                        ),
                      )
                      .toList(),
                  onTap: (item) => _openContent(context, item),
                ),

                // 🎪 الفعاليات والمهرجانات
                ContentRow(
                  title: '🎪 الفعاليات والمهرجانات - أهم الأحداث العالمية',
                  items: recentC.items
                      .where((it) => it.type == 'event' || it.type == 'festival')
                      .map(
                        (it) => ContentItem(
                          id: it.id,
                          title: it.title,
                          image: normalizeImageUrl(it.posterUrl ?? it.image),
                          badge: it.type == 'festival' ? 'مهرجان' : 'فعالية',
                          type: it.type,
                        ),
                      )
                      .toList(),
                  onTap: (item) => _openContent(context, item),
                ),

                // 🎨 الكرتون
                if (cartoonC.cartoons.isNotEmpty)
                  ContentRow(
                    title: '🎨 عالم الكرتون - أجمل أفلام الأطفال',
                    items: cartoonC.cartoons
                        .map(
                          (c) => ContentItem(
                            id: c.id,
                            title: c.title,
                            image: normalizeImageUrl(c.posterPath),
                            badge: 'كرتون',
                            type: 'cartoon',
                          ),
                        )
                        .toList(),
                    onTap: (item) => _openContent(context, item),
                  ),

                // 🎥 الأفلام الوثائقية
                if (docC.documentaries.isNotEmpty)
                  ContentRow(
                    title: '🎥 الأفلام الوثائقية - رحلات ومعرفة',
                    items: docC.documentaries
                        .map(
                          (d) => ContentItem(
                            id: d.id,
                            title: d.title,
                            image: normalizeImageUrl(d.posterPath),
                            badge: 'وثائقي',
                            type: 'documentary',
                          ),
                        )
                        .toList(),
                    onTap: (item) => _openContent(context, item),
                  ),

                // ⭐ جديد على المنصة
                if (recentC.items.isNotEmpty)
                  ContentRow(
                    title: '⭐ جديد على المنصة - أحدث الإصدارات',
                    items: recentC.items
                        .map(
                          (it) => ContentItem(
                            id: it.id,
                            title: it.title,
                            image: normalizeImageUrl(it.posterUrl ?? it.image),
                            badge: translateType(it.type),
                            type: it.type,
                          ),
                        )
                        .toList(),
                    onTap: (item) => _openContent(context, item),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
