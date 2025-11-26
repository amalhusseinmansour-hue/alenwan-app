// lib/views/series/series_details_screen.dart
import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

import '../../models/series_model.dart';
import '../../models/episode_model.dart';
import '../../core/services/series_service.dart';
import '../../common/video_player_screen.dart';
import '../../core/theme/professional_theme.dart';

/// ============================================================
/// SeriesDetailsScreen (Main)
/// ============================================================
class SeriesDetailsScreen extends StatefulWidget {
  final int seriesId;
  const SeriesDetailsScreen({super.key, required this.seriesId});

  @override
  State<SeriesDetailsScreen> createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends State<SeriesDetailsScreen>
    with TickerProviderStateMixin {
  static const double _kTabSafeGap = 92.0;
  static const Color primaryColor = Color(0xFFA20136);
  static const Color secondaryColor = Color(0xFF6B0024);

  late final SeriesService _service;
  late final String _origin;
  late Future<SeriesModel> _seriesFuture;

  VideoPlayerController? _bgCtr;
  String? _playingLabel;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _filmReelController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _filmReelAnimation;

  @override
  void initState() {
    super.initState();
    _service = SeriesService();
    _origin = Uri.parse(_service.baseUrl).origin;
    _seriesFuture = _service.fetchSeriesDetails(widget.seriesId);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _filmReelController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _filmReelAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _filmReelController, curve: Curves.linear),
    );

