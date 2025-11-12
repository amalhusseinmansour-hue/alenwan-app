import 'package:flutter/material.dart';

class HoverPosterCard extends StatefulWidget {
  final String title;
  final String image;
  final double width;
  final double height;
  final double gap;
  final VoidCallback onTap;

  const HoverPosterCard({
    super.key,
    required this.title,
    required this.image,
    required this.width,
    required this.height,
    required this.gap,
    required this.onTap,
  });

  @override
  State<HoverPosterCard> createState() => _HoverPosterCardState();
}

class _HoverPosterCardState extends State<HoverPosterCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final Matrix4 xform = _hover
        ? (Matrix4.identity()
          // ignore: deprecated_member_use
          ..translate(0.0, -6.0)
          // ignore: deprecated_member_use
          ..scale(1.06))
        : Matrix4.identity();

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: widget.gap / 2),
        transform: xform,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const [],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: widget.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.image,
                    height: widget.height,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: widget.height,
                      color: Colors.grey.shade800,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
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
