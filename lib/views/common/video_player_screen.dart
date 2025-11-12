import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url; // رابط الفيديو الأونلاين
  final String? localFile; // مسار الملف المحلي (لو متوفر)
  final String? title;

  const VideoPlayerScreen({
    super.key,
    required this.url,
    this.localFile,
    this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _v;
  ChewieController? _c;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      VideoPlayerController v;

      if (widget.localFile != null && widget.localFile!.isNotEmpty) {
        v = VideoPlayerController.file(
          io.File(widget.localFile!),
        ); // ✅ تشغيل أوفلاين
      } else {
        v = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      }

      await v.initialize();

      final c = ChewieController(
        videoPlayerController: v,
        autoPlay: true,
        looping: false,
      );

      if (!mounted) return;

      setState(() {
        _v = v;
        _c = c;
        _loading = false;
      });
    } catch (e) {
      debugPrint("❌ Video init error: $e");
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    _v?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    if (_v == null || !_v!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text(widget.title ?? '')),
        body: const Center(
          child: Text(
            "فشل تشغيل الفيديو",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.title ?? '')),
      body: Center(
        child: AspectRatio(
          aspectRatio: _v!.value.aspectRatio,
          child: Chewie(controller: _c!),
        ),
      ),
    );
  }
}
