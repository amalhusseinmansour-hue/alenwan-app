// lib/views/cartoons/cartoon_details/cartoon_details_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../models/cartoon_model.dart';
import '../../../core/services/cartoon_service.dart';
import '../../../core/services/dub_service.dart';
import '../../../common/video_player_screen.dart';
import '../../../core/utils/url_utils.dart';
import 'widgets/section_header.dart';
import 'widgets/info_grid.dart';
import 'widgets/related_cartoons_carousel.dart';

class CartoonDetailsScreen extends StatefulWidget {
  final int cartoonId;
  const CartoonDetailsScreen({super.key, required this.cartoonId});

  @override
  State<CartoonDetailsScreen> createState() => _CartoonDetailsScreenState();
}

class _CartoonDetailsScreenState extends State<CartoonDetailsScreen> {
  final _cartoonService = CartoonService();

  late final DubService _dubService = DubService();

  CartoonModel? _cartoon;
  String? _err;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final c = await _cartoonService.fetchCartoonDetails(widget.cartoonId);
      if (!mounted) return;
      setState(() {
        _cartoon = c;
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

  String _bestUrlFromPlayback({
    required String? raw,
    required Map<String, dynamic>? playback,
  }) {
    final hls = (playback?['hls'] ?? '').toString().trim();
    final mp4 = (playback?['mp4'] ?? '').toString().trim();

    if (hls.isEmpty && mp4.isEmpty && (raw?.isNotEmpty ?? false)) {
      return UrlUtils.normalize(raw!);
    }

    final chosen = kIsWeb
        ? [
            mp4,
            raw,
            hls,
          ].firstWhere((u) => (u ?? '').isNotEmpty, orElse: () => '')
        : [
            hls,
            mp4,
            raw,
          ].firstWhere((u) => (u ?? '').isNotEmpty, orElse: () => '');

    return UrlUtils.normalize(chosen);
  }

  String _bestPlayable(CartoonModel m) {
    return _bestUrlFromPlayback(raw: m.videoPath, playback: m.playback);
  }

  Future<void> _openFullScreen(CartoonModel cartoon) async {
    final url = _bestPlayable(cartoon);
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد مسار فيديو لهذا العنوان')),
      );
      return;
    }

    // دمج دبلجات من الـ payload + API
    List<Map<String, dynamic>> payloadDubs = [];
    try {
      final pb = cartoon.playback;
      if (pb != null && pb['audio_dubs'] is List) {
        payloadDubs = (pb['audio_dubs'] as List).map((e) {
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
    } catch (_) {}

    List<Map<String, dynamic>> apiDubs = [];
    try {
      apiDubs = await _dubService.list(type: 'cartoon', id: cartoon.id);
    } catch (e) {
      debugPrint("Error: $e");
    }

    // دمج الدبلجات
    Map<String, Map<String, dynamic>> merged = {};
    List<Map<String, dynamic>> normalize(List<Map<String, dynamic>> items) =>
        items.map((e) {
          final hls = (e['hls'] ?? e['url'] ?? '').toString();
          final mp4 = (e['mp4'] ?? e['mp4_url'] ?? '').toString();
          return {
            'label': (e['label'] ?? e['lang'] ?? '').toString(),
            'lang': (e['lang'] ?? '').toString(),
            'status': (e['status'] ?? 'ready').toString(),
            'hls': UrlUtils.normalize(hls),
            'mp4': UrlUtils.normalize(mp4),
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
      final has =
          ((m['hls'] ?? '').toString().isNotEmpty ||
          (m['mp4'] ?? '').toString().isNotEmpty);
      return ok && has;
    }).toList();

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          url: url,
          title: cartoon.title,
          audioDubs: readyDubs,
          dubLoader: () => _dubService.list(type: 'cartoon', id: cartoon.id),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_err != null || _cartoon == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'حدث خطأ: ${_err ?? 'غير معروف'}',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    final cartoon = _cartoon!;
    final banner = UrlUtils.normalize(cartoon.bannerPath ?? cartoon.posterPath);
    final desc = cartoon.description ?? '';

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              backgroundColor: Colors.black,
              expandedHeight: MediaQuery.of(context).size.width >= 700
                  ? 420
                  : 320,
              flexibleSpace: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: VideoPlayerScreen(
                      url: _bestPlayable(cartoon).isEmpty
                          ? banner
                          : _bestPlayable(cartoon),
                      title: cartoon.title,
                      autoPlay: true,
                      showControls: false,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, .55, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cartoon.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _openFullScreen(cartoon),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('شاهد الآن'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE50914),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (desc.isNotEmpty)
                      Text(
                        desc,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.6,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'ذات علاقة'),
                    const SizedBox(height: 12),
                    RelatedCartoonsCarousel(currentCartoonId: cartoon.id),
                    const SizedBox(height: 28),
                    const SectionHeader(title: 'المزيد من المعلومات'),
                    const SizedBox(height: 12),
                    InfoGrid(cartoon: cartoon),
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
