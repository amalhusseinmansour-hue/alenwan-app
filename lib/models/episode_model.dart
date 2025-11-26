// lib/models/episode_model.dart
class EpisodeModel {
  final int id;
  final int seriesId;
  final int episodeNumber;
  final String title;
  final String videoUrl;
  final String? vimeoId;
  final String posterUrl;
  final String? description;
  final int? durationSeconds;

  EpisodeModel({
    required this.id,
    required this.seriesId,
    required this.episodeNumber,
    required this.title,
    required this.videoUrl,
    this.vimeoId,
    required this.posterUrl,
    this.description,
    this.durationSeconds,
  });

  /// Get the best available image URL
  String? get imageUrl {
    if (posterUrl.isNotEmpty) {
      return posterUrl.startsWith('http')
          ? posterUrl
          : 'https://alenwan.app/storage/$posterUrl';
    }
    return 'https://via.placeholder.com/300x450?text=Episode';
  }

  factory EpisodeModel.fromJson(Map<String, dynamic> j) => EpisodeModel(
        id: j['id'] is String ? int.parse(j['id']) : (j['id'] ?? 0),
        seriesId: j['series_id'] ?? j['seriesId'] ?? 0,
        episodeNumber: j['episode_number'] ?? j['episodeNumber'] ?? 1,
        title: (j['title'] ?? '').toString(),
        videoUrl: (j['video_url'] ?? j['videoUrl'] ?? '').toString(),
        vimeoId: j['vimeo_id']?.toString(),
        posterUrl: (j['poster_url'] ?? j['posterUrl'] ?? '').toString(),
        description: j['description']?.toString(),
        durationSeconds: j['duration_seconds'],
      );
}
