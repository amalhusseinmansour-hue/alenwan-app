import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../routes/app_routes.dart';
import '../../controllers/sport_controller.dart';
import '../../models/sport_model.dart';
import '../../core/theme/professional_theme.dart';

// نفس قاعدة الصور المستخدمة في الهوم
import 'package:alenwan/core/services/api_client.dart';

/// يبني رابط الصورة للرياضة بنفس منطق الهوم:
/// - لو الرابط http/https يبقى كما هو (مع استبدال localhost فقط).
/// - لو مسار نسبي نركبه على filesBaseUrl.
/// - نحذف لاحقة المقاس -300x450 إن وُجدت في نهاية الاسم.
String _sportImageUrl(String? path) {
  if (path == null || path.trim().isEmpty) {
    return 'https://via.placeholder.com/300x450';
  }

  final filesBase = ApiClient().filesBaseUrl; // مثال: https://your-domain.com
  var p = path.trim();

  if (p.startsWith('//')) p = 'https:$p';

  if (p.startsWith('http')) {
    // استبدال أي localhost بـ النطاق الفعلي (فقط عند الحاجة)
    p = p.replaceFirst(
      RegExp(r'^https?:\/\/(127\.0\.0\.1|localhost)(:\d+)?'),
      filesBase,
    );
    // إزالة لاحقة المقاسات إن وجدت
    p = p.replaceFirst(RegExp(r'-\d+x\d+(?=\.\w+$)'), '');
    return p;
  }

  // relative
  if (p.startsWith('/')) p = p.substring(1);
  if (!p.startsWith('storage/')) p = 'storage/$p';
  p = p.replaceFirst(RegExp(r'-\d+x\d+(?=\.\w+$)'), '');
  return '$filesBase/$p';
}

/// كارت عنصر (أسلوب الكرتون/الوثائقيات)
class HoverMediaCardSport extends StatefulWidget {
  final String imageUrl;
  final String title;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double gap;
  final String? badge; // اختياري
  final double badgeOpacity; // اختياري

  const HoverMediaCardSport({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.width,
    required this.height,
    this.onTap,
    this.gap = 14,
    this.badge,
    this.badgeOpacity = .65,
  });

  @override
  State<HoverMediaCardSport> createState() => _HoverMediaCardSportState();
}

class _HoverMediaCardSportState extends State<HoverMediaCardSport> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    // تقليل استخدام الذاكرة لتحذيرات ImageReader_JNI
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetW = (widget.width * dpr).round();
    final targetH = (widget.height * dpr).round();

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        margin: EdgeInsets.symmetric(horizontal: widget.gap / 2),
        // ignore: deprecated_member_use
        transform: _hover
            // ignore: deprecated_member_use
            ? (Matrix4.identity()..scale(1.06, 1.06))
            : Matrix4.identity(),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // يمنع Overflow داخل خلايا الجريد/الليست
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          memCacheWidth: targetW,
                          memCacheHeight: targetH,
                          filterQuality: FilterQuality.low,
                          placeholder: (_, __) => Container(
                            color: ProfessionalTheme.surfaceCard,
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ProfessionalTheme.primaryColor,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: ProfessionalTheme.surfaceCard,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image,
                              color: ProfessionalTheme.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      if (widget.badge != null && widget.badge!.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(
                                alpha: widget.badgeOpacity,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      Positioned.fill(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: _hover
                                  ? [
                                      Colors.black.withValues(alpha: 0.55),
                                      Colors.transparent,
                                    ]
                                  : [
                                      Colors.black.withValues(alpha: 0.35),
                                      Colors.transparent,
                                    ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: ProfessionalTheme.labelMedium(
                      color: ProfessionalTheme.textPrimary,
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

class SportsContent extends StatelessWidget {
  const SportsContent({super.key});

  String _imageFor(SportModel s) {
    // جرّب أفضل المتوفر: posterUrl ثم bannerUrl (المتوافقة مع الـ API)
    final raw = (s.posterUrl != null && s.posterUrl!.isNotEmpty)
        ? s.posterUrl!
        : (s.bannerUrl ?? '');
    return _sportImageUrl(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SportController>(
      builder: (_, ctrl, __) {
        if (ctrl.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.error != null) {
          return Center(
            child: Text(
              'حدث خطأ: ${ctrl.error}',
              style: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.errorColor,
              ),
            ),
          );
        }
        if (ctrl.sports.isEmpty) {
          return Center(
            child: Text(
              'لا توجد عناصر رياضية حالياً',
              style: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.textSecondary,
              ),
            ),
          );
        }

        final items = ctrl.sports;

        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final useGrid = w >= 900;
            const gap = 14.0;
            final double cardW = (w / 6).clamp(130, 210).toDouble();
            final double cardH = cardW * 1.46;

            Widget section(String title, List<SportModel> list) {
              if (list.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        8,
                        16,
                        0,
                      ),
                      child: Row(
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
                    ),
                    const SizedBox(height: 12),
                    if (useGrid)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: cardW + gap,
                          crossAxisSpacing: gap,
                          mainAxisSpacing: gap,
                          childAspectRatio: cardW / cardH,
                        ),
                        itemBuilder: (_, i) {
                          final s = list[i];
                          return HoverMediaCardSport(
                            imageUrl: _imageFor(s),
                            title: s.title.isEmpty ? 'بدون عنوان' : s.title,
                            width: cardW,
                            height: cardH,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.sportDetails,
                              arguments: s,
                            ),
                          );
                        },
                      )
                    else
                      SizedBox(
                        height: cardH * 1.12,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final s = list[i];
                            return SizedBox(
                              width: cardW,
                              child: HoverMediaCardSport(
                                imageUrl: _imageFor(s),
                                title:
                                    s.title.isNotEmpty ? s.title : 'بدون عنوان',
                                width: cardW,
                                height: cardH,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.sportDetails,
                                  arguments: s.id, // بدل s
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  section('بث مباشر ومباريات قادمة', items),
                  section(
                    'المباريات التحضيرية للموسم',
                    items.reversed.toList(),
                  ),
                  section('أفضل اللقطات', items),
                  section('وثائقيات رياضية', items),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
