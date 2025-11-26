import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSidebarWidget extends StatefulWidget {
  final String currentRoute;

  const AdminSidebarWidget({
    super.key,
    required this.currentRoute,
  });

  @override
  State<AdminSidebarWidget> createState() => _AdminSidebarWidgetState();
}

class _AdminSidebarWidgetState extends State<AdminSidebarWidget> {
  String userName = 'Admin';
  String userEmail = 'admin@alenwan.com';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Admin';
      userEmail = prefs.getString('user_email') ?? 'admin@alenwan.com';
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF1E1E2E),
      child: Column(
        children: [
          // User Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3E),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blue,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Navigation Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: 'لوحة التحكم',
                  route: '/admin/dashboard',
                ),
                _buildMenuItem(
                  icon: Icons.people,
                  title: 'المستخدمين',
                  route: '/admin/users',
                ),
                _buildMenuItem(
                  icon: Icons.video_library,
                  title: 'المحتوى',
                  route: '/admin/content',
                ),
                _buildMenuItem(
                  icon: Icons.cloud_download,
                  title: 'استيراد من Vimeo',
                  route: '/admin/vimeo-import',
                ),
                _buildMenuItem(
                  icon: Icons.card_membership,
                  title: 'الاشتراكات',
                  route: '/admin/subscriptions',
                ),
                _buildMenuItem(
                  icon: Icons.payment,
                  title: 'المدفوعات',
                  route: '/admin/payments',
                ),
                _buildMenuItem(
                  icon: Icons.analytics,
                  title: 'الإيرادات',
                  route: '/admin/revenue',
                ),
                const Divider(
                  color: Colors.white24,
                  height: 30,
                  indent: 20,
                  endIndent: 20,
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'الإعدادات',
                  route: '/settings',
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isActive = widget.currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.blue : Colors.white70,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () {
          if (widget.currentRoute != route) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
