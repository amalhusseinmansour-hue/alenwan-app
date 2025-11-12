import 'dart:convert';

class Documentary {
  final int id;
  final String title;
  final String? titleAr; // العنوان بالعربية
  final String description;
  final String? descriptionAr; // الوصف بالعربية
  final String posterPath; // ← حنستخدمه لكن نقرأ من poster_url
  final String bannerPath; // ← نقرأ من banner_url
  final String videoPath; // ← نقرأ من video_url
  final bool isPublished; // ← الحقل الصحيح من API
  final bool isPremium;
  final bool isFeatured;
  final int releaseYear;
  final double rating;
  final String? type;
  final String? presenter;
  final String? guest;
  final String? producer;
  final String? director;
  final String? narrator;
  final String? intro;
  final String subscriptionTier;

  final Map<String, dynamic>? playback;
  final List<dynamic>? audioDubs;

  Documentary({
    required this.id,
    required this.title,
    this.titleAr,
    required this.description,
    this.descriptionAr,
    required this.posterPath,
    required this.bannerPath,
    required this.videoPath,
    required this.isPublished,
    required this.isPremium,
    required this.isFeatured,
    required this.releaseYear,
    required this.rating,
    this.type,
    this.presenter,
    this.guest,
    this.producer,
    this.director,
    this.narrator,
    this.intro,
    required this.subscriptionTier,
    this.playback,
    this.audioDubs,
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
    return description;
  }

  /// Get the best available image URL
  String? get imageUrl {
    if (posterPath.isNotEmpty) {
      return posterPath.startsWith('http')
          ? posterPath
          : 'https://alenwan.app/storage/$posterPath';
    }
    if (bannerPath.isNotEmpty) {
      return bannerPath.startsWith('http')
          ? bannerPath
          : 'https://alenwan.app/storage/$bannerPath';
    }
    return 'https://via.placeholder.com/300x450?text=Documentary';
  }

  factory Documentary.fromJson(Map<String, dynamic> json) {
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
      title = titleData ?? '';
      titleAr = json['title_ar']?.toString();
    }

    // Handle nested description from Laravel API
    String description = '';
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
      description = descData['en']?.toString() ?? descData['ar']?.toString() ?? '';
      descriptionAr = descData['ar']?.toString();
    } else {
      description = descData ?? '';
      descriptionAr = json['description_ar']?.toString();
    }

    // 🔧 Support multiple field names for images
    final posterPath = (json['poster_url'] ??
                       json['poster_path'] ??
                       json['poster'] ??
                       json['thumbnail'] ??
                       json['thumb_url'] ??
                       '').toString();

    final bannerPath = (json['banner_url'] ??
                       json['banner_path'] ??
                       json['banner'] ??
                       json['backdrop'] ??
                       '').toString();

    final videoPath = (json['video_url'] ??
                      json['video_path'] ??
                      '').toString();

    return Documentary(
      id: json['id'] ?? 0,
      title: title,
      titleAr: titleAr,
      description: description,
      descriptionAr: descriptionAr,
      posterPath: posterPath,
      bannerPath: bannerPath,
      videoPath: videoPath,
      isPublished: json['is_published'] == true || json['is_published'] == 1,
      isPremium: json['is_premium'] == true || json['is_premium'] == 1,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
      releaseYear: int.tryParse('${json['release_year'] ?? json['year'] ?? ''}') ?? 0,
      rating: double.tryParse('${json['rating'] ?? ''}') ?? 0.0,
      type: json['type']?.toString(),
      presenter: json['presenter']?.toString(),
      guest: json['guest']?.toString(),
      producer: json['producer']?.toString() ?? json['producer_ar']?.toString(),
      director: json['director']?.toString() ?? json['director_ar']?.toString(),
      narrator: json['narrator']?.toString() ?? json['narrator_ar']?.toString(),
      intro: json['intro']?.toString(),
      subscriptionTier: json['subscription_tier'] ?? 'free',
      playback: json['playback'] as Map<String, dynamic>?,
      audioDubs: json['audio_dubs'] as List<dynamic>?,
    );
  }
}
