class YouTubeCommentModel {
  final String text;
  final String author;
  final DateTime publishedAt;

  YouTubeCommentModel({
    required this.text,
    required this.author,
    required this.publishedAt,
  });

  factory YouTubeCommentModel.fromMap(Map<String, dynamic> map) {
    return YouTubeCommentModel(
      text: (map['text'] ?? '').toString(),
      author: (map['author'] ?? '').toString(),
      publishedAt:
          DateTime.tryParse(map['publishedAt'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }
}
