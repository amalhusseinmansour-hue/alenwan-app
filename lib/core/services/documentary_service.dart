import 'package:dio/dio.dart';
import '../services/api_client.dart';
import '../../models/documentary_model.dart';

class DocumentaryService {
  final Dio _dio = ApiClient().dio;

  Future<List<Documentary>> fetchDocumentaries() async {
    final res = await _dio.get('/documentaries');

    // Handle Laravel pagination: {"success": true, "data": {"data": [...]}}
    final List list;
    if (res.data is Map && res.data['data'] is Map && res.data['data']['data'] is List) {
      list = res.data['data']['data'] as List;
    } else if (res.data is Map && res.data['data'] is List) {
      list = res.data['data'] as List;
    } else if (res.data is List) {
      list = res.data as List;
    } else {
      list = [];
    }

    return list
        .map((e) => Documentary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Documentary> fetchDocumentaryDetails(int id) async {
    try {
      final res = await _dio.get('/documentaries/$id');
      if (res.statusCode == 200 && res.data is Map) {
        final body = res.data as Map;
        final data = body['data'];
        if (data is Map) {
          return Documentary.fromJson(Map<String, dynamic>.from(data));
        }
      }
      throw Exception('Unexpected response for /documentaries/$id');
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = e.response?.data ?? e.message;
      throw Exception('fetchDocumentaryDetails DioError($code): $msg');
    } catch (e) {
      throw Exception('fetchDocumentaryDetails error: $e');
    }
  }
}
