// lib/widgets/custom_video_player.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../core/theme/app_theme.dart';
import 'video_translation_overlay.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Function(Duration)? onPositionChanged;
  final bool autoPlay;
  final bool showControls;

  const CustomVideoPlayer({
    super.key,
    required this.videoUrl,
    this.title,
    this.subtitle,
    this.onBack,
    this.onPositionChanged,
    this.autoPlay = true,
    this.showControls = true,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer>
    with TickerProviderStateMixin {
  late AnimationController _controlsAnimationController;
  late AnimationController _bufferingAnimationController;
  late Animation<double> _controlsOpacity;

  bool _isPlaying = false;
  final bool _isBuffering = false;
  bool _showControls = true;
  bool _isFullScreen = false;
  bool _isMuted = false;

  final Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  double _volume = 1.0;
  double _playbackSpeed = 1.0;

  Timer? _hideControlsTimer;

  final List<double> _playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startHideControlsTimer();
    if (widget.autoPlay) {
      _play();
    }
  }

  void _initializeControllers() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bufferingAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _controlsOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    ));

    _controlsAnimationController.forward();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        setState(() => _showControls = false);
        _controlsAnimationController.reverse();
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _controlsAnimationController.forward();
      _startHideControlsTimer();
    } else {
      _controlsAnimationController.reverse();
    }
  }

  void _play() {
    setState(() => _isPlaying = true);
    _startHideControlsTimer();
  }

  void _pause() {
    setState(() => _isPlaying = false);
    _hideControlsTimer?.cancel();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  void _seek(Duration position) {
    setState(() => _position = position);
    widget.onPositionChanged?.call(position);
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    _bufferingAnimationController.dispose();
    _hideControlsTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoTranslationOverlay(
      showControls: widget.showControls,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              // Video placeholder
              Container(
                color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: AppTheme.surfaceColor,
                      child: const Center(
                        child: Icon(
                          Icons.movie_rounded,
                          size: 80,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Buffering indicator
              if (_isBuffering)
                Center(
                  child: AnimatedBuilder(
                    animation: _bufferingAnimationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle:
                            _bufferingAnimationController.value * 2 * 3.14159,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              width: 3,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryColor.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Controls overlay
              AnimatedBuilder(
                animation: _controlsOpacity,
                builder: (context, child) {
                  return Opacity(
                    opacity: _controlsOpacity.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            // Top controls
                            _buildTopControls(),

                            const Spacer(),

                            // Center play button
                            Center(
                              child: _buildCenterPlayButton(),
                            ),

                            const Spacer(),

                            // Bottom controls
                            _buildBottomControls(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          _buildControlButton(
            icon: Icons.arrow_back_rounded,
            onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Settings button
          _buildControlButton(
            icon: Icons.settings_rounded,
            onPressed: () => _showSettingsMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPlayButton() {
    if (!_showControls || _isBuffering) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _togglePlayPause,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primaryColor.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress bar
          _buildProgressBar(),

          const SizedBox(height: 12),

          // Control buttons
          Row(
            children: [
              // Play/Pause
              _buildControlButton(
                icon:
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onPressed: _togglePlayPause,
              ),

              const SizedBox(width: 16),

              // Time display
              Text(
                '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),

              const Spacer(),

              // Volume
              _buildVolumeControl(),

              const SizedBox(width: 16),

              // Speed
              _buildSpeedButton(),

              const SizedBox(width: 16),

              // Fullscreen
              _buildControlButton(
                icon: _isFullScreen
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                onPressed: _toggleFullScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return SizedBox(
      height: 30,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          activeTrackColor: AppTheme.primaryColor,
          inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
          thumbColor: AppTheme.primaryColor,
          overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
        child: Slider(
          value: _position.inSeconds.toDouble(),
          min: 0,
          max: _duration.inSeconds.toDouble() > 0
              ? _duration.inSeconds.toDouble()
              : 1.0,
          onChanged: (value) {
            _seek(Duration(seconds: value.toInt()));
          },
        ),
      ),
    );
  }

  Widget _buildVolumeControl() {
    return Row(
      children: [
        _buildControlButton(
          icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          onPressed: () {
            setState(() => _isMuted = !_isMuted);
          },
        ),
        SizedBox(
          width: 100,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              thumbColor: AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _isMuted ? 0 : _volume,
              min: 0,
              max: 1,
              onChanged: (value) {
                setState(() {
                  _volume = value;
                  _isMuted = value == 0;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedButton() {
    return GestureDetector(
      onTap: _showSpeedMenu,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          '${_playbackSpeed}x',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showSpeedMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'سرعة التشغيل',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_playbackSpeeds.length, (index) {
                final speed = _playbackSpeeds[index];
                final isSelected = speed == _playbackSpeed;

                return ListTile(
                  title: Text(
                    '${speed}x',
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    setState(() => _playbackSpeed = speed);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'إعدادات الفيديو',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.high_quality_rounded,
                    color: AppTheme.primaryColor),
                title: const Text(
                  'جودة الفيديو',
                  style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                ),
                subtitle: const Text(
                  '1080p',
                  style: TextStyle(color: Colors.white54, fontFamily: 'Cairo'),
                ),
                onTap: () {},
              ),
              ListTile(
                leading:
                    const Icon(Icons.subtitles_rounded, color: AppTheme.primaryColor),
                title: const Text(
                  'الترجمة',
                  style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                ),
                subtitle: const Text(
                  'العربية',
                  style: TextStyle(color: Colors.white54, fontFamily: 'Cairo'),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.audiotrack_rounded,
                    color: AppTheme.primaryColor),
                title: const Text(
                  'الصوت',
                  style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                ),
                subtitle: const Text(
                  'الأصلي',
                  style: TextStyle(color: Colors.white54, fontFamily: 'Cairo'),
                ),
                onTap: () {},
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
