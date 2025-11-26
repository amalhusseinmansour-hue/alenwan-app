import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pay/pay.dart';
import '../config/app_constants.dart';
import '../core/services/auth_service.dart';

class PaymentService {
  // Payment configuration for Apple Pay & Google Pay
  static const String _applePayMerchantId = 'merchant.com.alenwan';
  static const String _googlePayMerchantId = 'BCR2DN4T...';

  /// Apple Pay Configuration
  static const Map<String, dynamic> applePayConfig = {
    'provider': 'apple_pay',
    'data': {
      'merchantIdentifier': _applePayMerchantId,
      'displayName': 'Alenwan',
      'merchantCapabilities': ['3DS', 'debit', 'credit'],
      'supportedNetworks': ['visa', 'masterCard', 'amex', 'discover'],
      'countryCode': 'AE',
      'currencyCode': 'AED',
      'requiredBillingContactFields': ['name', 'postalAddress'],
      'requiredShippingContactFields': [],
    }
  };

  /// Google Pay Configuration
  static const Map<String, dynamic> googlePayConfig = {
    'provider': 'google_pay',
    'data': {
      'environment': 'TEST', // Change to 'PRODUCTION' for live
      'apiVersion': 2,
      'apiVersionMinor': 0,
      'allowedPaymentMethods': [
        {
          'type': 'CARD',
          'tokenizationSpecification': {
            'type': 'PAYMENT_GATEWAY',
            'parameters': {
              'gateway': 'tap',
              'gatewayMerchantId': _googlePayMerchantId,
            }
          },
          'parameters': {
            'allowedCardNetworks': ['VISA', 'MASTERCARD', 'AMEX'],
            'allowedAuthMethods': ['PAN_ONLY', 'CRYPTOGRAM_3DS'],
            'billingAddressRequired': true,
            'billingAddressParameters': {
              'format': 'FULL',
              'phoneNumberRequired': true
            }
          }
        }
      ],
      'merchantInfo': {
        'merchantId': _googlePayMerchantId,
        'merchantName': 'Alenwan'
      },
      'transactionInfo': {
        'countryCode': 'AE',
        'currencyCode': 'AED',
      }
    }
  };

  /// Process Apple Pay Payment
  Future<Map<String, dynamic>> processApplePayPayment({
    required String planId,
    required double amount,
    required String token,
  }) async {
    try {
      final authToken = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/payment/tap/charge'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'plan_id': planId,
          'payment_method': 'apple_pay',
          'apple_pay_token': token,
          'save_card': false,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Apple Pay payment failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Apple Pay error: $e');
    }
  }

  /// Process Google Pay Payment
  Future<Map<String, dynamic>> processGooglePayPayment({
    required String planId,
    required double amount,
    required String token,
  }) async {
    try {
      final authToken = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/payment/tap/charge'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'plan_id': planId,
          'payment_method': 'google_pay',
          'google_pay_token': token,
          'save_card': false,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Google Pay payment failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Google Pay error: $e');
    }
  }

  /// Tokenize Card for future use
  Future<Map<String, dynamic>> tokenizeCard({
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvv,
    required String cardHolderName,
  }) async {
    try {
      final authToken = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/payment/tap/tokenize-card'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'card_number': cardNumber,
          'exp_month': expMonth,
          'exp_year': expYear,
          'cvv': cvv,
          'card_holder_name': cardHolderName,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Card tokenization failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Tokenization error: $e');
    }
  }

  /// Process Card Payment
  Future<Map<String, dynamic>> processCardPayment({
    required String planId,
    required String cardToken,
    required bool saveCard,
  }) async {
    try {
      final authToken = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/payment/tap/charge'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'plan_id': planId,
          'payment_method': 'card',
          'card_token': cardToken,
          'save_card': saveCard,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Card payment failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Card payment error: $e');
    }
  }

  /// Verify Payment Status
  Future<Map<String, dynamic>> verifyPayment(String chargeId) async {
    try {
      final authToken = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/payment/tap/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'charge_id': chargeId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Payment verification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Verification error: $e');
    }
  }

  /// Get Subscription Plans
  Future<List<dynamic>> getSubscriptionPlans() async {
    try {
      final authToken = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/payment/tap/plans'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load plans');
      }
    } catch (e) {
      throw Exception('Error loading plans: $e');
    }
  }

  /// Get Payment History
  Future<List<dynamic>> getPaymentHistory() async {
    try {
      final authToken = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/payment/history'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['data'];
      } else {
        throw Exception('Failed to load payment history');
      }
    } catch (e) {
      throw Exception('Error loading history: $e');
    }
  }

  /// Helper: Create payment items for Pay package
  static List<PaymentItem> createPaymentItems(double amount, String currency) {
    return [
      PaymentItem(
        label: 'Alenwan Subscription',
        amount: amount.toStringAsFixed(2),
        status: PaymentItemStatus.final_price,
      )
    ];
  }
}
