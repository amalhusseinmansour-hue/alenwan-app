import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/paymob_service.dart';
import '../../config/app_colors.dart';
import '../../config/themes.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<PaymentHistoryItem> _payments = [];
  List<PaymentHistoryItem> _filteredPayments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all'; // all, completed, pending, failed

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payments = await PaymobService.getPaymentHistory();
      setState(() {
        _payments = payments;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'all') {
      _filteredPayments = _payments;
    } else {
      _filteredPayments = _payments
          .where((payment) => payment.status == _selectedFilter)
          .toList();
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  Future<void> _requestRefund(PaymentHistoryItem payment) async {
    final isArabic = context.locale.languageCode == 'ar';

    // Check if payment is within 30 days
    final daysSincePayment = DateTime.now().difference(payment.createdAt).inDays;
    if (daysSincePayment > 30) {
      _showMessage(
        isArabic
            ? 'لا يمكن طلب استرجاع بعد 30 يوم من الدفع'
            : 'Refund cannot be requested after 30 days',
        isError: true,
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isArabic ? 'طلب استرجاع' : 'Request Refund',
          style: AppThemes.getTextStyle(
            context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من طلب استرجاع المبلغ؟'
              : 'Are you sure you want to request a refund?',
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
              isArabic ? 'إلغاء' : 'Cancel',
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
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              isArabic ? 'تأكيد' : 'Confirm',
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
      // Process refund
      setState(() => _isLoading = true);
      final success = await PaymobService.requestRefund(payment.id);
      setState(() => _isLoading = false);

      if (success) {
        _showMessage(
          isArabic
              ? 'تم إرسال طلب الاسترجاع بنجاح'
              : 'Refund request sent successfully',
        );
        _loadPaymentHistory(); // Reload to update status
      } else {
        _showMessage(
          isArabic
              ? 'فشل في إرسال طلب الاسترجاع'
              : 'Failed to send refund request',
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
            isArabic ? 'سجل المدفوعات' : 'Payment History',
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
                : _buildHistoryView(isArabic),
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
            isArabic ? 'حدث خطأ في تحميل السجل' : 'Error loading history',
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
            onPressed: _loadPaymentHistory,
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

  Widget _buildHistoryView(bool isArabic) {
    return RefreshIndicator(
      onRefresh: _loadPaymentHistory,
      color: AppColors.primary,
      child: Column(
        children: [
          // Filter Chips
          _buildFilterChips(isArabic),
          const SizedBox(height: 8),

          // Payment List
          Expanded(
            child: _filteredPayments.isEmpty
                ? _buildEmptyView(isArabic)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPayments.length,
                    itemBuilder: (context, index) {
                      return _buildPaymentCard(
                        _filteredPayments[index],
                        isArabic,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', isArabic ? 'الكل' : 'All', isArabic),
            const SizedBox(width: 8),
            _buildFilterChip(
              'completed',
              isArabic ? 'مكتمل' : 'Completed',
              isArabic,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'pending',
              isArabic ? 'قيد الانتظار' : 'Pending',
              isArabic,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'failed',
              isArabic ? 'فاشل' : 'Failed',
              isArabic,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, bool isArabic) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onFilterChanged(value),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedColor: AppColors.primary,
      labelStyle: AppThemes.getTextStyle(
        context,
        fontSize: 14,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.white12,
        ),
      ),
    );
  }

  Widget _buildEmptyView(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long,
            color: Colors.white24,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لا توجد مدفوعات' : 'No payments found',
            style: AppThemes.getTextStyle(
              context,
              fontSize: 18,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentHistoryItem payment, bool isArabic) {
    final statusColor = _getStatusColor(payment.status);
    final statusText = _getStatusText(payment.status, isArabic);
    final canRefund = payment.status == 'completed' &&
        DateTime.now().difference(payment.createdAt).inDays <= 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: AppThemes.getTextStyle(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(payment.createdAt),
                  style: AppThemes.getTextStyle(
                    context,
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Plan and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'الخطة' : 'Plan',
                      style: AppThemes.getTextStyle(
                        context,
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.subscriptionTier,
                      style: AppThemes.getTextStyle(
                        context,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isArabic ? 'المبلغ' : 'Amount',
                      style: AppThemes.getTextStyle(
                        context,
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
                      style: AppThemes.getTextStyle(
                        context,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Payment ID
            const SizedBox(height: 12),
            Text(
              '${isArabic ? 'رقم الدفع' : 'Payment ID'}: #${payment.id}',
              style: AppThemes.getTextStyle(
                context,
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),

            // Refund Button
            if (canRefund) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _requestRefund(payment),
                  icon: const Icon(Icons.undo, size: 18),
                  label: Text(
                    isArabic ? 'طلب استرجاع' : 'Request Refund',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: const BorderSide(color: AppColors.warning),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, bool isArabic) {
    switch (status.toLowerCase()) {
      case 'completed':
        return isArabic ? 'مكتمل' : 'Completed';
      case 'pending':
        return isArabic ? 'قيد الانتظار' : 'Pending';
      case 'failed':
        return isArabic ? 'فاشل' : 'Failed';
      default:
        return status;
    }
  }
}
