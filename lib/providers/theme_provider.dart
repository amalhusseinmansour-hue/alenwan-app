import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  final SharedPreferences prefs;

  ThemeProvider(this.prefs) {
    _isDark = prefs.getBool('isDark') ?? false;
  }

  bool get isDark => _isDark;

  ThemeMode get currentTheme => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark = !_isDark;
    prefs.setBool('isDark', _isDark);
    notifyListeners();
  }
}
