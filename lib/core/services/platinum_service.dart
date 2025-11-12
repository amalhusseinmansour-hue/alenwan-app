import 'package:dio/dio.dart';
import 'package:alenwan/core/services/api_client.dart';
import 'package:alenwan/models/platinum_response.dart';

class PlatinumService {
  final Dio _dio = ApiClient().dio;

  Future<PlatinumResponse> fetchPlatinum() async {
    try {
      final res = await _dio.get('/platinum');
      if (res.statusCode != 200) {
        throw Exception('فشل: ${res.statusCode} | ${res.data}');
      }
      return PlatinumResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('DioException: ${e.message}');
    }
  }
}
