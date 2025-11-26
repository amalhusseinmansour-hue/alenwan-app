import 'package:dio/dio.dart';
import '../../config.dart';
import 'auth_service.dart';

class PaymobService {
  final Dio _dio;

  PaymobService({required Dio dio}) : _dio = dio;

  /// Initiate subscription payment with Paymob
  /// Returns payment URL and payment ID
  Future<Map<String, dynamic>> initiateSubscription({
    required String planType, // 'monthly' or 'yearly'
    bool useAmex = false,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      print('🔵 [PaymobService] Initiating subscription for plan: $planType');

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/paymob/subscribe',
        data: {
          'plan_type': planType,
          'use_amex': useAmex,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('🔵 [PaymobService] Response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data is Map) {
        final responseBody = response.data as Map;
        final isSuccess = responseBody['success'] == true ||
            responseBody['status'] == 'success';

        if (isSuccess) {
          final data = responseBody['data'] ?? responseBody;
          if (data is Map) {
            final result = {
              'success': true,
              'payment_url': data['payment_url']?.toString() ?? '',
              'payment_id': data['payment_id']?.toString() ?? '',
              'amount': data['amount'] ?? 0,
              'currency': data['currency']?.toString() ?? 'AED',
              'plan_type': data['plan_type']?.toString() ?? planType,
            };
            print(
                '✅ [PaymobService] Subscription initiated: ${result['payment_id']}');
            return result;
          }
        }
      }

      // Extract error message from response
      String errorMsg = 'فشل في إنشاء رابط الدفع';
      if (response.data is Map) {
        final respData = response.data as Map;
        if (respData['message'] != null) {
          errorMsg = respData['message'].toString();
        } else if (respData['error'] != null) {
          errorMsg = respData['error'].toString();
        }
      }
      throw Exception(errorMsg);
    } on DioException catch (e) {
      print('❌ [PaymobService] DioException: ${e.message}');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');

      String errorMsg = 'فشل في إنشاء رابط الدفع';

      // Handle specific status codes
      if (e.response?.statusCode == 401) {
        errorMsg = 'جلسة منتهية. يرجى تسجيل الدخول مرة أخرى.';
      } else if (e.response?.statusCode == 403) {
        errorMsg = 'ممنوع. لا تملك صلاحية.';
      } else if (e.response?.statusCode == 422) {
        errorMsg = 'بيانات غير صحيحة. تحقق من الخطة.';
      } else if (e.response?.statusCode == 500) {
        errorMsg = 'خطأ في الخادم. حاول لاحقاً.';
      } else if (e.response?.data is Map) {
        final respData = e.response!.data as Map;
        if (respData['message'] != null) {
          errorMsg = respData['message'].toString();
        } else if (respData['error'] != null) {
          errorMsg = respData['error'].toString();
        }
      }

      throw Exception(errorMsg);
    } catch (e) {
      print('❌ [PaymobService] Unexpected error: $e');
      throw Exception('خطأ غير متوقع: $e');
    }
  }

  /// Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(int paymentId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      print('🔵 [PaymobService] Checking payment status: $paymentId');

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/paymob/payment/$paymentId/status',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final responseBody = response.data as Map;
        final isSuccess =
            responseBody['success'] == true || responseBody['status'] != null;

        if (isSuccess) {
          final data = responseBody['data'] ?? responseBody;
          if (data is Map) {
            final result = {
              'success': true,
              'status': data['status']?.toString() ?? 'unknown',
              'payment_id': data['payment_id']?.toString() ?? '',
              'amount': data['amount'] ?? 0,
              'plan_type': data['plan_type']?.toString() ?? '',
              'paid_at': data['paid_at']?.toString() ?? '',
            };
            print('✅ [PaymobService] Payment status: ${result['status']}');
            return result;
          }
        }
      }

      String errorMsg = 'فشل في التحقق من حالة الدفع';
      if (response.data is Map) {
        final respData = response.data as Map;
        if (respData['message'] != null) {
          errorMsg = respData['message'].toString();
        }
      }
      throw Exception(errorMsg);
    } on DioException catch (e) {
      print('❌ [PaymobService] Check status error: ${e.message}');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');

      String errorMsg = 'فشل في التحقق من حالة الدفع';

      if (e.response?.statusCode == 401) {
        errorMsg = 'جلسة منتهية. يرجى تسجيل الدخول مرة أخرى.';
      } else if (e.response?.statusCode == 404) {
        errorMsg = 'لم يتم العثور على الدفع.';
      } else if (e.response?.statusCode == 500) {
        errorMsg = 'خطأ في الخادم. حاول لاحقاً.';
      } else if (e.response?.data is Map) {
        final respData = e.response!.data as Map;
        if (respData['message'] != null) {
          errorMsg = respData['message'].toString();
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'انتهت مهلة الاتصال. تحقق من الإنترنت.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'انتهت مهلة الاستقبال. حاول مرة أخرى.';
      }

      throw Exception(errorMsg);
    } catch (e) {
      print('❌ [PaymobService] Unexpected error: $e');
      throw Exception('خطأ غير متوقع: $e');
    }
  }

  /// Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      print('🔵 [PaymobService] Fetching payment history...');

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/paymob/history',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final responseBody = response.data as Map;
        final isSuccess =
            responseBody['success'] == true || responseBody['data'] != null;

        if (isSuccess) {
          final data = responseBody['data'] ?? [];
          final paymentsList = (data is Map && data['data'] is List)
              ? (data['data'] as List)
              : (data is List ? data : []);
          final result = List<Map<String, dynamic>>.from(paymentsList.map(
              (payment) =>
                  payment is Map ? Map<String, dynamic>.from(payment) : {}));
          print('✅ [PaymobService] Fetched ${result.length} payments');
          return result;
        }
      }

      String errorMsg = 'فشل في جلب سجل الدفع';
      if (response.data is Map) {
        final respData = response.data as Map;
        if (respData['message'] != null) {
          errorMsg = respData['message'].toString();
        }
      }
      throw Exception(errorMsg);
    } on DioException catch (e) {
      print('❌ [PaymobService] History error: ${e.message}');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');

      String errorMsg = 'فشل في جلب سجل الدفع';

      if (e.response?.statusCode == 401) {
        errorMsg = 'جلسة منتهية. يرجى تسجيل الدخول مرة أخرى.';
      } else if (e.response?.statusCode == 500) {
        errorMsg = 'خطأ في الخادم. حاول لاحقاً.';
      } else if (e.response?.data is Map) {
        final respData = e.response!.data as Map;
        if (respData['message'] != null) {
          errorMsg = respData['message'].toString();
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'انتهت مهلة الاتصال. تحقق من الإنترنت.';
      }

      throw Exception(errorMsg);
    } catch (e) {
      print('❌ [PaymobService] Unexpected error: $e');
      throw Exception('خطأ غير متوقع: $e');
    }
  }
}
