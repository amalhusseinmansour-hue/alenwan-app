import 'package:alenwan/core/services/api_client.dart';
import 'package:alenwan/models/movie_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alenwan/routes/app_routes.dart';
import '../../controllers/movie_controller.dart';
import '../../core/theme/professional_theme.dart';

class _DragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

class HoverMediaCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const HoverMediaCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.badge,
    this.onTap,
    this.width = 200,
    this.height = 300,
    required String posterPath,
    required double gap,
  });

  @override
  State<HoverMediaCard> createState() => _HoverMediaCardState();
}

class _HoverMediaCardState extends State<HoverMediaCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Stack(
            children: [
              // الصورة
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: ProfessionalTheme.surfaceCard,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ProfessionalTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: ProfessionalTheme.surfaceCard,
                    child: const Icon(
                      Icons.broken_image,
                      color: ProfessionalTheme.textTertiary,
                    ),
                  ),
                ),
              ),

              // البادج Badge
              if (widget.badge != null && widget.badge!.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ProfessionalTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // النصوص أسفل الكارت
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _hover ? 1 : 0.9,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ProfessionalTheme.labelMedium(
                            color: ProfessionalTheme.textPrimary,
                          ),
                        ),
                        if ((widget.subtitle ?? '').isNotEmpty)
                          Text(
                            widget.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ProfessionalTheme.labelSmall(
                              color: ProfessionalTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoviesContent extends StatelessWidget {
  const MoviesContent({super.key});
  String _pickBestImageUrl(String? raw) {
    if (raw == null) return '';
    // أزل الأسطر الجديدة والمسافات الزائدة
    final text = raw
        .replaceAll('\\n', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .trim();

    // قسّم على أي مسافات
    final parts = text.split(RegExp(r'\s+'));

    // التقط فقط العناصر اللي تبدأ بـ http/https
    final urls = parts
        .where((t) => t.startsWith('http://') || t.startsWith('https://'))
        .toList();
    if (urls.isEmpty) return '';

    // فضّل الروابط التي تبدو صورًا (jpg/png/webp/gif)
    final img = urls.firstWhere(
      (u) => RegExp(
        r'\.(jpg|jpeg|png|webp|gif)(\?.*)?$',
        caseSensitive: false,
      ).hasMatch(u),
      orElse: () =>
          urls.first, // لو مافي امتداد صورة خذ أول رابط (لسه بنفلتر لاحقًا)
    );

    // تجاهل الـ m3u8 إن وُجد
    if (img.toLowerCase().contains('.m3u8')) {
      final alt = urls.firstWhere(
        (u) => !u.toLowerCase().contains('.m3u8'),
        orElse: () => '',
      );
      return alt;
    }
    return img;
  }

  String _full(String? path) {
    final filesBase = ApiClient().filesBaseUrl; // https://domain
    final cleaned = _pickBestImageUrl(path);

    // لو لقينا رابط خارجي صالح (https/ http) رجّعه بعد استبدال localhost إن لزم
    if (cleaned.isNotEmpty &&
        (cleaned.startsWith('http://') || cleaned.startsWith('https://'))) {
      // استبدل 127.0.0.1/localhost لو ظهروا
      return cleaned.replaceFirst(
        RegExp(r'^http://(127\.0\.0\.1|localhost)(:\d+)?'),
        filesBase,
      );
    }

    // مسار داخلي → أضف storage و base
    if (cleaned.isNotEmpty) {
      final p = cleaned.startsWith('/') ? cleaned.substring(1) : cleaned;
      final withStorage = p.startsWith('storage/') ? p : 'storage/$p';
      return '$filesBase/$withStorage';
    }

    // fallback
    return 'https://via.placeholder.com/300x450?text=Movie';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: ProfessionalTheme.primaryColor,
            ),
          );
        }
        if (controller.error != null) {
          return Center(
            child: Text(
              'حدث خطأ: ${controller.error}',
              style: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.errorColor,
              ),
            ),
          );
        }
        if (controller.movies.isEmpty) {
          return Center(
            child: Text(
              'لا توجد أفلام متاحة',
              style: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.textSecondary,
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;

            // padding أفقي متدرّج حسب العرض
            final double hPad = w >= 1400
                ? 32
                : w >= 1100
                ? 24
                : 16;

            // عدد أعمدة مستهدف (لضبط عرض البطاقة والمسافات)
            int cols;
            if (w >= 1600) {
              cols = 7;
            } else if (w >= 1400) {
              cols = 6;
            } else if (w >= 1200) {
              cols = 5;
            } else if (w >= 900) {
              cols = 4;
            } else if (w >= 700) {
              cols = 3;
            } else {
              cols = 2;
            }

            // المسافة بين البطاقات
            final double gap = w >= 1600
                ? 20
                : w >= 1200
                ? 18
                : w >= 900
                ? 16
                : w >= 600
                ? 12
                : 10;

            // عرض البطاقة بحيث تملأ الصف تمامًا
            final double innerWidth = w - (hPad * 2);
            final double cardW = (innerWidth - (gap * (cols - 1))) / cols;
            final double cardH = cardW * 1.5; // 2:3 تقريبًا
            final double sliderHeight = (cardH * 1.10) + 46;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(
                    context: context,
                    title: 'إصدارات جديدة',
                    items: controller.movies,
                    cardW: cardW,
                    cardH: cardH,
                    gap: gap,
                    sliderHeight: sliderHeight,
                    hPad: hPad,
                  ),
                  _section(
                    context: context,
                    title: 'أفضل الأفلام',
                    items: controller.movies.reversed.toList(),
                    cardW: cardW,
                    cardH: cardH,
                    gap: gap,
                    sliderHeight: sliderHeight,
                    hPad: hPad,
                  ),
                  _section(
                    context: context,
                    title: 'أفلام الأكشن',
                    items: controller.movies,
                    cardW: cardW,
                    cardH: cardH,
                    gap: gap,
                    sliderHeight: sliderHeight,
                    hPad: hPad,
                  ),
                  _section(
                    context: context,
                    title: 'كوميديا ممتعة',
                    items: controller.movies,
                    cardW: cardW,
                    cardH: cardH,
                    gap: gap,
                    sliderHeight: sliderHeight,
                    hPad: hPad,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _section({
    required BuildContext context,
    required String title,
    required List<MovieModel> items,
    required double cardW,
    required double cardH,
    required double gap,
    required double sliderHeight,
    required double hPad,
  }) {
    final controller = context.read<MovieController>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان يمين مع شُرطة حمراء
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: ProfessionalTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: ProfessionalTheme.headlineSmall(
                  color: ProfessionalTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: sliderHeight,
            child: ScrollConfiguration(
              behavior: _DragScrollBehavior(),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: hPad),
                itemCount: items.length + (controller.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // اللودر في النهاية
                  if (index >= items.length) {
                    return const SizedBox(
                      width: 64,
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  // طلب المزيد قبل النهاية بقليل
                  if (index >= items.length - 6) {
                    controller.loadMore();
                  }

                  final m = items[index];
                  final image = _full(m.posterPath ?? m.bannerPath);
                  return HoverMediaCard(
                    imageUrl: image,
                    title: m.title,
                    subtitle: m.description, // 👈 لو عندك
                    badge: 'فيلم',
                    width: cardW,
                    height: cardH,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.movieDetails,
                      arguments: m,
                    ),
                    posterPath: '',
                    gap: gap,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
