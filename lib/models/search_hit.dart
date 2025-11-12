import 'package:flutter/foundation.dart';

/// تمثيل نتيجة البحث العامة (فيلم/مسلسل/وثائقي ...).
@immutable
class SearchHit {
  final int? id; // id أو media_id
  final String
      type; // movie | series | documentary | sport | cartoon | livestream ...
  final String title; // العنوان
  final String image; // رابط الصورة (قد يكون فارغ)
  final String? subtitle; // اختياري
  final String? description; // اختياري
  final int? year; // اختياري
  final double? score; // درجة التشابه/الترتيب إن وُجدت

  const SearchHit({
    required this.type,
    required this.title,
    required this.image,
    this.id,
    this.subtitle,
    this.description,
    this.year,
    this.score,
  });

  /// factory المرن: يقرأ مفاتيح شائعة مختلفة قادمة من الـ API
  factory SearchHit.fromMap(Map<String, dynamic> map) {
    final idRaw =
        map['id'] ?? map['media_id'] ?? map['movie_id'] ?? map['series_id'];
    final typeRaw = map['type'] ?? map['media_type'] ?? map['category'] ?? '';
    final titleRaw = map['title'] ?? map['name'] ?? map['label'] ?? '';
    final imgRaw = map['image'] ??
        map['poster_url'] ??
        map['posterPath'] ??
        map['poster'] ??
        map['thumbnail'] ??
        '';

    final yearRaw = map['year'] ?? map['release_year'];
    final scoreRaw = map['score'] ?? map['similarity'] ?? map['rank'];

    return SearchHit(
      id: (idRaw == null) ? null : int.tryParse(idRaw.toString()),
      type: typeRaw.toString(),
      title: titleRaw.toString(),
      image: imgRaw.toString(),
      subtitle: map['subtitle']?.toString(),
      description: (map['description'] ?? map['overview'])?.toString(),
      year: (yearRaw == null) ? null : int.tryParse(yearRaw.toString()),
      score: (scoreRaw == null) ? null : double.tryParse(scoreRaw.toString()),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'title': title,
        'image': image,
        'subtitle': subtitle,
        'description': description,
        'year': year,
        'score': score,
      };

  /// للتوافق إذا أردت استخدام fromJson/toJson
  factory SearchHit.fromJson(Map<String, dynamic> json) =>
      SearchHit.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  SearchHit copyWith({
    int? id,
    String? type,
    String? title,
    String? image,
    String? subtitle,
    String? description,
    int? year,
    double? score,
  }) {
    return SearchHit(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      image: image ?? this.image,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      year: year ?? this.year,
      score: score ?? this.score,
    );
  }

  @override
  String toString() => 'SearchHit(id:$id, type:$type, title:$title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          title == other.title &&
          image == other.image;

  @override
  int get hashCode => Object.hash(id, type, title, image);
}
