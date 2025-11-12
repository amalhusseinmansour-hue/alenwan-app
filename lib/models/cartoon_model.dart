import 'dart:convert';

class CartoonModel {
  final int id;
  final String title;
  final String? titleAr; // العنوان بالعربية
  final String? description;
  final String? descriptionAr; // الوصف بالعربية
  final String? posterPath; // poster_url | poster_path | thumb_url
  final String? bannerPath; // banner_url | banner_path
  final String? videoPath;  // video_url | video_path

  final Map<String, dynamic>? playback;
  final String? status;
  final int? languageId;
  final int? releaseYear;
  final double? rating;
  final String? audience;
  final String? createdAt;

  final List<CartoonModel> episodes;

  CartoonModel({
    required this.id,
    required this.title,
    this.titleAr,
    this.description,
    this.descriptionAr,
    this.posterPath,
    this.bannerPath,
    this.videoPath,
    this.playback,
    this.status,
    this.languageId,
    this.releaseYear,
    this.rating,
    this.audience,
    this.createdAt,
    this.episodes = const [],
  });

  // Helper method للحصول على العنوان حسب اللغة
  String getTitle(String locale) {
    if (locale == 'ar' && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    return title;
  }

  // Helper method للحصول على الوصف حسب اللغة
  String getDescription(String locale) {
    if (locale == 'ar' && descriptionAr != null && descriptionAr!.isNotEmpty) {
      return descriptionAr!;
    }
    return description ?? '';
  }

  /// Get the best available image URL
  String? get imageUrl {
    if (posterPath != null && posterPath!.isNotEmpty) {
      return posterPath!.startsWith('http')
          ? posterPath
          : 'https://alenwan.app/storage/$posterPath';
    }
    if (bannerPath != null && bannerPath!.isNotEmpty) {
      return bannerPath!.startsWith('http')
          ? bannerPath
          : 'https://alenwan.app/storage/$bannerPath';
    }
    return 'https://via.placeholder.com/300x450?text=Cartoon';
  }

  factory CartoonModel.fromJson(Map<String, dynamic> j) {
    // Handle nested title from Laravel API
    String title = '';
    String? titleAr;

    dynamic titleData = j['title'];
    if (titleData is String && titleData.startsWith('{')) {
      try {
        titleData = jsonDecode(titleData);
      } catch (e) {
        // If decoding fails, use as-is
      }
    }

    if (titleData is Map) {
      title = titleData['en']?.toString() ?? titleData['ar']?.toString() ?? '';
      titleAr = titleData['ar']?.toString();
    } else {
      title = (titleData ?? j['name'] ?? '').toString();
      titleAr = j['title_ar']?.toString();
    }

    // Handle nested description from Laravel API
    String? description;
    String? descriptionAr;

    dynamic descData = j['description'];
    if (descData is String && descData.startsWith('{')) {
      try {
        descData = jsonDecode(descData);
      } catch (e) {
        // If decoding fails, use as-is
      }
    }

    if (descData is Map) {
      description = descData['en']?.toString() ?? descData['ar']?.toString();
      descriptionAr = descData['ar']?.toString();
    } else {
      description = descData?.toString();
      descriptionAr = j['description_ar']?.toString();
    }

    return CartoonModel(
      id: _asInt(j['id']),
      title: title,
      titleAr: titleAr,
      description: description,
      descriptionAr: descriptionAr,
      // 👇 ناخذ أي مفتاح متاح للصورة
      posterPath: (j['poster'] ??
          j['poster_url'] ??
          j['poster_path'] ??
          j['thumb_url'] ??
          j['thumbnail'] ??
          j['image'])
          ?.toString(),
      bannerPath:
      (j['banner_url'] ?? j['banner_path'] ?? j['backdrop'])?.toString(),
      videoPath: (j['video_url'] ?? j['video_path'])?.toString(),
      playback: j['playback'] is Map
          ? Map<String, dynamic>.from(j['playback'])
          : null,
      status: j['status']?.toString(),
      languageId: _asIntNullable(j['language_id']),
      releaseYear: _asIntNullable(j['release_year']),
      rating: _asDoubleNullable(j['rating']),
      audience: j['audience']?.toString(),
      createdAt: j['created_at']?.toString(),
      episodes: (j['episodes'] is List)
          ? (j['episodes'] as List)
          .map((e) => CartoonModel.fromEpisodeJson(
        (e as Map).cast<String, dynamic>(),
      ))
          .toList()
          : const [],
    );
  }

  factory CartoonModel.fromEpisodeJson(Map<String, dynamic> j) {
    return CartoonModel(
      id: _asInt(j['id']),
      title: (j['title'] ?? j['name'] ?? '').toString(),
      titleAr: j['title_ar']?.toString(),
      description: j['description']?.toString(),
      descriptionAr: j['description_ar']?.toString(),
      posterPath: (j['poster'] ??
          j['thumb_url'] ??
          j['poster_url'] ??
          j['poster_path'] ??
          j['thumbnail'] ??
          j['image'])
          ?.toString(),
      bannerPath:
      (j['banner_url'] ?? j['banner_path'] ?? j['thumb_url'])?.toString(),
      videoPath: (j['video_url'] ?? j['video_path'])?.toString(),
      playback: (j['playback'] is Map)
          ? (j['playback'] as Map).cast<String, dynamic>()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'poster_url': posterPath,
    'banner_url': bannerPath,
    'video_url': videoPath,
    'playback': playback,
    'status': status,
    'language_id': languageId,
    'release_year': releaseYear,
    'rating': rating,
    'audience': audience,
    'created_at': createdAt,
  };

  static int _asInt(Object? v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  static int? _asIntNullable(Object? v) =>
      v == null ? null : (v is int ? v : int.tryParse(v.toString()));

  static double? _asDoubleNullable(Object? v) =>
      v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
}
