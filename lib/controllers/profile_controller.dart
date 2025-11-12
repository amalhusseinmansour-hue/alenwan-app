// lib/controllers/profile_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;

  ProfileController() {
    _loadFromCache();
    fetchProfile(); // تحديث من السيرفر
  }

  /// تحميل من الكاش
  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('user_cache');
    if (cached != null) {
      try {
        _user = Map<String, dynamic>.from(jsonDecode(cached));
        notifyListeners();
      } catch (e) {
        debugPrint("Error: $e");
      }
    }
  }

  /// تحميل من السيرفر
  Future<void> fetchProfile({bool force = false}) async {
    if (!force && _user != null) {
      notifyListeners();
      return;
    }
    try {
      _isLoading = true;
      notifyListeners();

      final res = await _profileService.getProfile();
      if (res.success && res.data != null) {
        _user = res.data;
        _error = null;

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user_cache', jsonEncode(_user));
      } else {
        _error = res.error ?? 'فشل في تحميل البيانات';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث إجباري
  Future<void> refresh() => fetchProfile(force: true);

  /// مسح بيانات البروفايل (Logout)
  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_cache');
    _user = null;
    _error = null;
    notifyListeners();
  }
}
