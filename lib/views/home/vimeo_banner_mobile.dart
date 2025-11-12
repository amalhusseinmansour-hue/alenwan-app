import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VimeoBanner extends StatefulWidget {
  final String? vimeoId; // للويب فقط
  final String? hlsUrl; // المهم للموبايل
  final String? placeholderUrl;
  final String? title;
  final String? subtitle;
  final String? buttonText;

  const VimeoBanner({
    super.key,
    this.vimeoId,
    this.hlsUrl,
    this.placeholderUrl,
    this.title,
    this.subtitle,
    this.buttonText,
  });

  @override
  State<VimeoBanner> createState() => _VimeoBannerState();
}

class _VimeoBannerState extends State<VimeoBanner> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final url = (widget.hlsUrl ?? '').trim();
    if (url.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _initFuture = _controller!.initialize().then((_) {
        _controller!
          ..setLooping(true)
          ..setVolume(0)
          ..play();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // حل لمشكلة "Unable to acquire buffer" على المحاكي
    if (_controller == null) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller!.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = (MediaQuery.of(context).size.width * 9 / 16) * 0.9;

    if (_controller == null) {
      // لا يوجد فيديو → اعرض صورة بديلة
      return _placeholder(h);
    }

    return FutureBuilder(
      future: _initFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done ||
            !_controller!.value.isInitialized) {
          return _placeholder(h);
        }

        return SizedBox(
          height: h,
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder(double h) {
    final ph = (widget.placeholderUrl ?? '').trim();
    return SizedBox(
      height: h,
      width: double.infinity,
      child: ph.isNotEmpty
          ? Image.network(
              ph,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            )
          : Container(color: Colors.black),
    );
  }
}
