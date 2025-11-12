import 'package:dio/dio.dart';
import 'package:alenwan/core/services/api_client.dart';
import 'package:alenwan/models/sport_model.dart';

class SportService {
  final Dio _dio = ApiClient().dio;
  String get baseUrl => ApiClient().baseUrl;

  /// 🔹 جميع الرياضات
  Future<List<SportModel>> fetchSports() async {
    try {
      final res = await _dio.get('/sports');
      final data = res.data;

      // Handle Laravel pagination: {"success": true, "data": {"data": [...]}}
      final List raw;
      if (data is Map && data['data'] is Map && data['data']['data'] is List) {
        raw = List.from(data['data']['data']);
      } else if (data is Map && data['data'] is List) {
        raw = List.from(data['data']);
      } else if (data is List) {
        raw = data;
      } else {
        throw Exception('Unexpected response format: $data');
      }

      return raw
          .map((e) => SportModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception('فشل تحميل الرياضات: ${e.message}');
    }
  }

  /// 🔹 صفحة رياضات مع Pagination
  Future<({List<SportModel> items, String? next})> fetchSportsPage({
    String? nextPageUrl,
  }) async {
    try {
      final url = nextPageUrl ?? '/sports';
      final res = await _dio.get(url);

      final root = res.data;
      final dataNode =
          (root is Map && root['data'] != null) ? root['data'] : root;

      List raw;
      String? next;

      if (dataNode is Map && dataNode['data'] is List) {
        raw = List.from(dataNode['data']);
        next = dataNode['next_page_url']?.toString();
      } else if (dataNode is List) {
        raw = dataNode;
        if (root is Map && root['links'] is Map) {
          next = root['links']['next']?.toString();
        }
      } else {
        raw = (root is Map && root['data'] is List)
            ? List.from(root['data'])
            : <dynamic>[];
        if (root is Map && root['links'] is Map) {
          next = root['links']['next']?.toString();
        }
      }

      final items = raw
          .whereType<Map>()
          .map((e) => SportModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return (items: items, next: next);
    } on DioException catch (e) {
      throw Exception('فشل تحميل صفحة الرياضة: ${e.message}');
    }
  }

  /// 🔹 تفاصيل عنصر رياضي
  Future<SportModel> fetchSportDetails(int id) async {
    try {
      final res = await _dio.get('/sports/$id');
      final data = (res.data is Map && res.data['data'] != null)
          ? res.data['data']
          : res.data;

      return SportModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('العنصر غير موجود');
      }
      throw Exception('فشل تحميل تفاصيل الرياضة: ${e.message}');
    }
  }
}
