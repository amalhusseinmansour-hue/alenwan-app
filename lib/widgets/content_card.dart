import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../views/home/enhanced_home_screen.dart';

class ContentCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String? rating;
  final String? year;
  final bool isPremium;
  final ContentCardType cardType;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ContentCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.rating,
    this.year,
    this.isPremium = false,
    this.cardType = ContentCardType.poster,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.cardType == ContentCardType.backdrop ? 200.0 : 120.0;
    final height = widget.cardType == ContentCardType.backdrop ? 120.0 : 180.0;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: width,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image container
                    Stack(
                      children: [
                        Container(
                          width: width,
                          height: height,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _isHovered
                                ? [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: widget.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  _buildPlaceholder(),
                              errorWidget: (context, url, error) =>
                                  _buildErrorWidget(),
                            ),
                          ),
                        ),

                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Premium badge
                        if (widget.isPremium)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        // Rating badge
                        if (widget.rating != null)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.rating!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Play button overlay (on hover)
                        if (_isHovered)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black.withOpacity(0.4),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Title and info
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.year != null)
                      Text(
                        widget.year!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.red.shade400),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie, color: Colors.grey.shade700, size: 30),
          const SizedBox(height: 4),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
