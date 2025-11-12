class FavoriteItem {
  final int id; // media_id
  final String
      type; // movie | series | documentary | sport | cartoon | livestream
  final String title;
  final String image; // full url or as returned by API

  FavoriteItem({
    required this.id,
    required this.type,
    required this.title,
    required this.image,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> j) {
    final idStr = (j['media_id'] ?? j['id']).toString();
    return FavoriteItem(
      id: int.tryParse(idStr) ?? 0,
      type: (j['media_type'] ?? j['type'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      image: (j['image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'media_id': id,
        'media_type': type,
        'title': title,
        'image': image,
      };
}
