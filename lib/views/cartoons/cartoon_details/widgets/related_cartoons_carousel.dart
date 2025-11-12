import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/cartoon_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/utils/url_utils.dart';
import 'hover_poster_card.dart';

class RelatedCartoonsCarousel extends StatelessWidget {
  final int currentCartoonId;
  const RelatedCartoonsCarousel({super.key, required this.currentCartoonId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartoonController>(
      builder: (_, ctrl, __) {
        final items =
            ctrl.cartoons.where((m) => m.id != currentCartoonId).toList();
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
                final img = UrlUtils.normalize(m.posterPath ?? m.bannerPath);
                return HoverPosterCard(
                  title: m.title,
                  image: img,
                  width: cardW,
                  height: cardH,
                  gap: gap,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.cartoonDetails,
                    arguments: m.id,
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
