import 'package:alenwan/models/simple_item.dart';
import 'package:flutter/foundation.dart';
import '../core/services/home_sections_service.dart';

class HomeSectionsController with ChangeNotifier {
  final HomeSectionsService service;
  HomeSectionsController({required this.service});

  bool isLoading = false;
  String? error;

  List<SimpleItem> bestSeries = [];
  List<SimpleItem> comingSoon = [];
  List<SimpleItem> liveStreams = [];
  List<SimpleItem> sports = [];
  List<SimpleItem> documentaries = [];

  Future<void> load({int limit = 12}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final sections = await service.fetchAll(limit: limit);

      for (final s in sections) {
        switch (s.type) {
          case 'best_series':
            bestSeries = s.items;
            break;
          case 'coming_soon':
            comingSoon = s.items;
            break;
          case 'live_streams':
            liveStreams = s.items;
            break;
          case 'sports':
            sports = s.items;
            break;
          case 'documentaries':
            documentaries = s.items;
            break;
        }
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
