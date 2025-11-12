// lib/core/services/media_service.dart
import 'package:dio/dio.dart';
import '../../models/media_item.dart';
import 'api_client.dart';

class MediaService {
  final Dio _dio = ApiClient().dio;

  Future<List<MediaItem>> fetchTrending() => _fetchList('/media/trending');
  Future<List<MediaItem>> fetchRecommended() =>
      _fetchList('/media/recommended');
  Future<List<MediaItem>> fetchNewReleases() =>
      _fetchList('/media/new-releases');
  Future<List<MediaItem>> fetchPopularSeries() =>
      _fetchList('/media/popular-series');
  Future<List<MediaItem>> fetchLatestAdded() =>
      _fetchList('/media/latest-added');

  /// دالة خاصة لإعادة استخدام نفس المنطق
  Future<List<MediaItem>> _fetchList(String endpoint) async {
    try {
      final res = await _dio.get(endpoint);

      final raw = (res.data is Map && res.data['data'] is List)
          ? res.data['data'] as List
          : (res.data is List ? res.data as List : []);

      return raw
          .map((e) => MediaItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('فشل تحميل المحتوى ($endpoint)');
    }
  }
}
