import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_service.dart';
import 'widgets/admin_sidebar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      if (_token != null) {
        final stats = await AdminService.getDashboardStats(_token!);
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading dashboard: $e');
      setState(() => _isLoading = false);
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
            const AdminSidebarWidget(currentRoute: '/admin/dashboard'),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDashboardContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (_stats == null) {
      return const Center(
        child: Text(
          'فشل في تحميل البيانات',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'لوحة التحكم',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          _buildStatsCards(),
          const SizedBox(height: 24),

          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildUserGrowthChart()),
              const SizedBox(width: 16),
              Expanded(child: _buildRevenueChart()),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activities & Quick Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRecentActivities()),
              const SizedBox(width: 16),
              Expanded(child: _buildQuickActions()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'إجمالي المستخدمين',
          value: '${_stats?['total_users'] ?? 0}',
          icon: Icons.people,
          color: Colors.blue,
          trend: _stats?['users_trend'] ?? 0.0,
        ),
        _buildStatCard(
          title: 'الاشتراكات النشطة',
          value: '${_stats?['active_subscriptions'] ?? 0}',
          icon: Icons.card_membership,
          color: Colors.green,
          trend: _stats?['subscriptions_trend'] ?? 0.0,
        ),
        _buildStatCard(
          title: 'الإيرادات الشهرية',
          value: '\$${_stats?['monthly_revenue'] ?? 0}',
          icon: Icons.attach_money,
          color: Colors.orange,
          trend: _stats?['revenue_trend'] ?? 0.0,
        ),
        _buildStatCard(
          title: 'المحتوى',
          value: '${_stats?['total_content'] ?? 0}',
          icon: Icons.video_library,
          color: Colors.purple,
          trend: _stats?['content_trend'] ?? 0.0,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double trend,
  }) {
    final isPositive = trend >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trend.abs()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نمو المستخدمين',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'يناير',
                          'فبراير',
                          'مارس',
                          'أبريل',
                          'مايو',
                          'يونيو'
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[value.toInt()],
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 4),
                      FlSpot(2, 5),
                      FlSpot(3, 5.5),
                      FlSpot(4, 7),
                      FlSpot(5, 8),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الإيرادات الشهرية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10000,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'ينا',
                          'فبر',
                          'مار',
                          'أبر',
                          'ماي',
                          'يون'
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[value.toInt()],
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarData(0, 5000),
                  _makeBarData(1, 6000),
                  _makeBarData(2, 7500),
                  _makeBarData(3, 7000),
                  _makeBarData(4, 8500),
                  _makeBarData(5, 9000),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.orange,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    final activities = _stats?['recent_activities'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'النشاطات الأخيرة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'لا توجد نشاطات حديثة',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            )
          else
            ...activities.take(5).map((activity) {
              return _buildActivityItem(
                title: activity['title'] ?? '',
                subtitle: activity['description'] ?? '',
                time: activity['time'] ?? '',
                icon: _getActivityIcon(activity['type']),
                color: _getActivityColor(activity['type']),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'user':
        return Icons.person_add;
      case 'subscription':
        return Icons.card_membership;
      case 'payment':
        return Icons.payment;
      case 'content':
        return Icons.video_library;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'user':
        return Colors.blue;
      case 'subscription':
        return Colors.green;
      case 'payment':
        return Colors.orange;
      case 'content':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(
            icon: Icons.video_library,
            label: 'إضافة فيلم',
            onTap: () => Navigator.of(context).pushNamed('/admin/movie/add'),
          ),
          const SizedBox(height: 10),
          _buildQuickActionButton(
            icon: Icons.tv,
            label: 'إضافة مسلسل',
            onTap: () => Navigator.of(context).pushNamed('/admin/series/add'),
          ),
          const SizedBox(height: 10),
          _buildQuickActionButton(
            icon: Icons.people,
            label: 'عرض المستخدمين',
            onTap: () => Navigator.of(context).pushNamed('/admin/users'),
          ),
          const SizedBox(height: 10),
          _buildQuickActionButton(
            icon: Icons.analytics,
            label: 'تقارير الإيرادات',
            onTap: () => Navigator.of(context).pushNamed('/admin/revenue'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
