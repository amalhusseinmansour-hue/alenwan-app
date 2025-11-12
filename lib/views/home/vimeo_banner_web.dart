import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

class VimeoBanner extends StatelessWidget {
  // نفس الواجهة بالضبط – حتى لو مش هنستخدم كل الحقول هنا
  final String? vimeoId; // المهم للويب
  final String? hlsUrl; // غير مستخدم
  final String? placeholderUrl; // احتياطي
  final String? title;
  final String? subtitle;
  final String? buttonText;

  const VimeoBanner({
    super.key,
    this.vimeoId,
    this.hlsUrl,
    this.placeholderUrl,
    this.title,
    this.subtitle,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final id = (vimeoId ?? '').trim();
    if (id.isEmpty) {
      final ph = (placeholderUrl ?? '').trim();
      return SizedBox(
        height: (MediaQuery.of(context).size.width * 9 / 16) * .70,
        width: double.infinity,
        child: ph.isNotEmpty
            ? Image.network(ph,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black))
            : Container(color: Colors.black),
      );
    }

    final viewType = 'vimeo-iframe-$id';
    final src =
        'https://player.vimeo.com/video/$id?autoplay=1&muted=1&loop=1&controls=0&playsinline=1&background=1';

    final iframe = html.IFrameElement()
      ..src = src
      ..style.border = '0'
      ..allow = 'autoplay; fullscreen; picture-in-picture'
      ..allowFullscreen = true;

    ui_web.platformViewRegistry
        .registerViewFactory(viewType, (int _) => iframe);

    return Stack(
      children: [
        HtmlElementView(viewType: viewType),
        // نصوص اختيارية
        if ((title ?? '').isNotEmpty || (subtitle ?? '').isNotEmpty)
          Positioned(
            right: 20,
            bottom: 40,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if ((title ?? '').isNotEmpty)
                    Text(title!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                  if ((subtitle ?? '').isNotEmpty)
                    Text(subtitle!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),
                  if ((buttonText ?? '').isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(buttonText!,
                          style: const TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
