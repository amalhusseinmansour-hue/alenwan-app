import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:dio/dio.dart';
import '../services/api_client.dart';

class BillingService extends ChangeNotifier {
  static final BillingService _instance = BillingService._internal();
  factory BillingService() => _instance;
  BillingService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Subscription Product IDs (must match store configurations)
  static final String monthlySubscriptionId = Platform.isIOS
      ? 'com.alenwan.subscription.monthly'
      : 'alenwan_monthly_subscription';

  static final String yearlySubscriptionId = Platform.isIOS
      ? 'com.alenwan.subscription.yearly'
      : 'alenwan_yearly_subscription';

  static final String premiumSubscriptionId = Platform.isIOS
      ? 'com.alenwan.subscription.premium'
      : 'alenwan_premium_subscription';

  // Product IDs list
  static final Set<String> _productIds = {
    monthlySubscriptionId,
    yearlySubscriptionId,
    premiumSubscriptionId,
  };

  // State
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _purchasePending = false;

  // Getters
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  List<PurchaseDetails> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get purchasePending => _purchasePending;

  // Initialize billing service
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if billing is available
      _isAvailable = await _inAppPurchase.isAvailable();

      if (!_isAvailable) {
        _errorMessage = 'Store is not available';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // iOS specific setup
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(PaymentQueueDelegate());
      }

      // Load products
      await loadProducts();

