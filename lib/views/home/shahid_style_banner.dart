import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/slider_service.dart';

class ShahidStyleBanner extends StatefulWidget {
  const ShahidStyleBanner({super.key});

  @override
  State<ShahidStyleBanner> createState() => _ShahidStyleBannerState();
}

class _ShahidStyleBannerState extends State<ShahidStyleBanner> {
  final SliderService _sliderService = SliderService();
  List<Map<String, dynamic>> _sliders = [];
  bool _loading = true;
  int _currentIndex = 0;
  Timer? _autoPlayTimer;
  final PageController _pageController = PageController();


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
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted || _sliders.isEmpty) {
        timer.cancel();
        return;
      }

      final nextIndex = (_currentIndex + 1) % _sliders.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  double _heroH(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    final h = MediaQuery.of(ctx).size.height;
    if (w > 1200) return h * 0.75;
    if (w > 800) return h * 0.6;
    return (w * 9 / 16).clamp(280.0, 550.0);
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
              return _buildShahidStyleSlider(_sliders[index], h, index);
            },
          ),

          // Page indicators - Shahid style
          if (_sliders.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: _buildShahidIndicators(),
            ),
        ],
      ),
    );
  }

  Widget _buildShahidStyleSlider(Map<String, dynamic> slider, double height, int index) {
    final imageUrl = slider['image']?.toString() ?? '';
    final title = _parseTitle(slider['title']);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image with gradient
        CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: const Color(0xFF0F0F0F),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE50914),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            print('Error loading image: $imageUrl');
            print('Error: $error');
            return Container(
              color: const Color(0xFF0F0F0F),
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.white38,
                size: 60,
              ),
            );
          },
        ),

        // Multi-layer gradient overlay - Shahid style
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.5),
                Colors.black.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.95),
              ],
              stops: const [0.0, 0.4, 0.75, 1.0],
            ),
          ),
        ),

        // Title only - no buttons (just image slider)
        if (title.isNotEmpty)
          Positioned(
            right: 32,
            left: 32,
            bottom: 80,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
      ],
    );
  }

  Widget _buildShahidIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _sliders.length,
        (index) {
          final isActive = _currentIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFE50914)
                  : Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE50914).withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          );
        },
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

  String _parseTitle(dynamic titleData) {
    if (titleData == null) return '';

    if (titleData is String) {
      // Try to parse as JSON
      try {
        final decoded = titleData;
        if (decoded.contains('"ar"')) {
          // Extract Arabic title from JSON string
          final match = RegExp(r'"ar":"([^"]*)"').firstMatch(decoded);
          if (match != null) {
            return match.group(1)!
                .replaceAll(r'\u0', '\\u0')
                .replaceAllMapped(
                  RegExp(r'\\u([0-9a-fA-F]{4})'),
                  (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
                );
          }
        }
        return titleData;
      } catch (e) {
        return titleData;
      }
    }

    return titleData.toString();
  }
}
