import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/paymob_service.dart';
import '../../config/app_colors.dart';
import '../../config/themes.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plans = await PaymobService.getPlans();
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
          isArabic ? 'خطط الاشتراك' : 'Subscription Plans',
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
              : _buildPlansView(isArabic),
    );
  }

  Widget _buildErrorView(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'حدث خطأ في تحميل الخطط' : 'Error loading plans',
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
            onPressed: _loadPlans,
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

  Widget _buildPlansView(bool isArabic) {
    return RefreshIndicator(
      onRefresh: _loadPlans,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Text(
              isArabic
                  ? 'اختر الخطة المناسبة لك'
                  : 'Choose the plan that suits you',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'استمتع بمشاهدة غير محدودة لجميع المحتويات'
                  : 'Enjoy unlimited viewing of all content',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Plans Grid
            if (_plans.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    isArabic ? 'لا توجد خطط متاحة' : 'No plans available',
                    style: AppThemes.getTextStyle(
                      context,
                      fontSize: 16,
                      color: Colors.white60,
                    ),
                  ),
                ),
              )
            else
              ..._plans.map((plan) => _buildPlanCard(plan, isArabic)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, bool isArabic) {
    final isPopular = plan.popular ?? false;
    final planName = isArabic ? plan.nameAr : plan.name;
    final features = isArabic ? plan.featuresAr : plan.features;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isPopular
            ? LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.accent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPopular ? null : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? AppColors.primary : Colors.white12,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      planName,
                      style: AppThemes.getTextStyle(
                        context,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isArabic ? 'الأكثر شعبية' : 'Most Popular',
                          style: AppThemes.getTextStyle(
                            context,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.price.toStringAsFixed(0),
                      style: AppThemes.getTextStyle(
                        context,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        plan.currency,
                        style: AppThemes.getTextStyle(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '/ ${isArabic ? _getDurationArabic(plan.duration) : plan.duration}',
                        style: AppThemes.getTextStyle(
                          context,
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Features
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppThemes.getTextStyle(
                                context,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),

                // Subscribe Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _onSubscribePressed(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPopular ? AppColors.primary : Colors.white,
                      foregroundColor:
                          isPopular ? Colors.white : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isPopular ? 4 : 0,
                    ),
                    child: Text(
                      isArabic ? 'اشترك الآن' : 'Subscribe Now',
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
        ],
      ),
    );
  }

  String _getDurationArabic(String duration) {
    switch (duration.toLowerCase()) {
      case 'month':
        return 'شهر';
      case 'year':
        return 'سنة';
      case 'week':
        return 'أسبوع';
      default:
        return duration;
    }
  }

  Future<void> _onSubscribePressed(SubscriptionPlan plan) async {
    // Open Paymob payment page directly
    const String paymobUrl = 'https://paymob.xyz/mjbvuyh7/';
    final Uri url = Uri.parse(paymobUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.locale.languageCode == 'ar'
                    ? 'سيتم فتح صفحة الدفع في المتصفح...'
                    : 'Payment page will open in browser...',
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw 'Could not launch $paymobUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.locale.languageCode == 'ar'
                  ? 'حدث خطأ في فتح صفحة الدفع'
                  : 'Error opening payment page',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
