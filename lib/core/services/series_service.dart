import 'package:dio/dio.dart';
import '../../models/series_model.dart';
import '../../models/series_page.dart';
import 'api_client.dart';

class SeriesService {
  final Dio _dio = ApiClient().dio;
  String get baseUrl => _dio.options.baseUrl;

  Future<List<SeriesModel>> fetchAllSeries() async {
    try {
      final res = await _dio.get('/series');
      final data = res.data;

      final List raw;

      // Handle Laravel pagination: {"success": true, "data": {"data": [...]}}
      if (data is Map && data['data'] is Map && data['data']['data'] is List) {
        raw = List.from(data['data']['data']);
      } else if (data is Map && data['data'] is List) {
        raw = List.from(data['data']);
      } else if (data is Map && data['series'] is List) {
        raw = List.from(data['series']);
      } else if (data is List) {
        raw = data;
      } else {
        throw Exception('Unexpected response format: $data');
      }

      return raw
          .map((e) => SeriesModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
          'فشل تحميل المسلسلات: ${e.response?.statusCode} | ${e.message}');
    }
  }

  Future<SeriesPage> fetchSeriesPage({String? nextPageUrl}) async {
    try {
      final url = nextPageUrl ?? '/series';
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
          .map((e) => SeriesModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return SeriesPage(items: items, next: next);
    } on DioException catch (e) {
      throw Exception(
          'فشل تحميل صفحة المسلسلات: ${e.response?.statusCode} | ${e.message}');
    }
  }

  Future<SeriesModel> fetchSeriesDetails(int id) async {
    try {
      final res = await _dio.get('/series/$id');
      final body = (res.data is Map && res.data['data'] != null)
          ? res.data['data']
          : res.data;
      return SeriesModel.fromJson(Map<String, dynamic>.from(body));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('المسلسل غير موجود');
      }
      throw Exception(
          'فشل تحميل تفاصيل المسلسل: ${e.response?.statusCode} | ${e.message}');
    }
  }
}
