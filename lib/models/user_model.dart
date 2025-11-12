import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.profileImage,
    required this.createdAt,
    required this.lastLogin,
  });

  /// تحويل البيانات من Firestore إلى نموذج المستخدم
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserModel(
        uid: doc.id,
        email: '',
        name: null,
        profileImage: null,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] as String?,
      profileImage: data['profileImage'] as String?,
      createdAt: data['createdAt'] != null
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
      lastLogin: data['lastLogin'] != null
        ? (data['lastLogin'] as Timestamp).toDate()
        : DateTime.now(),
    );
  }

  /// تحويل النموذج إلى بيانات يمكن تخزينها في Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  /// إنشاء نسخة جديدة من النموذج مع تحديث بعض البيانات
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? profileImage,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
