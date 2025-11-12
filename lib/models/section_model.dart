import 'simple_item.dart';

class SectionModel {
  final int id;
  final String title;
  final String type;
  final int order;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<SimpleItem> items; // ✅ هنا

  SectionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.order,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: (json['title'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      order: int.tryParse(json['order'].toString()) ?? 0,
      isActive: (json['is_active'] == 1 || json['is_active'] == true),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      items: (json['items'] as List? ?? [])
          .map((e) => SimpleItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'order': order,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };
}
