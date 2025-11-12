import 'dart:ui' as ui;
import 'package:alenwan/models/cartoon_model.dart';
import 'package:alenwan/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/url_utils.dart'; // 👈 نستخدم نفس normalize

class CartoonCard extends StatefulWidget {
  final CartoonModel cartoon;
  final double width;
  final double height;

  const CartoonCard({
    super.key,
    required this.cartoon,
    this.width = 150,
    this.height = 220,
  });

  @override
  State<CartoonCard> createState() => _CartoonCardState();
}

class _CartoonCardState extends State<CartoonCard> {
  bool _isHovered = false;
  bool _imageLoaded = false;

  @override
  Widget build(BuildContext context) {
    final imageUrl = UrlUtils.normalize(
      widget.cartoon.posterPath?.isNotEmpty == true
          ? widget.cartoon.posterPath
          : widget.cartoon.bannerPath,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        // ignore: deprecated_member_use
        transform: _isHovered
            // ignore: deprecated_member_use
            ? (Matrix4.identity()..scale(1.06, 1.06))
            : Matrix4.identity(),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.cartoonDetails,
              arguments: widget.cartoon.id,
            );
          },
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // صورة الخلفية مع Fade-In
                  AnimatedOpacity(
                    opacity: _imageLoaded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade900,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image,
                        color: Colors.white30,
                        size: 30,
                      ),
                      imageBuilder: (context, provider) {
                        if (!_imageLoaded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _imageLoaded = true);
                          });
                        }
                        return Image(image: provider, fit: BoxFit.cover);
                      },
                    ),
                  ),

                  // تدرّج لوني أعلى/أسفل
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
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
                            color: Colors.black.withValues(alpha: 0.30),
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 10,
                            ),
                            child: Text(
                              widget.cartoon.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
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
      ),
    );
  }
}
