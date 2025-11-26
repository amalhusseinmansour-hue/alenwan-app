import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../core/services/slider_service.dart';
import '../../core/services/vimeo_service.dart';
import '../common/video_player_screen.dart';
import '../../widgets/vimeo_player_widget.dart';

class SliderBanner extends StatefulWidget {
  const SliderBanner({super.key});

  @override
  State<SliderBanner> createState() => _SliderBannerState();
}

class _SliderBannerState extends State<SliderBanner> {
  final SliderService _sliderService = SliderService();
  final VimeoService _vimeoService = VimeoService();
  List<Map<String, dynamic>> _sliders = [];
  bool _loading = true;
  int _currentIndex = 0;
  Timer? _autoPlayTimer;
  final PageController _pageController = PageController();

  // Video controllers for each slider
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};

  @override
  void initState() {
    super.initState();
    _loadSliders();
  }

  Future<void> _loadSliders() async {
    try {
      final sliders = await _sliderService.getSliders();
      if (mounted) {
        setState(() {
          _sliders = sliders;
          _loading = false;
        });

        if (_sliders.isNotEmpty) {
          _startAutoPlay();
        }
      }
    } catch (e) {
      print('Error loading sliders: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _sliders.isEmpty) {
        timer.cancel();
        return;
      }

      final nextIndex = (_currentIndex + 1) % _sliders.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();

    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    for (var controller in _chewieControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  double _heroH(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    final h = MediaQuery.of(ctx).size.height;
    if (w > 1200) return h * 0.7;
    if (w > 800) return h * 0.55;
    return (w * 9 / 16).clamp(250.0, 500.0);
  }

  @override
  Widget build(BuildContext context) {
    final h = _heroH(context);

    if (_loading) {
      return SizedBox(
        height: h,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE50914),
          ),
        ),
      );
    }

    if (_sliders.isEmpty) {
      return _buildPlaceholder(h);
    }

    return SizedBox(
      height: h,
      child: Stack(
        children: [
          // PageView for sliders
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: _sliders.length,
            itemBuilder: (context, index) {
              return _buildSliderItem(_sliders[index], h);
            },
          ),

          // Page indicators
          if (_sliders.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: _buildPageIndicators(),
            ),
        ],
      ),
    );
  }

  Widget _buildSliderItem(Map<String, dynamic> slider, double height) {
    final sliderId = slider['id'] as int;
    final imageUrl = slider['image']?.toString() ?? '';
    final title = slider['title']?.toString() ?? '';
    final url = slider['url']?.toString() ?? '';

    // 🎬 الحقول الجديدة
    final mediaType = slider['media_type']?.toString() ?? 'image';
    final videoUrl = slider['video_url']?.toString() ?? '';
    final videoType = slider['video_type']?.toString() ?? '';

    // Check if we should play video directly
    final shouldPlayVideo = mediaType == 'video' && videoUrl.isNotEmpty;

    if (shouldPlayVideo) {
      // 🎥 تحديد نوع الفيديو والتعامل معه
      if (videoType == 'youtube') {
        // ✨ عرض صورة مصغرة YouTube مع زر تشغيل
        final youtubeId = _extractYoutubeId(videoUrl);
        final ytThumbnail = youtubeId != null
            ? 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg'
            : '';

        return _buildImageSlider(ytThumbnail, title, videoUrl, isVideo: true);
      } else if (videoType == 'vimeo') {
        // 🎬 تشغيل Vimeo مباشرة في البانر
        final vimeoId = _extractVimeoId(videoUrl);

        if (vimeoId != null) {
          // Initialize video if not already done
          if (!_chewieControllers.containsKey(sliderId)) {
            _initializeVideoPlayer(sliderId, vimeoId, title);
          }

          // Play video directly in banner
          return Stack(
            fit: StackFit.expand,
            children: [
              // Video Player
              if (_chewieControllers[sliderId] != null)
                Chewie(controller: _chewieControllers[sliderId]!)
              else
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE50914)),
                  ),
                ),

              // Title overlay
              if (title.isNotEmpty)
                Positioned(
                  right: 24,
                  bottom: 60,
                  left: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          );
        }
      } else if (videoType == 'direct') {
        // 📹 فيديو مباشر (MP4/M3U8) - عرض صورة مع زر تشغيل
        return _buildImageSlider(imageUrl, title, videoUrl, isVideo: true);
      }
    }

    // Fallback to image with click handler
    return _buildImageSlider(imageUrl, title, url.isNotEmpty ? url : videoUrl);
  }

  /// 🖼️ بناء سلايد صورة (للصور العادية أو الفيديوهات التي تحتاج صورة مصغرة)
  Widget _buildImageSlider(String imageUrl, String title, String actionUrl,
      {bool isVideo = false}) {
    return GestureDetector(
      onTap: () => _handleSliderTap(actionUrl, title),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: const Color(0xFF121212),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE50914),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFF121212),
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.white38,
                size: 60,
              ),
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // 🎬 علامة فيديو (إذا كان فيديو)
          if (isVideo)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),

          // Title and button
          if (title.isNotEmpty)
            Positioned(
              right: 24,
              bottom: 60,
              left: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  if (actionUrl.isNotEmpty)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _handleSliderTap(actionUrl, title),
                      icon: Icon(
                        isVideo ? Icons.play_arrow : Icons.open_in_new,
                        color: Colors.white,
                      ),
                      label: Text(
                        isVideo ? 'شاهد الآن' : 'المزيد',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _initializeVideoPlayer(
      int sliderId, String vimeoId, String title) async {
    try {
      print('🎬 Initializing video player for slider $sliderId, Vimeo: $vimeoId');

      // Get video configuration
      final config = await _vimeoService.getVideoConfig(vimeoId);
      if (config == null) {
        print('❌ Failed to get Vimeo config for $vimeoId');
        return;
      }

      // Get video URL (prefer HLS)
      String? videoUrl;
      if (config.hlsUrl != null) {
        videoUrl = config.hlsUrl;
      } else if (config.qualities.isNotEmpty) {
        // Use 720p or first available quality
        final quality = config.qualities.firstWhere(
          (q) => q.height == 720,
          orElse: () => config.qualities.first,
        );
        videoUrl = quality.url;
      }

      if (videoUrl == null) {
        print('❌ No playable URL found for $vimeoId');
        return;
      }

      print('✅ Got video URL: ${videoUrl.substring(0, 50)}...');

      // Create video controller
      final videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: {
          'Referer': 'https://alenwan.app',
          'User-Agent': 'Alenwan Mobile App',
        },
      );

      await videoController.initialize();

      // Create Chewie controller for inline playback (no fullscreen forcing)
      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        looping: true,
        allowFullScreen: false, // Keep it inline
        showControls: true,
        showControlsOnInitialize: false,
        aspectRatio: videoController.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFE50914),
          handleColor: const Color(0xFFE50914),
          bufferedColor: Colors.white.withValues(alpha: 0.3),
          backgroundColor: Colors.white.withValues(alpha: 0.2),
        ),
      );

      if (mounted) {
        setState(() {
          _videoControllers[sliderId] = videoController;
          _chewieControllers[sliderId] = chewieController;
        });
      }

      print('✅ Video player initialized for slider $sliderId');
    } catch (e) {
      print('❌ Error initializing video for slider $sliderId: $e');
    }
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _sliders.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? const Color(0xFFE50914)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double height) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF0A0A0A),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_creation_outlined,
            color: Colors.white.withValues(alpha: 0.3),
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد عروض حالياً',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSliderTap(String url, String title) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد رابط متاح'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if it's a Vimeo URL
    if (url.contains('vimeo.com')) {
      final vimeoId = _extractVimeoId(url);
      if (vimeoId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: Text(title.isNotEmpty ? title : 'تشغيل الفيديو'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Center(
                child: VimeoPlayerWidget(
                  vimeoId: vimeoId,
                  contentId: 'slider_$vimeoId',
                  title: title,
                ),
              ),
            ),
          ),
        );
        return;
      }
    }

    // Check if it's a direct video URL (.mp4, .m3u8)
    if (_isDirectVideoUrl(url)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            url: url,
            title: title.isNotEmpty ? title : 'تشغيل الفيديو',
          ),
        ),
      );
      return;
    }

    // For YouTube or other URLs, open in external app
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح الرابط'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isDirectVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.m3u8') ||
        lowerUrl.contains('.mp4?') ||
        lowerUrl.contains('.m3u8?');
  }

  String? _extractVimeoId(String url) {
    // Extract Vimeo ID from URL
    // Example: https://vimeo.com/1110521673 -> 1110521673
    final RegExp vimeoRegex = RegExp(r'vimeo\.com/(\d+)');
    final match = vimeoRegex.firstMatch(url);
    return match?.group(1);
  }

  String? _extractYoutubeId(String url) {
    // Extract YouTube ID from various URL formats
    // Examples:
    // https://www.youtube.com/watch?v=VIDEO_ID
    // https://youtu.be/VIDEO_ID
    // https://www.youtube.com/embed/VIDEO_ID
    final RegExp youtubeRegex = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = youtubeRegex.firstMatch(url);
    return match?.group(1);
  }
}
