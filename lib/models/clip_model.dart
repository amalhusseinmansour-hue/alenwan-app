class ClipModel {
  final int id;
  final String title;
  final String? thumbnailPath;
  final String? videoPath;
  final int? duration;

  ClipModel({
    required this.id,
    required this.title,
    this.thumbnailPath,
    this.videoPath,
    this.duration,
  });

  factory ClipModel.fromJson(Map<String, dynamic> json) {
    String? s(dynamic v) => v?.toString();

    return ClipModel(
      id: json['id'] as int,
      title: s(json['title']) ?? '',
      thumbnailPath: s(json['thumbnail_url'] ?? json['thumbnailPath']),
      videoPath: s(json['video_url'] ?? json['videoPath']),
      duration: json['duration'] != null
          ? int.tryParse(json['duration'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnail_url': thumbnailPath,
        'video_url': videoPath,
        'duration': duration,
      };

  // ✅ أضف getters بالأسماء التي تستخدمها في الـ UI:
  String? get thumbnailUrl => thumbnailPath;
  String? get videoUrl => videoPath;
}
