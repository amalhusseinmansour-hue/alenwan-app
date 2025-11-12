import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

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
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);

            // Check if payment completed successfully
            if (url.contains('success') || url.contains('completed')) {
              Navigator.pop(context, true); // Payment successful
            } else if (url.contains('fail') || url.contains('cancel')) {
              Navigator.pop(context, false); // Payment failed/cancelled
            }
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ في تحميل صفحة الدفع: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFA20136),
        title: const Text('إتمام الدفع'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFA20136),
              ),
            ),
        ],
      ),
    );
  }
}
