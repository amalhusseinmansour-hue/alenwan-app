// lib/core/services/subscription_verification_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/subscription_controller.dart';
import '../../models/subscription_plan.dart'; // يحتوي على enum SubscriptionPlanType
import '../../routes/app_routes.dart';

class SubscriptionVerificationService {
  // Singleton
  static final SubscriptionVerificationService _instance =
      SubscriptionVerificationService._internal();
  factory SubscriptionVerificationService() => _instance;
  SubscriptionVerificationService._internal();

  /// ✅ التحقق من وجود اشتراك فعّال
  Future<bool> verifySubscription(SubscriptionController controller) async {
    // انتظر لو الكنترولر ما خلص تحميل بياناته
    if (controller.isLoading) {
      await Future.delayed(const Duration(milliseconds: 300));
      return verifySubscription(controller);
    }
    return controller.currentSubscription?.isActive ?? false;
  }

  /// ✅ التحقق من الوصول إلى نوع خطة معين (Premium, Platinum, ..)
  Future<bool> verifyAccess(
    SubscriptionController controller,
    SubscriptionPlanType type,
  ) async {
    if (!await verifySubscription(controller)) return false;
    return controller.currentSubscription?.plan.type == type;
  }

  /// ✅ تحويل المستخدم لصفحة الاشتراك عند الحاجة
  void redirectToSubscription(BuildContext context, {String? message}) {
    if (message != null && message.isNotEmpty) {
      Get.snackbar(
        "تنبيه",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
    Navigator.pushNamed(context, AppRoutes.subscription);
  }
}
