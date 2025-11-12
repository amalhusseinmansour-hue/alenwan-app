import 'package:alenwan/config.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../device_settings/device_auth_interceptor.dart';
import '../exceptions/error_handler.dart';
import '../exceptions/api_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  // Retry configuration
  static const int _maxRetries = 3;
  static const int _retryDelay = 1000; // milliseconds

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl, // https://alenwan.app/api
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: const {'Accept': 'application/json'},
      ),
    );

    // Add interceptors for error handling and retry logic
    dio.interceptors.addAll([
      // Device authentication interceptor
      DeviceAuthInterceptor(),

      // Request/Response logging interceptor
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),

      // Error handling interceptor with custom exceptions
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final apiException = ErrorHandler.handleDioError(error);

          print('❌ API Error: ${apiException.message}');
          print('   Status Code: ${apiException.statusCode}');

          // Handle token expiration
          if (ErrorHandler.requiresAuth(apiException)) {
            print('⚠️ Authentication required: Clearing tokens');
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            await prefs.remove('auth_token');
            // TODO: Navigate to login screen
          }

          // Handle subscription issues
          if (ErrorHandler.requiresSubscription(apiException)) {
            print('⚠️ Subscription required');
            // TODO: Navigate to subscription screen
          }

          handler.next(error);
        },
      ),

      // Retry interceptor
      RetryInterceptor(dio: dio),
    ]);
  }

  /// e.g. https://alenwan.app/api
  String get baseUrl => dio.options.baseUrl;

  /// e.g. https://alenwan.app
  /// يزيل /api في الآخر عشان الملفات والصور
  String get filesBaseUrl {
    final re = RegExp(r'/api/?$');
    return baseUrl.replaceFirst(re, '');
  }

  /// يحدث الـ Authorization Header من SharedPreferences
  Future<void> refreshAuthHeader() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final t = prefs.getString('token') ?? prefs.getString('auth_token');
      if (t != null && t.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $t';
      } else {
        dio.options.headers.remove('Authorization');
      }
    } catch (e) {
      print('Error refreshing auth header: $e');
    }
  }

  /// Make a GET request with retry logic and error handling
  Future<Response> getWithRetry(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retries = _maxRetries,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      final apiException = ErrorHandler.handleDioError(e);

      // Retry if error is recoverable
      if (retries > 0 && ErrorHandler.isRecoverable(apiException)) {
        print('🔄 Retrying request... (${_maxRetries - retries + 1}/$_maxRetries)');
        await Future.delayed(Duration(milliseconds: _retryDelay * (_maxRetries - retries + 1)));
        return getWithRetry(path, queryParameters: queryParameters, options: options, retries: retries - 1);
      }

      rethrow;
    }
  }

  /// Make a POST request with retry logic and error handling
  Future<Response> postWithRetry(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retries = _maxRetries,
  }) async {
    try {
      return await dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      final apiException = ErrorHandler.handleDioError(e);

      // Retry if error is recoverable (but not for POST by default to avoid duplication)
      // Only retry on network/timeout errors for POST requests
      if (retries > 0 && (apiException is NetworkException || apiException is TimeoutException)) {
        print('🔄 Retrying POST request... (${_maxRetries - retries + 1}/$_maxRetries)');
        await Future.delayed(Duration(milliseconds: _retryDelay * (_maxRetries - retries + 1)));
        return postWithRetry(path, data: data, queryParameters: queryParameters, options: options, retries: retries - 1);
      }

      rethrow;
    }
  }

  /// Check if error should trigger a retry
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.connectionError ||
           (error.type == DioExceptionType.badResponse &&
            (error.response?.statusCode == 503 || error.response?.statusCode == 504));
  }
}

/// Custom retry interceptor
class RetryInterceptor extends Interceptor {
  final Dio dio;

  RetryInterceptor({required this.dio});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown;

    if (shouldRetry && err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }

    int retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    if (shouldRetry && retryCount < 3) {
      retryCount++;
      err.requestOptions.extra['retryCount'] = retryCount;

      await Future.delayed(Duration(seconds: retryCount));

      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}