    _fadeController.forward();
    _scaleController.forward();
    _filmReelController.repeat();
  }

  @override
  void dispose() {
    _bgCtr?.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _filmReelController.dispose();
    super.dispose();
  }

  /// ================= Helpers =================
  String _fullMedia(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return path.startsWith('/') ? '$_origin$path' : '$_origin/$path';
  }

  bool _isDirectPlayable(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.mp4') || u.contains('.m3u8');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _playBackground(String url, {String? label}) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return;

      await _bgCtr?.pause();
      _bgCtr?.dispose();

      final ctr = VideoPlayerController.networkUrl(uri);
      await ctr.initialize();
      await ctr.setLooping(true);
      await ctr.setVolume(0.0);
      await ctr.play();

      if (!mounted) return;
      setState(() {
        _bgCtr = ctr;
        _playingLabel = label;
      });
    } catch (_) {}
  }

  Future<void> _ensureInitialBackground(SeriesModel series) async {
    if (_bgCtr != null || series.episodes.isEmpty) return;
    final ep = series.episodes.first;
    final url = _fullMedia(ep.videoUrl);
    if (url.isNotEmpty && _isDirectPlayable(url)) {
      await _playBackground(url, label: ep.title);
    }
  }

  void _openEpisodeFullScreen(EpisodeModel ep, SeriesModel series) {
    final url = _fullMedia(ep.videoUrl);
    if (url.isEmpty || !_isDirectPlayable(url)) {
      _showError('لا يوجد رابط فيديو مباشر قابل للتشغيل لهذه الحلقة');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          url: url,
          title: ep.title.isNotEmpty
              ? ep.title
              : (series.titleAr ?? series.titleEn),
          audioDubs: const [],
        ),
        fullscreenDialog: true,
      ),
    );
  }

  double _heroHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1700) return 820;
    if (w >= 1500) return 760;
    if (w >= 1300) return 700;
    if (w >= 1100) return 660;
    if (w >= 900) return 620;
    if (w >= 700) return 580;
    return 540; // موبايل
  }

  /// ================= Build =================
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SeriesModel>(
      future: _seriesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }
        if (snap.hasError) {
          return _ErrorScreen(error: snap.error.toString());
        }
        if (!snap.hasData) {
          return const _ErrorScreen(error: 'لا توجد بيانات');
        }

        final series = snap.data!;
        _ensureInitialBackground(series);

        final title = series.titleAr ?? series.titleEn;
        final desc = series.description ?? '';
        final poster = _fullMedia(series.thumbnail ?? series.coverImage);

        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    backgroundColor: Colors.black,
                    body: Stack(
                      children: [
                        // Animated background
                        Positioned.fill(
                          child: CustomPaint(
                            painter: SeriesDetailsPainter(
                              animation: _filmReelAnimation,
                              primaryColor: primaryColor,
                              secondaryColor: secondaryColor,
                            ),
                          ),
                        ),
                        // Main content
                        NestedScrollView(
                          headerSliverBuilder: (_, __) => [
                            SliverAppBar(
                              backgroundColor: Colors.transparent,
                              pinned: true,
                              expandedHeight:
                                  _heroHeight(context) + _kTabSafeGap,
                              titleTextStyle: ProfessionalTheme.body1(
                                context: context,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              title:
                                  Text(title, overflow: TextOverflow.ellipsis),
                              flexibleSpace: FlexibleSpaceBar(
                                background: _HeroBackground(
                                  controller: _bgCtr,
                                  posterUrl: poster,
                                  playingLabel: _playingLabel,
                                  title: title,
                                  episodesCount: series.episodes.length,
                                  bottomSafe: _kTabSafeGap,
                                  scaleAnimation: _scaleAnimation,
                                  onWatchNow: () => _openEpisodeFullScreen(
                                    series.episodes.first,
                                    series,
                                  ),
                                ),
                              ),
                              bottom: const PreferredSize(
                                preferredSize: Size.fromHeight(46),
                                child: _TabsBar(),
                              ),
                            ),
                          ],
                          body: TabBarView(
                            children: [
                              _EpisodesTab(
                                episodes: series.episodes,
                                full: _fullMedia,
                                onPlay: (ep) =>
                                    _openEpisodeFullScreen(ep, series),
                              ),
                              const _RelatedTab(),
                              _MoreInfoTab(description: desc),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ============================================================
/// Sub Widgets (kept in same file for clarity)
/// ============================================================
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
}

class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'حدث خطأ: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
}

class _TabsBar extends StatelessWidget {
  const _TabsBar();
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: const Color(0xFFA20136).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: TabBar(
          isScrollable: true,
          indicatorColor: const Color(0xFFA20136),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: ProfessionalTheme.body1(
            context: context,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: ProfessionalTheme.body1(
            context: context,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'الحلقات'),
            Tab(text: 'ذات صلة'),
            Tab(text: 'المزيد من المعلومات'),
          ],
        ),
      );
}

class _HeroBackground extends StatelessWidget {
  final VideoPlayerController? controller;
  final String posterUrl;
  final String? playingLabel;
  final String title;
  final int episodesCount;
  final double bottomSafe;
  final Animation<double> scaleAnimation;
  final VoidCallback onWatchNow;

  const _HeroBackground({
    required this.controller,
    required this.posterUrl,
    required this.playingLabel,
    required this.title,
    required this.episodesCount,
    required this.bottomSafe,
    required this.scaleAnimation,
    required this.onWatchNow,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 1000;

    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Background video/image with scale animation
            Transform.scale(
              scale: scaleAnimation.value,
              child: _CoveringMedia(
                  controller: controller, fallbackUrl: posterUrl),
            ),
            // Glass morphism overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, .4, 1],
                ),
              ),
            ),
            // Glass effect overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(
                color: const Color(0xFFA20136).withValues(alpha: 0.1),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 20, 18 + bottomSafe),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? w * .46 : w * .92,
                    ),
                    child: _HeroTexts(
                      title: title,
                      episodesCount: episodesCount,
                      isWide: isWide,
                      subtitle: playingLabel,
                      onWatchNow: onWatchNow,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CoveringMedia extends StatelessWidget {
  final VideoPlayerController? controller;
  final String fallbackUrl;
  const _CoveringMedia({required this.controller, required this.fallbackUrl});

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return CachedNetworkImage(
        imageUrl: fallbackUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: const Color(0xFF101010)),
        errorWidget: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white38),
        ),
      );
    }
    return VideoPlayer(controller!);
  }
}