      // Listen to purchase updates
      final purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdated,
        onDone: _onPurchaseDone,
        onError: _onPurchaseError,
      );

      // Restore previous purchases
      await restorePurchases();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize billing: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load available products from stores
  Future<void> loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        _errorMessage = 'Error loading products: ${response.error!.message}';
        notifyListeners();
        return;
      }

      _products = response.productDetails;

      // Sort products by price
      _products.sort((a, b) {
        final priceA = _extractPrice(a);
        final priceB = _extractPrice(b);
        return priceA.compareTo(priceB);
      });

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
      notifyListeners();
    }
  }

  // Extract price for sorting
  double _extractPrice(ProductDetails product) {
    // Platform specific price extraction
    if (Platform.isAndroid) {
      final androidDetails = product as GooglePlayProductDetails;
      return (androidDetails.productDetails.subscriptionOfferDetails?.firstOrNull?.pricingPhases.firstOrNull?.priceAmountMicros ?? 0) / 1000000.0;
    } else if (Platform.isIOS) {
      final iosDetails = product as AppStoreProductDetails;
      return double.tryParse(iosDetails.price) ?? 0.0;
    }
    return 0.0;
  }

  // Purchase a subscription
  Future<bool> purchaseSubscription(String productId) async {
    // Find product
    final ProductDetails product = _products.firstWhere(
      (product) => product.id == productId,
      orElse: () => throw Exception('Product not found'),
    );

    // Create purchase parameter
    late final PurchaseParam purchaseParam;

    if (Platform.isAndroid) {
      // Android specific configuration
      purchaseParam = GooglePlayPurchaseParam(
        productDetails: product,
        changeSubscriptionParam: _getUpgradeDowngradeInfo(productId),
      );
    } else {
      // iOS configuration
      purchaseParam = PurchaseParam(productDetails: product);
    }

    try {
      _purchasePending = true;
      notifyListeners();

      // Initiate purchase
      bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        _errorMessage = 'Purchase failed';
        _purchasePending = false;
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = 'Purchase error: $e';
      _purchasePending = false;
      notifyListeners();
      return false;
    }
  }

  // Handle purchase updates
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          await _verifyAndDeliverProduct(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          _errorMessage = 'Purchase cancelled';
          _purchasePending = false;
          notifyListeners();
        }

        // Complete purchase (important for both platforms)
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // Verify purchase with backend
  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    try {
      // Prepare verification data based on platform
      Map<String, dynamic> verificationData = {
        'product_id': purchaseDetails.productID,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'transaction_date': purchaseDetails.transactionDate,
        'status': purchaseDetails.status.toString(),
      };

      if (Platform.isIOS) {
        // iOS specific data
        verificationData['receipt_data'] =
            purchaseDetails.verificationData.serverVerificationData;
        verificationData['transaction_id'] = purchaseDetails.purchaseID;
      } else {
        // Android specific data
        verificationData['purchase_token'] =
            purchaseDetails.verificationData.serverVerificationData;
        verificationData['order_id'] = purchaseDetails.purchaseID;
        verificationData['package_name'] =
            'com.alenwan.app'; // Your package name
      }

      // Send receipt to backend for validation
      final response = await ApiClient().dio.post(
            '/api/subscription/verify',
            data: verificationData,
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );

      if (response.statusCode == 200 && response.data['valid'] == true) {
        // Purchase verified successfully
        _purchases.add(purchaseDetails);
        _purchasePending = false;
        _errorMessage = null;

        // Update subscription status
        await _updateSubscriptionStatus(response.data['subscription']);

        notifyListeners();
      } else {
        _errorMessage =
            response.data['message'] ?? 'Purchase verification failed';
        _purchasePending = false;
        notifyListeners();
      }
    } catch (e) {
      print('Verification error: $e');
      // If backend verification fails, still mark as successful locally
      // You may want to retry verification later
      _purchases.add(purchaseDetails);
      _purchasePending = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Update local subscription status
  Future<void> _updateSubscriptionStatus(
      Map<String, dynamic> subscription) async {
    // This would update your subscription controller
    // You can emit events or call methods to update UI
    print('Subscription updated: $subscription');
  }

  // Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _errorMessage = 'Failed to restore purchases: $e';
      notifyListeners();
    }
  }

  // Get upgrade/downgrade info for Android
  ChangeSubscriptionParam? _getUpgradeDowngradeInfo(String newProductId) {
    // Check if user has an existing subscription
    if (_purchases.isNotEmpty) {
      final oldPurchase = _purchases.last;

      if (oldPurchase.productID != newProductId) {
        // This is an upgrade or downgrade
        return ChangeSubscriptionParam(
          oldPurchaseDetails: oldPurchase as GooglePlayPurchaseDetails,
          replacementMode: ReplacementMode.withTimeProration,
        );
      }
    }
    return null;
  }

  // Handle errors
  void _handleError(IAPError error) {
    _errorMessage = 'Purchase error: ${error.message}';
    _purchasePending = false;
    notifyListeners();
  }

  // Handle purchase stream done
  void _onPurchaseDone() {
    _subscription?.cancel();
  }

  // Handle purchase stream error
  void _onPurchaseError(dynamic error) {
    _errorMessage = 'Purchase stream error: $error';
    notifyListeners();
  }

  // Check if user has active subscription
  bool hasActiveSubscription() {
    return _purchases.any((purchase) =>
        purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored);
  }

  // Get active subscription details
  PurchaseDetails? getActiveSubscription() {
    try {
      return _purchases.firstWhere((purchase) =>
          purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored);
    } catch (e) {
      return null;
    }
  }

  // Cancel subscription (redirects to store)
  Future<void> cancelSubscription() async {
    if (Platform.isIOS) {
      // Open iOS subscription management
      // TODO: Use url_launcher to open: https://apps.apple.com/account/subscriptions
    } else if (Platform.isAndroid) {
      // Open Google Play subscription management
      // TODO: Use url_launcher to open: https://play.google.com/store/account/subscriptions
    }
  }

  // Format price for display
  String formatPrice(ProductDetails product) {
    if (Platform.isAndroid) {
      final androidDetails = product as GooglePlayProductDetails;
      return androidDetails.productDetails.subscriptionOfferDetails?.firstOrNull?.pricingPhases.firstOrNull?.formattedPrice ?? '';
    } else if (Platform.isIOS) {
      final iosDetails = product as AppStoreProductDetails;
      return iosDetails.price;
    }
    return '';
  }

  // Get subscription period
  String getSubscriptionPeriod(String productId) {
    if (productId.contains('monthly')) {
      return 'Monthly';
    } else if (productId.contains('yearly')) {
      return 'Yearly';
    } else if (productId.contains('premium')) {
      return 'Premium Annual';
    }
    return 'Subscription';
  }

  // Dispose
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// iOS Payment Queue Delegate
class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    // Allow all transactions to continue
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    // Show price consent if needed
    return false;
  }
}
