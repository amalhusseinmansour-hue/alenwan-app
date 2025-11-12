// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// هذا هو الصحيح على الويب:
import 'dart:ui_web' as ui;

void registerIFrame(String viewType, String url) {
  // بعض المحللات تحتاج هذا التعليق لأن الرمز متاح فقط على الويب
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final el = html.IFrameElement()
      ..src = url
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'autoplay; fullscreen; picture-in-picture'
      ..allowFullscreen = true
      ..setAttribute('frameborder', '0')
      ..setAttribute('allowfullscreen', 'true');
    return el;
  });
}
