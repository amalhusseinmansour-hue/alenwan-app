class SimpleItem {
  final int id;
  final String title;
  final String type;
  final String? image;
  final String? subtitle;

  SimpleItem({
    required this.id,
    required this.title,
    required this.type,
    this.image,
    this.subtitle,
  });

  factory SimpleItem.fromJson(Map<String, dynamic> json) {
    return SimpleItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: (json['title'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      image: (json['image'] ?? json['poster_url'] ?? '').toString(),
      subtitle: json['subtitle']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'image': image,
        'subtitle': subtitle,
      };
}
