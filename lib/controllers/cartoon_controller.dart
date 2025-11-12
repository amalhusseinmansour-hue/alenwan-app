import 'package:flutter/foundation.dart'; // ✅ يوفّر ChangeNotifier + kDebugMode
import 'package:alenwan/core/services/cartoon_service.dart';
import 'package:alenwan/models/cartoon_model.dart';

class CartoonController extends ChangeNotifier {
  final CartoonService _cartoonService = CartoonService();

  List<CartoonModel> _cartoons = [];
  List<CartoonModel> get cartoons => _cartoons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  CartoonModel? _selectedCartoon;
  CartoonModel? get selectedCartoon => _selectedCartoon;

  List<CartoonModel> _episodes = [];
  List<CartoonModel> get episodes => _episodes;

  CartoonController() {
    loadCartoons();
  }

  /// تحميل كل الكرتون
  Future<void> loadCartoons() async {
    _setLoading(true);
    _error = null;

    try {
      _cartoons = await _cartoonService.fetchCartoons();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {}
    }

    _setLoading(false);
  }

  /// تحميل تفاصيل كرتون محدد
  Future<void> loadCartoonDetails(int id) async {
    _setLoading(true);
    _error = null;

    try {
      _selectedCartoon = await _cartoonService.fetchCartoonDetails(id);
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  /// تحميل الحلقات المرتبطة
  Future<void> loadEpisodes(int cartoonId) async {
    _setLoading(true);
    _error = null;

    try {
      _episodes = await _cartoonService.fetchRelatedEpisodes(cartoonId);
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
