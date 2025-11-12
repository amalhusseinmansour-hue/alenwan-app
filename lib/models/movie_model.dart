import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class MovieModel {
  final int id;
  final String title;
  final String? description;
  final String? posterPath;
  final String? bannerPath;
  final String? videoPath;
  final String status;
  final int? releaseYear;
  final double? rating;
  final String subscriptionTier;

  // علاقات
  final int? languageId;
  final String? languageName;
  final int? categoryId;
  final String? categoryName;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? playback;

  MovieModel({
    required this.id,
    required this.title,
    this.description,
    this.posterPath,
    this.bannerPath,
    this.videoPath,
    this.status = 'draft',
    this.releaseYear,
    this.rating,
    this.subscriptionTier = 'free',
    this.languageId,
    this.languageName,
    this.categoryId,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
    this.playback,
  });

  /// Getters مساعدة
  String get hlsUrl => (playback?['hls'] ?? '').toString().trim();
  String get mp4Url => (playback?['mp4'] ?? '').toString().trim();

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
    return 'https://via.placeholder.com/300x450?text=Movie';
  }

  /// يختار أفضل مسار تشغيل حسب الجهاز
  String get bestPlayableUrl {
    final raw = (videoPath ?? '').trim();
    if (kIsWeb) {
      return [mp4Url, hlsUrl, raw].firstWhere(
        (u) => u.isNotEmpty,
        orElse: () => '',
      );
    }
    return [hlsUrl, mp4Url, raw].firstWhere(
      (u) => u.isNotEmpty,
      orElse: () => '',
    );
  }

  bool get hasVideo =>
      hlsUrl.isNotEmpty ||
      mp4Url.isNotEmpty ||
      (videoPath?.isNotEmpty ?? false);

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> src =
        (json['data'] is Map) ? Map<String, dynamic>.from(json['data']) : json;

    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim());
      return null;
    }

    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim());
      return null;
    }

    DateTime? asDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    String? asStr(dynamic v) => v?.toString();

    Map<String, dynamic>? asMap(dynamic v) {
      if (v is Map) return Map<String, dynamic>.from(v);
      return null;
    }

    // Handle nested title object from Laravel API
    String title = '';
    dynamic titleData = src['title'];

    // First, check if title is a JSON-encoded string
    if (titleData is String && titleData.startsWith('{')) {
      try {
        titleData = jsonDecode(titleData);
      } catch (e) {
        // If decoding fails, use as-is
      }
    }

    if (titleData is Map) {
      title = asStr(titleData['ar']) ?? asStr(titleData['en']) ?? '';
    } else {
      title = asStr(titleData) ?? '';
    }

    // Handle nested description object from Laravel API
    String? description;
    dynamic descData = src['description'];

    // First, check if description is a JSON-encoded string
    if (descData is String && descData.startsWith('{')) {
      try {
        descData = jsonDecode(descData);
      } catch (e) {
        // If decoding fails, use as-is
      }
    }

    if (descData is Map) {
      description = asStr(descData['ar']) ?? asStr(descData['en']);
    } else {
      description = asStr(descData);
    }

    return MovieModel(
      id: asInt(src['id']) ?? 0,
      title: title,
      description: description,
      posterPath: asStr(src['poster_url'] ?? src['poster_path'] ?? src['poster'] ?? src['thumbnail']),
      bannerPath: asStr(src['banner_url'] ?? src['banner_path'] ?? src['poster']),
      videoPath: asStr(src['video_url'] ?? src['video_path']),
      status: asStr(src['status']) ?? 'draft',
      releaseYear: asInt(src['release_year']),
      rating: asDouble(src['rating']),
      subscriptionTier: asStr(src['subscription_tier']) ?? 'free',

      // ✅ العلاقات
      languageId: src['language']?['id'] ?? asInt(src['language_id']),
      languageName: src['language']?['name'] is Map
          ? (src['language']?['name']?['ar'] ?? src['language']?['name']?['en'])
          : asStr(src['language']?['name']),
      categoryId: src['category']?['id'] ?? asInt(src['category_id']),
      categoryName: src['category']?['name'] is Map
          ? (src['category']?['name']?['ar'] ?? src['category']?['name']?['en'])
          : asStr(src['category']?['name']),

      createdAt: asDate(src['created_at']),
      updatedAt: asDate(src['updated_at']),
      playback: asMap(src['playback']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "poster_path": posterPath,
        "banner_path": bannerPath,
        "video_path": videoPath,
        "status": status,
        "release_year": releaseYear,
        "rating": rating,
        "subscription_tier": subscriptionTier,
        "language": {
          "id": languageId,
          "name": languageName,
        },
        "category": {
          "id": categoryId,
          "name": categoryName,
        },
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "playback": playback,
      };
}
