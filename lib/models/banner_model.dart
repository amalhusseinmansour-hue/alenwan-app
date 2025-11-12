// lib/models/banner_model.dart
class BannerModel {
  final int id;
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final String? buttonUrl;
  final String? vimeoId;
  final String? placeholderUrl;
  final bool isLive;
  final String? liveLabel;
  final String? scheduleAt;
  final double overlayOpacity;
  final Map<String, dynamic>? playback;

  BannerModel({
    required this.id,
    this.title,
    this.subtitle,
    this.buttonText,
    this.buttonUrl,
    this.vimeoId,
    this.placeholderUrl,
    required this.isLive,
    this.liveLabel,
    this.scheduleAt,
    required this.overlayOpacity,
    this.playback,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return BannerModel(
      id: int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      buttonText: json['button_text']?.toString(),
      buttonUrl: json['button_url']?.toString(),
      vimeoId: json['vimeo_id']?.toString(),
      // نخليها كما هي (قد تكون رابط خارجي https)
      placeholderUrl: json['placeholder_url']?.toString(),
      isLive: (json['is_live'] ?? false) == true,
      liveLabel: json['live_label']?.toString(),
      scheduleAt: json['schedule_at']?.toString(),
      overlayOpacity: toDouble(json['overlay_opacity']),
      playback: (json['playback'] is Map)
          ? Map<String, dynamic>.from(json['playback'])
          : null,
    );
  }
}
