class PlatinumResponse {
  final List movies;
  final List series;
  final List documentaries;
  final List liveStreams;
  final List cartoons;
  final List sports;

  PlatinumResponse({
    required this.movies,
    required this.series,
    required this.documentaries,
    required this.liveStreams,
    required this.cartoons,
    required this.sports,
  });

  factory PlatinumResponse.fromJson(Map<String, dynamic> json) {
    // Check if data is a list (new backend structure)
    if (json['data'] is List) {
      final List allItems = json['data'] as List;

      // Group items by content_type
      final movies = allItems.where((item) => item['content_type'] == 'movie').toList();
      final series = allItems.where((item) => item['content_type'] == 'series').toList();
      final documentaries = allItems.where((item) => item['content_type'] == 'documentary').toList();
      final liveStreams = allItems.where((item) => item['content_type'] == 'livestream').toList();
      final cartoons = allItems.where((item) => item['content_type'] == 'cartoon').toList();
      final sports = allItems.where((item) => item['content_type'] == 'sport').toList();

      return PlatinumResponse(
        movies: movies,
        series: series,
        documentaries: documentaries,
        liveStreams: liveStreams,
        cartoons: cartoons,
        sports: sports,
      );
    }

    // Old structure: data is a map
    final root =
        (json['data'] is Map) ? json['data'] as Map<String, dynamic> : json;
    return PlatinumResponse(
      movies: (root['movies'] as List?) ?? [],
      series: (root['series'] as List?) ?? [],
      documentaries: (root['documentaries'] as List?) ?? [],
      liveStreams: (root['live_streams'] as List?) ?? [],
      cartoons: (root['cartoons'] as List?) ?? [],
      sports: (root['sports'] as List?) ?? [],
    );
  }
}
