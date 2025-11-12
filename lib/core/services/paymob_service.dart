import 'package:dio/dio.dart';
import '../../config.dart';
import 'auth_service.dart';

class PaymobService {
  final Dio _dio;

  PaymobService({required Dio dio})
      : _dio = dio;

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
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'payment_url': response.data['data']['payment_url'],
          'payment_id': response.data['data']['payment_id'],
          'amount': response.data['data']['amount'],
          'currency': response.data['data']['currency'],
          'plan_type': response.data['data']['plan_type'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to initiate payment');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to initiate payment');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(int paymentId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/paymob/payment/$paymentId/status',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'status': response.data['data']['status'],
          'payment_id': response.data['data']['payment_id'],
          'amount': response.data['data']['amount'],
          'plan_type': response.data['data']['plan_type'],
          'paid_at': response.data['data']['paid_at'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to check status');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to check status');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/paymob/history',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final payments = (response.data['data']['data'] as List)
            .map((payment) => payment as Map<String, dynamic>)
            .toList();
        return payments;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get history');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get history');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
