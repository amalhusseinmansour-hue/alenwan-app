// lib/models/podcast_model.dart
import 'dart:convert';

class Podcast {
  final int id;
  final String title;
  final String? titleAr;
  final String? description;
  final String? descriptionAr;
  final String? poster;
  final String? thumbnail;
  final String? posterPath;
  final String? bannerPath;
  final String? audioUrl;
  final String? videoUrl;
  final int? duration; // in minutes
  final String? host;
  final String? hostAr;
  final String? releaseDate;
  final int? seasonNumber;
  final int? episodeNumber;
  final int? categoryId;
  final int? languageId;
  final double? rating;
  final bool isPremium;
  final bool isPublished;
  final bool isFeatured;
  final int viewsCount;
  final int likesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Podcast({
    required this.id,
    required this.title,
    this.titleAr,
    this.description,
    this.descriptionAr,
    this.poster,
    this.thumbnail,
    this.posterPath,
    this.bannerPath,
    this.audioUrl,
    this.videoUrl,
    this.duration,
    this.host,
    this.hostAr,
    this.releaseDate,
    this.seasonNumber,
    this.episodeNumber,
    this.categoryId,
    this.languageId,
    this.rating,
    this.isPremium = false,
    this.isPublished = true,
    this.isFeatured = false,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Get the best available image
  String? get imageUrl {
    if (thumbnail != null && thumbnail!.isNotEmpty) {
      return thumbnail!.startsWith('http')
          ? thumbnail
          : 'https://alenwan.app/storage/$thumbnail';
    }
    if (posterPath != null && posterPath!.isNotEmpty) {
      return posterPath!.startsWith('http')
          ? posterPath
          : 'https://alenwan.app/storage/$posterPath';
    }
    if (poster != null && poster!.isNotEmpty) {
      return poster!.startsWith('http')
          ? poster
          : 'https://alenwan.app/storage/$poster';
    }
    return 'https://via.placeholder.com/300x400.png?text=Podcast';
  }

  // Get localized title
  String getLocalizedTitle(String languageCode) {
    if (languageCode == 'ar' && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    return title;
  }

  // Get localized description
  String? getLocalizedDescription(String languageCode) {
    if (languageCode == 'ar' && descriptionAr != null && descriptionAr!.isNotEmpty) {
      return descriptionAr;
    }
    return description;
  }

  // Get localized host
  String? getLocalizedHost(String languageCode) {
    if (languageCode == 'ar' && hostAr != null && hostAr!.isNotEmpty) {
      return hostAr;
    }
    return host;
  }

  // Format duration
  String get formattedDuration {
    if (duration == null) return '';
    if (duration! < 60) {
      return '$duration دقيقة';
    }
    final hours = duration! ~/ 60;
    final mins = duration! % 60;
    if (mins == 0) {
      return '$hours ساعة';
    }
    return '$hours س $mins د';
  }

  // Episode label
  String get episodeLabel {
    if (seasonNumber != null && episodeNumber != null) {
      return 'S$seasonNumber E$episodeNumber';
    } else if (episodeNumber != null) {
      return 'Episode $episodeNumber';
    }
    return '';
  }

  factory Podcast.fromJson(Map<String, dynamic> json) {
    // Handle nested title from Laravel API
    String title = 'Untitled Podcast';
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
      title = titleData['en']?.toString() ?? titleData['ar']?.toString() ?? 'Untitled Podcast';
      titleAr = titleData['ar']?.toString();
    } else {
      title = titleData?.toString() ?? 'Untitled Podcast';
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

    // Handle nested host from Laravel API
    String? host;
    String? hostAr;
    if (json['host'] is Map) {
      host = json['host']['en']?.toString() ?? json['host']['ar']?.toString();
      hostAr = json['host']['ar']?.toString();
    } else {
      host = json['host']?.toString();
      hostAr = json['host_ar']?.toString();
    }

    return Podcast(
      id: json['id'] ?? 0,
      title: title,
      titleAr: titleAr,
      description: description,
      descriptionAr: descriptionAr,
      // 🔧 Support multiple poster field names
      poster: json['poster']?.toString(),
      thumbnail: json['thumbnail']?.toString() ?? json['poster_url']?.toString(),
      posterPath: json['poster_path']?.toString() ?? json['poster_url']?.toString(),
      bannerPath: json['banner_path']?.toString() ?? json['banner_url']?.toString(),
      audioUrl: json['audio_url']?.toString(),
      videoUrl: json['video_url']?.toString(),
      duration: json['duration'] != null ? int.tryParse(json['duration'].toString()) : null,
      host: host,
      hostAr: hostAr,
      releaseDate: json['release_date']?.toString(),
      seasonNumber: json['season_number'] != null ? int.tryParse(json['season_number'].toString()) : null,
      episodeNumber: json['episode_number'] != null ? int.tryParse(json['episode_number'].toString()) : null,
      categoryId: json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null,
      languageId: json['language_id'] != null ? int.tryParse(json['language_id'].toString()) : null,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      isPremium: json['is_premium'] == 1 || json['is_premium'] == true,
      isPublished: json['is_published'] == 1 || json['is_published'] == true,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      viewsCount: json['views_count'] != null ? int.tryParse(json['views_count'].toString()) ?? 0 : 0,
      likesCount: json['likes_count'] != null ? int.tryParse(json['likes_count'].toString()) ?? 0 : 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'description': description,
      'description_ar': descriptionAr,
      'poster': poster,
      'thumbnail': thumbnail,
      'poster_path': posterPath,
      'banner_path': bannerPath,
      'audio_url': audioUrl,
      'video_url': videoUrl,
      'duration': duration,
      'host': host,
      'host_ar': hostAr,
      'release_date': releaseDate,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'category_id': categoryId,
      'language_id': languageId,
      'rating': rating,
      'is_premium': isPremium,
      'is_published': isPublished,
      'is_featured': isFeatured,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Podcast copyWith({
    int? id,
    String? title,
    String? titleAr,
    String? description,
    String? descriptionAr,
    String? poster,
    String? thumbnail,
    String? posterPath,
    String? bannerPath,
    String? audioUrl,
    String? videoUrl,
    int? duration,
    String? host,
    String? hostAr,
    String? releaseDate,
    int? seasonNumber,
    int? episodeNumber,
    int? categoryId,
    int? languageId,
    double? rating,
    bool? isPremium,
    bool? isPublished,
    bool? isFeatured,
    int? viewsCount,
    int? likesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Podcast(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      poster: poster ?? this.poster,
      thumbnail: thumbnail ?? this.thumbnail,
      posterPath: posterPath ?? this.posterPath,
      bannerPath: bannerPath ?? this.bannerPath,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      host: host ?? this.host,
      hostAr: hostAr ?? this.hostAr,
      releaseDate: releaseDate ?? this.releaseDate,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      categoryId: categoryId ?? this.categoryId,
      languageId: languageId ?? this.languageId,
      rating: rating ?? this.rating,
      isPremium: isPremium ?? this.isPremium,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
