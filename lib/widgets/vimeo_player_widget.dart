import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../core/services/vimeo_service.dart';
import '../core/security/simple_video_protection.dart';
import 'dart:async';

class VimeoPlayerWidget extends StatefulWidget {
  final String vimeoId;
  final String contentId;
  final String title;
  final int? startPosition;
  final Function(int position)? onProgress;
  final VoidCallback? onComplete;

  const VimeoPlayerWidget({
    super.key,
    required this.vimeoId,
    required this.contentId,
    required this.title,
    this.startPosition,
    this.onProgress,
    this.onComplete,
  });

  @override
  State<VimeoPlayerWidget> createState() => _VimeoPlayerWidgetState();
}

class _VimeoPlayerWidgetState extends State<VimeoPlayerWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  final VimeoService _vimeoService = VimeoService();
  final SimpleVideoProtection _protection = SimpleVideoProtection();

  bool _isLoading = true;
  String? _errorMessage;
  Timer? _progressTimer;
  List<VideoQuality> _availableQualities = [];
  VideoQuality? _currentQuality;
  int _lastPosition = 0;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _protection.enableProtection();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get video configuration
      final config = await _vimeoService.getVideoConfig(widget.vimeoId);
      if (config == null) {
        throw Exception('Failed to load video configuration');
      }

      _availableQualities = config.qualities;

      // Select initial quality based on connection
      String? videoUrl;
      if (config.hlsUrl != null) {
        // Use HLS for adaptive streaming
        videoUrl = config.hlsUrl;
      } else if (_availableQualities.isNotEmpty) {
        // Select HD quality by default (720p)
        _currentQuality = _availableQualities.firstWhere(
          (q) => q.height == 720,
          orElse: () => _availableQualities.first,
        );
        videoUrl = _currentQuality!.url;
      }

      if (videoUrl == null) {
        throw Exception('No playable video URL found');
      }

      // Initialize video controller
      _videoController = VideoPlayerController.network(
        videoUrl,
        httpHeaders: {
          'Referer': 'https://alenwan.app',
          'User-Agent': 'Alenwan Mobile App',
        },
      );

      await _videoController!.initialize();

      // Set start position if resuming
      final startPos =
          widget.startPosition ?? _vimeoService.getLastPosition(widget.vimeoId);
      if (startPos > 0) {
        await _videoController!.seekTo(Duration(seconds: startPos));
      }

      // Create Chewie controller with custom controls
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showControlsOnInitialize: false,
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _retryPlayer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        customControls: _buildCustomControls(),
        additionalOptions: (context) => _buildQualityOptions(),
      );

      // Start progress tracking
      _startProgressTracking();

      // Add buffer listener
      _videoController!.addListener(_onVideoUpdate);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Widget _buildCustomControls() {
    return Stack(
      children: [
        // Main controls
        const MaterialControls(),

        // Quality selector button
        if (_availableQualities.length > 1)
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: PopupMenuButton<VideoQuality>(
                icon: Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      _currentQuality?.label ?? 'Auto',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                onSelected: _changeQuality,
                itemBuilder: (context) => _availableQualities
                    .map((quality) => PopupMenuItem(
                          value: quality,
                          child: Row(
                            children: [
                              if (quality == _currentQuality)
                                const Icon(Icons.check, size: 16)
                              else
                                const SizedBox(width: 16),
                              const SizedBox(width: 8),
                              Text(quality.label),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

        // Buffering indicator
        if (_isBuffering)
          const Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          ),

        // Skip intro button (if applicable)
        if (_lastPosition > 0 && _lastPosition < 120)
          Positioned(
            bottom: 80,
            right: 16,
            child: ElevatedButton(
              onPressed: _skipIntro,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Skip Intro'),
            ),
          ),
      ],
    );
  }

  List<OptionItem> _buildQualityOptions() {
    return [
      OptionItem(
        onTap: (context) => _showQualityDialog(),
        iconData: Icons.hd,
        title: 'Video Quality',
      ),
      OptionItem(
        onTap: (context) => _showPlaybackSpeedDialog(),
        iconData: Icons.speed,
        title: 'Playback Speed',
      ),
      OptionItem(
        onTap: (context) => _downloadForOffline(),
        iconData: Icons.download,
        title: 'Download',
      ),
    ];
  }

  void _changeQuality(VideoQuality quality) async {
    if (_currentQuality == quality) return;

    final currentPosition = await _videoController!.position;
    final wasPlaying = _videoController!.value.isPlaying;

    setState(() {
      _currentQuality = quality;
      _isBuffering = true;
    });

    // Dispose old controller
    await _videoController!.pause();

    // Create new controller with new quality
    _videoController = VideoPlayerController.network(
      quality.url,
      httpHeaders: {
        'Referer': 'https://alenwan.app',
        'User-Agent': 'Alenwan Mobile App',
      },
    );

    await _videoController!.initialize();
    await _videoController!.seekTo(currentPosition!);

    if (wasPlaying) {
      await _videoController!.play();
    }

    // Dispose and recreate Chewie controller with new video controller
    final oldChewieController = _chewieController;
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: wasPlaying,
      looping: false,
      aspectRatio: _videoController!.value.aspectRatio,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.red,
        bufferedColor: Colors.red.withOpacity(0.3),
        backgroundColor: Colors.white.withOpacity(0.3),
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Error: $errorMessage',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _initializePlayer();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
      customControls: _buildCustomControls(),
      additionalOptions: (context) => _buildQualityOptions(),
    );

    oldChewieController?.dispose();

    setState(() {
      _isBuffering = false;
    });
  }

  void _startProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_videoController?.value.isPlaying ?? false) {
        final position = await _videoController!.position;
        final duration = _videoController!.value.duration;

        if (position != null) {
          final positionSeconds = position.inSeconds;
          final durationSeconds = duration.inSeconds;

          _lastPosition = positionSeconds;

          // Track progress
          await _vimeoService.trackProgress(
            widget.vimeoId,
            widget.contentId,
            positionSeconds,
            durationSeconds,
          );

          // Call progress callback
          widget.onProgress?.call(positionSeconds);

          // Check if completed
          if (positionSeconds >= durationSeconds - 5) {
            await _vimeoService.markAsWatched(widget.vimeoId, widget.contentId);
            widget.onComplete?.call();
            timer.cancel();
          }
        }
      }
    });
  }

  void _onVideoUpdate() {
    final isBuffering = _videoController!.value.isBuffering;
    if (isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = isBuffering;
      });
    }
  }

  void _skipIntro() async {
    await _videoController!.seekTo(const Duration(seconds: 120));
  }

  void _showQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableQualities
              .map((quality) => ListTile(
                    leading: quality == _currentQuality
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.circle_outlined),
                    title: Text(quality.label),
                    subtitle: Text('${quality.width}x${quality.height}'),
                    onTap: () {
                      Navigator.pop(context);
                      _changeQuality(quality);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showPlaybackSpeedDialog() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds
              .map((speed) => ListTile(
                    leading: _videoController!.value.playbackSpeed == speed
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.circle_outlined),
                    title: Text('${speed}x'),
                    onTap: () {
                      _videoController!.setPlaybackSpeed(speed);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _downloadForOffline() async {
    final success = await _vimeoService.downloadVideo(
      widget.vimeoId,
      widget.contentId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Download started'
                : 'Download not available for this video',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _retryPlayer() {
    _initializePlayer();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    _chewieController?.dispose();
    _protection.disableProtection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.red),
              )
            else if (_errorMessage != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _retryPlayer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_chewieController != null)
              Chewie(controller: _chewieController!),

            // Back button
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                  ]);
                  Navigator.pop(context);
                },
              ),
            ),

            // Title
            if (!_isLoading && _errorMessage == null)
              Positioned(
                top: 40,
                left: 60,
                right: 100,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
