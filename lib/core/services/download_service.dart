import 'package:dio/dio.dart';
import 'package:alenwan/models/download_model.dart';
import 'api_client.dart';

class DownloadService {
  // Use the centralized ApiClient (reads domain from config.dart)
  Dio get _dio => ApiClient().dio;

  /// GET /downloads
  Future<List<DownloadModel>> fetchDownloads() async {
    try {
      final res = await _dio.get(
        '/downloads',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final raw = res.data;
      final list = raw is List ? raw : (raw['data'] as List? ?? const []);
      return list
          .map((e) => DownloadModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_prettyErr(e, fallback: 'فشل تحميل قائمة التنزيلات'));
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع أثناء تحميل التنزيلات');
    }
  }

  /// DELETE /downloads/{id}
  Future<void> deleteDownload(int id) async {
    try {
      await _dio.delete(
        '/downloads/$id',
        options: Options(
          receiveTimeout: const Duration(seconds: 25),
          sendTimeout: const Duration(seconds: 25),
        ),
      );
    } on DioException catch (e) {
      throw Exception(_prettyErr(e, fallback: 'فشل حذف التنزيل'));
    }
  }

  /// POST /downloads
  Future<DownloadModel> storeCompletedDownload({
    required String mediaId,
    required String mediaType,
    required String title,
    String? description,
    String? posterUrl,
    String? quality,
    int? year,
    required int fileSizeBytes,
    required String localFilePath,
  }) async {
    try {
      final res = await _dio.post(
        '/downloads',
        data: {
          'media_id': mediaId,
          'media_type': mediaType,
          'title': title,
          'description': description,
          'poster_url': posterUrl,
          'quality': quality ?? 'auto',
          'year': year,
          'status': 'completed',
          'progress': 100,
          'file_size': fileSizeBytes,
          'downloaded_size': fileSizeBytes,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final data = res.data;
      final map = (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);
      return DownloadModel.fromJson(map);
    } on DioException catch (e) {
      throw Exception(_prettyErr(e, fallback: 'فشل حفظ التنزيل'));
    }
  }

  String _prettyErr(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    return fallback;
  }
}
