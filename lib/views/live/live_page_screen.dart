import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:alenwan/controllers/live_controller.dart';
import 'package:alenwan/controllers/channel_controller.dart';
import 'package:alenwan/models/live_stream_model.dart';
import 'package:alenwan/models/channel_model.dart';
import 'package:alenwan/routes/app_routes.dart';
import 'package:alenwan/core/services/api_client.dart';
import 'package:alenwan/core/theme/professional_theme.dart';
import 'package:alenwan/widgets/common_app_bar.dart';

class LivePageScreen extends StatefulWidget {
  const LivePageScreen({super.key});

  @override
  State<LivePageScreen> createState() => _LivePageScreenState();
}

class _LivePageScreenState extends State<LivePageScreen> {
  int _currentBanner = 0;

  static const kPlaceholderBig =
      'https://via.placeholder.com/500x300.png?text=No+Thumbnail';
  static const kPlaceholderSmall =
      'https://via.placeholder.com/200x120.png?text=No+Thumbnail';

  // ===== Helpers =====
  String _tr(String key, String fallback) {
    final t = key.tr();
    return t == key ? fallback : t;
  }

  String _fullFromServer(String path) {
    var p = path.trim();
    if (p.startsWith('http')) return p;
    if (p.startsWith('/')) p = p.substring(1);
    if (!p.startsWith('storage/')) p = 'storage/$p';
    final base = ApiClient().filesBaseUrl;
    return '$base/$p';
  }

  String _bestThumb(LiveStreamModel s, {bool small = false}) {
    final thumb = s.thumbnail.trim();

    // ✅ تجاهل الـ default placeholder من السيرفر
    if (thumb.isNotEmpty &&
        thumb != 'default_youtube_thumbnail.jpg' &&
        thumb.startsWith('http')) {
      return thumb;
    }

    if (thumb.isNotEmpty && thumb != 'default_youtube_thumbnail.jpg') {
      return _fullFromServer(thumb);
    }

    // ✅ لو المصدر يوتيوب: اعرض صورة اليوتيوب
    if (s.sourceType.toLowerCase() == 'youtube') {
      final url = s.videoUrl?.isNotEmpty == true ? s.videoUrl! : s.streamUrl;
      final id = _youtubeIdFromUrl(url);
      if (id != null) {
        return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
      }
    }

    // ✅ fallback
    return small ? kPlaceholderSmall : kPlaceholderBig;
  }

