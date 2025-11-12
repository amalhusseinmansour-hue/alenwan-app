class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? profileImage;
  final String? role;
  final bool isActive;
  final bool isAdmin;
  final String subscriptionTier;
  final DateTime? subscriptionExpiresAt;
  final int maxDevices;
  final Map<String, dynamic>? preferences;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.profileImage,
    this.role,
    this.isActive = true,
    this.isAdmin = false,
    this.subscriptionTier = 'free',
    this.subscriptionExpiresAt,
    this.maxDevices = 1,
    this.preferences,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      profileImage: json['profile_image'],
      role: json['role'],
      isActive: json['is_active'] ?? true,
      isAdmin: json['is_admin'] ?? false,
      subscriptionTier: json['subscription_tier'] ?? 'free',
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'])
          : null,
      maxDevices: json['max_devices'] ?? 1,
      preferences: json['preferences'] != null
          ? (json['preferences'] is Map ? json['preferences'] as Map<String, dynamic> : null)
          : null,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'profile_image': profileImage,
      'role': role,
      'is_active': isActive,
      'is_admin': isAdmin,
      'subscription_tier': subscriptionTier,
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
      'max_devices': maxDevices,
      'preferences': preferences,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool hasActiveSubscription() {
    if (subscriptionTier == 'free') return false;
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  bool canAccessContent(String requiredTier) {
    final tierHierarchy = {
      'free': 0,
      'basic': 1,
      'premium': 2,
      'platinum': 3,
    };

    final userLevel = hasActiveSubscription()
        ? (tierHierarchy[subscriptionTier] ?? 0)
        : 0;
    final requiredLevel = tierHierarchy[requiredTier] ?? 0;

    return userLevel >= requiredLevel;
  }

  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  String get avatarUrl => profileImage ?? avatar ?? '';

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? profileImage,
    String? role,
    bool? isActive,
    bool? isAdmin,
    String? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    int? maxDevices,
    Map<String, dynamic>? preferences,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isAdmin: isAdmin ?? this.isAdmin,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      maxDevices: maxDevices ?? this.maxDevices,
      preferences: preferences ?? this.preferences,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}