import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../device_settings/device_fingerprint_service.dart';
import '../exceptions/error_handler.dart';
import '../exceptions/api_exceptions.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;
  final DeviceFingerprintService _fingerprintService = DeviceFingerprintService();

  static const _tokenKey = 'token';

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  String _handleError(dynamic e, [String fallback = 'حدث خطأ غير متوقع']) {
    if (e is DioException) {
      final apiException = ErrorHandler.handleDioError(e);
      return apiException.message;
    } else if (e is ApiException) {
      return e.message;
    }
    return fallback;
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String phone) async {
    try {
      // Get device information
      final deviceId = await _fingerprintService.getDeviceId();
      final deviceInfo = await _fingerprintService.getDeviceInfo();

      final res = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone': phone,
        'device_id': deviceId,
        'device_name': deviceInfo['model'] ?? 'Unknown Device',
        'device_type': deviceInfo['platform'] ?? 'mobile',
        'platform': deviceInfo['platform'] ?? 'android',
      });

      // Handle response based on Laravel structure
      final data = res.data['data'] ?? res.data;
      final token = data['token'];
      if (token != null) await _saveToken(token);

      return {
        'success': true,
        'token': token,
        'user': data['user'],
      };
    } on DioException catch (e) {
      final apiException = ErrorHandler.handleDioError(e);
      // Use firstError for ValidationException to show specific field errors
      final errorMessage = apiException is ValidationException
          ? apiException.firstError
          : apiException.message;
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      return {'success': false, 'error': _handleError(e, 'فشل التسجيل')};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Get device information
      final deviceId = await _fingerprintService.getDeviceId();
      final deviceInfo = await _fingerprintService.getDeviceInfo();

      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
        'device_id': deviceId,
        'device_name': deviceInfo['model'] ?? 'Unknown Device',
        'device_type': deviceInfo['platform'] ?? 'mobile',
        'platform': deviceInfo['platform'] ?? 'android',
      });

      // API returns: { status: 'success', data: { user: {...}, token: '...' } }
      final data = res.data['data'] ?? res.data;
      final token = data['token'];
      if (token != null) {
        await _saveToken(token);
        // Update ApiClient auth header
        await ApiClient().refreshAuthHeader();
      }

      return {
        'success': true,
        'token': token,
        'user': data['user'],
      };
    } on DioException catch (e) {
      final apiException = ErrorHandler.handleDioError(e);
      // Use firstError for ValidationException to show specific field errors
      final errorMessage = apiException is ValidationException
          ? apiException.firstError
          : apiException.message;
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      return {'success': false, 'error': _handleError(e, 'فشل تسجيل الدخول')};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final res = await _dio.post('/auth/forgot-password', data: {'email': email});
      return res.data;
    } on DioException catch (e) {
      final apiException = ErrorHandler.handleDioError(e);
      return {'success': false, 'error': apiException.message};
    } catch (e) {
      return {'success': false, 'error': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final res = await _dio.post('/reset-password', data: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      });

      return res.data;
    } on DioException catch (e) {
      final apiException = ErrorHandler.handleDioError(e);
      return {
        'success': false,
        'message': apiException.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e, 'فشل إعادة تعيين كلمة المرور'),
      };
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _dio.post(
          '/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
      // Ignore errors during logout
    } finally {
      await _removeToken();
      // Clear ApiClient auth header
      await ApiClient().refreshAuthHeader();
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final res = await _dio.get('/me');
      // Handle Laravel response structure
      // الـ response الفعلي: {"success": true, "data": {"user": {...}}}
      if (res.data is Map) {
        final body = res.data as Map;
        // تحقق من success أو status
        final isSuccess = body['success'] == true || body['status'] == 'success';

        if (isSuccess && body['data'] != null) {
          final data = body['data'] as Map;
          // تحقق إذا كانت البيانات في data.user
          if (data.containsKey('user')) {
            return Map<String, dynamic>.from(data['user'] as Map);
          }
          // إذا كانت البيانات مباشرة في data
          return Map<String, dynamic>.from(data);
        }
      }
      return null;
    } on DioException catch (e) {
      final apiException = ErrorHandler.handleDioError(e);
      print('❌ Fetch profile error: ${apiException.message}');
      return null;
    } catch (e) {
      print('❌ Fetch profile error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? authCode,
    String? name,
    String? phone,
    String? avatar,
    String? email,
    String? appleUserId,
    String? googleId,
  }) async {
    try {
      // Get device information
      final deviceId = await _fingerprintService.getDeviceId();
      final deviceInfo = await _fingerprintService.getDeviceInfo();

      final res = await _dio.post('/auth/social-login', data: {
        'provider': provider,
        if (idToken != null) 'id_token': idToken,
        if (accessToken != null) 'access_token': accessToken,
        if (authCode != null) 'auth_code': authCode,
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
        if (email != null) 'email': email,
        if (appleUserId != null) 'apple_user_id': appleUserId,
        if (googleId != null) 'google_id': googleId,
        'device_id': deviceId,
        'device_name': deviceInfo['model'] ?? 'Unknown Device',
        'device_type': deviceInfo['platform'] ?? 'mobile',
        'platform': deviceInfo['platform'] ?? 'android',
      });

      // Handle Laravel response structure
      final data = res.data['data'] ?? res.data;
      final token = data['token'];
      if (token != null) {
        await _saveToken(token);
        await ApiClient().refreshAuthHeader();
      }

      return {
        'success': token != null,
        'token': token,
        'user': data['user'],
        'message': res.data['message'],
      };
    } on DioException catch (e) {
      final apiException = ErrorHandler.handleDioError(e);
      return {
        'success': false,
        'error': apiException.message,
        'message': apiException.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': _handleError(e, 'فشل تسجيل الدخول الاجتماعي'),
        'message': 'فشل تسجيل الدخول',
      };
    }
  }

  // =========================
  // 📱 Phone / WhatsApp OTP
  // =========================
  Future<bool> requestOtp({required String phone, String channel = 'sms'}) async {
    try {
      final res = await _dio.post('/login/phone', data: {
        'phone': phone,
        'channel': channel,
      });
      return (res.data['success'] == true);
    } on DioException catch (e) {
      final apiException = ErrorHandler.handleDioError(e);
      throw apiException.message;
    } catch (e) {
      throw _handleError(e, 'تعذر إرسال الرمز');
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final res = await _dio.post('/login/phone/verify', data: {
        'phone': phone,
        'otp': otp,
      });

      // Handle Laravel response structure
      final data = res.data['data'] ?? res.data;
      final token = data['token'];
      if (token != null) {
        await _saveToken(token);
        await ApiClient().refreshAuthHeader();
      }

      return {
        'success': token != null,
        'token': token,
        'user': data['user'],
      };
    } on DioException catch (e) {
      final apiException = ErrorHandler.handleDioError(e);
      return {
        'success': false,
        'error': apiException.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': _handleError(e, 'فشل التحقق من الرمز'),
      };
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get current user info from token/storage
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return {'name': userJson}; // Simplified - in real app parse JSON
    }
    return null;
  }

  /// Delete user account permanently
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      print('🗑️ [AuthService] Attempting to delete account...');

      final response = await _dio.delete(
        '/auth/delete-account',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      print('✅ [AuthService] Account deleted successfully');

      return {
        'success': true,
        'message': response.data['message'] ?? 'تم حذف الحساب بنجاح',
      };
    } on DioException catch (e) {
      print('❌ [AuthService] Delete account error: ${e.message}');

      if (e.response != null) {
        print('❌ [AuthService] Response: ${e.response?.data}');

        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'فشل حذف الحساب',
        };
      }

      return {
        'success': false,
        'message': 'فشل الاتصال بالخادم',
      };
    } catch (e) {
      print('❌ [AuthService] Unexpected error: $e');

      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
      };
    }
  }
}
