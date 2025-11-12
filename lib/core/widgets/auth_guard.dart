// lib/widgets/auth_guard.dart  (أو مسارك الحالي)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alenwan/controllers/auth_controller.dart';
import 'package:alenwan/routes/app_routes.dart';

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

    // Allow access if user has token OR is in guest mode
    if (auth.token == null && !auth.isGuestMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (r) => false);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return child;
  }
}
