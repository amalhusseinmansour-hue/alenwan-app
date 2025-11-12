class LiveComment {
  final int id;
  final String text;
  final DateTime createdAt;
  final String userName;
  final int? userId;
  final int likesCount;
  final bool isLiked;
  final bool isPinned;
  final bool isVerified;
  final List<LiveComment>? replies;

  LiveComment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.userName,
    this.userId,
    this.likesCount = 0,
    this.isLiked = false,
    this.isPinned = false,
    this.isVerified = false,
    this.replies,
  });

  factory LiveComment.fromJson(Map<String, dynamic> json) {
    // Extract user name from user object if available
    String userName = 'Unknown';
    int? userId;

    if (json['user'] != null && json['user'] is Map) {
      final user = json['user'] as Map<String, dynamic>;
      userName = user['name']?.toString() ?? user['username']?.toString() ?? 'Unknown';
      userId = int.tryParse(user['id']?.toString() ?? '0');
    } else if (json['user_name'] != null) {
      userName = json['user_name'].toString();
    }

    // Parse replies if they exist
    List<LiveComment>? replies;
    if (json['replies'] != null && json['replies'] is List) {
      replies = (json['replies'] as List)
          .map((r) => LiveComment.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return LiveComment(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      text: json['content']?.toString() ?? json['text']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      userName: userName,
      userId: userId ?? int.tryParse(json['user_id']?.toString() ?? '0'),
      likesCount: int.tryParse(json['likes_count']?.toString() ?? '0') ?? 0,
      isLiked: json['is_liked'] == true || json['is_liked'] == 1,
      isPinned: json['is_pinned'] == true || json['is_pinned'] == 1,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      replies: replies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': text,
      'user_name': userName,
      'user_id': userId,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'is_pinned': isPinned,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      if (replies != null) 'replies': replies!.map((r) => r.toJson()).toList(),
    };
  }
}
