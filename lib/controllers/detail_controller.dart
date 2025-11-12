import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../core/services/subscription_verification_service.dart';
import '../core/services/series_service.dart';
import '../core/services/cartoon_service.dart';
import 'subscription_controller.dart';

class DetailController extends ChangeNotifier {
  final MediaItem mediaItem;
  final SubscriptionVerificationService _subscriptionService =
      SubscriptionVerificationService();

  bool _isLoadingDetails = false;
  bool _isLoadingEpisodes = false;
  String? _error;
  List<dynamic> _episodes = [];
  Map<String, dynamic>? _additionalDetails;
  bool _hasSubscriptionAccess = false;
  bool _isCheckingSubscription = true;

  DetailController({required this.mediaItem});

  // ✅ Getters
  bool get isLoadingDetails => _isLoadingDetails;
  bool get isLoadingEpisodes => _isLoadingEpisodes;
  bool get isCheckingSubscription => _isCheckingSubscription;
  String? get error => _error;

  List<dynamic> get episodes => _episodes;
  Map<String, dynamic>? get additionalDetails => _additionalDetails;
  bool get hasSubscriptionAccess => _hasSubscriptionAccess;

  // ✅ التحقق من الاشتراك
  Future<bool> checkSubscriptionAccess(
      SubscriptionController subscriptionController) async {
    _isCheckingSubscription = true;
    notifyListeners();

    try {
      _hasSubscriptionAccess =
          await _subscriptionService.verifySubscription(subscriptionController);
      return _hasSubscriptionAccess;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isCheckingSubscription = false;
      notifyListeners();
    }
  }

  // ✅ تحميل تفاصيل المحتوى
  Future<void> loadDetails() async {
    try {
      _isLoadingDetails = true;
      _error = null;
      notifyListeners();

      // محاكاة بيانات إضافية (ممكن تستبدلها ب API خاص)
      _additionalDetails = {
        'director': mediaItem.type == MediaType.movie
            ? 'المخرج الشهير'
            : 'المنتج الشهير',
        'duration': mediaItem.type == MediaType.movie ? '120 دقيقة' : null,
        'contentRating': 'PG-13',
        'releaseDate': '${mediaItem.year ?? 2024}-01-01',
      };

      // تحميل الحلقات لو المحتوى مسلسل أو كرتون
      if (mediaItem.type == MediaType.series ||
          mediaItem.type == MediaType.cartoon) {
        await _loadEpisodes();
      }

      _isLoadingDetails = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  // ✅ تحميل الحلقات
  Future<void> _loadEpisodes() async {
    _isLoadingEpisodes = true;
    notifyListeners();

    try {
      if (mediaItem.type == MediaType.series) {
        final service = SeriesService();
        final series = await service.fetchSeriesDetails(mediaItem.id);
        _episodes = series.episodes; // List<EpisodeModel>
      } else if (mediaItem.type == MediaType.cartoon) {
        final service = CartoonService();
        _episodes = await service.fetchRelatedEpisodes(mediaItem.id);
      }
    } catch (e) {
      _error = 'فشل تحميل الحلقات: $e';
    } finally {
      _isLoadingEpisodes = false;
      notifyListeners();
    }
  }
}
