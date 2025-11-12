import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VimeoEmbed extends StatefulWidget {
  final String videoUrl; // رابط MP4 أو HLS من Laravel
  final double height;

  const VimeoEmbed({
    super.key,
    required this.videoUrl,
    required this.height,
  });

  @override
  State<VimeoEmbed> createState() => _VimeoEmbedState();
}

class _VimeoEmbedState extends State<VimeoEmbed> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(widget.videoUrl as Uri)
      ..initialize().then((_) {
        setState(() => _initialized = true);
        _controller
          ..setLooping(true)
          ..setVolume(0)
          ..play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: _initialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
