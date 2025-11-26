import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

// نموذج لنتيجة التشخيص
class DiagnosticResult {
  final String test;
  final String message;
  final bool? success;
  final DateTime timestamp;

  DiagnosticResult({
    required this.test,
    required this.message,
    this.success,
    required this.timestamp,
  });
}

class BackendDiagnosticTool extends StatefulWidget {
  const BackendDiagnosticTool({super.key});

  @override
  State<BackendDiagnosticTool> createState() => _BackendDiagnosticToolState();
}

class _BackendDiagnosticToolState extends State<BackendDiagnosticTool> {
  bool _isRunning = false;
  List<DiagnosticResult> _results = [];

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _results.clear();
    });

    await _testBasicConnectivity();
    await _testApiEndpoints();
    await _testAuthentication();
    await _testAdminEndpoints();
    await _testDatabase();
    await _testFileAccess();

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _testBasicConnectivity() async {
    _addResult('🔗 اختبار الاتصال الأساسي', 'testing');

    try {
      // Test domain accessibility
      final response = await http.get(
        Uri.parse(AppConfig.domain),
        headers: {'Accept': 'text/html'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _updateResult('🔗 اختبار الاتصال الأساسي', 'النطاق متاح', true);
      } else {
        _updateResult('🔗 اختبار الاتصال الأساسي',
            'النطاق غير متاح: ${response.statusCode}', false);
      }
    } catch (e) {
      _updateResult('🔗 اختبار الاتصال الأساسي', 'فشل الاتصال: $e', false);
    }
  }

  Future<void> _testApiEndpoints() async {
    _addResult('📡 اختبار نقاط API', 'testing');

    final endpoints = [
      '/test-connection',
      '/api/test-api',
      '/api/categories',
      '/api/movies',
      '/api/series',
      '/api/channels',
    ];

    int successCount = 0;
    List<String> failures = [];

    for (String endpoint in endpoints) {
      try {
        final response = await http.get(
          Uri.parse('${AppConfig.domain}$endpoint'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200 || response.statusCode == 401) {
          successCount++;
        } else {
          failures.add('$endpoint: ${response.statusCode}');
        }
      } catch (e) {
        failures.add('$endpoint: خطأ في الاتصال');
      }
    }

    if (successCount == endpoints.length) {
      _updateResult('📡 اختبار نقاط API', 'جميع النقاط متاحة', true);
    } else {
      _updateResult(
          '📡 اختبار نقاط API',
          '${successCount}/${endpoints.length} متاح. فشل: ${failures.join(", ")}',
          false);
    }
  }

  Future<void> _testAuthentication() async {
    _addResult('🔐 اختبار المصادقة', 'testing');

    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiUrl}/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'email': 'test@test.com',
              'password': 'wrongpassword',
            }),
          )
          .timeout(const Duration(seconds: 10));

      // نتوقع 422 أو 401 - يعني API يعمل
      if (response.statusCode == 422 || response.statusCode == 401) {
        _updateResult('🔐 اختبار المصادقة', 'نقطة المصادقة تعمل', true);
      } else if (response.statusCode == 200) {
        _updateResult('🔐 اختبار المصادقة', 'تحذير: المصادقة مفتوحة', false);
      } else {
        _updateResult('🔐 اختبار المصادقة',
            'نقطة المصادقة لا تعمل: ${response.statusCode}', false);
      }
    } catch (e) {
      _updateResult('🔐 اختبار المصادقة', 'فشل اختبار المصادقة: $e', false);
    }
  }

  Future<void> _testAdminEndpoints() async {
    _addResult('👨‍💼 اختبار نقاط الإدارة', 'testing');

    final adminEndpoints = [
      '/api/v1/admin/dashboard/stats',
      '/api/v1/admin/users',
      '/api/v1/admin/content',
    ];

    int reachableCount = 0;

    for (String endpoint in adminEndpoints) {
      try {
        final response = await http.get(
          Uri.parse('${AppConfig.domain}$endpoint'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));

        // 401 يعني الـ endpoint موجود لكن يحتاج authentication
        if (response.statusCode == 401 || response.statusCode == 200) {
          reachableCount++;
        }
      } catch (e) {
        // Endpoint might not be reachable
      }
    }

    if (reachableCount >= 2) {
      _updateResult('👨‍💼 اختبار نقاط الإدارة', 'نقاط الإدارة متاحة', true);
    } else {
      _updateResult(
          '👨‍💼 اختبار نقاط الإدارة', 'نقاط الإدارة غير متاحة', false);
    }
  }

  Future<void> _testDatabase() async {
    _addResult('🗃️ اختبار قاعدة البيانات', 'testing');

    try {
      // Test if we can get categories (should work even without auth)
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/categories'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map &&
            (data['status'] == 'success' || data['data'] != null)) {
          _updateResult(
              '🗃️ اختبار قاعدة البيانات', 'قاعدة البيانات متصلة', true);
        } else {
          _updateResult(
              '🗃️ اختبار قاعدة البيانات', 'هيكل البيانات غير صحيح', false);
        }
      } else {
        _updateResult('🗃️ اختبار قاعدة البيانات',
            'فشل الوصول لقاعدة البيانات: ${response.statusCode}', false);
      }
    } catch (e) {
      _updateResult(
          '🗃️ اختبار قاعدة البيانات', 'خطأ في قاعدة البيانات: $e', false);
    }
  }

  Future<void> _testFileAccess() async {
    _addResult('📁 اختبار الوصول للملفات', 'testing');

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.domain}/storage/'),
        headers: {'Accept': 'text/html'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        _updateResult('📁 اختبار الوصول للملفات', 'مجلد التخزين متاح', true);
      } else {
        _updateResult('📁 اختبار الوصول للملفات',
            'مشكلة في الوصول للملفات: ${response.statusCode}', false);
      }
    } catch (e) {
      _updateResult(
          '📁 اختبار الوصول للملفات', 'فشل الوصول للملفات: $e', false);
    }
  }

  void _addResult(String test, String message, [bool? success]) {
    setState(() {
      _results.add(DiagnosticResult(
        test: test,
        message: message,
        success: success,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _updateResult(String test, String message, bool success) {
    setState(() {
      final index = _results.indexWhere((r) => r.test == test);
      if (index != -1) {
        _results[index] = DiagnosticResult(
          test: test,
          message: message,
          success: success,
          timestamp: DateTime.now(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تشخيص مشاكل الباك اند'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRunning ? null : _runDiagnostics,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🌐 الخادم: ${AppConfig.domain}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('📡 API: ${AppConfig.apiUrl}'),
                Text('📊 الحالة: ${_isRunning ? "جاري الفحص..." : "مكتمل"}'),
              ],
            ),
          ),

          // Results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: _getStatusIcon(result.success),
                    title: Text(result.test),
                    subtitle: Text(result.message),
                    trailing: _isRunning && result.success == null
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),

          // Summary
          if (!_isRunning && _results.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: _buildSummary(),
            ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(bool? success) {
    if (success == null) {
      return const Icon(Icons.schedule, color: Colors.orange);
    } else if (success) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else {
      return const Icon(Icons.error, color: Colors.red);
    }
  }

  Widget _buildSummary() {
    final successCount = _results.where((r) => r.success == true).length;
    final totalCount = _results.where((r) => r.success != null).length;
    final failureCount = totalCount - successCount;

    final overallHealth = successCount / totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📊 ملخص التشخيص',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ نجح: $successCount'),
                  Text('❌ فشل: $failureCount'),
                  Text('📈 الصحة العامة: ${(overallHealth * 100).toInt()}%'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: overallHealth >= 0.8
                    ? Colors.green
                    : overallHealth >= 0.5
                        ? Colors.orange
                        : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                overallHealth >= 0.8
                    ? 'ممتاز'
                    : overallHealth >= 0.5
                        ? 'متوسط'
                        : 'يحتاج إصلاح',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        if (failureCount > 0) ...[
          const SizedBox(height: 12),
          const Text('🔧 الإجراءات المقترحة:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...(_getRecommendations()),
        ],
      ],
    );
  }

  List<Widget> _getRecommendations() {
    List<Widget> recommendations = [];

    final failedTests =
        _results.where((r) => r.success == false).map((r) => r.test).toList();

    if (failedTests.any((test) => test.contains('الاتصال الأساسي'))) {
      recommendations.add(const Text('• تحقق من اتصال الإنترنت والنطاق'));
    }

    if (failedTests.any((test) => test.contains('API'))) {
      recommendations.add(const Text('• تحقق من إعدادات Laravel API'));
    }

    if (failedTests.any((test) => test.contains('المصادقة'))) {
      recommendations.add(const Text('• تحقق من إعدادات المصادقة في Laravel'));
    }

    if (failedTests.any((test) => test.contains('الإدارة'))) {
      recommendations.add(const Text('• تحقق من routes الإدارة وFilament'));
    }

    if (failedTests.any((test) => test.contains('قاعدة البيانات'))) {
      recommendations
          .add(const Text('• تحقق من اتصال قاعدة البيانات و migrations'));
    }

    if (failedTests.any((test) => test.contains('الملفات'))) {
      recommendations.add(const Text('• تحقق من أذونات مجلد storage'));
    }

    return recommendations;
  }
}
