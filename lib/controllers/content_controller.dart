import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:alenwan/core/services/api_client.dart';
import '../models/content_model.dart';

class ContentController extends ChangeNotifier {
  final Dio _dio = ApiClient().dio;

  bool isLoading = false;
  String? errorMessage;
  List<ContentSection> sections = [];

  /// 🔹 تحميل كل الأقسام
  Future<void> loadAllContent() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/sections');

      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = (raw is Map && raw['data'] is List)
            ? raw['data']
            : (raw is List ? raw : []);
        sections = data
            .map((item) => ContentSection.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      } else {
        errorMessage = 'فشل تحميل البيانات (${response.statusCode})';
      }
    } on DioException catch (e) {
      errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'فشل الاتصال بالسيرفر';
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء تحميل المحتوى: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔹 إعادة التحميل
  Future<void> refresh() async {
    await loadAllContent();
  }
}
