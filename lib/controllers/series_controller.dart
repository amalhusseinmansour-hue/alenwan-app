// lib/controllers/series_controller.dart
import 'package:flutter/foundation.dart';
import 'package:alenwan/models/series_model.dart';
import 'package:alenwan/core/services/series_service.dart';

class SeriesController extends ChangeNotifier {
  final SeriesService _service = SeriesService();

  // قائمة المسلسلات
  final List<SeriesModel> _series = [];
  List<SeriesModel> get series => List.unmodifiable(_series);

  // تفاصيل مسلسل واحد
  SeriesModel? _seriesDetails;
  SeriesModel? get seriesDetails => _seriesDetails;

  // حالة التحميل
  bool _isLoadingList = false;
  bool get isLoadingList => _isLoadingList;

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  String? _error;
  String? get error => _error;

  /// 🟢 جلب كل المسلسلات
  Future<void> loadSeries() async {
    if (_isLoadingList) return; // منع التكرار
    _isLoadingList = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.fetchAllSeries();
      _series
        ..clear()
        ..addAll(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  /// 🟢 جلب تفاصيل مسلسل واحد
  Future<void> loadSeriesDetails(int seriesId) async {
    if (_isLoadingDetails) return; // منع التكرار
    _isLoadingDetails = true;
    _error = null;
    notifyListeners();

    try {
      _seriesDetails = await _service.fetchSeriesDetails(seriesId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  /// 🟠 تحديث مسلسل واحد داخل القائمة لو موجود
  void updateSeriesInList(SeriesModel updated) {
    final index = _series.indexWhere((s) => s.id == updated.id);
    if (index >= 0) {
      _series[index] = updated;
      notifyListeners();
    }
  }

  /// 🟠 مسح الكاش
  void clear() {
    _series.clear();
    _seriesDetails = null;
    _error = null;
    notifyListeners();
  }
}
