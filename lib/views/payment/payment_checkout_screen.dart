import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/paymob_service.dart';
import '../../config/app_colors.dart';
import '../../config/themes.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final SubscriptionPlan plan;

  const PaymentCheckoutScreen({
    super.key,
    required this.plan,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await PaymobService.initializePayment(
        subscriptionTier: widget.plan.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (response != null && mounted) {
        // Navigate to Paymob iframe screen
        Navigator.pushNamed(
          context,
          '/paymob-iframe',
          arguments: response,
        );
      } else {
        _showError(context.locale.languageCode == 'ar'
            ? 'فشل في تهيئة الدفع. حاول مرة أخرى.'
            : 'Failed to initialize payment. Please try again.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
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
          isArabic ? 'إتمام الدفع' : 'Checkout',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Summary
            _buildOrderSummary(isArabic),
            const SizedBox(height: 32),

            // Payment Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Text(
                      isArabic ? 'معلومات الفوترة' : 'Billing Information',
                      style: AppThemes.getTextStyle(
                        context,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // First Name
                    TextFormField(
                      controller: _firstNameController,
                      style: AppThemes.getTextStyle(
                        context,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: isArabic ? 'الاسم الأول' : 'First Name',
                        labelStyle: AppThemes.getTextStyle(
                          context,
                          color: Colors.white70,
                        ),
                        prefixIcon: const Icon(Icons.person, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return isArabic
                              ? 'الرجاء إدخال الاسم الأول'
                              : 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    TextFormField(
                      controller: _lastNameController,
                      style: AppThemes.getTextStyle(
                        context,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: isArabic ? 'الاسم الأخير' : 'Last Name',
                        labelStyle: AppThemes.getTextStyle(
                          context,
                          color: Colors.white70,
                        ),
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return isArabic
                              ? 'الرجاء إدخال الاسم الأخير'
                              : 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppThemes.getTextStyle(
                        context,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                        labelStyle: AppThemes.getTextStyle(
                          context,
                          color: Colors.white70,
                        ),
                        prefixIcon: const Icon(Icons.email, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return isArabic
                              ? 'الرجاء إدخال البريد الإلكتروني'
                              : 'Please enter email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return isArabic
                              ? 'الرجاء إدخال بريد إلكتروني صحيح'
                              : 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: AppThemes.getTextStyle(
                        context,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: isArabic ? 'رقم الهاتف' : 'Phone Number',
                        labelStyle: AppThemes.getTextStyle(
                          context,
                          color: Colors.white70,
                        ),
                        prefixIcon: const Icon(Icons.phone, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return isArabic
                              ? 'الرجاء إدخال رقم الهاتف'
                              : 'Please enter phone number';
                        }
                        if (value.trim().length < 10) {
                          return isArabic
                              ? 'الرجاء إدخال رقم هاتف صحيح'
                              : 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Payment Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isArabic ? 'إتمام الدفع' : 'Complete Payment',
                                style: AppThemes.getTextStyle(
                                  context,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Security Note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isArabic
                              ? 'جميع المعاملات آمنة ومشفرة'
                              : 'All transactions are secure and encrypted',
                          style: AppThemes.getTextStyle(
                            context,
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildOrderSummary(bool isArabic) {
    final planName = isArabic ? widget.plan.nameAr : widget.plan.name;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'ملخص الطلب' : 'Order Summary',
            style: AppThemes.getTextStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),

          // Plan Name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'الخطة' : 'Plan',
                style: AppThemes.getTextStyle(
                  context,
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),
              Text(
                planName,
                style: AppThemes.getTextStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'المدة' : 'Duration',
                style: AppThemes.getTextStyle(
                  context,
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),
              Text(
                isArabic
                    ? _getDurationArabic(widget.plan.duration)
                    : widget.plan.duration,
                style: AppThemes.getTextStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'الإجمالي' : 'Total',
                style: AppThemes.getTextStyle(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${widget.plan.price.toStringAsFixed(2)} ${widget.plan.currency}',
                style: AppThemes.getTextStyle(
                  context,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
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
}
