import 'dart:io';
import 'package:dio/dio.dart';
import 'api_exceptions.dart';

class ErrorHandler {
  /// Convert DioException to custom ApiException
  static ApiException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت.',
          data: error.response?.data,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'تم إلغاء الطلب.',
          data: error.response?.data,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'فشل الاتصال. تحقق من اتصالك بالإنترنت.',
          data: error.response?.data,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'خطأ في شهادة الأمان. لا يمكن الاتصال بالخادم.',
          data: error.response?.data,
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException(
            message: 'لا يوجد اتصال بالإنترنت.',
            data: error.response?.data,
          );
        }
        return UnknownException(
          message: 'حدث خطأ غير متوقع: ${error.message}',
          data: error.response?.data,
        );
    }
  }

  /// Handle bad response based on status code
  static ApiException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Extract error message from response
    String? errorMessage;
    try {
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message']?.toString() ??
            responseData['error']?.toString();
      }
    } catch (e) {
      print('⚠️ Error extracting error message: $e');
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message: errorMessage ?? 'طلب غير صالح.',
          statusCode: statusCode,
          data: responseData,
        );

      case 401:
        if (errorMessage?.toLowerCase().contains('expired') ?? false) {
          return TokenExpiredException(
            message: errorMessage ?? 'انتهت صلاحية الجلسة.',
            data: responseData,
          );
        }
        return UnauthorizedException(
          message: errorMessage ?? 'غير مصرح. يرجى تسجيل الدخول.',
          data: responseData,
        );

      case 403:
        if (errorMessage?.toLowerCase().contains('subscription') ?? false) {
          return SubscriptionException(
            message: errorMessage ?? 'يتطلب هذا المحتوى اشتراكاً.',
            data: responseData,
          );
        }
        return ForbiddenException(
          message: errorMessage ?? 'لا تملك صلاحية الوصول.',
          data: responseData,
        );

      case 404:
        return NotFoundException(
          message: errorMessage ?? 'المحتوى غير موجود.',
          data: responseData,
        );

      case 422:
        Map<String, List<String>>? errors;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('errors')) {
          errors = _parseValidationErrors(responseData['errors']);
        }
        return ValidationException(
          message: errorMessage ?? 'خطأ في التحقق من البيانات.',
          errors: errors,
          data: responseData,
        );

      case 429:
        return RateLimitException(
          message: errorMessage ?? 'تم تجاوز الحد المسموح من الطلبات.',
          data: responseData,
        );

      case 500:
        return ServerException(
          message: errorMessage ?? 'خطأ في الخادم.',
          data: responseData,
        );

      case 503:
        return MaintenanceException(
          message: errorMessage ?? 'الخادم قيد الصيانة.',
          data: responseData,
        );

      default:
        return ApiException(
          message: errorMessage ?? 'حدث خطأ غير متوقع.',
          statusCode: statusCode,
          data: responseData,
        );
    }
  }

  /// Parse validation errors from Laravel response
  static Map<String, List<String>> _parseValidationErrors(dynamic errors) {
    final Map<String, List<String>> parsedErrors = {};

    if (errors is Map<String, dynamic>) {
      errors.forEach((key, value) {
        if (value is List) {
          parsedErrors[key] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          parsedErrors[key] = [value];
        }
      });
    }

    return parsedErrors;
  }

  /// Handle generic exceptions
  static ApiException handleError(dynamic error) {
    if (error is DioException) {
      return handleDioError(error);
    } else if (error is ApiException) {
      return error;
    } else if (error is SocketException) {
      return NetworkException(
        message: 'لا يوجد اتصال بالإنترنت.',
      );
    } else if (error is FormatException) {
      return ParseException(
        message: 'خطأ في تحليل البيانات.',
      );
    } else {
      return UnknownException(
        message: error.toString(),
      );
    }
  }

  /// Get user-friendly error message
  static String getUserMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is DioException) {
      return handleDioError(error).message;
    } else {
      return 'حدث خطأ غير متوقع.';
    }
  }

  /// Check if error is recoverable (should retry)
  static bool isRecoverable(ApiException error) {
    return error is NetworkException ||
        error is TimeoutException ||
        error is ServerException ||
        error is MaintenanceException;
  }

  /// Check if error requires authentication
  static bool requiresAuth(ApiException error) {
    return error is UnauthorizedException || error is TokenExpiredException;
  }

  /// Check if error is related to subscription
  static bool requiresSubscription(ApiException error) {
    return error is SubscriptionException ||
        error is SubscriptionExpiredException;
  }
}
