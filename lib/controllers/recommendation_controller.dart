import 'package:flutter/foundation.dart';
import 'package:alenwan/core/services/recommendation_service.dart';

class RecommendationController extends ChangeNotifier {
  final _service = RecommendationService();
  List<Map<String, dynamic>> recommendations = [];
  bool isLoading = false;
  String? error;

  Future<void> loadRecommendations(int userId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      recommendations = await _service.getRecommendations(userId);
    } catch (e) {
      error = 'فشل تحميل التوصيات: $e';
      debugPrint("Recommendation error: $e");
      recommendations = [];
    }
    isLoading = false;
    notifyListeners();
  }
}
