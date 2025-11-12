import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DownloadManager {
  final Dio _dio = Dio();

  /// تنزيل فيديو وحفظه داخل التطبيق
  Future<String> downloadVideo({
    required String url,
    required String fileName,
    void Function(int received, int total)? onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = p.join(dir.path, "downloads", fileName);

    // إنشاء فولدر downloads لو مش موجود
    await Directory(p.dirname(savePath)).create(recursive: true);

    await _dio.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      options: Options(
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 10),
      ),
    );

    return savePath;
  }
}
