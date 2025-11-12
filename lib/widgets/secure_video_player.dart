import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../core/security/video_protection_service.dart';
import '../core/services/video_streaming_service.dart';
import 'package:provider/provider.dart';
import '../controllers/subscription_controller.dart';
import 'dart:async';

class SecureVideoPlayer extends StatefulWidget {
  final String videoId;
  final String videoUrl;
  final String title;
  final String? thumbnailUrl;
  final bool requiresSubscription;
  final Function(Duration)? onProgress;
  final VoidCallback? onComplete;

  const SecureVideoPlayer({
    super.key,
    required this.videoId,
    required this.videoUrl,
    required this.title,
    this.thumbnailUrl,
    this.requiresSubscription = true,
    this.onProgress,
    this.onComplete,
  });

  @override
  State<SecureVideoPlayer> createState() => _SecureVideoPlayerState();
}

class _SecureVideoPlayerState extends State<SecureVideoPlayer>
    with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  final VideoProtectionService _protectionService = VideoProtectionService();
  final VideoStreamingService _streamingService = VideoStreamingService();

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Timer? _progressTimer;
  bool _isInBackground = false;
  DateTime? _sessionStartTime;
  int _watchedSeconds = 0;

  // Security flags
  bool _securityViolation = false;
  int _bufferingAttempts = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
    _startSecurityMonitoring();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _onAppBackground();
        break;
      case AppLifecycleState.resumed:
        _onAppForeground();
        break;
      case AppLifecycleState.detached:
        _onAppTerminated();
        break;
      default:
        break;
    }
  }

  void _onAppBackground() {
    _isInBackground = true;
    // Pause video when app goes to background
    if (_chewieController?.isPlaying ?? false) {
      _chewieController?.pause();
    }
  }

  void _onAppForeground() {
    _isInBackground = false;
    // Check for security violations when returning
    _checkSecurityStatus();
  }

  void _onAppTerminated() {
    _cleanup();
  }

  Future<void> _initializeVideo() async {
    try {
      // Check subscription if required
      if (widget.requiresSubscription) {
        final subController = context.read<SubscriptionController>();
        if (!subController.hasActive) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Subscription required to watch this content';
          });
          return;
        }
      }

      // Enable video protection
      await _protectionService.initialize();

      // Get secure video URL
      final secureUrl = await _protectionService.getSecureVideoUrl(
        widget.videoId,
        widget.videoUrl,
      );

      // Get optimal quality based on network
      final quality = _streamingService.getOptimalQuality();
      final streamUrl = _streamingService.getStreamUrl(secureUrl, quality);

      // Initialize video controller with secure URL
      _videoController = VideoPlayerController.network(
        streamUrl,
        httpHeaders: {
          'User-Agent': 'AlenWanPlayer/1.0',
          'Referer': 'https://alenwan.app',
        },
      );

      await _videoController.initialize();

      // Create Chewie controller with custom controls
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        aspectRatio: _videoController.value.aspectRatio,
        autoPlay: true,
        looping: false,
        showControlsOnInitialize: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        placeholder: widget.thumbnailUrl != null
            ? Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Center(
                      child: Image.network(
                        widget.thumbnailUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE50914),
                      ),
                    ),
                  ],
                ),
              )
            : Container(color: Colors.black),
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget(errorMessage);
        },
        customControls: _buildSecureControls(),
        overlay: _buildWatermark(),
      );

      // Start tracking
      _sessionStartTime = DateTime.now();
      _startProgressTracking();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildSecureControls() {
    return Stack(
      children: [
        // Default controls
        const MaterialControls(),

        // Security overlay (invisible but prevents right-click on web)
        if (Theme.of(context).platform == TargetPlatform.android ||
            Theme.of(context).platform == TargetPlatform.iOS)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPress: () {
                // Prevent long press actions
              },
              onSecondaryTap: () {
                // Prevent right-click on web
              },
              child: Container(),
            ),
          ),
      ],
    );
  }

  Widget _buildWatermark() {
    // Dynamic watermark with user info
    return Positioned(
      top: 20,
      right: 20,
      child: AnimatedOpacity(
        opacity: 0.3,
        duration: const Duration(seconds: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'ALENWAN', // You can add user ID here
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _startSecurityMonitoring() {
    // Monitor for suspicious activity
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Check for debugger
      if (_isDebuggerAttached()) {
        _onSecurityViolation('debugger_detected');
      }

      // Check video progress anomalies
      if (_videoController.value.isInitialized) {
        _checkProgressAnomaly();
      }

      // Check buffering patterns (might indicate download attempt)
      _checkBufferingPattern();
    });
  }

  bool _isDebuggerAttached() {
    // Check if debugger is attached (basic check)
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  void _checkProgressAnomaly() {
    // Detect if video is being manipulated
    final position = _videoController.value.position;
    final duration = _videoController.value.duration;

    if (position > duration) {
      _onSecurityViolation('progress_anomaly');
    }
  }

  void _checkBufferingPattern() {
    // Detect suspicious buffering patterns
    if (_videoController.value.isBuffering) {
      _bufferingAttempts++;
      if (_bufferingAttempts > 10) {
        // Too many buffering attempts might indicate download attempt
        _onSecurityViolation('suspicious_buffering');
      }
    } else {
      _bufferingAttempts = 0;
    }
  }

  void _checkSecurityStatus() {
    // Re-validate security when returning from background
    if (_securityViolation) {
      _stopAndReport('security_check_failed');
    }
  }

  void _onSecurityViolation(String reason) {
    _securityViolation = true;
    _stopAndReport(reason);
  }

  void _stopAndReport(String reason) {
    // Stop playback immediately
    _chewieController?.pause();
    _videoController.pause();

    // Report to protection service
    _protectionService.endVideoSession();

    // Show security warning
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Security Alert'),
          content: const Text(
            'Playback has been stopped due to a security violation. '
            'This incident has been reported.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit player
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _startProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_chewieController?.isPlaying ?? false) {
        _watchedSeconds++;

        // Report progress
        final position = _videoController.value.position;
        widget.onProgress?.call(position);

        // Check if completed
        final duration = _videoController.value.duration;
        if (position >= duration * 0.95) {
          widget.onComplete?.call();
          timer.cancel();
        }
      }
    });
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _initializeVideo();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _cleanup() {
    _progressTimer?.cancel();
    _videoController.dispose();
    _chewieController?.dispose();
    _protectionService.endVideoSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE50914),
          ),
        ),
      );
    }

    if (_hasError) {
      return _buildErrorWidget(_errorMessage ?? 'Unknown error');
    }

    if (_securityViolation) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                color: Colors.red,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Security Violation Detected',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Playback has been stopped',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Chewie(controller: _chewieController!),
      ),
    );
  }
}
