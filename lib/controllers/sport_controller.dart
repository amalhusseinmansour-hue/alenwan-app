// lib/controllers/sport_controller.dart
import 'package:flutter/foundation.dart';
import 'package:alenwan/core/services/sport_service.dart';
import '../models/sport_model.dart';

class SportController extends ChangeNotifier {
  final SportService _sportService = SportService();

  List<SportModel> _sports = [];
  List<SportModel> get sports => _sports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  SportController() {
    loadSports();
  }

  /// 🔹 تحميل قائمة الرياضات
  Future<void> loadSports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sports = await _sportService.fetchSports();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 إعادة التحميل (refresh)
  Future<void> refresh() async {
    await loadSports();
  }

  /// 🔹 إعادة تعيين الخطأ
  void resetError() {
    _error = null;
    notifyListeners();
  }
}
