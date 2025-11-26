import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import 'widgets/admin_sidebar.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  bool _isLoading = true;
  bool _isExporting = false;
  String? _token;
  List<dynamic> _payments = [];
  int _currentPage = 1;
  int _totalPages = 1;
  Map<String, dynamic>? _stats;

  String _selectedStatus = 'all'; // all, completed, pending, failed
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      if (_token != null) {
        final filters = <String, dynamic>{};
        if (_selectedStatus != 'all') filters['status'] = _selectedStatus;
        if (_dateRange != null) {
          filters['start_date'] =
              DateFormat('yyyy-MM-dd').format(_dateRange!.start);
          filters['end_date'] =
              DateFormat('yyyy-MM-dd').format(_dateRange!.end);
        }

        final result = await AdminService.getPayments(
          token: _token!,
          page: _currentPage,
          filters: filters,
        );

        if (result != null) {
          setState(() {
            _payments = result['payments'] ?? [];
            _totalPages = result['total_pages'] ?? 1;
            _stats = result['stats'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading payments: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToCSV() async {
    setState(() => _isExporting = true);

    try {
      if (_token != null) {
        final filters = <String, dynamic>{};
        if (_selectedStatus != 'all') filters['status'] = _selectedStatus;
        if (_dateRange != null) {
          filters['start_date'] =
              DateFormat('yyyy-MM-dd').format(_dateRange!.start);
          filters['end_date'] =
              DateFormat('yyyy-MM-dd').format(_dateRange!.end);
        }

        final csvData = await AdminService.exportPaymentsCSV(
          token: _token!,
          filters: filters,
        );

        if (csvData != null && mounted) {
          // In a real app, you would save this to a file or download it
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تصدير البيانات بنجاح')),
          );
        }
      }
    } catch (e) {
      print('Error exporting CSV: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تصدير البيانات: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      _currentPage = 1;
      _loadPayments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1E),
        body: Row(
          children: [
            const AdminSidebarWidget(currentRoute: '/admin/payments'),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  if (!_isLoading && _stats != null) _buildStatsCards(),
                  _buildFilters(),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildPaymentsTable(),
                  ),
                  if (!_isLoading) _buildPagination(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'إدارة المدفوعات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isExporting ? null : _exportToCSV,
            icon: _isExporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download),
            label: const Text('تصدير CSV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'المدفوعات المكتملة',
              value: '${_stats?['completed'] ?? 0}',
              color: Colors.green,
              icon: Icons.check_circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'قيد الانتظار',
              value: '${_stats?['pending'] ?? 0}',
              color: Colors.orange,
              icon: Icons.pending,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'فاشلة',
              value: '${_stats?['failed'] ?? 0}',
              color: Colors.red,
              icon: Icons.error,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'إجمالي المبلغ',
              value: '\$${_stats?['total_amount'] ?? 0}',
              color: Colors.blue,
              icon: Icons.attach_money,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              dropdownColor: const Color(0xFF1E1E2E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'الحالة',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('الكل')),
                DropdownMenuItem(value: 'completed', child: Text('مكتملة')),
                DropdownMenuItem(value: 'pending', child: Text('قيد الانتظار')),
                DropdownMenuItem(value: 'failed', child: Text('فاشلة')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
                _currentPage = 1;
                _loadPayments();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(
                _dateRange == null
                    ? 'اختر فترة زمنية'
                    : '${DateFormat('yyyy-MM-dd').format(_dateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_dateRange != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() => _dateRange = null);
                _currentPage = 1;
                _loadPayments();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentsTable() {
    if (_payments.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد مدفوعات',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 24,
          headingRowColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.05),
          ),
          columns: const [
            DataColumn(
              label: Text(
                'ID',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'المستخدم',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'المبلغ',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'طريقة الدفع',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'الحالة',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'التاريخ',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'رقم المعاملة',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
          rows: _payments.map((payment) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    '${payment['id']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  Text(
                    payment['user_name'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  Text(
                    '\$${payment['amount'] ?? 0}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    payment['payment_method'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  _buildStatusBadge(payment['status'] ?? 'pending'),
                ),
                DataCell(
                  Text(
                    payment['created_at'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  Text(
                    payment['transaction_id'] ?? '',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        label = 'مكتملة';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'قيد الانتظار';
        break;
      case 'failed':
        color = Colors.red;
        label = 'فاشلة';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadPayments();
                  }
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            'صفحة $_currentPage من $_totalPages',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadPayments();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
