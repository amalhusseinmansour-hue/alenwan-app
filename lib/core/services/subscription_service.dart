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
      print('🔵 [SubscriptionService] Fetching subscription plans...');
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

      print('✅ [SubscriptionService] Fetched ${list.length} plans');
      return list
          .map((e) => SubscriptionPlan.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      print('❌ [SubscriptionService] List plans error: ${_handleError(e)}');
      throw Exception(_handleError(e));
    }
  }

  /// 🟢 الاشتراك بخطة
  Future<Map<String, dynamic>> subscribe(int planId) async {
    try {
      print('🔵 [SubscriptionService] Subscribing to plan: $planId');
      final response = await _dio.post(
        '/subscribe/checkout',
        data: {
          'plan': 'monthly', // Laravel expects 'monthly' plan
          'plan_id': planId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('🔵 [SubscriptionService] Response: ${response.data}');

      if (response.data is Map) {
        final data = response.data as Map;
        if (data['success'] == true && data['data'] != null) {
          final paymentData = data['data'];
          if (paymentData is Map) {
            return Map<String, dynamic>.from(paymentData);
          }
        }
        // Check if error message is in response
        if (data['message'] != null) {
          throw Exception(data['message'].toString());
        }
        if (data['error'] != null) {
          throw Exception(data['error'].toString());
        }
      }

      final errorMsg = response.data is Map
          ? response.data['message'] ?? 'Unknown error'
          : 'Invalid response format';
      throw Exception('فشل إنشاء رابط الدفع: $errorMsg');
    } on DioException catch (e) {
      final errorMsg = _handleError(e);
      print('❌ [SubscriptionService] Subscribe error: $errorMsg');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      throw Exception(errorMsg);
    }
  }

  /// 🟢 الاشتراك الحالي للمستخدم
  Future<UserSubscription?> mySubscription() async {
    try {
      print('🔵 [SubscriptionService] Fetching my subscription...');
      final res = await _dio.get('/my-subscription');

      print('🔵 [SubscriptionService] Subscription response: ${res.data}');

      final payload = (res.data is Map && res.data['subscription'] != null)
          ? res.data['subscription']
          : res.data;

      return UserSubscription.fromMap(Map<String, dynamic>.from(payload));
    } on DioException catch (e) {
      // Handle 404 (no subscription) and 500 (server error) gracefully
      if (e.response?.statusCode == 404) {
        print('ℹ️ [SubscriptionService] No active subscription (404)');
        return null; // لا يوجد اشتراك
      }
      if (e.response?.statusCode == 500) {
        print('⚠️ [SubscriptionService] Server error on subscription check');
        return null; // Server error - return null to let app continue
      }
      print(
          '❌ [SubscriptionService] My subscription error: ${_handleError(e)}');
      throw Exception(_handleError(e));
    }
  }

  /// 🟢 إلغاء الاشتراك
  Future<void> cancel() async {
    try {
      print('🔵 [SubscriptionService] Cancelling subscription...');
      await _dio.post('/subscription/cancel');
      print('✅ [SubscriptionService] Subscription cancelled successfully');
    } on DioException catch (e) {
      print('❌ [SubscriptionService] Cancel error: ${_handleError(e)}');
      throw Exception(_handleError(e));
    }
  }

  /// 🟠 دالة خاصة للتعامل مع الأخطاء
  String _handleError(DioException e) {
    try {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      // Handle specific status codes
      if (statusCode == 401) {
        return 'غير مصرح. يرجى تسجيل الدخول مرة أخرى.';
      }
      if (statusCode == 403) {
        return 'لا تملك صلاحية للقيام بهذا الإجراء.';
      }
      if (statusCode == 404) {
        return 'لم يتم العثور على الخطة المطلوبة.';
      }
      if (statusCode == 422) {
        return 'البيانات المدخلة غير صحيحة. تحقق من الخطة المختارة.';
      }
      if (statusCode == 500) {
        return 'خطأ في الخادم. يرجى المحاولة لاحقاً.';
      }
      if (statusCode == 503) {
        return 'الخادم قيد الصيانة الآن. حاول مرة أخرى لاحقاً.';
      }

      // Try to extract error message from response
      if (data is Map) {
        if (data['message'] != null) {
          return data['message'].toString();
        }
        if (data['error'] != null) {
          return data['error'].toString();
        }
        if (data['errors'] != null) {
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            return errors.first.toString();
          }
          if (errors is Map && errors.isNotEmpty) {
            return errors.values.first.toString();
          }
        }
      }

      // Fallback based on error type
      if (e.type == DioExceptionType.connectionTimeout) {
        return 'انتهت مهلة الاتصال. تحقق من الإنترنت.';
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        return 'انتهت مهلة الاستقبال. حاول مرة أخرى.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'فشل الاتصال بالخادم. تحقق من الإنترنت.';
      }

      return e.message ?? 'حدث خطأ غير متوقع';
    } catch (ex) {
      print('❌ Error extracting error message: $ex');
      return 'حدث خطأ في معالجة رسالة الخطأ';
    }
  }
}
