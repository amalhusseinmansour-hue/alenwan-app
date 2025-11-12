import 'package:alenwan/config.dart';

class UrlUtils {
  static String get hostBase => AppConfig.domain; // ✅ بدل ما يكون ثابت

  static String normalize(String? path, {String placeholder = ''}) {
    if (path == null || path.isEmpty) {
      return placeholder.isEmpty
          ? 'https://via.placeholder.com/300x450'
          : placeholder;
    }

    var p = path.trim();
    if (p.startsWith('//')) p = 'https:$p';

    if (p.startsWith('http')) {
      return p.replaceFirst(
        RegExp(r'^https?:\/\/(127\.0\.0\.1|localhost)(:\d+)?'),
        hostBase,
      );
    }

    if (p.startsWith('/')) p = p.substring(1);
    if (!p.startsWith('storage/')) p = 'storage/$p';
    return '$hostBase/$p';
  }
}
