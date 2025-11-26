import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/paymob_service.dart';
import '../../services/api_service.dart';
import '../../config/app_colors.dart';
import '../../config/themes.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  Map<String, dynamic>? _currentSubscription;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final subscription = await ApiService.getCurrentSubscription(token);
        setState(() {
          _currentSubscription = subscription;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Not authenticated';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelSubscription() async {
    final isArabic = context.locale.languageCode == 'ar';

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isArabic ? 'إلغاء الاشتراك' : 'Cancel Subscription',
          style: AppThemes.getTextStyle(
            context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من إلغاء الاشتراك؟ ستفقد الوصول إلى المحتوى المميز.'
              : 'Are you sure you want to cancel your subscription? You will lose access to premium content.',
          style: AppThemes.getTextStyle(
            context,
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              isArabic ? 'لا، الاحتفاظ بالاشتراك' : 'No, Keep Subscription',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
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

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success = await PaymobService.cancelSubscription();
      setState(() => _isLoading = false);

      if (success && mounted) {
        _showMessage(
          isArabic
              ? 'تم إلغاء الاشتراك بنجاح'
              : 'Subscription cancelled successfully',
        );
        _loadSubscription(); // Reload subscription data
      } else {
        _showMessage(
          isArabic
              ? 'فشل في إلغاء الاشتراك'
              : 'Failed to cancel subscription',
          isError: true,
        );
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
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
            isArabic ? 'إدارة الاشتراك' : 'Manage Subscription',
            style: AppThemes.getTextStyle(
              context,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : _errorMessage != null
                ? _buildErrorView(isArabic)
                : _buildSubscriptionView(isArabic),
    );
  }

  Widget _buildErrorView(bool isArabic) {
    return Center(
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
            isArabic ? 'حدث خطأ في تحميل الاشتراك' : 'Error loading subscription',
            style: AppThemes.getTextStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
            onPressed: _loadSubscription,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
    );
  }

  Widget _buildSubscriptionView(bool isArabic) {
    if (_currentSubscription == null) {
      return _buildNoSubscriptionView(isArabic);
    }

    final tier = _currentSubscription!['tier'] ?? 'Free';
    final status = _currentSubscription!['status'] ?? 'inactive';
    final expiresAt = _currentSubscription!['expires_at'] != null
        ? DateTime.parse(_currentSubscription!['expires_at'])
        : null;
    final isActive = status == 'active';
    final daysRemaining =
        expiresAt != null ? expiresAt.difference(DateTime.now()).inDays : 0;

    return RefreshIndicator(
      onRefresh: _loadSubscription,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Plan Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.accent.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.success : AppColors.warning,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive
                          ? (isArabic ? 'نشط' : 'Active')
                          : (isArabic ? 'غير نشط' : 'Inactive'),
                      style: AppThemes.getTextStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Plan Name
                  Text(
                    tier.toUpperCase(),
                    style: AppThemes.getTextStyle(
                      context,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic ? 'خطتك الحالية' : 'Your Current Plan',
                    style: AppThemes.getTextStyle(
                      context,
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Expiry Info
                  if (expiresAt != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'ينتهي في' : 'Expires on',
                          style: AppThemes.getTextStyle(
                            context,
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMMM yyyy').format(expiresAt),
                      style: AppThemes.getTextStyle(
                        context,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$daysRemaining ${isArabic ? 'يوم متبقي' : 'days remaining'}',
                      style: AppThemes.getTextStyle(
                        context,
                        fontSize: 14,
                        color: daysRemaining < 7
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upgrade Plan Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/subscription-plans');
                },
                icon: const Icon(Icons.upgrade, size: 24),
                label: Text(
                  isArabic ? 'ترقية الخطة' : 'Upgrade Plan',
                  style: AppThemes.getTextStyle(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Payment History Button
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/payment-history');
                },
                icon: const Icon(Icons.history, size: 24),
                label: Text(
                  isArabic ? 'سجل المدفوعات' : 'Payment History',
                  style: AppThemes.getTextStyle(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Cancel Subscription Section
            if (isActive) ...[
              const Divider(color: Colors.white12),
              const SizedBox(height: 24),
              Text(
                isArabic ? 'إدارة الاشتراك' : 'Manage Subscription',
                style: AppThemes.getTextStyle(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _cancelSubscription,
                  icon: const Icon(Icons.cancel, size: 24),
                  label: Text(
                    isArabic ? 'إلغاء الاشتراك' : 'Cancel Subscription',
                    style: AppThemes.getTextStyle(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'سيبقى لديك وصول إلى المحتوى حتى نهاية فترة الفوترة الحالية'
                    : 'You will have access to content until the end of your current billing period',
                style: AppThemes.getTextStyle(
                  context,
                  fontSize: 12,
                  color: Colors.white60,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoSubscriptionView(bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.subscriptions_outlined,
              color: Colors.white24,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'لا يوجد اشتراك نشط' : 'No Active Subscription',
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
                  ? 'اشترك الآن للاستمتاع بمحتوى غير محدود'
                  : 'Subscribe now to enjoy unlimited content',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 16,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/subscription-plans');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isArabic ? 'عرض الخطط' : 'View Plans',
                  style: AppThemes.getTextStyle(
                    context,
                    fontSize: 18,
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
}
