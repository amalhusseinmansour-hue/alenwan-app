import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_service.dart';
import 'widgets/admin_sidebar.dart';

class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  State<AdminSubscriptionsScreen> createState() =>
      _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState extends State<AdminSubscriptionsScreen> {
  bool _isLoading = true;
  String? _token;
  List<dynamic> _subscriptions = [];
  int _currentPage = 1;
  int _totalPages = 1;
  Map<String, dynamic>? _stats;

  String _selectedStatus = 'all'; // all, active, expired, cancelled

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      if (_token != null) {
        final filters = <String, dynamic>{};
        if (_selectedStatus != 'all') filters['status'] = _selectedStatus;

        final result = await AdminService.getSubscriptions(
          token: _token!,
          page: _currentPage,
          filters: filters,
        );

        if (result != null) {
          setState(() {
            _subscriptions = result['subscriptions'] ?? [];
            _totalPages = result['total_pages'] ?? 1;
            _stats = result['stats'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading subscriptions: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1E),
        body: Row(
          children: [
            const AdminSidebarWidget(currentRoute: '/admin/subscriptions'),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  if (!_isLoading && _stats != null) _buildStatsCards(),
                  _buildFilters(),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildSubscriptionsTable(),
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'إدارة الاشتراكات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
              title: 'الاشتراكات النشطة',
              value: '${_stats?['active'] ?? 0}',
              color: Colors.green,
              icon: Icons.check_circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'الاشتراكات المنتهية',
              value: '${_stats?['expired'] ?? 0}',
              color: Colors.orange,
              icon: Icons.access_time,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'الاشتراكات الملغاة',
              value: '${_stats?['cancelled'] ?? 0}',
              color: Colors.red,
              icon: Icons.cancel,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'إجمالي الإيرادات',
              value: '${_stats?['total_revenue'] ?? 0} AED',
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
                DropdownMenuItem(value: 'active', child: Text('نشط')),
                DropdownMenuItem(value: 'expired', child: Text('منتهي')),
                DropdownMenuItem(value: 'cancelled', child: Text('ملغى')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
                _currentPage = 1;
                _loadSubscriptions();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsTable() {
    if (_subscriptions.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد اشتراكات',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return SingleChildScrollView(
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
                'المستخدم',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'نوع الاشتراك',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'تاريخ البداية',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'تاريخ الانتهاء',
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
                'السعر',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
          rows: _subscriptions.map((sub) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    sub['user_name'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  _buildTypeBadge(sub['type'] ?? 'free'),
                ),
                DataCell(
                  Text(
                    sub['start_date'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  Text(
                    sub['end_date'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  _buildStatusBadge(sub['status'] ?? 'active'),
                ),
                DataCell(
                  Text(
                    '${sub['price'] ?? 0} AED',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;

    switch (type.toLowerCase()) {
      case 'premium':
        color = Colors.purple;
        label = 'مميز';
        break;
      case 'basic':
        color = Colors.blue;
        label = 'أساسي';
        break;
      default:
        color = Colors.grey;
        label = 'مجاني';
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        label = 'نشط';
        break;
      case 'expired':
        color = Colors.orange;
        label = 'منتهي';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'ملغى';
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
                    _loadSubscriptions();
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
                    _loadSubscriptions();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
