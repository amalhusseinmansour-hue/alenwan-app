import 'package:flutter/foundation.dart';
import 'package:alenwan/core/services/documentary_service.dart';
import 'package:alenwan/models/documentary_model.dart';

class DocumentaryDetailsController extends ChangeNotifier {
  final DocumentaryService _service = DocumentaryService();

  Documentary? _documentary;
  Documentary? get documentary => _documentary;

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  String? _error;
  String? get error => _error;

  /// تحميل تفاصيل وثائقي واحد
  Future<void> loadDetails(int id) async {
    _isLoadingDetails = true;
    _error = null;
    notifyListeners();

    try {
      _documentary = await _service.fetchDocumentaryDetails(id);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {}
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  /// تحديث التفاصيل يدويًا
  Future<void> refresh(int id) async {
    await loadDetails(id);
  }
}
