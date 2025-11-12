// lib/models/live_stream_model.dart
import 'dart:convert';

class LiveStreamModel {
  final int id;
  final String title;
  final String? titleAr; // العنوان بالعربية
  final String description;
  final String? descriptionAr; // الوصف بالعربية
  final String thumbnail;
  final String streamUrl;
  final String channelName;
  final String sourceType; // youtube | vimeo | custom
  final String startsAt;
  final bool isPaid;
  final int? viewersCount;
  final String? videoUrl;

  // ✅ جديد
  final int? channelId;

  LiveStreamModel({
    required this.id,
    required this.title,
    this.titleAr,
    required this.description,
    this.descriptionAr,
    required this.thumbnail,
    required this.streamUrl,
    required this.channelName,
    required this.sourceType,
    required this.startsAt,
    required this.isPaid,
    this.viewersCount,
    this.videoUrl,
    this.channelId, // ✅
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
    if (thumbnail.isNotEmpty) {
      return thumbnail.startsWith('http')
          ? thumbnail
          : 'https://alenwan.app/storage/$thumbnail';
    }
    return 'https://via.placeholder.com/300x450?text=Live+Stream';
  }

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    // 🔧 Parse title - handle both string and JSON object formats
    String parsedTitle = '';
    String? parsedTitleAr;

    dynamic titleData = json['title'];
    if (titleData is String && titleData.startsWith('{')) {
      try {
        titleData = jsonDecode(titleData);
      } catch (e) {
        // If decoding fails, use as-is
      }
    }

    if (titleData is Map) {
      parsedTitle = titleData['en']?.toString() ?? titleData['ar']?.toString() ?? '';
      parsedTitleAr = titleData['ar']?.toString();
    } else if (titleData != null) {
      parsedTitle = titleData.toString();
    }

    // 🔧 Parse description - same logic
    String parsedDescription = '';
    String? parsedDescriptionAr;

    dynamic descData = json['description'];
    if (descData is String && descData.startsWith('{')) {
      try {
        descData = jsonDecode(descData);
      } catch (e) {
        // If decoding fails, use as-is
      }
    }

    if (descData is Map) {
      parsedDescription = descData['en']?.toString() ?? descData['ar']?.toString() ?? '';
      parsedDescriptionAr = descData['ar']?.toString();
    } else if (descData != null) {
      parsedDescription = descData.toString();
    }

    return LiveStreamModel(
      id: json['id'] ?? 0,
      title: parsedTitle,
      titleAr: parsedTitleAr ?? json['title_ar']?.toString(),
      description: parsedDescription,
      descriptionAr: parsedDescriptionAr ?? json['description_ar']?.toString(),
      thumbnail: json['thumbnail']?.toString() ?? '',
      streamUrl: json['stream_url']?.toString() ?? '',
      channelName: json['channel_name']?.toString() ?? '',
      sourceType: json['source_type']?.toString() ?? '',
      startsAt: json['starts_at']?.toString() ?? '',
      isPaid: json['is_paid'] == 1 || json['is_paid'] == true,
      viewersCount: json['viewers_count'] != null
          ? int.tryParse(json['viewers_count'].toString())
          : null,
      videoUrl: json['video_url']?.toString(),
      channelId: json['channel_id'] != null
          ? int.tryParse(json['channel_id'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'stream_url': streamUrl,
      'channel_name': channelName,
      'source_type': sourceType,
      'starts_at': startsAt,
      'is_paid': isPaid ? 1 : 0,
      'viewers_count': viewersCount,
      'video_url': videoUrl,
      'channel_id': channelId, // ✅
    };
  }
}
