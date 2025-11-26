import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alenwan/models/auth_settings_model.dart';
import 'package:flutter/foundation.dart';
import '../../config.dart';

class AppSettingsService {
  static final AppSettingsService _instance = AppSettingsService._internal();
  factory AppSettingsService() => _instance;
  AppSettingsService._internal();

  AuthSettingsModel? _cachedAuthSettings;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 30);

  /// Get authentication settings (with cache)
  Future<AuthSettingsModel> getAuthSettings() async {
    // Return cached settings if available and not expired
    if (_cachedAuthSettings != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      debugPrint('📦 [AppSettings] Returning cached auth settings');
      return _cachedAuthSettings!;
    }

    try {
      debugPrint('🌐 [AppSettings] Fetching auth settings from API...');

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/settings/auth'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ [AppSettings] Request timeout, using default settings');
          throw Exception('Request timeout');
        },
      );

      debugPrint('📡 [AppSettings] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          _cachedAuthSettings = AuthSettingsModel.fromJson(data['data']);
          _cacheTime = DateTime.now();

          debugPrint('✅ [AppSettings] Auth settings loaded successfully');
          debugPrint('   - Google Login: ${_cachedAuthSettings!.enableGoogleLogin}');
          debugPrint('   - Apple Login: ${_cachedAuthSettings!.enableAppleLogin}');
          debugPrint('   - Guest Mode: ${_cachedAuthSettings!.enableGuestMode}');

          return _cachedAuthSettings!;
        }
      }

      debugPrint('⚠️ [AppSettings] Failed to load settings, using defaults');
      return AuthSettingsModel.defaultSettings();

    } catch (e) {
      debugPrint('❌ [AppSettings] Error fetching auth settings: $e');
      debugPrint('   Using default settings (all enabled)');

      // Return default settings if API fails
      return AuthSettingsModel.defaultSettings();
    }
  }

  /// Clear cached settings
  void clearCache() {
    _cachedAuthSettings = null;
    _cacheTime = null;
    debugPrint('🗑️ [AppSettings] Cache cleared');
  }

  /// Force refresh settings from API
  Future<AuthSettingsModel> refreshAuthSettings() async {
    clearCache();
    return getAuthSettings();
  }
}
