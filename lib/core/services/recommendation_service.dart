import 'dart:convert';
import 'package:alenwan/core/services/api_client.dart';

class RecommendationService {
  final _client = ApiClient();

  Future<List<Map<String, dynamic>>> getRecommendations(int userId) async {
    try {
      final res = await _client.dio.get('/recommendations/$userId');

      if (res.statusCode == 200) {
        final data = res.data is String ? jsonDecode(res.data) : res.data;
        final List recs = data['recommendations'] ?? [];
        return recs.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      // Handle 404 and other errors gracefully by returning empty list
      print('Recommendations API error: $e');
      return [];
    }
  }
}
