import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../controllers/subscription_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class SubscriptionGuard extends StatefulWidget {
  final Widget child;
  final bool allowPreview; // Allow limited preview for non-subscribers
  final Widget? previewChild; // Optional preview content
  final String? contentType; // Type of content (movie, series, etc.)

  const SubscriptionGuard({
    super.key,
    required this.child,
    this.allowPreview = false,
    this.previewChild,
    this.contentType,
  });

  @override
  State<SubscriptionGuard> createState() => _SubscriptionGuardState();
}

class _SubscriptionGuardState extends State<SubscriptionGuard> {
  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final subController = context.read<SubscriptionController>();
    await subController.refreshSubscription();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final subController = context.watch<SubscriptionController>();

    // Check if user is logged in
    if (authController.token == null) {
      return _buildLoginRequired();
    }

    // Check subscription status
    if (subController.isLoading) {
      return _buildLoading();
    }

    // If user has active subscription, show content
    if (subController.hasActive) {
      return widget.child;
    }

    // If preview is allowed and preview content exists
    if (widget.allowPreview && widget.previewChild != null) {
      return Stack(
        children: [
          widget.previewChild!,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildSubscriptionBanner(),
          ),
        ],
      );
    }

    // Show subscription required screen
    return _buildSubscriptionRequired();
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE50914),
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'login_required'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'login_to_watch_content'.tr(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'login'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionRequired() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              const Color(0xFFE50914).withOpacity(0.1),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Premium Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE50914),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      size: 60,
                      color: Color(0xFFE50914),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'subscription_required'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    widget.contentType != null
                        ? 'content_requires_subscription'.tr(args: [widget.contentType!])
                        : 'premium_content_subscription_required'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Benefits
                  _buildBenefitsList(),
                  const SizedBox(height: 40),

                  // Subscribe Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.subscription);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'subscribe_now'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Back Button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'go_back'.tr(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      'unlimited_movies_series'.tr(),
      'ad_free_experience'.tr(),
      'hd_4k_quality'.tr(),
      'download_offline'.tr(),
      'multiple_devices'.tr(),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: benefits.map((benefit) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFE50914),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    benefit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubscriptionBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE50914).withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_open,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'unlock_full_content'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.subscription);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'subscribe'.tr(),
              style: const TextStyle(
                color: Color(0xFFE50914),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}