class _HeroTexts extends StatelessWidget {
  final String title;
  final int episodesCount;
  final bool isWide;
  final String? subtitle;
  final VoidCallback onWatchNow;
  const _HeroTexts({
    required this.title,
    required this.episodesCount,
    required this.isWide,
    this.subtitle,
    required this.onWatchNow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: ProfessionalTheme.body1(
            context: context,
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: isWide ? 30 : 24,
            height: 1.2,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              subtitle!,
              style: ProfessionalTheme.body1(
                context: context,
                color: Colors.white70,
              ),
            ),
          ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [Color(0xFFA20136), Color(0xFF6B0024)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA20136).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onWatchNow,
                icon: const Icon(Icons.play_arrow),
                label: Text('شاهد الآن',
                    style: ProfessionalTheme.body1(
                        context: context, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFA20136), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: Text('قائمة المشاهدة',
                        style: ProfessionalTheme.body1(context: context)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      foregroundColor: Colors.white,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EpisodesTab extends StatelessWidget {
  final List<EpisodeModel> episodes;
  final String Function(String? path) full;
  final void Function(EpisodeModel ep) onPlay;
  const _EpisodesTab({
    required this.episodes,
    required this.full,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    if (episodes.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد حلقات متاحة حالياً',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      itemCount: episodes.length,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (context, i) {
        final ep = episodes[i];
        final thumb = ep.posterUrl.isNotEmpty
            ? full(ep.posterUrl)
            : 'https://via.placeholder.com/640x360?text=Episode';
        final label = ep.title.isNotEmpty ? ep.title : 'الحلقة ${i + 1}';
        return _EpisodeCard(
          imageUrl: thumb,
          label: label,
          onTap: () => onPlay(ep),
        );
      },
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  final String imageUrl;
  final String label;
  final VoidCallback? onTap;
  const _EpisodeCard({required this.imageUrl, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFA20136).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: const Color(0xFF1A1A1A),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFA20136),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFF1A1A1A),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Color(0xFFA20136),
                        size: 48,
                      ),
                    ),
                  ),
                  // Glass morphism overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Play button overlay
                  const Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Color(0xFFA20136),
                      size: 40,
                    ),
                  ),
                  // Title
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ProfessionalTheme.body1(
                          context: context,
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RelatedTab extends StatelessWidget {
  const _RelatedTab();
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            'لا توجد عناصر ذات صلة حالياً',
            style: ProfessionalTheme.body1(
              context: context,
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
}

class _MoreInfoTab extends StatelessWidget {
  final String description;
  const _MoreInfoTab({required this.description});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFA20136).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            description.isEmpty ? 'لا يوجد وصف متاح' : description,
            style: ProfessionalTheme.body1(
              context: context,
              color: Colors.white70,
              height: 1.6,
              fontSize: 15,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      );
}

class SeriesDetailsPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;

  SeriesDetailsPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw animated film reels
    for (int i = 0; i < 3; i++) {
      final centerX = size.width * (0.2 + i * 0.3);
      final centerY = size.height * (0.3 + (i % 2) * 0.4);
      final radius = 30.0 + i * 10;

      // Film reel body
      paint.color = primaryColor.withValues(alpha: 0.1);
      canvas.drawCircle(Offset(centerX, centerY), radius, paint);

      // Film reel spokes
      paint.color = secondaryColor.withValues(alpha: 0.2);
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;

      for (int j = 0; j < 8; j++) {
        final angle = (animation.value * 2 * pi) + (j * pi / 4);
        final startX = centerX + (radius * 0.3) * cos(angle);
        final startY = centerY + (radius * 0.3) * sin(angle);
        final endX = centerX + (radius * 0.8) * cos(angle);
        final endY = centerY + (radius * 0.8) * sin(angle);

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      }

      // Central hub
      paint.style = PaintingStyle.fill;
      paint.color = primaryColor.withValues(alpha: 0.3);
      canvas.drawCircle(Offset(centerX, centerY), radius * 0.2, paint);
    }

    // Draw floating film strips
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final x = size.width * (0.1 + i * 0.2);
      final y = size.height * 0.6 + 20 * sin(animation.value * 2 * pi + i);

      paint.color = primaryColor.withValues(alpha: 0.1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 40, 8),
          const Radius.circular(4),
        ),
        paint,
      );

      // Film holes
      paint.color = secondaryColor.withValues(alpha: 0.2);
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(Offset(x + 8 + j * 12, y + 4), 2, paint);
      }
    }

    // Draw series-themed decorative elements
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    paint.color = primaryColor.withValues(alpha: 0.15);

    // TV/Monitor frames
    for (int i = 0; i < 2; i++) {
      final x = size.width * (0.15 + i * 0.7);
      final y = size.height * 0.8;
      final width = 60.0;
      final height = 40.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, width, height),
          const Radius.circular(8),
        ),
        paint,
      );

      // Screen glow effect
      paint.style = PaintingStyle.fill;
      paint.color = primaryColor.withValues(
          alpha: 0.05 * (1 + sin(animation.value * 3 + i)));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 5, y + 5, width - 10, height - 10),
          const Radius.circular(4),
        ),
        paint,
      );
      paint.style = PaintingStyle.stroke;
    }
  }

  @override
  bool shouldRepaint(covariant SeriesDetailsPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
