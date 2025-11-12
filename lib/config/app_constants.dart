class AppConstants {
  // App Information
  static const String appName = 'ALENWAN PLAY PLUS';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://alenwan.app';

  static const String apiVersion = 'v1';

  // Storage Keys
  static const String languageKey = 'language';
  static const String themeKey = 'isDarkMode';
  static const String userKey = 'user_data';

  // Default Values
  static const String defaultLanguage = 'ar';
  static const bool defaultDarkMode = false;

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
