/// Base API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends ApiException {
  NetworkException({
    super.message = 'فشل الاتصال بالإنترنت. تحقق من اتصالك بالشبكة.',
    super.statusCode,
    super.data,
  });
}

/// Authentication exceptions
class AuthException extends ApiException {
  AuthException({
    super.message = 'فشل المصادقة. يرجى تسجيل الدخول مرة أخرى.',
    super.statusCode,
    super.data,
  });
}

class UnauthorizedException extends AuthException {
  UnauthorizedException({
    super.message = 'غير مصرح لك بالوصول إلى هذا المحتوى.',
    super.statusCode = 401,
    super.data,
  });
}

class TokenExpiredException extends AuthException {
  TokenExpiredException({
    super.message = 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.',
    super.statusCode = 401,
    super.data,
  });
}

/// Server exceptions
class ServerException extends ApiException {
  ServerException({
    super.message = 'خطأ في الخادم. يرجى المحاولة لاحقاً.',
    super.statusCode = 500,
    super.data,
  });
}

class MaintenanceException extends ServerException {
  MaintenanceException({
    super.message = 'الخادم قيد الصيانة حالياً. يرجى المحاولة لاحقاً.',
    super.statusCode = 503,
    super.data,
  });
}

/// Validation exceptions
class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException({
    super.message = 'خطأ في التحقق من البيانات.',
    super.statusCode = 422,
    this.errors,
    super.data,
  });

  String get firstError {
    if (errors == null || errors!.isEmpty) return message;
    return errors!.values.first.first;
  }

  List<String> getFieldErrors(String field) {
    return errors?[field] ?? [];
  }
}

/// Not Found exceptions
class NotFoundException extends ApiException {
  NotFoundException({
    super.message = 'المحتوى المطلوب غير موجود.',
    super.statusCode = 404,
    super.data,
  });
}

/// Forbidden exceptions
class ForbiddenException extends ApiException {
  ForbiddenException({
    super.message = 'لا تملك صلاحية الوصول إلى هذا المحتوى.',
    super.statusCode = 403,
    super.data,
  });
}

/// Subscription exceptions
class SubscriptionException extends ApiException {
  SubscriptionException({
    super.message = 'يتطلب هذا المحتوى اشتراكاً مدفوعاً.',
    super.statusCode,
    super.data,
  });
}

class SubscriptionExpiredException extends SubscriptionException {
  SubscriptionExpiredException({
    super.message = 'انتهى اشتراكك. يرجى تجديد الاشتراك للمتابعة.',
    super.statusCode,
    super.data,
  });
}

/// Timeout exceptions
class TimeoutException extends ApiException {
  TimeoutException({
    super.message = 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.',
    super.statusCode = 408,
    super.data,
  });
}

/// Rate Limit exceptions
class RateLimitException extends ApiException {
  RateLimitException({
    super.message = 'تم تجاوز الحد المسموح من الطلبات. يرجى المحاولة لاحقاً.',
    super.statusCode = 429,
    super.data,
  });
}

/// Parse exceptions
class ParseException extends ApiException {
  ParseException({
    super.message = 'خطأ في تحليل البيانات من الخادم.',
    super.statusCode,
    super.data,
  });
}

/// Payment exceptions
class PaymentException extends ApiException {
  PaymentException({
    super.message = 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى.',
    super.statusCode,
    super.data,
  });
}

/// Device Limit exceptions
class DeviceLimitException extends ApiException {
  DeviceLimitException({
    super.message = 'لقد وصلت إلى الحد الأقصى من الأجهزة المسموح بها.',
    super.statusCode,
    super.data,
  });
}

/// Unknown exceptions
class UnknownException extends ApiException {
  UnknownException({
    super.message = 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.',
    super.statusCode,
    super.data,
  });
}
