// lib/core/services/search_service.dart
import 'package:dio/dio.dart';
import '../../models/search_hit.dart';
import 'api_client.dart';

class SearchService {
  final Dio _dio = ApiClient().dio;

  Future<List<SearchHit>> search(
    String q, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        '/search',
        queryParameters: {
          'q': q,
          'page': page,
          'limit': limit,
        },
      );

      final raw = res.data;

      // Handle the actual API response structure:
      // {"success": true, "query": "...", "data": {"movies": [], "series": [], "live_streams": []}}
      final List<SearchHit> combinedResults = [];

      if (raw is Map && raw['data'] is Map) {
        final data = raw['data'] as Map<String, dynamic>;

        // Extract all content types
        final contentTypes = [
          {'key': 'movies', 'type': 'movie'},
          {'key': 'series', 'type': 'series'},
          {'key': 'live_streams', 'type': 'livestream'},
          {'key': 'documentaries', 'type': 'documentary'},
          {'key': 'cartoons', 'type': 'cartoon'},
          {'key': 'sports', 'type': 'sport'},
        ];

        for (var contentType in contentTypes) {
          if (data[contentType['key']] is List) {
            for (var item in data[contentType['key']] as List) {
              if (item is Map) {
                final hit = SearchHit.fromMap({
                  ...Map<String, dynamic>.from(item),
                  'type': contentType['type'],
                });
                combinedResults.add(hit);
              }
            }
          }
        }
      } else if (raw is Map && raw['results'] is List) {
        // Fallback: handle old API format
        final list = raw['results'] as List;
        combinedResults.addAll(
          list
              .whereType<Map>()
              .map((e) => SearchHit.fromMap(Map<String, dynamic>.from(e)))
        );
      }

      return combinedResults;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.message ??
          'فشل البحث، تحقق من الاتصال';
      throw Exception(msg);
    } catch (e) {
      throw Exception('خطأ غير متوقع أثناء البحث: $e');
    }
  }
}
