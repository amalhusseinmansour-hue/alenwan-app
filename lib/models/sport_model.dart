import 'dart:convert';
import 'sport_clip_model.dart';

class SportModel {
  final int id;
  final String title;
  final String? titleAr; // العنوان بالعربية
  final String? description;
  final String? descriptionAr; // الوصف بالعربية

  /// ركّز: أسماء متوافقة مع الـ API
  final String? posterUrl;   // poster_url
  final String? bannerUrl;   // banner_url

  final String? videoUrl;   // video_url أو video_path
  final String? streamUrl;  // stream_url للبث المباشر
  final String status;
  final int languageId;
  final int? releaseYear;
  final double? rating;
  final int categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String subscriptionTier;
  final Map<String, dynamic>? playback;
  final List<SportClipModel>? clips;

  SportModel({
    required this.id,
    required this.title,
    this.titleAr,
    this.description,
    this.descriptionAr,
    this.posterUrl,
    this.bannerUrl,
    this.videoUrl,
    this.streamUrl,
    this.status = 'draft',
    required this.languageId,
    this.releaseYear,
    this.rating,
    required this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.subscriptionTier = 'free',
    this.playback,
    this.clips,
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

  String get hlsUrl => (playback?['hls'] ?? '').toString();
  String get mp4Url => (playback?['mp4'] ?? '').toString();

  String get bestPlayableUrl {
    final candidates = [hlsUrl, mp4Url, videoUrl ?? ''];
    for (final u in candidates) {
      if (u.trim().isNotEmpty) return u.trim();
    }
    return '';
  }

  /// Get the best available image URL
  String? get imageUrl {
    if (posterUrl != null && posterUrl!.isNotEmpty) {
      return posterUrl!.startsWith('http')
          ? posterUrl
          : 'https://alenwan.app/storage/$posterUrl';
    }
    if (bannerUrl != null && bannerUrl!.isNotEmpty) {
      return bannerUrl!.startsWith('http')
          ? bannerUrl
          : 'https://alenwan.app/storage/$bannerUrl';
    }
    return 'https://via.placeholder.com/300x450?text=Sport';
  }

  factory SportModel.fromJson(Map<String, dynamic> json) {
    // Handle nested title from Laravel API
    String title = '';
    String? titleAr;

    dynamic titleData = json['title'];
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
      title = titleData?.toString() ?? '';
      titleAr = json['title_ar']?.toString();
    }

    // Handle nested description from Laravel API
    String? description;
    String? descriptionAr;

    dynamic descData = json['description'];
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
      descriptionAr = json['description_ar']?.toString();
    }

    // 🔧 Support multiple field names for images
    final posterUrl = (json['poster_url'] ??
                      json['poster_path'] ??
                      json['poster'] ??
                      json['thumbnail'] ??
                      json['thumb_url'] ??
                      '').toString();

    final bannerUrl = (json['banner_url'] ??
                      json['banner_path'] ??
                      json['banner'] ??
                      json['backdrop'] ??
                      '').toString();

    final videoUrl = (json['video_url'] ??
                     json['video_path'] ??
                     '').toString();

    final streamUrl = (json['stream_url'] ?? '').toString();

    // 🔧 Support both 'status' string and 'is_published' boolean
    final status = (json['is_published'] == true || json['is_published'] == 1)
        ? 'published'
        : (json['status']?.toString() ?? 'draft');

    return SportModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: title,
      titleAr: titleAr,
      description: description,
      descriptionAr: descriptionAr,
      posterUrl: posterUrl.isNotEmpty ? posterUrl : null,
      bannerUrl: bannerUrl.isNotEmpty ? bannerUrl : null,
      videoUrl: videoUrl.isNotEmpty ? videoUrl : null,
      streamUrl: streamUrl.isNotEmpty ? streamUrl : null,
      status: status,
      languageId: int.tryParse(json['language_id']?.toString() ?? '1') ?? 1,
      releaseYear: json['release_year'] == null
          ? null
          : int.tryParse(json['release_year'].toString()),
      rating: (json['rating'] != null)
          ? double.tryParse(json['rating'].toString())
          : null,
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      subscriptionTier: json['subscription_tier']?.toString() ?? 'free',
      clips: (json['clips'] as List<dynamic>?)
          ?.map((e) => SportClipModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      playback: (json['playback'] is Map)
          ? (json['playback'] as Map).cast<String, dynamic>()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "poster_url": posterUrl,
      "banner_url": bannerUrl,
      "video_url": videoUrl,
      "status": status,
      "language_id": languageId,
      "release_year": releaseYear,
      "rating": rating,
      "category_id": categoryId,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      "subscription_tier": subscriptionTier,
      "clips": clips?.map((e) => e.toJson()).toList(),
      "playback": playback,
    };
  }
}
