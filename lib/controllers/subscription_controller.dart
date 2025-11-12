// lib/controllers/subscription_controller.dart
import 'package:flutter/foundation.dart';
import '../core/services/subscription_service.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';

class SubscriptionController extends ChangeNotifier {
  final SubscriptionService _service;

  SubscriptionController({SubscriptionService? service})
      : _service = service ?? SubscriptionService();

  bool isLoading = false;
  bool isProcessingPayment = false;
  String? error;

  List<SubscriptionPlan> availablePlans = [];
  SubscriptionPlan? selectedPlan;
  UserSubscription? currentSubscription;

  bool get hasActive => currentSubscription?.isActive ?? false;
  bool get hasSelected => selectedPlan != null;

  // Check if content is accessible
  bool canAccessContent(String? contentType) {
    // Admin or premium users can access everything
    if (hasActive) return true;

    // Check for free trial
    if (currentSubscription != null && currentSubscription!.status == 'trial') {
      return true;
    }

    // Some content might be free
    if (contentType == 'trailer' || contentType == 'preview') {
      return true;
    }

    return false;
  }

  int get daysRemaining {
    if (currentSubscription == null) return 0;
    final now = DateTime.now();
    final difference = currentSubscription!.endsAt.difference(now);
    return difference.inDays;
  }

  /// تحميل الباقات والاشتراك الحالي
  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      availablePlans = await _service.listPlans();
      currentSubscription = await _service.mySubscription();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// إعادة تحميل الاشتراك الحالي فقط
  Future<void> refreshSubscription() async {
    try {
      currentSubscription = await _service.mySubscription();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  /// اختيار خطة
  void selectPlan(SubscriptionPlan plan) {
    selectedPlan = plan;
    notifyListeners();
  }

  /// تنفيذ الاشتراك في الخطة المختارة
  Future<String?> subscribeSelected() async {
    if (selectedPlan == null) return null;
    isProcessingPayment = true;
    error = null;
    notifyListeners();
    try {
      final paymentData = await _service.subscribe(selectedPlan!.id);
      // Return payment_url for opening in WebView
      return paymentData['payment_url'];
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      isProcessingPayment = false;
      notifyListeners();
    }
  }

  /// إلغاء الاشتراك الحالي
  Future<bool> cancel() async {
    isProcessingPayment = true;
    error = null;
    notifyListeners();
    try {
      await _service.cancel();
      currentSubscription = null;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isProcessingPayment = false;
      notifyListeners();
    }
  }

  /// إعادة تعيين الخطأ
  void resetError() {
    error = null;
    notifyListeners();
  }
}
