class YouTubeStreamModel {
  final String title;
  final String channelName;
  final String thumbnail;

  YouTubeStreamModel({
    required this.title,
    required this.channelName,
    required this.thumbnail,
  });

  factory YouTubeStreamModel.fromMap(Map<String, dynamic> map) {
    return YouTubeStreamModel(
      title: (map['title'] ?? '').toString(),
      channelName: (map['channelName'] ?? '').toString(),
      thumbnail: (map['thumbnail'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'channelName': channelName,
      'thumbnail': thumbnail,
    };
  }
}
