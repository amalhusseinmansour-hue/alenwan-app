import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class LocalVideoPlayer extends StatefulWidget {
  final String filePath;
  final String? title;
  const LocalVideoPlayer({super.key, required this.filePath, this.title});

  @override
  State<LocalVideoPlayer> createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
  late VideoPlayerController _vc;
  ChewieController? _cc;

  @override
  void initState() {
    super.initState();
    _vc = VideoPlayerController.file(File(widget.filePath));
    _vc.initialize().then((_) {
      setState(() {
        _cc = ChewieController(videoPlayerController: _vc, autoPlay: true);
      });
    });
  }

  @override
  void dispose() {
    _vc.dispose();
    _cc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.title ?? 'Offline Video')),
      body: Center(
        child: _cc == null
            ? const CircularProgressIndicator()
            : Chewie(controller: _cc!),
      ),
    );
  }
}
