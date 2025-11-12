import 'package:dio/dio.dart';
import 'package:alenwan/core/services/api_client.dart';
import 'package:alenwan/models/recent_item.dart';

class RecentService {
  final Dio _dio = ApiClient().dio;

  Future<List<RecentItem>> fetchRecent({
    int days = 14,
    int limit = 40,
  }) async {
    try {
      final res = await _dio.get(
        '/recent-items',
        queryParameters: {
          'days': days,
          'limit': limit,
        },
      );

      if (res.statusCode == 200) {
        final data = res.data;
        final List raw = (data['items'] as List?) ?? [];
        return raw
            .map((e) => RecentItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      throw Exception('فشل تحميل العناصر: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'خطأ أثناء تحميل العناصر الحديثة');
    } catch (e) {
      throw Exception('خطأ غير متوقع أثناء تحميل العناصر');
    }
  }
}
