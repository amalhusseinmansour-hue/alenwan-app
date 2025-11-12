import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PaymobService {
  static String get apiUrl => ApiService.apiUrl;

  /// Get subscription plans
  static Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$apiUrl/v1/payments/plans'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final plans = (data['data'] as List)
            .map((plan) => SubscriptionPlan.fromJson(plan))
            .toList();
        return plans;
      } else {
        throw Exception('Failed to load plans: ${response.body}');
      }
    } catch (e) {
      print('Error getting plans: $e');
      rethrow;
    }
  }

  /// Initialize payment
  static Future<PaymentInitResponse?> initializePayment({
    required String subscriptionTier,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$apiUrl/paymob/subscribe'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'plan_type': subscriptionTier == '1' ? 'monthly' : 'yearly',
          'use_amex': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentInitResponse.fromJson(data['data']);
      } else {
        throw Exception('Failed to initialize payment: ${response.body}');
      }
    } catch (e) {
      print('Error initializing payment: $e');
      rethrow;
    }
  }

  /// Check payment status
  static Future<PaymentStatus?> checkPaymentStatus(int paymentId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$apiUrl/paymob/payment/$paymentId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentStatus.fromJson(data['data']);
      } else {
        throw Exception('Failed to check payment status: ${response.body}');
      }
    } catch (e) {
      print('Error checking payment status: $e');
      return null;
    }
  }

  /// Get payment history
  static Future<List<PaymentHistoryItem>> getPaymentHistory() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$apiUrl/paymob/history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final history = (data['data'] as List)
            .map((item) => PaymentHistoryItem.fromJson(item))
            .toList();
        return history;
      } else {
        throw Exception('Failed to load payment history: ${response.body}');
      }
    } catch (e) {
      print('Error getting payment history: $e');
      return [];
    }
  }

  /// Cancel subscription
  static Future<bool> cancelSubscription() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$apiUrl/v1/payments/cancel-subscription'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to cancel subscription: ${response.body}');
      }
    } catch (e) {
      print('Error cancelling subscription: $e');
      return false;
    }
  }

  /// Request refund
  static Future<bool> requestRefund(int paymentId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$apiUrl/v1/payments/$paymentId/refund'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to request refund: ${response.body}');
      }
    } catch (e) {
      print('Error requesting refund: $e');
      return false;
    }
  }
}

// Models

class SubscriptionPlan {
  final String id;
  final String name;
  final String nameAr;
  final double price;
  final String currency;
  final String duration;
  final List<String> features;
  final List<String> featuresAr;
  final bool? popular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    required this.currency,
    required this.duration,
    required this.features,
    required this.featuresAr,
    this.popular,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      nameAr: json['name_ar'],
      price: (json['price'] as num).toDouble(),
      currency: json['currency'],
      duration: json['duration'],
      features: List<String>.from(json['features']),
      featuresAr: List<String>.from(json['features_ar']),
      popular: json['popular'],
    );
  }
}

class PaymentInitResponse {
  final int paymentId;
  final String iframeUrl;
  final String paymentKey;

  PaymentInitResponse({
    required this.paymentId,
    required this.iframeUrl,
    required this.paymentKey,
  });

  factory PaymentInitResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitResponse(
      paymentId: json['payment_id'],
      iframeUrl: json['iframe_url'],
      paymentKey: json['payment_key'],
    );
  }
}

class PaymentStatus {
  final int paymentId;
  final String status;
  final double amount;
  final String currency;
  final String subscriptionTier;
  final DateTime createdAt;
  final DateTime? paidAt;

  PaymentStatus({
    required this.paymentId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.subscriptionTier,
    required this.createdAt,
    this.paidAt,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      paymentId: json['payment_id'],
      status: json['status'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      subscriptionTier: json['subscription_tier'],
      createdAt: DateTime.parse(json['created_at']),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
}

class PaymentHistoryItem {
  final int id;
  final String subscriptionTier;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime? paidAt;

  PaymentHistoryItem({
    required this.id,
    required this.subscriptionTier,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.paidAt,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItem(
      id: json['id'],
      subscriptionTier: json['subscription_tier'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }
}
