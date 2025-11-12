// lib/models/channel_model.dart
class ChannelModel {
  final int id;
  final String name;
  final String? youtubeChannelId;
  final String thumbnail; // قد يكون كامل أو مسار storage
  final bool isActive;

  ChannelModel({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.isActive,
    this.youtubeChannelId,
  });

  /// Get the best available image URL
  String? get imageUrl {
    if (thumbnail.isNotEmpty) {
      return thumbnail.startsWith('http')
          ? thumbnail
          : 'https://alenwan.app/storage/$thumbnail';
    }
    return 'https://via.placeholder.com/300x300?text=Channel';
  }

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      youtubeChannelId: json['youtube_channel_id']?.toString(),
      thumbnail: json['thumbnail']?.toString() ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}
