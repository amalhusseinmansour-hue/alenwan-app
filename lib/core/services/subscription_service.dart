import 'package:dio/dio.dart';
import 'package:alenwan/core/services/api_client.dart';
import 'package:alenwan/models/subscription_plan.dart';
import 'package:alenwan/models/user_subscription.dart';

class SubscriptionService {
  final Dio _dio = ApiClient().dio;
  String get baseUrl => ApiClient().baseUrl;

  /// 🟢 جلب قائمة الخطط
  Future<List<SubscriptionPlan>> listPlans() async {
    try {
      final res = await _dio.get('/subscriptions/plans');

      // Handle response format: {"success": true, "data": [...]}
      final data = res.data;
      List list;

      if (data is Map) {
        if (data['data'] is List) {
          list = data['data'] as List;
        } else if (data['plans'] is List) {
          list = data['plans'] as List;
        } else {
          list = [];
        }
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      return list
          .map((e) => SubscriptionPlan.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🟢 الاشتراك بخطة
  Future<Map<String, dynamic>> subscribe(int planId) async {
    try {
      final response = await _dio.post('/subscribe/checkout', data: {
        'plan': 'monthly', // Laravel expects 'monthly' plan
      });

      if (response.data is Map && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }

      throw Exception('فشل إنشاء رابط الدفع');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🟢 الاشتراك الحالي للمستخدم
  Future<UserSubscription?> mySubscription() async {
    try {
      final res = await _dio.get('/my-subscription');
      final payload = (res.data is Map && res.data['subscription'] != null)
          ? res.data['subscription']
          : res.data;
      return UserSubscription.fromMap(Map<String, dynamic>.from(payload));
    } on DioException catch (e) {
      // Handle 404 (no subscription) and 500 (server error) gracefully
      if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
        print('My subscription API error: ${e.response?.statusCode} - ${_handleError(e)}');
        return null; // لا يوجد اشتراك
      }
      throw Exception(_handleError(e));
    }
  }

  /// 🟢 إلغاء الاشتراك
  Future<void> cancel() async {
    try {
      await _dio.post('/subscription/cancel');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🟠 دالة خاصة للتعامل مع الأخطاء
  String _handleError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return e.message ?? 'Server error';
    } catch (_) {
      return e.message ?? 'Server error';
    }
  }
}
