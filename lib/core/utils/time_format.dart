// lib/core/utils/time_format.dart
String formatDuration(int seconds) {
  final d = Duration(seconds: seconds);
  String two(int n) => n.toString().padLeft(2, '0');
  if (d.inHours > 0) {
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }
  return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
}
