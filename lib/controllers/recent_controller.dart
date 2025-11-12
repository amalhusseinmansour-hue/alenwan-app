import 'package:flutter/foundation.dart';
import '../core/services/recent_service.dart';
import '../models/recent_item.dart';

class RecentController with ChangeNotifier {
  final RecentService service;
  RecentController({required this.service});

  bool isLoading = false;
  String? error;
  List<RecentItem> items = []; // ✅ الآن النوع متوافق

  Future<void> load({int days = 14, int limit = 40}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      items = await service.fetchRecent(days: days, limit: limit);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
