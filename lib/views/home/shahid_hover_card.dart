import 'package:flutter/material.dart';

class ShahidHoverCard extends StatefulWidget {
  final double width;
  final double height;
  final String imageUrl;
  final String title;
  final String badge;
  final String? subtitle;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onFav;
  final VoidCallback? onDownload;

  const ShahidHoverCard({
    super.key,
    required this.width,
    required this.height,
    required this.imageUrl,
    required this.title,
    required this.badge,
    this.subtitle,
    this.isFavorite = false,
    this.onTap,
    this.onPlay,
    this.onFav,
    this.onDownload,
  });

  @override
  State<ShahidHoverCard> createState() => _ShahidHoverCardState();
}

class _ShahidHoverCardState extends State<ShahidHoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (h) => setState(() => _hovered = h),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(widget.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            if (_hovered)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(widget.badge,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
            if (_hovered)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: widget.onPlay,
                      icon: const Icon(Icons.play_circle,
                          color: Colors.white, size: 28),
                    ),
                    if (widget.onFav != null)
                      IconButton(
                        onPressed: widget.onFav,
                        icon: Icon(
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.redAccent,
                        ),
                      ),
                    if (widget.onDownload != null)
                      IconButton(
                        onPressed: widget.onDownload,
                        icon: const Icon(Icons.download,
                            color: Colors.white, size: 22),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
