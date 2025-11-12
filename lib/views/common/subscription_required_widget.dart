import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/app_colors.dart';
import '../../routes/app_routes.dart';

class SubscriptionRequiredWidget extends StatelessWidget {
  final String? message;

  const SubscriptionRequiredWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'subscription_required'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'subscription_required_message'.tr(),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.subscription),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('subscribe_now'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
