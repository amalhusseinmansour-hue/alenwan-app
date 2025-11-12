// lib/controllers/channel_controller.dart
import 'package:flutter/foundation.dart';
import 'package:alenwan/core/services/api_client.dart';
import 'package:alenwan/models/channel_model.dart';

class ChannelController extends ChangeNotifier {
  bool isLoading = false;
  List<ChannelModel> channels = [];
  String? error;

  Future<void> loadChannels() async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // ⚠️ تأكد أن ApiClient عندك يوفّر Dio أو method get
      final client = ApiClient();
      final dio = client.dio; // إن كان مختلف عدّل حسب مشروعك
      final res = await dio.get('/channels'); // روت API: GET /api/channels

      final data = res.data;
      final List list = data is Map && data['data'] is List
          ? data['data']
          : (data is List ? data : []);

      channels = list.map((e) => ChannelModel.fromJson(e)).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
