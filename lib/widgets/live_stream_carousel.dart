import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:alenwan/models/live_stream_model.dart';
import 'package:alenwan/core/theme/professional_theme.dart';

/// ✨ سلايدر البث المباشر - يمكن استخدامه في أي صفحة
class LiveStreamCarousel extends StatefulWidget {
  final List<LiveStreamModel> streams;
  final Function(LiveStreamModel)? onStreamTap;

  const LiveStreamCarousel({
    super.key,
    required this.streams,
    this.onStreamTap,
  });

  @override
  State<LiveStreamCarousel> createState() => _LiveStreamCarouselState();
}

class _LiveStreamCarouselState extends State<LiveStreamCarousel> {
  int _currentBanner = 0;

  String _bestThumb(LiveStreamModel s) {
    final thumb = s.thumbnail.trim();

    // ✅ تجاهل الـ default placeholder من السيرفر
    if (thumb.isNotEmpty &&
        thumb != 'default_youtube_thumbnail.jpg' &&
        !thumb.contains('placeholder') &&
        thumb.startsWith('http')) {
      return thumb;
    }

    if (thumb.isNotEmpty &&
        thumb != 'default_youtube_thumbnail.jpg' &&
        !thumb.contains('placeholder')) {
      return _fullFromServer(thumb);
    }

    // ✅ لو المصدر يوتيوب: اعرض صورة اليوتيوب
    if (s.sourceType.toLowerCase() == 'youtube') {
      final url = s.videoUrl?.isNotEmpty == true ? s.videoUrl! : s.streamUrl;
      final id = _youtubeIdFromUrl(url);
      if (id != null) {
        return 'https://img.youtube.com/vi/$id/maxresdefault.jpg';
      }
    }

    // ✅ لو المصدر فيميو: حاول استخراج ID
    if (s.sourceType.toLowerCase() == 'vimeo') {
      // Note: Vimeo thumbnails require API call, so we use a fallback
      return 'https://via.placeholder.com/500x300.png?text=Vimeo+Live';
    }

    // ✅ fallback
    return 'https://via.placeholder.com/500x300.png?text=Live+Stream';
  }

  String _fullFromServer(String path) {
    var p = path.trim();
    if (p.startsWith('http')) return p;
    if (p.startsWith('/')) p = p.substring(1);
    if (!p.startsWith('storage/')) p = 'storage/$p';
    return 'https://alenwan.app/$p';
  }

  String? _youtubeIdFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final reg = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11})');
    final match = reg.firstMatch(url);
    return match?.group(1);
  }

  String _getTitle(LiveStreamModel s) {
    // ✅ Try to get Arabic title first
    if (s.titleAr != null && s.titleAr!.isNotEmpty) {
      return s.titleAr!;
    }

    // ✅ Fallback to title
    if (s.title.isNotEmpty) {
      return s.title;
    }

    // ✅ Use channel name as last resort
    return s.channelName.isNotEmpty ? s.channelName : 'بث مباشر';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.streams.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CarouselSlider.builder(
              itemCount: widget.streams.length,
              itemBuilder: (context, index, realIndex) {
                final s = widget.streams[index];
                final thumbnail = _bestThumb(s);
                final title = _getTitle(s);

                return GestureDetector(
                  onTap: () => widget.onStreamTap?.call(s),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ✅ الصورة
                      CachedNetworkImage(
                        imageUrl: thumbnail,
                        fit: BoxFit.cover,
                        placeholder: (c, _) =>
                            Container(color: ProfessionalTheme.surfaceCard),
                        errorWidget: (c, u, e) => const Icon(
                          Icons.broken_image,
                          color: ProfessionalTheme.textTertiary,
                          size: 50,
                        ),
                      ),

                      // ✅ التدرج (Gradient)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              ProfessionalTheme.backgroundColor
                                  .withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),

                      // ✅ العنوان
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 18,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: ProfessionalTheme.headlineSmall(
                            color: Colors.white,
                          ).copyWith(
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ✅ شارة LIVE
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              options: CarouselOptions(
                height: 230,
                viewportFraction: 1,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                enlargeCenterPage: false,
                onPageChanged: (index, _) =>
                    setState(() => _currentBanner = index),
              ),
            ),
          ),
        ),

        // ✅ المؤشرات (Dots)
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.streams.length, (i) {
            final active = _currentBanner == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: active ? 20 : 6,
              decoration: BoxDecoration(
                color: active
                    ? ProfessionalTheme.primaryBrand
                    : ProfessionalTheme.textTertiary,
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
