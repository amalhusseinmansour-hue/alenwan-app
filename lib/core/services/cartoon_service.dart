import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/cartoon_model.dart';
import 'api_client.dart';

class CartoonService {
  CartoonService() {
    if (!_inited) {
      ApiClient().refreshAuthHeader();
      _inited = true;
    }
  }

  static bool _inited = false;
  Dio get _dio => ApiClient().dio;

  // 👇 هيلبر صغير للتطبيع
  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      // Handle Laravel pagination: {"success": true, "data": {"data": [...]}}
      if (data['data'] is Map && data['data']['data'] is List) {
        return data['data']['data'] as List;
      }
      return (data['data'] ??
          data['cartoons'] ??
          data['results'] ??
          data['items'] ??
          const []) as List;
    }
    return const [];
  }

  Future<List<CartoonModel>> fetchCartoons() async {
    try {
      final res = await _dio.get('/cartoons',
          options: Options(headers: const {'Accept': 'application/json'}));

      if (res.statusCode == 200) {
        final list = _extractList(res.data);
        final items = list
            .map((j) => CartoonModel.fromJson(Map<String, dynamic>.from(j)))
            .toList();
        if (kDebugMode) {}
        return items;
      }
      throw Exception('فشل تحميل الكرتون: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception('خطأ أثناء تحميل الكرتون: ${e.message}');
    } catch (e) {
      throw Exception('خطأ أثناء تحميل الكرتون: $e');
    }
  }

  Future<CartoonModel> fetchCartoonDetails(int id) async {
    try {
      final res = await _dio.get('/cartoons/$id',
          options: Options(headers: const {'Accept': 'application/json'}));

      if (res.statusCode == 200) {
        final data = (res.data is Map && res.data['data'] != null)
            ? Map<String, dynamic>.from(res.data['data'])
            : Map<String, dynamic>.from(res.data as Map);
        return CartoonModel.fromJson(data);
      }
      throw Exception('فشل تحميل تفاصيل الكرتون: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception('خطأ أثناء تحميل تفاصيل الكرتون: ${e.message}');
    } catch (e) {
      throw Exception('خطأ أثناء تحميل تفاصيل الكرتون: $e');
    }
  }

  Future<List<CartoonModel>> fetchRelatedEpisodes(int cartoonId) async {
    final opts = Options(headers: const {'Accept': 'application/json'});

    try {
      final r = await _dio.get('/cartoons/$cartoonId/episodes', options: opts);
      if (r.statusCode == 200) {
        final list = _extractList(r.data);
        return list
            .map<CartoonModel>((e) =>
                CartoonModel.fromEpisodeJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}

    // fallback
    final r2 = await _dio.get('/cartoon/$cartoonId/episodes', options: opts);
    if (r2.statusCode == 200) {
      final list = _extractList(r2.data);
      return list
          .map<CartoonModel>(
              (e) => CartoonModel.fromEpisodeJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('فشل تحميل الحلقات');
  }
}
