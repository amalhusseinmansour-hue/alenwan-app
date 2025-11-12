// lib/controllers/podcast_controller.dart
import 'package:flutter/foundation.dart';
import 'package:alenwan/core/services/podcast_service.dart';
import 'package:alenwan/models/podcast_model.dart';

class PodcastController extends ChangeNotifier {
  final PodcastService _service = PodcastService();

  List<Podcast> podcasts = [];
  bool isLoading = false;
  String? error;

  Future<void> loadPodcasts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      podcasts = await _service.fetchPodcasts();
    } catch (e) {
      error = e.toString();
      if (kDebugMode) {
        print('Error loading podcasts: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔄 لإعادة التحميل
  void refresh() {
    loadPodcasts();
  }

  /// Get featured podcasts
  List<Podcast> get featuredPodcasts {
    return podcasts.where((p) => p.isFeatured).toList();
  }

  /// Get podcasts by category
  List<Podcast> getPodcastsByCategory(int categoryId) {
    return podcasts.where((p) => p.categoryId == categoryId).toList();
  }

  /// Get premium podcasts
  List<Podcast> get premiumPodcasts {
    return podcasts.where((p) => p.isPremium).toList();
  }

  /// Get free podcasts
  List<Podcast> get freePodcasts {
    return podcasts.where((p) => !p.isPremium).toList();
  }

  /// Get podcast by ID
  Podcast? getPodcastById(int id) {
    try {
      return podcasts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
