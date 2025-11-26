import 'package:flutter/material.dart';

class PaymentWebViewScreenWeb extends StatelessWidget {
  final String paymentUrl;

  const PaymentWebViewScreenWeb({
    super.key,
    required this.paymentUrl,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Web payment view not supported on this platform'),
      ),
    );
  }
}