  /// ✅ خلي نسخة واحدة من الدالة
  String? _youtubeIdFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final reg = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11})');
    final match = reg.firstMatch(url);
    return match?.group(1);
  }

  String _bestChannelThumb(ChannelModel c, {bool small = false}) {
    if (c.thumbnail.isNotEmpty) {
      return _fullFromServer(c.thumbnail);
    }
    return small ? kPlaceholderSmall : kPlaceholderBig;
  }

  int? _findChannelIdByName(List<ChannelModel> channels, String name) {
    final target = name.trim().toLowerCase();
    for (final ch in channels) {
      if (ch.name.trim().toLowerCase() == target) return ch.id;
    }
    return null;
  }

  DateTime? _safeParse(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  bool _isLiveNow(LiveStreamModel s, DateTime now) {
    if (s.startsAt.trim().isEmpty) return true;
    final dt = _safeParse(s.startsAt);
    if (dt == null) return true;
    return !dt.isAfter(now);
  }

  bool _isComingSoon(LiveStreamModel s, DateTime now) {
    if (s.startsAt.trim().isEmpty) return false;
    final dt = _safeParse(s.startsAt);
    if (dt == null) return false;
    return dt.isAfter(now);
  }

  String _formatStartsAt(String startsAt) {
    final dt = _safeParse(startsAt);
    if (dt == null) return '';
    final locale = context.locale.languageCode;
    final fmt = DateFormat('dd/MM • HH:mm', locale);
    return fmt.format(dt);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveController>().loadStreams();
      context.read<ChannelController>().loadChannels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalTheme.backgroundColor,
      appBar: CommonAppBar(
        title: 'البث المباشر',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: ProfessionalTheme.textPrimary,
            ),
            onPressed: () {
              context.read<LiveController>().loadStreams();
              context.read<ChannelController>().loadChannels();
            },
          ),
        ],
      ),
      body: Consumer2<LiveController, ChannelController>(
        builder: (context, liveC, chC, _) {
          final isLoading = liveC.isLoading || chC.isLoading;

          if (isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: ProfessionalTheme.primaryBrand,
              ),
            );
          }

          // Check for errors first
          if (liveC.error != null && liveC.error!.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: ProfessionalTheme.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ في تحميل البث المباشر',
                    style: ProfessionalTheme.bodyLarge(
                      color: ProfessionalTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    liveC.error!,
                    style: ProfessionalTheme.bodySmall(
                      color: ProfessionalTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<LiveController>().loadStreams();
                      context.read<ChannelController>().loadChannels();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfessionalTheme.primaryBrand,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final List<LiveStreamModel> streams = liveC.availableStreams;
          final List<ChannelModel> channels = chC.channels;

          if (streams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.live_tv_outlined,
                    size: 80,
                    color: ProfessionalTheme.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _tr('no_streams', 'لا يوجد بث مباشر حالياً'),
                    style: ProfessionalTheme.headlineSmall(
                      color: ProfessionalTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سيتم إضافة بثوث مباشرة قريباً',
                    style: ProfessionalTheme.bodyMedium(
                      color: ProfessionalTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<LiveController>().loadStreams();
                      context.read<ChannelController>().loadChannels();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('تحديث'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ProfessionalTheme.primaryBrand,
                      side: BorderSide(color: ProfessionalTheme.primaryBrand),
                    ),
                  ),
                ],
              ),
            );
          }

          final now = DateTime.now();

          final liveNowStreams =
              streams.where((s) => _isLiveNow(s, now)).toList();
          final comingSoonStreams =
              streams.where((s) => _isComingSoon(s, now)).toList();

          // خريطة: channelId -> أول بث مباشر
          final Map<int, LiveStreamModel> youtubeLiveByChannel = {};
          for (final s in liveNowStreams) {
            int? key = s.channelId;
            key ??= _findChannelIdByName(channels, s.channelName);
            if (key != null && !youtubeLiveByChannel.containsKey(key)) {
              youtubeLiveByChannel[key] = s;
            }
          }

          final Set<String> liveChannelNames = liveNowStreams
              .map((s) => s.channelName.trim().toLowerCase())
              .toSet();

          return RefreshIndicator(
            color: ProfessionalTheme.primaryBrand,
            backgroundColor: ProfessionalTheme.surfaceCard,
            onRefresh: () async {
              await Future.wait([liveC.loadStreams(), chC.loadChannels()]);
            },
            child: CustomScrollView(
              slivers: [
                _buildHeroCarousel(liveNowStreams),
                _buildCategorySliver(
                  _tr('live_now', 'بث مباشر'),
                  liveNowStreams,
                  liveC,
                  mode: _RowMode.live,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 6)),
                SliverToBoxAdapter(
                  child: _buildPopularChannels(
                    channels: channels,
                    liveChannelNames: liveChannelNames,
                    youtubeLiveByChannel: youtubeLiveByChannel,
                    controller: liveC,
                  ),
                ),
                _buildCategorySliver(
                  _tr('coming_soon', 'يعرض قريباً'),
                  comingSoonStreams,
                  liveC,
                  mode: _RowMode.comingSoon,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= Channels UI =================
  Widget _buildPopularChannels({
    required List<ChannelModel> channels,
    required Set<String> liveChannelNames,
    required Map<int, LiveStreamModel> youtubeLiveByChannel,
    required LiveController controller,
  }) {
    if (channels.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(text: _tr('popular_channels', 'القنوات الشائعة')),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: channels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final c = channels[index];
              final img = _bestChannelThumb(c, small: true);
              final showLiveDot = liveChannelNames.contains(
                c.name.trim().toLowerCase(),
              );
              final LiveStreamModel? liveForThisChannel =
                  youtubeLiveByChannel[c.id];

              return SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _openChannel(c),
                      child: Stack(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ProfessionalTheme.primaryBrand
                                    .withValues(alpha: 0.3),
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(img),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (showLiveDot)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ProfessionalTheme.surfaceCard,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.6),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _openChannel(c),
                      child: Text(
                        c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: ProfessionalTheme.labelMedium(
                          color: ProfessionalTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (liveForThisChannel != null) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () =>
                            _openStream(liveForThisChannel, controller),
                        child: _LiveThumbCard(
                          imageUrl: _bestThumb(liveForThisChannel, small: true),
                          badgeText: 'LIVE',
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= Hero Carousel =================
  SliverToBoxAdapter _buildHeroCarousel(List<LiveStreamModel> streams) {
    if (streams.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CarouselSlider.builder(
                itemCount: streams.length,
                itemBuilder: (context, index, realIndex) {
                  final s = streams[index];
                  final thumbnail = _bestThumb(s);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: thumbnail,
                        fit: BoxFit.cover,
                        placeholder: (c, _) =>
                            Container(color: ProfessionalTheme.surfaceCard),
                        errorWidget: (c, u, e) => Icon(
                          Icons.broken_image,
                          color: ProfessionalTheme.textTertiary,
                          size: 50,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              ProfessionalTheme.backgroundColor
                                  .withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 18,
                        child: Text(
                          s.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: ProfessionalTheme.headlineSmall(
                            color: Colors.white,
                          ).copyWith(
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                options: CarouselOptions(
                  height: 230,
                  viewportFraction: 1,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  onPageChanged: (index, _) =>
                      setState(() => _currentBanner = index),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(streams.length, (i) {
              final active = _currentBanner == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: active ? 20 : 6,
                decoration: BoxDecoration(
                  color: active
                      ? ProfessionalTheme.primaryBrand
                      : ProfessionalTheme.textTertiary,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'مباشر',
            style: ProfessionalTheme.labelSmall(
              color: Colors.white,
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewersChip(int viewers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ProfessionalTheme.backgroundColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility,
            size: 14,
            color: ProfessionalTheme.primaryBrand,
          ),
          const SizedBox(width: 4),
          Text(
            '$viewers مشاهدة',
            style: ProfessionalTheme.labelSmall(
              color: ProfessionalTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildCategorySliver(
    String title,
    List<LiveStreamModel> streams,
    LiveController controller, {
    required _RowMode mode,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(text: title),
          if (streams.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                mode == _RowMode.comingSoon
                    ? _tr('no_upcoming', 'لا يوجد بث قريب')
                    : _tr('no_live', 'لا يوجد بث مباشر حالياً'),
                style: ProfessionalTheme.bodyMedium(
                  color: ProfessionalTheme.textSecondary,
                ),
              ),
            )
          else
            SizedBox(
              height: 190,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: streams.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final s = streams[index];
                  final img = _bestThumb(s, small: true);

                  return GestureDetector(
                    onTap: () => _openStream(s, controller),
                    child: SizedBox(
                      width: 220,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: img,
                                  width: 220,
                                  height: 190,
                                  fit: BoxFit.cover,
                                  placeholder: (c, _) => Container(
                                      color: ProfessionalTheme.surfaceCard),
                                  errorWidget: (c, u, e) => Icon(
                                    Icons.broken_image,
                                    color: ProfessionalTheme.textTertiary,
                                    size: 40,
                                  ),
                                ),
                                Container(
                                  width: 220,
                                  height: 190,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        ProfessionalTheme.backgroundColor
                                            .withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 10,
                                  right: 10,
                                  bottom: 12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: ProfessionalTheme.titleMedium(
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          if (mode == _RowMode.live)
                                            _buildLiveBadge(),
                                          if (mode == _RowMode.live)
                                            const SizedBox(width: 8),
                                          _buildViewersChip(
                                            s.viewersCount ?? 0,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (mode == _RowMode.comingSoon)
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ProfessionalTheme.surfaceCard
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: ProfessionalTheme.primaryBrand
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 13,
                                      color: ProfessionalTheme.primaryBrand,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatStartsAt(s.startsAt),
                                      style: ProfessionalTheme.labelSmall(
                                        color: ProfessionalTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _openStream(LiveStreamModel stream, LiveController controller) {
    controller.setCurrentStream(stream);
    Navigator.pushNamed(
      context,
      AppRoutes.liveStreamDetails,
      arguments: stream,
    );
  }

  void _openChannel(ChannelModel channel) {
    Navigator.pushNamed(context, AppRoutes.channelDetails, arguments: channel);
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 8),
      child: Row(
        children: [
          Text(
            text,
            style: ProfessionalTheme.headlineSmall(
              color: ProfessionalTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              gradient: ProfessionalTheme.premiumGradient,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveThumbCard extends StatelessWidget {
  final String imageUrl;
  final String badgeText;
  const _LiveThumbCard({required this.imageUrl, required this.badgeText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              width: 120,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (c, _) => Container(
                color: ProfessionalTheme.surfaceCard,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ProfessionalTheme.primaryBrand,
                  ),
                ),
              ),
              errorWidget: (c, u, e) => Container(
                color: ProfessionalTheme.surfaceCard,
                child: Icon(
                  Icons.broken_image,
                  color: ProfessionalTheme.textTertiary,
                  size: 28,
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
                    ProfessionalTheme.backgroundColor.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      badgeText,
                      style: ProfessionalTheme.labelSmall(
                        color: Colors.white,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _RowMode { live, comingSoon }
