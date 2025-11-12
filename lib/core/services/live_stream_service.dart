import 'package:dio/dio.dart';
import 'package:alenwan/models/live_stream_model.dart';
import 'package:alenwan/models/live_stream_page.dart';
import 'package:alenwan/models/comment_live.dart';
import 'api_client.dart';

class LiveStreamService {
  final Dio _dio = ApiClient().dio;
  String get baseUrl => ApiClient().baseUrl;

  Future<List<LiveStreamModel>> fetchLiveStreams({
    bool onlyActive = false,
  }) async {
    try {
      final res = await _dio.get(
        '/live-streams',
        queryParameters: {'only_active': onlyActive ? 1 : 0},
      );

      if (res.statusCode == 200) {
        final root = res.data;

        // Handle Laravel pagination: {"success": true, "data": {"data": [...]}}
        List raw = [];
        if (root is Map && root['data'] is Map && root['data']['data'] is List) {
          raw = List.from(root['data']['data']);
        } else if (root is Map && root['data'] is List) {
          raw = List.from(root['data']);
        } else if (root is List) {
          raw = root;
        }

        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => LiveStreamModel.fromJson(e))
            .toList();
      }
      throw Exception('فشل تحميل البثوث: ${res.statusCode}');
    } catch (e) {
      throw Exception('خطأ أثناء تحميل البثوث: $e');
    }
  }

  Future<LiveStreamPage> fetchLiveStreamsPage({
    String? nextPageUrl,
    bool onlyActive = false,
  }) async {
    try {
      final res = await _dio.get(
        nextPageUrl ?? '/live-streams',
        queryParameters: nextPageUrl == null
            ? {'only_active': onlyActive ? 1 : 0}
            : null,
      );

      if (res.statusCode == 200) {
        final root = res.data;

        // Handle Laravel pagination: {"success": true, "data": {"data": [...], "next_page_url": "..."}}
        List raw = [];
        String? nextUrl;

        if (root is Map && root['data'] is Map) {
          final dataMap = root['data'] as Map;
          if (dataMap['data'] is List) {
            raw = List.from(dataMap['data']);
          }
          nextUrl = dataMap['next_page_url'] as String?;
        } else if (root is Map && root['data'] is List) {
          raw = List.from(root['data']);
          nextUrl = root['next_page_url'] as String?;
        } else if (root is List) {
          raw = root;
        }

        final streams = raw
            .whereType<Map<String, dynamic>>()
            .map((e) => LiveStreamModel.fromJson(e))
            .toList();

        return LiveStreamPage(items: streams, next: nextUrl);
      }

      throw Exception('فشل تحميل الصفحة: ${res.statusCode}');
    } catch (e) {
      throw Exception('خطأ أثناء تحميل البثوث: $e');
    }
  }

  Future<LiveStreamModel> fetchStreamDetails(int id) async {
    try {
      final res = await _dio.get('/live-streams/$id');
      final data = (res.data is Map && res.data['data'] != null)
          ? res.data['data']
          : res.data;

      if (data is Map<String, dynamic>) {
        return LiveStreamModel.fromJson(data);
      }
      throw Exception('شكل الرد غير متوقع');
    } catch (e) {
      throw Exception('خطأ أثناء تحميل تفاصيل البث: $e');
    }
  }

  Future<List<LiveComment>> fetchComments(int streamId) async {
    try {
      final response = await _dio.get('/live-streams/$streamId/comments');
      final data = response.data;

      if (data is Map && data['comments'] is List) {
        return (data['comments'] as List)
            .map((item) => LiveComment.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  Future<LiveComment> postComment(int streamId, String text) async {
    try {
      final response = await _dio.post(
        '/live-streams/$streamId/comments',
        data: {'text': text},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return LiveComment.fromJson(body);
      } else {
        throw Exception('فشل إرسال التعليق');
      }
    } catch (e) {
      throw Exception('Failed to post comment: $e');
    }
  }

  Future<bool> sendReaction(int streamId, String type) async {
    try {
      final response = await _dio.post(
        '/live-streams/$streamId/reactions',
        data: {'type': type},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to send reaction');
    }
  }
}
