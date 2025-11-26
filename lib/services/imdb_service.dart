import 'package:dio/dio.dart';
import '../core/services/api_client.dart';

class IMDbService {
  final Dio _dio = ApiClient().dio;

  /// Search for movies/series on IMDb
  Future<List<Map<String, dynamic>>> search(String query, {String type = 'all'}) async {
    try {
      final response = await _dio.get(
        '/api/imdb/search',
        queryParameters: {
          'query': query,
          'type': type, // 'movie', 'series', or 'all'
        },
      );

      if (response.data['success'] == true) {
        final results = response.data['results'] as List;
        return results.map((item) => item as Map<String, dynamic>).toList();
      }

      return [];
    } catch (e) {
      print('Error searching IMDb: $e');
      return [];
    }
  }

  /// Get detailed information about a movie/series from IMDb
  Future<Map<String, dynamic>?> getDetails(String imdbId) async {
    try {
      final response = await _dio.get(
        '/api/imdb/details',
        queryParameters: {
          'imdb_id': imdbId,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print('Error fetching IMDb details: $e');
      return null;
    }
  }
}
