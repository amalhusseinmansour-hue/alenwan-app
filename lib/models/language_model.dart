class LanguageModel {
  final int id;
  final String name;
  final String locale;
  final String code;
  final bool isRtl;
  final bool isDefault;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LanguageModel({
    required this.id,
    required this.name,
    required this.locale,
    required this.code,
    required this.isRtl,
    required this.isDefault,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      locale: json['locale']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isRtl: json['is_rtl'] == 1 || json['is_rtl'] == true,
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
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
      'name': name,
      'locale': locale,
      'code': code,
      'is_rtl': isRtl ? 1 : 0,
      'is_default': isDefault ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
