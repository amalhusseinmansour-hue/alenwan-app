import 'package:flutter/foundation.dart';

/// Professional logging system for Alenwan app
/// Replaces print() statements with structured logging
class AppLogger {
  static const String _appName = 'Alenwan';

  /// Log level colors for better visibility
  static const String _resetColor = '\x1B[0m';
  static const String _redColor = '\x1B[31m';
  static const String _yellowColor = '\x1B[33m';
  static const String _blueColor = '\x1B[34m';
  static const String _greenColor = '\x1B[32m';

  /// Log debug information (only in debug mode)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_blueColor[DEBUG]$_resetColor [$_appName]$tagStr $message');
    }
  }

  /// Log information
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_greenColor[INFO]$_resetColor [$_appName]$tagStr $message');
    }
  }

  /// Log warnings
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_yellowColor[WARNING]$_resetColor [$_appName]$tagStr $message');
    }
  }

  /// Log errors
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_redColor[ERROR]$_resetColor [$_appName]$tagStr $message');
      if (error != null) {
        debugPrint('$_redColor[ERROR]$_resetColor Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('$_redColor[ERROR]$_resetColor Stack trace: $stackTrace');
      }
    }
  }

  /// Log API requests
  static void api(String message, {String? endpoint}) {
    if (kDebugMode) {
      final endpointStr = endpoint != null ? '[$endpoint]' : '';
      debugPrint('$_blueColor[API]$_resetColor [$_appName]$endpointStr $message');
    }
  }

  /// Log authentication events
  static void auth(String message) {
    if (kDebugMode) {
      debugPrint('$_greenColor[AUTH]$_resetColor [$_appName] $message');
    }
  }

  /// Log payment events
  static void payment(String message) {
    if (kDebugMode) {
      debugPrint('$_yellowColor[PAYMENT]$_resetColor [$_appName] $message');
    }
  }

  /// Log video player events
  static void video(String message) {
    if (kDebugMode) {
      debugPrint('$_blueColor[VIDEO]$_resetColor [$_appName] $message');
    }
  }
}
