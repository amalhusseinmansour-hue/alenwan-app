// lib/core/services/comment_service.dart
import 'package:dio/dio.dart';
import 'package:alenwan/models/comment_live.dart';

class CommentService {
  final Dio _dio;

  CommentService(this._dio);

  /// Get comments for a specific resource (livestream, movie, etc.)
  Future<List<LiveComment>> fetchComments({
    required String commentableType,
    required int commentableId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      print('📥 Fetching comments for $commentableType #$commentableId');

      final response = await _dio.get('/comments', queryParameters: {
        'commentable_type': commentableType,
        'commentable_id': commentableId,
        'per_page': perPage,
        'page': page,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final commentsData = data['data'] ?? data;

        final comments = (commentsData as List)
            .map((json) => LiveComment.fromJson(json))
            .toList();

        print('✅ Loaded ${comments.length} comments');
        return comments;
      }

      return [];
    } catch (e) {
      print('❌ Error fetching comments: $e');
      rethrow;
    }
  }

  /// Post a new comment
  Future<LiveComment> postComment({
    required String commentableType,
    required int commentableId,
    required String content,
    int? parentId,
  }) async {
    try {
      print('📤 Posting comment to $commentableType #$commentableId');

      final response = await _dio.post('/comments', data: {
        'commentable_type': commentableType,
        'commentable_id': commentableId,
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      });

      if (response.data['success'] == true) {
        final comment = LiveComment.fromJson(response.data['data']);
        print('✅ Comment posted successfully');
        return comment;
      }

      throw Exception('Failed to post comment');
    } catch (e) {
      print('❌ Error posting comment: $e');
      rethrow;
    }
  }

  /// Toggle like on a comment
  Future<Map<String, dynamic>> toggleLike(int commentId) async {
    try {
      final response = await _dio.post('/comments/$commentId/like');

      if (response.data['success'] == true) {
        return {
          'is_liked': response.data['is_liked'],
          'likes_count': response.data['likes_count'],
        };
      }

      throw Exception('Failed to toggle like');
    } catch (e) {
      print('❌ Error toggling like: $e');
      rethrow;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(int commentId) async {
    try {
      final response = await _dio.delete('/comments/$commentId');

      if (response.data['success'] == true) {
        print('✅ Comment deleted successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error deleting comment: $e');
      rethrow;
    }
  }
}
