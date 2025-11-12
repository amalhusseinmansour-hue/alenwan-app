import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MediaPosterCard extends StatefulWidget {
  final String id; // ممكن تستخدمه كـ argument عند التنقل
  final String title;
  final String imageUrl;
  final String? route; // اختياري: اسم الـ Route للتنقل
  final double borderRadius;
  final double scaleOnHover;

  const MediaPosterCard({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    this.route,
    this.borderRadius = 12,
    this.scaleOnHover = 1.1,
  });

  @override
  State<MediaPosterCard> createState() => _MediaPosterCardState();
}

class _MediaPosterCardState extends State<MediaPosterCard> {
  bool _isHovered = false;
  bool _imageLoaded = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        transform: _isHovered
            // ignore: deprecated_member_use
            ? (Matrix4.identity()..scale(widget.scaleOnHover))
            : Matrix4.identity(),
        child: GestureDetector(
          onTap: () {
            if (widget.route != null) {
              Navigator.pushNamed(context, widget.route!, arguments: widget.id);
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // صورة الخلفية مع Fade-In
                AnimatedOpacity(
                  opacity: _imageLoaded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl.isNotEmpty
                        ? widget.imageUrl
                        : 'https://via.placeholder.com/300x450?text=No+Image',
                    fit: BoxFit.cover,
                    placeholder: (ctx, _) => Container(
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.broken_image, color: Colors.red),
                    imageBuilder: (context, imageProvider) {
                      if (!_imageLoaded) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _imageLoaded = true);
                        });
                      }
                      return Image(image: imageProvider, fit: BoxFit.cover);
                    },
                  ),
                ),

                // تدرج لوني علوي/سفلي
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // العنوان مع Blur خلفي
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
