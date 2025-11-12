import 'package:dio/dio.dart';
import 'api_client.dart';

class DubService {
  // 👈 استخدم ApiClient統統統統統統
  Dio get _dio => ApiClient().dio;

  /// جلب قائمة الدبلجات (حسب نوع الفيديو/المسلسل)
  Future<List<Map<String, dynamic>>> list({
    required String type,
    required int id,
  }) async {
    try {
      final res = await _dio.get(
        '/dubs',
        queryParameters: {'type': type, 'id': id},
      );

      final List data = (res.data?['data'] as List?) ?? [];
      return data.map((e) {
        return {
          'label': (e['label'] ?? e['lang'] ?? '').toString(),
          'lang': (e['lang'] ?? '').toString(),
          'status': (e['status'] ?? 'ready').toString(),
          'hls': (e['url'] ?? e['hls'] ?? '').toString(),
          'mp4': (e['mp4_url'] ?? e['mp4'] ?? '').toString(),
        };
      }).toList();
    } on DioException {
      rethrow;
    }
  }

  /// طلب إنشاء دبلجة جديدة
  Future<Map<String, dynamic>> request({
    required String type,
    required int id,
    required String lang,
    required String label,
  }) async {
    try {
      final res = await _dio.post(
        '/dubs',
        data: {'type': type, 'id': id, 'lang': lang, 'label': label},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final m = Map<String, dynamic>.from(res.data?['data'] ?? {});
      return {
        'lang': (m['lang'] ?? '').toString(),
        'label': (m['label'] ?? '').toString(),
        'status': (m['status'] ?? '').toString(),
      };
    } on DioException {
      rethrow;
    }
  }
}
