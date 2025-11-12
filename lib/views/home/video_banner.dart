import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:alenwan/core/services/banner_playback_service.dart';
import 'package:alenwan/models/banner_model.dart';
import 'package:alenwan/views/home/shahid_hero_banner.dart';
import 'package:alenwan/common/video_player_screen.dart';
import 'package:alenwan/core/utils/url_utils.dart';
import 'package:alenwan/views/home/premium_banner.dart';

class VideoBanner extends StatefulWidget {
  const VideoBanner({super.key});

  @override
  State<VideoBanner> createState() => _VideoBannerState();
}

class _VideoBannerState extends State<VideoBanner> with WidgetsBindingObserver {
  BannerModel? _banner;
  bool _loading = true;

  VideoPlayerController? _vc;
  Future<void>? _initFut;
  bool _muted = true;

  double _heroH(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    final h = MediaQuery.of(ctx).size.height;
    if (w > 1200) return h * 0.8;
    if (w > 800) return h * 0.6;
    return (w * 9 / 16).clamp(300.0, 600.0);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _load() async {
    try {
      final playback = await BannerPlaybackService().getActiveBannerPlayback();

      _banner = BannerModel(
        id: 0, // أو id حقيقي لو عندك من الـ API
        title: playback['title'],
        subtitle: playback['subtitle'],
        vimeoId: null,
        placeholderUrl: null,
        isLive: false, // قيمة افتراضية
        overlayOpacity: 0.35, // قيمة افتراضية
        playback: {
          'hls': playback['hls'],
          'mp4': playback['mp4'],
        },
      );

      if (!kIsWeb) {
        final hls = (playback['hls'] ?? '').toString().trim();
        if (hls.isNotEmpty) {
          await _initPlayer(hls);
        } else {
          _disposePlayer();
        }
      }
    } catch (e, s) {
      log('❌ load banner error: $e', stackTrace: s);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _initPlayer(String url) async {
    _disposePlayer();
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    _vc = c;
    _initFut = c.initialize().then((_) {
      if (!mounted) return;
      c
        ..setLooping(true)
        ..setVolume(_muted ? 0.0 : 1.0)
        ..play();
      setState(() {});
    }).catchError((e, s) {
      log('❌ video init failed: $e', stackTrace: s);
      _disposePlayer();
    });
    await _initFut;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_vc == null) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _vc!.pause();
    }
  }

  void _disposePlayer() {
    try {
      _vc?.pause();
      _vc?.dispose();
    } catch (_) {}
    _vc = null;
    _initFut = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposePlayer();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (_vc != null && kDebugMode) {
      _vc!.pause();
      _vc!.play();
    }
  }

  void _toggleMute() {
    if (_vc == null) return;
    setState(() {
      _muted = !_muted;
      _vc!.setVolume(_muted ? 0.0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = _heroH(context);

    if (_loading) {
      return SizedBox(
        height: h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_banner == null) {
      return _buildDemoBanner(h);
    }

    // 🎥 Web: Vimeo iframe
    final vimeoId = (_banner!.vimeoId ?? '').trim();
    if (kIsWeb && vimeoId.isNotEmpty) {
      return ShahidHeroBanner(
        vimeoId: vimeoId,
        title: _banner!.title ?? '',
        subtitle: _banner!.subtitle,
        isLive: _banner!.isLive,
        overlayOpacity:
            _banner!.overlayOpacity == 0 ? .35 : _banner!.overlayOpacity,
        debugLabel: 'api',
      );
    }

    // 📱 Mobile/Desktop: HLS
    final hls = (_banner!.playback?['hls'] ?? '').toString().trim();
    if (hls.isNotEmpty && _vc != null) {
      return SizedBox(
        height: h,
        width: double.infinity,
        child: FutureBuilder(
          future: _initFut,
          builder: (_, snap) {
            final ready = snap.connectionState == ConnectionState.done &&
                _vc!.value.isInitialized;
            if (!ready) return _posterLayer(h);

            return Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _vc!.value.size.width,
                    height: _vc!.value.size.height,
                    child: VideoPlayer(_vc!),
                  ),
                ),
                _gradients(),
                _texts(),
                _muteButton(),
              ],
            );
          },
        ),
      );
    }

    return _posterLayer(h);
  }

  Widget _gradients() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
              stops: [0.0, 0.6],
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Colors.black54, Colors.transparent],
              stops: [0.0, 0.55],
            ),
          ),
        ),
      ],
    );
  }

  Widget _texts() {
    return Positioned(
      right: 24,
      bottom: 50,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _banner!.title ?? '',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            if ((_banner!.subtitle ?? '').isNotEmpty)
              Text(
                _banner!.subtitle!,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.right,
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _handleWatchAction();
              },
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text("شاهد الآن",
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _muteButton() {
    return Positioned(
      top: 20,
      left: 20,
      child: IconButton(
        onPressed: _toggleMute,
        icon: Icon(
          _muted ? Icons.volume_off : Icons.volume_up,
          color: Colors.white,
          size: 28,
        ),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black54,
          shape: const CircleBorder(),
        ),
      ),
    );
  }

  Widget _posterLayer(double h) {
    return _placeholder(h, 'لا يوجد فيديو متاح');
  }

  Widget _buildDemoBanner(double h) {
    return PremiumBanner(height: h);
  }

  Widget _placeholder(double h, String text) {
    return Container(
      height: h,
      color: const Color(0xFF121212),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.movie_creation_outlined, color: Colors.white38),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  void _handleWatchAction() {
    if (_banner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_content_available'.tr())),
      );
      return;
    }

    // Check if there's a button URL (external link)
    if (_banner!.buttonUrl != null && _banner!.buttonUrl!.isNotEmpty) {
      final url = UrlUtils.normalize(_banner!.buttonUrl!);
      if (_isDirectPlayable(url)) {
        // Navigate to video player for direct playable content
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(
              url: url,
              title: _banner!.title ?? 'فيديو',
              audioDubs: const [],
            ),
          ),
        );
        return;
      }
    }

    // Check if there's playback data
    if (_banner!.playback != null) {
      final playback = _banner!.playback!;
      String? videoUrl;

      // Try to get HLS or MP4 URL from playback
      if (playback['hls'] != null && playback['hls'].toString().isNotEmpty) {
        videoUrl = playback['hls'].toString();
      } else if (playback['mp4'] != null &&
          playback['mp4'].toString().isNotEmpty) {
        videoUrl = playback['mp4'].toString();
      }

      if (videoUrl != null && videoUrl.isNotEmpty) {
        final normalizedUrl = UrlUtils.normalize(videoUrl);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(
              url: normalizedUrl,
              title: _banner!.title ?? 'فيديو',
              audioDubs: const [],
            ),
          ),
        );
        return;
      }
    }

    // If no playable content found
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لا يوجد فيديو متاح للتشغيل')),
    );
  }

  bool _isDirectPlayable(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.contains('.m3u8') ||
        lowerUrl.contains('hls');
  }
}
