import 'package:dio/dio.dart';
import 'api_client.dart';
import 'package:alenwan/models/language_model.dart';
import 'package:alenwan/models/translation_model.dart';

class LanguageService {
  final Dio _dio = ApiClient().dio;

  /// جلب جميع اللغات
  Future<List<LanguageModel>> fetchLanguages() async {
    try {
      final res = await _dio.get('/languages');
      final List data = (res.data is Map ? res.data['data'] : res.data) ?? [];
      return data
          .map((e) => LanguageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// جلب جميع الترجمات الخاصة بلغة معينة
  Future<List<TranslationModel>> fetchTranslations(int languageId) async {
    try {
      final res = await _dio.get('/languages/$languageId/translations');
      final List data = (res.data is Map ? res.data['data'] : res.data) ?? [];
      return data
          .map((e) => TranslationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException {
      rethrow;
    }
  }
}
