import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/paymob_service.dart';
import '../../config/app_colors.dart';
import '../../config/themes.dart';

class PaymobIframeScreen extends StatefulWidget {
  final PaymentInitResponse paymentData;

  const PaymobIframeScreen({
    super.key,
    required this.paymentData,
  });

  @override
  State<PaymobIframeScreen> createState() => _PaymobIframeScreenState();
}

class _PaymobIframeScreenState extends State<PaymobIframeScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _checkPaymentCallback(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = error.description;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Check for payment callbacks
            _checkPaymentCallback(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentData.iframeUrl));
  }

  void _checkPaymentCallback(String url) {
    // Check for success callback
    if (url.contains('success=true') ||
        url.contains('payment_status=success') ||
        url.contains('/payment/success')) {
      _handlePaymentSuccess();
    }
    // Check for failure callback
    else if (url.contains('success=false') ||
             url.contains('payment_status=failed') ||
             url.contains('/payment/failed')) {
      _handlePaymentFailure();
    }
  }

  Future<void> _handlePaymentSuccess() async {
    final isArabic = context.locale.languageCode == 'ar';

    // Check payment status with backend
    final status = await PaymobService.checkPaymentStatus(
      widget.paymentData.paymentId,
    );

    if (status != null && status.isCompleted && mounted) {
      _showSuccessDialog(isArabic);
    }
  }

  void _handlePaymentFailure() {
    final isArabic = context.locale.languageCode == 'ar';
    _showFailureDialog(isArabic);
  }

  void _showSuccessDialog(bool isArabic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'تم الدفع بنجاح!' : 'Payment Successful!',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? 'تم تفعيل اشتراكك بنجاح'
                  : 'Your subscription has been activated',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close iframe
                  Navigator.of(context).pop(); // Close checkout
                  Navigator.of(context).pop(); // Close plans
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isArabic ? 'حسناً' : 'OK',
                  style: AppThemes.getTextStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFailureDialog(bool isArabic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error,
                color: AppColors.error,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'فشل الدفع' : 'Payment Failed',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? 'حدث خطأ أثناء معالجة الدفع. الرجاء المحاولة مرة أخرى.'
                  : 'An error occurred while processing payment. Please try again.',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close iframe
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isArabic ? 'حسناً' : 'OK',
                  style: AppThemes.getTextStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          isArabic ? 'الدفع الآمن' : 'Secure Payment',
          style: AppThemes.getTextStyle(
            context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(isArabic ? Icons.close : Icons.close),
          onPressed: () {
            _showCancelConfirmation(isArabic);
          },
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            _buildErrorView(isArabic)
          else
            WebViewWidget(controller: _controller),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic ? 'جاري التحميل...' : 'Loading...',
                      style: AppThemes.getTextStyle(
                        context,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'حدث خطأ في التحميل' : 'Error Loading Payment',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 14,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _initializeWebView();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                isArabic ? 'إعادة المحاولة' : 'Retry',
                style: AppThemes.getTextStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isArabic ? 'إلغاء الدفع؟' : 'Cancel Payment?',
          style: AppThemes.getTextStyle(
            context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من إلغاء عملية الدفع؟'
              : 'Are you sure you want to cancel the payment?',
          style: AppThemes.getTextStyle(
            context,
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              isArabic ? 'لا' : 'No',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close iframe
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              isArabic ? 'نعم، إلغاء' : 'Yes, Cancel',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
