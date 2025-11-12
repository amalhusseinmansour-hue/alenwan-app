// lib/controllers/documentary_controller.dart
import 'package:flutter/foundation.dart';
import 'package:alenwan/core/services/documentary_service.dart';
import 'package:alenwan/models/documentary_model.dart';

class DocumentaryController extends ChangeNotifier {
  final DocumentaryService _service = DocumentaryService();

  List<Documentary> documentaries = [];
  bool isLoading = false;
  String? error;

  Future<void> loadDocumentaries() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      documentaries = await _service.fetchDocumentaries();
    } catch (e) {
      error = e.toString();
      if (kDebugMode) {}
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔄 لإعادة التحميل
  void refresh() {
    loadDocumentaries();
  }
}
