class SportClipModel {
  final int id;
  final int sportId; // مفتاح أجنبي من sport
  final String title;
  final String videoPath;
  final String? posterPath;
  final int? durationSeconds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SportClipModel({
    required this.id,
    required this.sportId,
    required this.title,
    required this.videoPath,
    this.posterPath,
    this.durationSeconds,
    this.createdAt,
    this.updatedAt,
  });

  factory SportClipModel.fromJson(Map<String, dynamic> json) {
    return SportClipModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      sportId:
          int.tryParse((json['sport_id'] ?? json['sportId']).toString()) ?? 0,
      title: (json['title'] ?? '').toString(),
      videoPath:
          (json['video_url'] ?? json['video_path'] ?? json['videoPath'] ?? '')
              .toString(),
      posterPath:
          (json['thumbnail_url'] ?? json['poster_path'] ?? json['posterPath'])
              ?.toString(),
      durationSeconds: json['duration'] != null
          ? int.tryParse(json['duration'].toString())
          : (json['duration_seconds'] != null
              ? int.tryParse(json['duration_seconds'].toString())
              : null),
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
      'sport_id': sportId,
      'title': title,
      'video_path': videoPath,
      'poster_path': posterPath,
      'duration_seconds': durationSeconds,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
