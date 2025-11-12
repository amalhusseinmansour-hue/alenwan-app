// lib/views/home/shahid_hero_banner.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// على الويب يستخدم register_iframe_web، وإلا stub
import 'package:alenwan/web/register_iframe_stub.dart'
    if (dart.library.html) 'package:alenwan/web/register_iframe_web.dart'
    as iframe;

class ShahidHeroBanner extends StatefulWidget {
  final String vimeoId;
  final String title;
  final String? subtitle;
  final String ctaText;
  final VoidCallback? onWatch;
  final VoidCallback? onMore;
  final bool isLive;
  final double overlayOpacity;

  /// اختياري للتشخيص: يعرض شارة صغيرة “api / fallback”
  final String? debugLabel;

  const ShahidHeroBanner({
    super.key,
    required this.vimeoId,
    required this.title,
    this.subtitle,
    this.ctaText = 'شاهد الآن',
    this.onWatch,
    this.onMore,
    this.isLive = false,
    this.overlayOpacity = .35,
    this.debugLabel,
  });

  @override
  State<ShahidHeroBanner> createState() => _ShahidHeroBannerState();
}

class _ShahidHeroBannerState extends State<ShahidHeroBanner> {
  String _viewType = '';
  String _url = '';

  double _heroH(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    final h = MediaQuery.of(c).size.height;

    if (w > 1200) return h * 0.8; // شاشات كبيرة
    if (w > 800) return h * 0.6; // متوسطة
    return (w * 9 / 16).clamp(240.0, 500.0); // موبايل
  }

  void _register() {
    _viewType =
        'vimeo-${widget.vimeoId}-${DateTime.now().millisecondsSinceEpoch}';
    _url =
        'https://player.vimeo.com/video/${widget.vimeoId}'
        '?autoplay=1&muted=1&loop=1&background=1&controls=0&playsinline=1&autopause=0';

    if (kIsWeb) {
      iframe.registerIFrame(_viewType, _url);
    }
  }

  @override
  void initState() {
    super.initState();
    _register();
  }

  @override
  void didUpdateWidget(covariant ShahidHeroBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vimeoId != widget.vimeoId) {
      _register();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = _heroH(context);
    final overlay = (widget.overlayOpacity == 0 ? .35 : widget.overlayOpacity)
        .clamp(0.0, 0.6);

    if (!kIsWeb) {
      return Container(
        height: h,
        color: const Color(0xFF121212),
        alignment: Alignment.center,
        child: const Text(
          'الفيديو يظهر على الويب فقط',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// ✅ الفيديو يملأ الشاشة بالكامل
          SizedBox.expand(child: HtmlElementView(viewType: _viewType)),

          /// طبقة تعتيم
          Container(color: Colors.black.withValues(alpha: overlay)),

          /// Gradient من اليمين لليسار
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Colors.black54, Colors.transparent],
                  stops: [0.0, 0.55],
                ),
              ),
            ),
          ),

          /// شارة Debug (اختياري)
          if ((widget.debugLabel ?? '').isNotEmpty)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.debugLabel!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),

          /// النصوص + CTA
          Positioned(
            right: 24,
            left: 24,
            bottom: 30,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'مباشر',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      fontSize: 34,
                    ),
                  ),
                  if ((widget.subtitle ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: widget.onWatch,
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: Text(
                      widget.ctaText,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
