class ContentSection {
  final String type;
  final String title;
  final List<ContentItem> items;

  ContentSection({
    required this.type,
    required this.title,
    required this.items,
  });

  factory ContentSection.fromJson(Map<String, dynamic> json) {
    return ContentSection(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => ContentItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ContentItem {
  final int id;
  final String title;
  final String image;
  final String? description;
  final bool isPremium;

  ContentItem({
    required this.id,
    required this.title,
    required this.image,
    this.description,
    required this.isPremium,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
      isPremium: json['is_premium'] == 1,
    );
  }
}
