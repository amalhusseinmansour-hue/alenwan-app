import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HoverPosterCard extends StatefulWidget {
  const HoverPosterCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
    required this.width,
    required this.height,
    this.badge,
  });

  final String title;
  final String imageUrl;
  final VoidCallback onTap;
  final double width;
  final double height;
  final String? badge; // ✅ متغيّر جديد

  @override
  State<HoverPosterCard> createState() => _HoverPosterCardState();
}

class _HoverPosterCardState extends State<HoverPosterCard> {
  bool _hover = false;
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final transform =
        // ignore: deprecated_member_use
        _hover ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity();
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: transform,
        margin: const EdgeInsets.symmetric(vertical: 4),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const [],
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedOpacity(
                  opacity: _loaded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.grey.shade900,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.broken_image, color: Colors.white54),
                    imageBuilder: (context, provider) {
                      if (!_loaded) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _loaded = true);
                        });
                      }
                      return Image(image: provider, fit: BoxFit.cover);
                    },
                  ),
                ),
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: _hover
                            ? [
                                // ignore: deprecated_member_use
                                Colors.black.withValues(alpha: 0.55),
                                Colors.transparent,
                              ]
                            : [
                                // ignore: deprecated_member_use
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          // ignore: deprecated_member_use
                          color: Colors.black.withValues(alpha: 0.35),
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          child: Text(
                            widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
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
