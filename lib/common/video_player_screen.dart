// lib/common/video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final String? title;

  final List<Map<String, dynamic>>? audioDubs;
  final Future<List<Map<String, dynamic>>> Function()? dubLoader;

  final bool autoPlay; // ✅ جديد
  final bool showControls; // ✅ جديد

  const VideoPlayerScreen({
    super.key,
    required this.url,
    this.title,
    List<Map<String, dynamic>>? audioDubs,
    this.dubLoader,
    this.autoPlay = true, // ✅ قيمة افتراضية
    this.showControls = true, // ✅ قيمة افتراضية
  }) : audioDubs = audioDubs ?? const [];

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _v;
  ChewieController? _c;

  String _currentUrl = '';
  String? _currentDubLabel;

  bool _isDisposed = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _initForUrl(_currentUrl);
  }

  String _makeAbsolute(String? u) {
    if (u == null || u.trim().isEmpty) return '';
    final s = u.trim();
    if (s.startsWith('http')) return s;
    final origin = Uri.parse(widget.url).origin;
    if (s.startsWith('/')) return '$origin$s';
    return '$origin/$s';
  }

  Future<void> _initForUrl(String url, {Duration? pos, String? label}) async {
    if (_isDisposed || _isInitializing) return;
    _isInitializing = true;

    final oldV = _v;
    final oldC = _c;

    final newV = VideoPlayerController.networkUrl(Uri.parse(url));
    await newV.initialize();
    if (pos != null && pos > Duration.zero) {
      await newV.seekTo(pos);
    }

    final newC = ChewieController(
      videoPlayerController: newV,
      autoPlay: true,
      looping: false,
      showControls: true,
      allowFullScreen: true,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
      additionalOptions: _buildOptions,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.redAccent,
        handleColor: Colors.white,
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white54,
      ),
    );

    if (!mounted || _isDisposed) {
      newC.dispose();
      newV.dispose();
      return;
    }

    setState(() {
      _v = newV;
      _c = newC;
      _currentUrl = url;
      _currentDubLabel = label;
      _isInitializing = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldC?.dispose();
      oldV?.dispose();
    });
  }

  List<OptionItem> _buildOptions(BuildContext ctx) {
    return [
      OptionItem(
        onTap: _openAudioDubPicker,
        iconData: Icons.record_voice_over_rounded,
        title: _currentDubLabel == null
            ? 'الترجمة الصوتية'
            : 'الترجمة الصوتية: $_currentDubLabel',
      ),
    ];
  }

  Future<void> _openAudioDubPicker(BuildContext ctx) async {
    List<Map<String, dynamic>> fromApi = [];
    if (widget.dubLoader != null) {
      try {
        fromApi = await widget.dubLoader!();
      } catch (e) {
        debugPrint("Failed to load audio dubs: $e");
        // Continue with default dubs if API fails
      }
    }

    List<Map<String, dynamic>> dubs =
        (fromApi.isNotEmpty ? fromApi : widget.audioDubs)!.map((e) {
          final hls = (e['hls'] ?? e['url'] ?? '').toString();
          final mp4 = (e['mp4'] ?? e['mp4_url'] ?? '').toString();
          return {
            'label': (e['label'] ?? e['lang'] ?? '').toString(),
            'lang': (e['lang'] ?? '').toString(),
            'status': (e['status'] ?? 'ready').toString(),
            'hls': _makeAbsolute(hls),
            'mp4': _makeAbsolute(mp4),
          };
        }).toList();

    if (dubs.isEmpty) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('لا تتوفر ترجمات صوتية لهذا الفيديو حالياً'),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      // ignore: use_build_context_synchronously
      context: ctx,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (bCtx) => Directionality(
        textDirection: TextDirection.ltr,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'اختر لغة الترجمة الصوتية',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...dubs.map((m) {
                final label = (m['label'] ?? m['lang'] ?? '').toString();
                final status = (m['status'] ?? '').toString().toLowerCase();
                final hls = (m['hls'] ?? '').toString();
                final mp4 = (m['mp4'] ?? '').toString();

                final playable =
                    status == 'ready' && (hls.isNotEmpty || mp4.isNotEmpty);
                final isCurrent = _currentDubLabel == label;

                return ListTile(
                  title: Text(
                    label,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    status == 'ready' ? 'جاهزة' : status,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: isCurrent
                      ? const Icon(Icons.check, color: Colors.greenAccent)
                      : (playable
                            ? const Icon(Icons.play_arrow, color: Colors.white)
                            : const Icon(
                                Icons.hourglass_bottom,
                                color: Colors.white54,
                              )),
                  enabled: playable,
                  onTap: !playable
                      ? null
                      : () {
                          if (!bCtx.mounted) return;
                          Navigator.pop(bCtx, {
                            'label': label,
                            'hls': hls,
                            'mp4': mp4,
                          });
                        },
                );
              }),
              const Divider(color: Colors.white24),
              ListTile(
                title: const Text(
                  'العودة إلى الصوت الأصلي',
                  style: TextStyle(color: Colors.white),
                ),
                leading: const Icon(Icons.undo, color: Colors.white70),
                onTap: () {
                  if (!bCtx.mounted) return;
                  Navigator.pop(bCtx, {
                    'label': null,
                    'hls': _makeAbsolute(widget.url),
                    'mp4': '',
                  });
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || selected == null) return;

    String newUrl = (selected['hls'] ?? '').toString();
    final String? newLabel = selected['label']?.toString();

    if (kIsWeb) {
      final mp4 = (selected['mp4'] ?? '').toString();
      if (mp4.isNotEmpty) newUrl = mp4;
    }

    if (newUrl.isEmpty || newUrl == _currentUrl) return;

    final pos = _v?.value.position ?? Duration.zero;
    await _initForUrl(newUrl, pos: pos, label: newLabel);
  }

  @override
  void dispose() {
    _isDisposed = true;

    final c = _c;
    final v = _v;
    setState(() {
      _c = null;
      _v = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      c?.dispose();
      v?.dispose();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(widget.title ?? '', overflow: TextOverflow.ellipsis),
        ),
        body: Center(
          child: (_c == null || _v == null || !_v!.value.isInitialized)
              ? const CircularProgressIndicator()
              : AspectRatio(
                  aspectRatio: (_v?.value.aspectRatio ?? 0) == 0
                      ? 16 / 9
                      : _v!.value.aspectRatio,
                  child: Chewie(key: ValueKey(_currentUrl), controller: _c!),
                ),
        ),
      ),
    );
  }
}
