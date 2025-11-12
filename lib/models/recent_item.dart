// lib/models/recent_item.dart
import 'media_item.dart';

class RecentItem {
  final MediaItem media;
  final DateTime addedAt; // متى أُضيف العنصر

  RecentItem({
    required this.media,
    required this.addedAt,
  });

  factory RecentItem.fromJson(Map<String, dynamic> json) {
    return RecentItem(
      media: MediaItem.fromJson(json),
      addedAt: _asDate(json['added_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...media.toJson(),
      'added_at': addedAt.toIso8601String(),
    };
  }

  // ✅ Getters لتسهيل الوصول مباشرة من RecentItem
  int get id => media.id;
  String get title => media.title;
  String? get description => media.description;
  String? get posterUrl => media.posterUrl;
  String? get backdropUrl => media.backdropUrl;
  String get type => media.type.nameStr;
  String? get subtitle => media.description;
  String? get image => media.posterUrl;

  // لو احتجت تستعمل الـ [] زي قبل
  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'title':
        return title;
      case 'description':
        return description;
      case 'poster_url':
      case 'posterUrl':
        return posterUrl;
      case 'backdrop_url':
      case 'backdropUrl':
        return backdropUrl;
      case 'type':
        return type;
      case 'subtitle':
        return subtitle;
      case 'image':
        return image;
      case 'added_at':
        return addedAt;
      default:
        return null;
    }
  }
}

DateTime _asDate(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString()) ?? DateTime.now();
}
