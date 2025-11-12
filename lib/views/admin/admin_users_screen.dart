import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_service.dart';
import 'widgets/admin_sidebar.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = true;
  String? _token;
  List<dynamic> _users = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;

  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all'; // all, active, inactive
  String _selectedSubscription = 'all'; // all, free, basic, premium

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      if (_token != null) {
        final filters = <String, dynamic>{};
        if (_selectedStatus != 'all') filters['status'] = _selectedStatus;
        if (_selectedSubscription != 'all') {
          filters['subscription'] = _selectedSubscription;
        }

        final result = await AdminService.getUsers(
          token: _token!,
          page: _currentPage,
          search: _searchController.text,
          filters: filters,
        );

        if (result != null) {
          setState(() {
            _users = result['users'] ?? [];
            _totalPages = result['total_pages'] ?? 1;
            _totalUsers = result['total'] ?? 0;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading users: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستخدم'),
        content: const Text('هل أنت متأكد من حذف هذا المستخدم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && _token != null) {
      final success = await AdminService.deleteUser(token: _token!, id: userId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المستخدم بنجاح')),
        );
        _loadUsers();
      }
    }
  }

  Future<void> _showUserDetails(dynamic user) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تفاصيل المستخدم',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow('الاسم', user['name'] ?? ''),
              _buildDetailRow('البريد الإلكتروني', user['email'] ?? ''),
              _buildDetailRow('الحالة', user['status'] ?? ''),
              _buildDetailRow('الاشتراك', user['subscription_type'] ?? 'Free'),
              _buildDetailRow(
                'تاريخ التسجيل',
                user['created_at'] ?? '',
              ),
              _buildDetailRow(
                'آخر نشاط',
                user['last_active'] ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إغلاق'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showEditUserDialog(user);
                    },
                    child: const Text('تعديل'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditUserDialog(dynamic user) async {
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    String selectedStatus = user['status'] ?? 'active';
    String selectedSubscription = user['subscription_type'] ?? 'free';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تعديل المستخدم',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'الحالة',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('نشط')),
                      DropdownMenuItem(
                          value: 'inactive', child: Text('غير نشط')),
                      DropdownMenuItem(value: 'banned', child: Text('محظور')),
                    ],
                    onChanged: (value) {
                      setDialogState(() => selectedStatus = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSubscription,
                    decoration: const InputDecoration(
                      labelText: 'نوع الاشتراك',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'free', child: Text('مجاني')),
                      DropdownMenuItem(value: 'basic', child: Text('أساسي')),
                      DropdownMenuItem(value: 'premium', child: Text('مميز')),
                    ],
                    onChanged: (value) {
                      setDialogState(() => selectedSubscription = value!);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('إلغاء'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_token != null) {
                            final success = await AdminService.updateUser(
                              token: _token!,
                              id: user['id'],
                              data: {
                                'name': nameController.text,
                                'email': emailController.text,
                                'status': selectedStatus,
                                'subscription_type': selectedSubscription,
                              },
                            );
                            if (success && mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تحديث المستخدم بنجاح'),
                                ),
                              );
                              _loadUsers();
                            }
                          }
                        },
                        child: const Text('حفظ'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1E),
        body: Row(
          children: [
            const AdminSidebarWidget(currentRoute: '/admin/users'),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildFilters(),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildUsersTable(),
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
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'إدارة المستخدمين',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'إجمالي المستخدمين: $_totalUsers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
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
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'البحث عن مستخدم...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _currentPage = 1;
                    _loadUsers();
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              dropdownColor: const Color(0xFF1E1E2E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'الحالة',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('الكل')),
                DropdownMenuItem(value: 'active', child: Text('نشط')),
                DropdownMenuItem(value: 'inactive', child: Text('غير نشط')),
                DropdownMenuItem(value: 'banned', child: Text('محظور')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
                _currentPage = 1;
                _loadUsers();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedSubscription,
              dropdownColor: const Color(0xFF1E1E2E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'الاشتراك',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('الكل')),
                DropdownMenuItem(value: 'free', child: Text('مجاني')),
                DropdownMenuItem(value: 'basic', child: Text('أساسي')),
                DropdownMenuItem(value: 'premium', child: Text('مميز')),
              ],
              onChanged: (value) {
                setState(() => _selectedSubscription = value!);
                _currentPage = 1;
                _loadUsers();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable() {
    if (_users.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد مستخدمين',
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
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 24,
          headingRowColor: WidgetStateProperty.all(
            Colors.white.withOpacity(0.05),
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
                'الاسم',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'البريد الإلكتروني',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'الاشتراك',
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
                'تاريخ التسجيل',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'الإجراءات',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
          rows: _users.map((user) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    '${user['id']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  Text(
                    user['name'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  Text(
                    user['email'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  _buildSubscriptionBadge(user['subscription_type'] ?? 'free'),
                ),
                DataCell(
                  _buildStatusBadge(user['status'] ?? 'active'),
                ),
                DataCell(
                  Text(
                    user['created_at'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () => _showUserDetails(user),
                        tooltip: 'عرض التفاصيل',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showEditUserDialog(user),
                        tooltip: 'تعديل',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user['id']),
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSubscriptionBadge(String type) {
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
        color: color.withOpacity(0.2),
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
      case 'banned':
        color = Colors.red;
        label = 'محظور';
        break;
      default:
        color = Colors.grey;
        label = 'غير نشط';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
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
            color: Colors.white.withOpacity(0.1),
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
                    _loadUsers();
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
                    _loadUsers();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
