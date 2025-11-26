// lib/views/documentaries/documentaries_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/documentary_controller.dart';
import '../../models/documentary_model.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/professional_theme.dart';
import 'package:alenwan/core/services/api_client.dart';

class HoverMediaCardDocumentary extends StatefulWidget {
  final String imageUrl;
  final String title;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double gap;
  final String? badge;
  final double badgeOpacity;

  const HoverMediaCardDocumentary({
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
  State<HoverMediaCardDocumentary> createState() =>
      _HoverMediaCardDocumentaryState();
}

class _HoverMediaCardDocumentaryState extends State<HoverMediaCardDocumentary> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
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
        transform: _hover
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

class DocumentariesContent extends StatelessWidget {
  const DocumentariesContent({super.key});

  String _documentaryImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return 'https://via.placeholder.com/300x450';
    }

    final filesBase = ApiClient().filesBaseUrl;
    var p = path.trim();

    if (p.startsWith('//')) p = 'https:$p';

    if (p.startsWith('http')) {
      p = p.replaceFirst(
        RegExp(r'^https?:\\/\\/(127\\.0\\.0\\.1|localhost)(:\\d+)?'),
        filesBase,
      );
      p = p.replaceFirst(RegExp(r'-\\d+x\\d+(?=\\.\\w+$)'), '');
      return p;
    }

    if (p.startsWith('/')) p = p.substring(1);
    if (!p.startsWith('storage/')) p = 'storage/$p';
    p = p.replaceFirst(RegExp(r'-\\d+x\\d+(?=\\.\\w+$)'), '');
    return '$filesBase/$p';
  }

  String _imageFor(Documentary d) {
    final raw = (d.posterPath.isNotEmpty) ? d.posterPath : d.bannerPath;
    return _documentaryImageUrl(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentaryController>(
      builder: (_, ctrl, __) {
        if (ctrl.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: ProfessionalTheme.primaryColor,
            ),
          );
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
        if (ctrl.documentaries.isEmpty) {
          return Center(
            child: Text(
              'لا توجد وثائقيات متاحة',
              style: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.textSecondary,
              ),
            ),
          );
        }

        final items = ctrl.documentaries;

        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final useGrid = w >= 900;
            const gap = 14.0;
            final double cardW = (w / 6).clamp(130, 210).toDouble();
            final double cardH = cardW * 1.46;

            Widget section(String title, List<Documentary> list) {
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
                          final d = list[i];
                          return HoverMediaCardDocumentary(
                            imageUrl: _imageFor(d),
                            title: d.title.isEmpty ? 'بدون عنوان' : d.title,
                            width: cardW,
                            height: cardH,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.documentaryDetails,
                              arguments: d,
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
                            final d = list[i];
                            return SizedBox(
                              width: cardW,
                              child: HoverMediaCardDocumentary(
                                imageUrl: _imageFor(d),
                                title:
                                    d.title.isNotEmpty ? d.title : 'بدون عنوان',
                                width: cardW,
                                height: cardH,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.documentaryDetails,
                                  arguments: d.id,
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
                  section('الأكثر مشاهدة', items),
                  section(
                    'جديد على المنصة',
                    items.reversed.toList(),
                  ),
                  section('مقترح لك', items),
                  section('وثائقيات تاريخية', items),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
