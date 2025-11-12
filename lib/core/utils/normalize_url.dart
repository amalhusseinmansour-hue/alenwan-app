String normalizeUrl(String baseOrigin, String? path) {
  if (path == null || path.trim().isEmpty) return '';
  var p = path.trim();

  // /storage/...  أو  storage/...
  if (p.startsWith('/')) return '$baseOrigin$p';
  if (p.startsWith('storage/')) return '$baseOrigin/$p';

  // روابط كاملة: استبدل localhost/127.0.0.1 بـ IP السيرفر
  if (p.startsWith('http://') || p.startsWith('https://')) {
    return p.replaceFirst(
      RegExp(r'^http://(127\.0\.0\.1|localhost)(:\d+)?'),
      baseOrigin,
    );
  }

  // حالات /storage/https://...
  final httpsIdx = p.indexOf('https://');
  final httpIdx = p.indexOf('http://');
  final idx = httpsIdx >= 0 ? httpsIdx : (httpIdx >= 0 ? httpIdx : -1);
  if (idx >= 0) return p.substring(idx);

  return '$baseOrigin/$p';
}
