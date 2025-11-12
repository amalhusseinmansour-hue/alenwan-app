class Movie {
  final int id;
  final String title;
  final String? description;
  final String? thumbnail;
  final String? videoUrl;
  final String? vimeoVideoId;
  final int? duration;
  final String? genre;
  final double? rating;
  final int? year;
  final String? director;
  final String? cast;
  final bool isFeatured;
  final bool isTrending;
  final DateTime createdAt;
  final DateTime updatedAt;

  Movie({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    this.videoUrl,
    this.vimeoVideoId,
    this.duration,
    this.genre,
    this.rating,
    this.year,
    this.director,
    this.cast,
    this.isFeatured = false,
    this.isTrending = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      videoUrl: json['video_url'],
      vimeoVideoId: json['vimeo_video_id'],
      duration: json['duration'],
      genre: json['genre'],
      rating: json['rating']?.toDouble(),
      year: json['year'],
      director: json['director'],
      cast: json['cast'],
      isFeatured: json['is_featured'] ?? false,
      isTrending: json['is_trending'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'video_url': videoUrl,
      'vimeo_video_id': vimeoVideoId,
      'duration': duration,
      'genre': genre,
      'rating': rating,
      'year': year,
      'director': director,
      'cast': cast,
      'is_featured': isFeatured,
      'is_trending': isTrending,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}