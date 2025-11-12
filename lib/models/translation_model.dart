class TranslationModel {
  final int id;
  final String key;
  final String value;
  final int languageId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TranslationModel({
    required this.id,
    required this.key,
    required this.value,
    required this.languageId,
    this.createdAt,
    this.updatedAt,
  });

  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      id: json['id'] ?? 0,
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      languageId: json['language_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'language_id': languageId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
