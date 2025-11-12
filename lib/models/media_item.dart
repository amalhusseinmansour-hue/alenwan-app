// lib/models/media_item.dart

enum MediaType { movie, series, documentary, livestream, sport, cartoon }

extension MediaTypeX on MediaType {
  static MediaType fromString(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'movie':
        return MediaType.movie;
      case 'series':
        return MediaType.series;
      case 'documentary':
        return MediaType.documentary;
      case 'livestream':
        return MediaType.livestream;
      case 'sport':
        return MediaType.sport;
      case 'cartoon':
        return MediaType.cartoon;
      default:
        return MediaType.movie;
    }
  }

  String get nameStr {
    switch (this) {
      case MediaType.movie:
        return 'movie';
      case MediaType.series:
        return 'series';
      case MediaType.documentary:
        return 'documentary';
      case MediaType.livestream:
        return 'livestream';
      case MediaType.sport:
        return 'sport';
      case MediaType.cartoon:
        return 'cartoon';
    }
  }
}

class MediaItem {
  final int id;
  final String title;
  final String? description;
  final String? posterUrl; // البوستر الرئيسي
  final String? backdropUrl; // البانر/الخلفية الكبيرة
  final List<String>? genres;
  final double? rating;
  final int? year;
  final MediaType type;

  // ملاحظة: بعض الأماكن تمرّر imageUrl، نقبله ونخزّنه كبوستر
  MediaItem({
    required this.id,
    required this.title,
    this.description,
    String? imageUrl, // <-- مقبول لتوافق الكود القديم
    String? posterUrl,
    this.backdropUrl,
    this.genres,
    this.rating,
    this.year,
    required this.type,
  }) : posterUrl = posterUrl ?? imageUrl;

  factory MediaItem.fromJson(Map<String, dynamic> j) {
    final poster = j['poster_url'] ??
        j['posterUrl'] ??
        j['poster'] ??
        j['thumbnail'] ??
        j['imageUrl'];

    final backdrop =
        j['banner_url'] ?? j['backdrop_url'] ?? j['backdrop'] ?? j['banner'];

    final genresList = (j['genres'] is List)
        ? (j['genres'] as List).map((e) => e.toString()).toList()
        : null;

    return MediaItem(
      id: _asInt(j['id']),
      title: (j['title'] ?? j['name'] ?? '').toString(),
      description: j['description']?.toString(),
      posterUrl: poster?.toString(),
      backdropUrl: backdrop?.toString(),
      genres: genresList,
      rating: _asDoubleOrNull(j['rating']),
      year: j['year'] == null ? null : _asInt(j['year']),
      type: MediaTypeX.fromString(j['type']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'poster_url': posterUrl,
      'banner_url': backdropUrl,
      'genres': genres,
      'rating': rating,
      'year': year,
      'type': type.nameStr,
    };
  }
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final parsed = int.tryParse(v.toString());
  return parsed ?? 0;
}

double? _asDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  final str = v.toString();
  if (str.isEmpty || str == 'null') return null;
  return double.tryParse(str);
}
