// lib/controllers/settings_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsController extends ChangeNotifier {
  final SharedPreferences _prefs;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  SettingsController({required SharedPreferences prefs}) : _prefs = prefs {
    _init();
  }

  Future<void> _init() async {
    await _loadDefaultSettings();
    notifyListeners();
  }

  /// 🔹 اللغة
  String get languageCode => _prefs.getString('language') ?? 'ar';

  bool isArabic(BuildContext context) => context.locale.languageCode == 'ar';

  bool isRTL(BuildContext context) => isArabic(context);

  Future<void> setLanguage(BuildContext context, String code) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _prefs.setString('language', code);
      // ignore: use_build_context_synchronously
      await context.setLocale(Locale(code));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLanguage(BuildContext context) async {
    final newCode = languageCode == 'ar' ? 'en' : 'ar';
    await setLanguage(context, newCode);
  }

  /// 🔹 الثيم
  ThemeMode get themeMode {
    final isDark = _prefs.getBool('isDarkMode') ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleDarkMode() async {
    try {
      final current = _prefs.getBool('isDarkMode') ?? false;
      await _prefs.setBool('isDarkMode', !current);
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// 🔹 تحميل الإعدادات الافتراضية
  Future<void> _loadDefaultSettings() async {
    try {
      _prefs.putIfAbsent('language', () => 'ar');
      _prefs.putIfAbsent('isDarkMode', () => false);
    } catch (e) {
      _error = e.toString();
    }
  }

  /// 🔹 إعادة تعيين الخطأ
  void resetError() {
    _error = null;
    notifyListeners();
  }
}

extension SharedPreferencesX on SharedPreferences {
  Future<void> putIfAbsent<T>(String key, T Function() defaultValue) async {
    if (!containsKey(key)) {
      final val = defaultValue();
      if (val is bool) await setBool(key, val);
      if (val is String) await setString(key, val);
      if (val is int) await setInt(key, val);
      if (val is double) await setDouble(key, val);
      if (val is List<String>) await setStringList(key, val);
    }
  }
}
