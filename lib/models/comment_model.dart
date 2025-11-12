class LiveComment {
  final int id;
  final String text;
  final String userName;
  final DateTime createdAt;

  LiveComment({
    required this.id,
    required this.text,
    required this.userName,
    required this.createdAt,
  });

  factory LiveComment.fromJson(Map<String, dynamic> json) {
    return LiveComment(
      id: json['id'],
      text: json['text'],
      userName: json['user_name'] ?? 'مستخدم',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
