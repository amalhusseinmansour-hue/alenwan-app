class AppConfig {
  // Environment configuration
  // Set to true when deploying to production
  static const bool isProduction = true; // ✅ PRODUCTION MODE - Using live server

  // Production URLs
  static const String productionDomain = "https://alenwan.app";

  // Development URLs (local Laravel backend)
  // For emulator: http://10.0.2.2:8000
  // For physical device on same network: http://YOUR_LOCAL_IP:8000
  static const String developmentDomain = "http://192.168.1.9:8000";

  // Current domain based on environment
  static String get domain =>
      isProduction ? productionDomain : developmentDomain;

  // API base URL (adds /api to domain)
  static String get apiBaseUrl => "$domain/api";

  // API version prefix (no version for now)
  static String get apiVersion => "";

  // Full API URL (direct to /api without version)
  static String get apiUrl => apiBaseUrl;

  // Storage URL for images and videos
  static String get storageBaseUrl => "$domain/storage";

  // App Configuration
  static const String appName = "ALENWAN PLAY PLUS";
  static const String appVersion = "1.1.1";

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // API Endpoints
  static const String loginEndpoint = "/auth/login";
  static const String registerEndpoint = "/auth/register";
  static const String socialLoginEndpoint = "/auth/social-login";
  static const String forgotPasswordEndpoint = "/auth/forgot-password";

  // Content Endpoints
  static const String moviesEndpoint = "/movies";
  static const String seriesEndpoint = "/series";
  static const String liveStreamsEndpoint = "/live-streams";
  static const String channelsEndpoint = "/channels";
  static const String bannersEndpoint = "/sliders";
  static const String categoriesEndpoint = "/categories";
  static const String searchEndpoint = "/search";

  // Test endpoint
  static const String testEndpoint = "/test-api";

  // Vimeo Configuration (if using Vimeo)
  static const String vimeoBaseUrl = "https://api.vimeo.com";
  static const String vimeoAccessToken = "your-vimeo-access-token";

  // Payment Configuration
  static const String tapApiKey = "your-tap-api-secret-key-here";

  // Feature Flags
  static const bool enableDeviceManagement = true;
  static const bool enableOfflineDownloads = true;
  static const bool enableVideoProtection = true;
  static const bool enableSubscriptions = true;
  static const bool enableGuestMode = true; // السماح بالدخول كضيف

  // Device Limits
  static const int maxDevicesPerUser = 1;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB
}
