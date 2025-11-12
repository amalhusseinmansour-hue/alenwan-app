// lib/core/services/download_manager.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html show Blob, AnchorElement, Url; // للويب فقط

import 'dart:io' as io show File;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DownloadResult {
  final String path; // المسار المحلي أو اسم الملف
  final int fileSize; // الحجم بالبايت

  DownloadResult({required this.path, required this.fileSize});
}

class DownloadManager {
  final Dio _dio;

  DownloadManager({Dio? dio}) : _dio = dio ?? Dio();

  /// 🟢 تنزيل ملف من [url] وحفظه باسم [fileName].
  /// - في الويب: يطلق التحميل عبر المتصفح.
  /// - في الموبايل/ديسكتوب: يحفظ الملف محليًا في Documents.
  Future<DownloadResult> downloadFile({
    required String url,
    required String fileName,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      if (kIsWeb) {
        // 📂 الويب: تحميل الملف كبايتات
        final res = await _dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: onProgress,
        );

        final bytes = res.data ?? <int>[];

        // إنشاء Blob وتشغيل التنزيل
        final blob = html.Blob([bytes]);
        final objectUrl = html.Url.createObjectUrlFromBlob(blob);
        final a = html.AnchorElement(href: objectUrl)..download = fileName;
        a.click();
        html.Url.revokeObjectUrl(objectUrl);

        return DownloadResult(path: fileName, fileSize: bytes.length);
      } else {
        // 📂 الموبايل/ديسكتوب: حفظ الملف محليًا
        final dir = await getApplicationDocumentsDirectory();
        final savePath = p.join(dir.path, fileName);

        await _dio.download(
          url,
          savePath,
          onReceiveProgress: onProgress,
          options: Options(
            followRedirects: true,
            receiveTimeout: const Duration(minutes: 10),
          ),
        );

        final f = io.File(savePath);
        final size = await f.length();

        return DownloadResult(path: savePath, fileSize: size);
      }
    } catch (e) {
      throw Exception('❌ فشل تنزيل الملف: $e');
    }
  }
}
