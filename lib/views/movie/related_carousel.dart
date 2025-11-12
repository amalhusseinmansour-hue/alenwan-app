// lib/views/movie/related_carousel.dart
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:path/path.dart' as UrlUtils;
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../controllers/movie_controller.dart';
import 'hover_poster_card.dart';

class RelatedCarousel extends StatelessWidget {
  final int currentMovieId;
  const RelatedCarousel({super.key, required this.currentMovieId});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieController>(
      builder: (_, ctrl, __) {
        final items = ctrl.movies.where((m) => m.id != currentMovieId).toList();
        if (items.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text('لا يوجد محتوى متعلق الآن',
                  style: TextStyle(color: Colors.white54)),
            ),
          );
        }

        return LayoutBuilder(builder: (_, c) {
          double w = c.maxWidth;
          double cardW;
          if (w >= 1600) {
            cardW = 200;
          } else if (w >= 1400) {
            cardW = 185;
          } else if (w >= 1200) {
            cardW = 170;
          } else if (w >= 900) {
            cardW = 155;
          } else if (w >= 600) {
            cardW = 140;
          } else {
            cardW = 120;
          }
          final cardH = cardW * 1.46;
          const gap = 14.0;
          final sliderH = (cardH * 1.08) + 40;

          return SizedBox(
            height: sliderH,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final m = items[i];
                final img =
                    UrlUtils.normalize(m.posterPath ?? m.bannerPath!); // ✅ هنا
                return HoverPosterCard(
                  title: m.title,
                  image: img,
                  width: cardW,
                  height: cardH,
                  gap: gap,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.movieDetails,
                    arguments: m,
                  ),
                );
              },
            ),
          );
        });
      },
    );
  }
}
