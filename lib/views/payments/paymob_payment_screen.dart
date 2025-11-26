import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String planType;
  final double amount;
  final int paymentId;

  const PaymobPaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.planType,
    required this.amount,
    required this.paymentId,
  });

  @override
  State<PaymobPaymentScreen> createState() => _PaymobPaymentScreenState();
}

class _PaymobPaymentScreenState extends State<PaymobPaymentScreen> {
  late final WebViewController _controller;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
            _checkUrlForCallback(url);
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            _checkUrlForCallback(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              this.error = error.description;
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkUrlForCallback(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkUrlForCallback(String url) {
    // Check if payment is complete (success or failure)
    if (url.contains('payment/success') || url.contains('success=true')) {
      _handlePaymentComplete(true);
    } else if (url.contains('payment/failure') || url.contains('success=false')) {
      _handlePaymentComplete(false);
    }
  }

  void _handlePaymentComplete(bool success) {
    // Pop the screen and return the result
    if (mounted) {
      Navigator.of(context).pop({
        'success': success,
        'payment_id': widget.paymentId,
        'plan_type': widget.planType,
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        // Ask user if they want to cancel payment
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('إلغاء الدفع'),
            content: const Text('هل أنت متأكد من إلغاء عملية الدفع؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('العودة'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('إلغاء'),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'الدفع - ${widget.planType == 'monthly' ? 'شهري' : 'سنوي'}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1a1a2e),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                _controller.reload();
              },
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: Stack(
          children: [
            // WebView
            if (error == null)
              WebViewWidget(controller: _controller)
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'حدث خطأ في تحميل صفحة الدفع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            error = null;
                          });
                          _initializeWebView();
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),

            // Loading indicator
            if (isLoading && error == null)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16213e)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'جاري تحميل صفحة الدفع...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المبلغ:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.amount.toStringAsFixed(2)} جنيه',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16213e),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'اشتراك ${widget.planType == 'monthly' ? 'شهري' : 'سنوي'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
