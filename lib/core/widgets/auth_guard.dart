// lib/widgets/auth_guard.dart  (أو مسارك الحالي)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alenwan/controllers/auth_controller.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);

    if (!auth.bootstrapped) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Allow access to everyone (guests and logged-in users)
    // Guest mode is automatically enabled in AuthController._bootstrap()
    return child;
  }
}
