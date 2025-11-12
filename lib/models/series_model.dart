// lib/models/series_model.dart
import 'dart:convert';
import 'episode_model.dart';

class SeriesModel {
  final int id;
  final String titleEn;
  final String? titleAr;
  final String? description;
  final String? thumbnail;
  final String? coverImage;
  final List<EpisodeModel> episodes;

  SeriesModel({
    required this.id,
    required this.titleEn,
    this.titleAr,
    this.description,
    this.thumbnail,
    this.coverImage,
    this.episodes = const [],
  });

  /// Get the best available image URL
  String? get imageUrl {
    if (thumbnail != null && thumbnail!.isNotEmpty) {
      return thumbnail!.startsWith('http')
          ? thumbnail
          : 'https://alenwan.app/storage/$thumbnail';
    }
    if (coverImage != null && coverImage!.isNotEmpty) {
      return coverImage!.startsWith('http')
          ? coverImage
          : 'https://alenwan.app/storage/$coverImage';
    }
    return 'https://via.placeholder.com/300x450?text=Series';
  }

  factory SeriesModel.fromJson(Map<String, dynamic> json) {
    // Handle nested title object from Laravel API
    String titleEn = '';
    String? titleAr;

    // First, check if title is a JSON-encoded string
    dynamic titleData = json['title'];
    if (titleData is String && titleData.startsWith('{')) {
      try {
        titleData = jsonDecode(titleData);
      } catch (e) {
        // If decoding fails, use as-is
      }
    }

    if (titleData is Map) {
      titleEn = (titleData['en'] ?? '').toString();
      titleAr = titleData['ar']?.toString();
    } else {
      titleEn = (json['titleEn'] ?? json['title_en'] ?? titleData ?? '').toString();
      titleAr = json['titleAr'] ?? json['title_ar'];
    }

    // Handle nested description object from Laravel API
    String? description;
    dynamic descData = json['description'];
    if (descData is String && descData.startsWith('{')) {
      try {
        descData = jsonDecode(descData);
      } catch (e) {
        // If decoding fails, use as-is
      }
    }

    if (descData is Map) {
      description = descData['ar']?.toString() ?? descData['en']?.toString();
    } else {
      description = descData?.toString();
    }

    return SeriesModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] ?? 0),
      titleEn: titleEn,
      titleAr: titleAr,
      description: description,
      coverImage: json['coverImage'] ?? json['cover_image'] ?? json['banner_url'] ?? json['banner_path'] ?? json['poster'] ?? json['poster_url'] ?? json['poster_path'],
      thumbnail: json['thumbnail'] ?? json['poster'] ?? json['poster_url'] ?? json['poster_path'] ?? json['thumb_url'],
      episodes: (json['episodes'] as List?)
              ?.map((e) => EpisodeModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }
}
