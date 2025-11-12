import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:math' as math;
import 'package:alenwan/core/utils/url_utils.dart' show UrlUtils;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/movie_model.dart';
import '../../routes/app_routes.dart';
import '../../controllers/movie_controller.dart';
import '../../controllers/subscription_controller.dart';
import '../../core/services/movie_service.dart';
import '../../core/services/dub_service.dart';
import '../../common/video_player_screen.dart';
import '../../core/widgets/subscription_guard.dart';
import '../../core/security/simple_video_protection.dart';
import '../../core/theme/professional_theme.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/watchlist_controller.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int? movieId;
  final MovieModel? movie;

  const MovieDetailsScreen({super.key, this.movieId, this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen>
    with TickerProviderStateMixin {
  final _movieService = MovieService();
  late final DubService _dubService = DubService();

  MovieModel? _movie;
  String? _err;
  bool _loading = true;

  // Controllers for favorites and watchlist
  late FavoritesController _favoritesController;
  late WatchlistController _watchlistController;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  // Theme colors
  static const Color primaryColor = Color(0xFFA20136);
  static const Color secondaryColor = Color(0xFF6B0024);
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();

    // Initialize favorites and watchlist controllers
    _favoritesController = FavoritesController();
    _watchlistController = WatchlistController();
    _watchlistController.initialize();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
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
    _floatingAnimation = CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
    _scaleController.forward();
    _floatingController.repeat(reverse: true);

    if (widget.movie != null) {
      _movie = widget.movie!;
      _loading = false;
    } else if (widget.movieId != null) {
      _loading = true;
    } else {
      _err = 'لم يتم تمرير بيانات الفيلم أو معرفه';
      _loading = false;
    }

    _loadDetailsIfNeeded();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _loadDetailsIfNeeded() async {
    if (widget.movieId == null || _movie != null) return;
    try {
      final m = await _movieService.fetchMovieDetails(widget.movieId!);
      if (!mounted) return;
      setState(() {
        _movie = m;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e.toString();
        _loading = false;
      });
    }
  }

  String _full(String? path) {
    return UrlUtils.normalize(path);
  }

  String _bestUrlFromPlayback({
    required String? raw,
    required Map<String, dynamic>? playback,
  }) {
    final hls = (playback?['hls'] ?? '').toString().trim();
    final mp4 = (playback?['mp4'] ?? '').toString().trim();

    if (hls.isEmpty && mp4.isEmpty && (raw?.isNotEmpty ?? false)) {
      return raw!;
    }

    final chosen = kIsWeb
        ? [mp4, raw, hls].firstWhere((u) => u!.isNotEmpty, orElse: () => '')
        : [hls, mp4, raw].firstWhere((u) => u!.isNotEmpty, orElse: () => '');

    return _full(chosen);
  }

  String _bestPlayable(MovieModel m) {
    return _bestUrlFromPlayback(raw: m.videoPath, playback: m.playback);
  }

  Future<void> _openFullScreen(MovieModel movie) async {
    // Check subscription status first
    final subController = context.read<SubscriptionController>();
    if (!subController.hasActive) {
      // Navigate to subscription screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubscriptionGuard(
            contentType: 'movie',
            allowPreview: false,
            child: Container(), // This won't be shown
          ),
        ),
      );
      return;
    }

    // Enable video protection before playing
    final protection = SimpleVideoProtection();
    await protection.enableProtection();

    // Get secure URL from backend
    String? secureUrl = await protection.getSecureVideoUrl(movie.id);

    final url = secureUrl ?? _bestPlayable(movie);
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد مسار فيديو لهذا العنوان')),
      );
      return;
    }

    List<Map<String, dynamic>> payloadDubs = [];
    try {
      final pb = movie.playback;
      if (pb != null) {
        final audioDubs = pb['audio_dubs'];
        if (audioDubs is List) {
          payloadDubs = audioDubs.map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            return {
              'label': (m['label'] ?? m['lang'] ?? '').toString(),
              'lang': (m['lang'] ?? '').toString(),
              'status': (m['status'] ?? 'ready').toString(),
              'hls': (m['url'] ?? m['hls'] ?? '').toString(),
              'mp4': (m['mp4_url'] ?? '').toString(),
            };
          }).toList();
        }
      }
    } catch (_) {}

    List<Map<String, dynamic>> apiDubs = [];
    try {
      apiDubs = await _dubService.list(type: 'movie', id: movie.id);
    } catch (e) {
      debugPrint("Error: $e");
    }

    Map<String, Map<String, dynamic>> merged = {};
    List<Map<String, dynamic>> normalize(List<Map<String, dynamic>> items) =>
        items.map((e) {
          final hls = (e['hls'] ?? e['url'] ?? '').toString();
          final mp4 = (e['mp4'] ?? e['mp4_url'] ?? '').toString();
          return {
            'label': (e['label'] ?? e['lang'] ?? '').toString(),
            'lang': (e['lang'] ?? '').toString(),
            'status': (e['status'] ?? 'ready').toString(),
            'hls': _full(hls),
            'mp4': _full(mp4),
          };
        }).toList();

    for (final d in normalize(payloadDubs)) {
      final key = (d['lang']!.isNotEmpty ? d['lang'] : d['label']).toString();
      if (key.isNotEmpty) merged[key] = d;
    }
    for (final d in normalize(apiDubs)) {
      final key = (d['lang']!.isNotEmpty ? d['lang'] : d['label']).toString();
      if (key.isNotEmpty) merged[key] = d;
    }

    final readyDubs = merged.values.where((m) {
      final ok = (m['status']?.toString().toLowerCase() == 'ready');
      final has = ((m['hls'] ?? '').toString().isNotEmpty ||
          (m['mp4'] ?? '').toString().isNotEmpty);
      return ok && has;
    }).toList();

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          url: url,
          title: movie.title,
          audioDubs: readyDubs,
          dubLoader: () => _dubService.list(type: 'movie', id: movie.id),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            CustomPaint(
              painter: MovieDetailsPainter(0.5),
              size: Size.infinite,
            ),
            const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          ],
        ),
      );
    }

    if (_err != null || _movie == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            CustomPaint(
              painter: MovieDetailsPainter(0.5),
              size: Size.infinite,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: primaryColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ: ${_err ?? 'غير معروف'}',
                    style: ProfessionalTheme.subtitle1(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final movie = _movie!;
    final desc = movie.description ?? '';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _favoritesController),
        ChangeNotifierProvider.value(value: _watchlistController),
      ],
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: Stack(
          children: [
            // Animated Background
            CustomPaint(
              painter: MovieDetailsPainter(_floatingAnimation.value),
              size: Size.infinite,
            ),
            // Main Content
            CustomScrollView(
              slivers: [
                // Modern App Bar with Hero Image
                SliverAppBar(
                  expandedHeight: 500,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  stretch: true,
                  leading: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: surfaceColor.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Hero Image with Parallax Effect
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: CachedNetworkImage(
                                imageUrl: _full(movie.bannerPath ?? movie.posterPath),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: surfaceColor,
                                  child: const Center(
                                    child: CircularProgressIndicator(color: primaryColor),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: surfaceColor,
                                  child: const Icon(Icons.movie, color: Colors.white54, size: 64),
                                ),
                              ),
                            );
                          },
                        ),
                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                backgroundColor.withValues(alpha: 0.3),
                                Colors.transparent,
                                backgroundColor.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                        // Movie Info Overlay
                        Positioned(
                          bottom: 60,
                          left: 20,
                          right: 20,
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: ProfessionalTheme.headline2(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildModernButton(
                                          onPressed: () => _openFullScreen(movie),
                                          icon: Icons.play_arrow,
                                          label: 'شاهد الآن',
                                          isPrimary: true,
                                        ),
                                        const SizedBox(width: 12),
                                        Consumer<FavoritesController>(
                                          builder: (context, favoritesController, _) {
                                            final isFavorite = favoritesController.isFavorite(
                                              movie.id,
                                              'movie',
                                            );
                                            return _buildModernButton(
                                              onPressed: () async {
                                                await favoritesController.toggle(
                                                  id: movie.id,
                                                  type: 'movie',
                                                  title: movie.title ?? '',
                                                  image: movie.posterPath ?? '',
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      isFavorite
                                                          ? 'تمت الإزالة من المفضلة'
                                                          : 'تمت الإضافة إلى المفضلة',
                                                      style: ProfessionalTheme.body1(color: Colors.white),
                                                    ),
                                                    backgroundColor: primaryColor,
                                                  ),
                                                );
                                              },
                                              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                                              label: 'المفضلة',
                                              isPrimary: false,
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Consumer<WatchlistController>(
                                          builder: (context, watchlistController, _) {
                                            final isInWatchlist = watchlistController.isInWatchlist(movie.id.toString());
                                            return _buildModernButton(
                                              onPressed: () async {
                                                await watchlistController.toggleWatchlist(
                                                  movie.id.toString(),
                                                  {
                                                    'id': movie.id.toString(),
                                                    'title': movie.title ?? '',
                                                    'thumbnail': movie.posterPath ?? '',
                                                    'description': movie.description ?? '',
                                                    'type': 'movie',
                                                  },
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      isInWatchlist
                                                          ? 'تمت الإزالة من قائمة المشاهدة'
                                                          : 'تمت الإضافة إلى قائمة المشاهدة',
                                                      style: ProfessionalTheme.body1(color: Colors.white),
                                                    ),
                                                    backgroundColor: primaryColor,
                                                  ),
                                                );
                                              },
                                              icon: isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                                              label: 'المشاهدة لاحقاً',
                                              isPrimary: false,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content Section
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Description Section
                              if (desc.isNotEmpty) ...[
                                _buildSectionTitle('القصة'),
                                const SizedBox(height: 12),
                                _buildDescriptionCard(desc),
                                const SizedBox(height: 32),
                              ],

                              // Movie Info Section
                              _buildSectionTitle('معلومات الفيلم'),
                              const SizedBox(height: 16),
                              _buildInfoCards(movie),
                              const SizedBox(height: 32),

                              // Related Movies Section
                              _buildSectionTitle('أفلام مشابهة'),
                              const SizedBox(height: 16),
                              _ModernRelatedCarousel(currentMovieId: movie.id),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  double? _parseRating(dynamic r) {
    if (r == null) return null;
    if (r is num) return r.toDouble();
    return double.tryParse(r.toString());
  }

  Widget _buildModernButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(colors: [primaryColor, secondaryColor])
            : null,
        color: isPrimary ? null : surfaceColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(25),
        border: isPrimary ? null : Border.all(color: primaryColor.withValues(alpha: 0.3)),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(25),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: ProfessionalTheme.subtitle2(color: Colors.white),
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: ProfessionalTheme.headline3(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            surfaceColor.withValues(alpha: 0.8),
            surfaceColor.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Text(
            description,
            style: ProfessionalTheme.body1(color: Colors.white70).copyWith(height: 1.6),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards(MovieModel movie) {
    final infoItems = [
      {'السنة': '${movie.releaseYear}', 'icon': Icons.calendar_today},
      {'التقييم': movie.rating?.toStringAsFixed(1) ?? '-', 'icon': Icons.star},
      {'الحالة': movie.status, 'icon': Icons.info_outline},
      {'اللغة': '${movie.languageId}', 'icon': Icons.language},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: infoItems.length,
      itemBuilder: (context, index) {
        final item = infoItems[index];
        final key = item.keys.first;
        final value = item[key] as String;
        final icon = item['icon'] as IconData;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                surfaceColor.withValues(alpha: 0.8),
                surfaceColor.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            key,
                            style: ProfessionalTheme.caption(color: Colors.white70),
                          ),
                          Text(
                            value,
                            style: ProfessionalTheme.subtitle2(color: Colors.white),
                          ),
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
  }
}

// ignore: unused_element
class _BannerContent extends StatelessWidget {
  final String poster;
  final String title;
  final int? year;
  final double? rating;
  final VoidCallback? onPlay;
  final VoidCallback onAddToList;

  const _BannerContent({
    required this.poster,
    required this.title,
    required this.year,
    required this.rating,
    required this.onPlay,
    required this.onAddToList,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final isNarrow = c.maxWidth < 520;
        final posterW = isNarrow ? 120.0 : 170.0;
        final posterH = posterW * 1.46;

        final titleStyle = TextStyle(
          color: Colors.white,
          fontSize: isNarrow ? 22 : 28,
          fontWeight: FontWeight.w800,
          height: 1.2,
        );
        const metaStyle = TextStyle(color: Colors.white70, fontSize: 12.5);

        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: titleStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('${year ?? '-'}', style: metaStyle),
                const SizedBox(width: 10),
                const Text('•', style: TextStyle(color: Colors.white54)),
                const SizedBox(width: 10),
                Text(
                  'التقييم: ${rating?.toStringAsFixed(1) ?? '-'}',
                  style: metaStyle,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('شاهد الآن'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: onAddToList,
                  icon: const Icon(Icons.add),
                  label: const Text('قائمة المشاهدة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  poster,
                  width: posterW,
                  height: posterH,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              details,
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  poster,
                  width: posterW,
                  height: posterH,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: details),
            ],
          );
        }
      },
    );
  }
}

class _ModernRelatedCarousel extends StatelessWidget {
  final int currentMovieId;
  const _ModernRelatedCarousel({required this.currentMovieId});

  String _full(String? path) {
    return UrlUtils.normalize(path);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieController>(
      builder: (_, ctrl, __) {
        final items = ctrl.movies.where((m) => m.id != currentMovieId).take(10).toList();
        if (items.isEmpty) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1A1A).withValues(alpha: 0.8),
                  const Color(0xFF1A1A1A).withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA20136).withValues(alpha: 0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.movie_outlined, color: Colors.white54, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'لا يوجد محتوى متعلق الآن',
                        style: ProfessionalTheme.subtitle1(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final m = items[i];
              final img = _full(m.posterPath ?? m.bannerPath);
              return _ModernMovieCard(
                movie: m,
                image: img,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.movieDetails,
                  arguments: m,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ModernMovieCard extends StatefulWidget {
  final MovieModel movie;
  final String image;
  final VoidCallback onTap;

  const _ModernMovieCard({
    required this.movie,
    required this.image,
    required this.onTap,
  });

  @override
  State<_ModernMovieCard> createState() => _ModernMovieCardState();
}

class _ModernMovieCardState extends State<_ModernMovieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_hoverAnimation.value * 0.05),
            child: Container(
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA20136).withValues(alpha: _hoverAnimation.value * 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Poster
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: widget.image,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFF1A1A1A),
                                  child: const Center(
                                    child: CircularProgressIndicator(color: Color(0xFFA20136)),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFF1A1A1A),
                                  child: const Center(
                                    child: Icon(Icons.movie, color: Colors.white54, size: 32),
                                  ),
                                ),
                              ),
                              if (_isHovered)
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withValues(alpha: 0.6),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              if (_isHovered)
                                const Center(
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Movie Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1A1A1A).withValues(alpha: 0.9),
                              const Color(0xFF1A1A1A).withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                          border: Border.all(
                            color: const Color(0xFFA20136).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.movie.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: ProfessionalTheme.subtitle2(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.movie.rating?.toStringAsFixed(1) ?? '-',
                                  style: ProfessionalTheme.caption(color: Colors.white70),
                                ),
                                const Spacer(),
                                Text(
                                  '${widget.movie.releaseYear}',
                                  style: ProfessionalTheme.caption(color: Colors.white70),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}

// Custom Painter for Movie Details Background
class MovieDetailsPainter extends CustomPainter {
  final double animationValue;

  MovieDetailsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Background gradient
    paint.shader = LinearGradient(
      colors: [
        const Color(0xFF0A0A0A),
        const Color(0xFF1A1A1A),
        const Color(0xFF0A0A0A),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Animated film reels and camera elements
    for (int i = 0; i < 6; i++) {
      final x = (size.width * 0.1) + (i * size.width * 0.15);
      final y = size.height * 0.2 + (i % 2) * size.height * 0.6;

      _drawFilmReel(
        canvas,
        Offset(x, y),
        25 + (i * 3),
        animationValue + (i * 0.3),
        const Color(0xFFA20136).withValues(alpha: 0.1),
      );
    }

    // Movie camera icons
    for (int i = 0; i < 4; i++) {
      final x = size.width * 0.2 + (i * size.width * 0.2);
      final y = size.height * 0.7 + math.sin(animationValue * 1.5 + i) * 40;

      _drawCameraIcon(
        canvas,
        Offset(x, y),
        20 + (i * 3),
        const Color(0xFF6B0024).withValues(alpha: 0.15),
      );
    }
  }

  void _drawFilmReel(Canvas canvas, Offset center, double radius, double rotation, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Draw outer circle
    canvas.drawCircle(Offset.zero, radius, paint);

    // Draw inner circles
    canvas.drawCircle(Offset.zero, radius * 0.7, paint);
    canvas.drawCircle(Offset.zero, radius * 0.3, paint);

    // Draw spokes
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      final x1 = math.cos(angle) * (radius * 0.3);
      final y1 = math.sin(angle) * (radius * 0.3);
      final x2 = math.cos(angle) * (radius * 0.7);
      final y2 = math.sin(angle) * (radius * 0.7);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    canvas.restore();
  }

  void _drawCameraIcon(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw camera body
    final rect = Rect.fromCenter(center: center, width: size * 1.5, height: size);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size * 0.1)), paint);

    // Draw lens
    canvas.drawCircle(center, size * 0.4, paint);
    canvas.drawCircle(center, size * 0.25, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
