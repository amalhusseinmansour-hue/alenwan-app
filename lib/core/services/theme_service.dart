import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _key = 'isDarkMode';

  /// ✅ تحميل الوضع الحالي (افتراضي Light لو مش محفوظ)
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// ✅ تبديل بين Light و Dark
  Future<void> switchTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final current = Get.isDarkMode;
    final newMode = !current;

    await prefs.setBool(_key, newMode);
    Get.changeThemeMode(newMode ? ThemeMode.dark : ThemeMode.light);
  }

  /// ✅ تطبيق الوضع الحالي عند بداية تشغيل التطبيق
  Future<void> initTheme() async {
    final mode = await getThemeMode();
    Get.changeThemeMode(mode);
  }
}
