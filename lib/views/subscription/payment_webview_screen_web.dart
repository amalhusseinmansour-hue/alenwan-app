// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class PaymentWebViewScreenWeb extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebViewScreenWeb({
    super.key,
    required this.paymentUrl,
  });

  @override
  State<PaymentWebViewScreenWeb> createState() => _PaymentWebViewScreenWebState();
}

class _PaymentWebViewScreenWebState extends State<PaymentWebViewScreenWeb> {
  final String viewType = 'payment-iframe-${DateTime.now().millisecondsSinceEpoch}';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _registerIframe();
  }

  void _registerIframe() {
    // Register the iframe view factory
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.paymentUrl
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%';

        // Listen for load event
        iframe.onLoad.listen((event) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });

        // Listen for messages from iframe (if Paymob sends postMessage)
        html.window.onMessage.listen((event) {
          print('📨 Message from iframe: ${event.data}');

          // Check if payment completed
          final data = event.data.toString().toLowerCase();
          if (data.contains('success') || data.contains('completed')) {
            Navigator.pop(context, true);
          } else if (data.contains('fail') || data.contains('cancel')) {
            Navigator.pop(context, false);
          }
        });

        return iframe;
      },
    );
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
        actions: [
          // زر لفتح في نافذة جديدة
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'فتح في نافذة جديدة',
            onPressed: () {
              html.window.open(widget.paymentUrl, '_blank');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // IFrame لعرض صفحة الدفع
          HtmlElementView(viewType: viewType),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFA20136),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحميل صفحة الدفع...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
