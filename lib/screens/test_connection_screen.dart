import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config.dart';
import '../core/theme/professional_theme.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  bool _isLoading = false;
  String _status = 'Ready to test';
  Color _statusColor = ProfessionalTheme.textSecondary;
  final List<Map<String, dynamic>> _testResults = [];

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _status = 'Running tests...';
      _testResults.clear();
    });

    // Test 1: Basic API Connection
    await _testBasicConnection();

    // Test 2: Content Endpoints
    await _testContentEndpoints();

    // Test 3: Authentication Endpoint
    await _testAuthEndpoints();

    setState(() {
      _isLoading = false;
      final failedTests =
          _testResults.where((r) => r['success'] == false).length;
      if (failedTests == 0) {
        _status = 'All tests passed! ✅';
        _statusColor = ProfessionalTheme.successColor;
      } else {
        _status = '$failedTests test(s) failed ❌';
        _statusColor = ProfessionalTheme.errorColor;
      }
    });
  }

  Future<void> _testBasicConnection() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '${AppConfig.apiBaseUrl}${AppConfig.testEndpoint}',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      setState(() {
        _testResults.add({
          'name': 'Basic API Connection',
          'endpoint': '${AppConfig.apiBaseUrl}${AppConfig.testEndpoint}',
          'success': response.statusCode == 200,
          'message': response.data['message'] ?? 'Connected',
          'data': response.data,
        });
      });
    } catch (e) {
      setState(() {
        _testResults.add({
          'name': 'Basic API Connection',
          'endpoint': '${AppConfig.apiBaseUrl}${AppConfig.testEndpoint}',
          'success': false,
          'message': 'Connection failed',
          'error': e.toString(),
        });
      });
    }
  }

  Future<void> _testContentEndpoints() async {
    final endpoints = [
      {'name': 'Movies', 'path': AppConfig.moviesEndpoint},
      {'name': 'Series', 'path': AppConfig.seriesEndpoint},
      {'name': 'Categories', 'path': AppConfig.categoriesEndpoint},
    ];

    for (var endpoint in endpoints) {
      try {
        final dio = Dio();
        final response = await dio.get(
          '${AppConfig.apiUrl}${endpoint['path']}',
          options: Options(
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        setState(() {
          _testResults.add({
            'name': '${endpoint['name']} Endpoint',
            'endpoint': '${AppConfig.apiUrl}${endpoint['path']}',
            'success': response.statusCode == 200,
            'message': 'Endpoint accessible',
            'data': response.data,
          });
        });
      } catch (e) {
        setState(() {
          _testResults.add({
            'name': '${endpoint['name']} Endpoint',
            'endpoint': '${AppConfig.apiUrl}${endpoint['path']}',
            'success': false,
            'message': 'Endpoint failed',
            'error': e.toString(),
          });
        });
      }
    }
  }

  Future<void> _testAuthEndpoints() async {
    // Just test if endpoints are accessible (not actual login)
    try {
      final dio = Dio();
      final response = await dio.post(
        '${AppConfig.apiUrl}${AppConfig.loginEndpoint}',
        data: {'email': '', 'password': ''}, // Empty data to test endpoint
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => true, // Accept any status
        ),
      );

      setState(() {
        _testResults.add({
          'name': 'Login Endpoint',
          'endpoint': '${AppConfig.apiUrl}${AppConfig.loginEndpoint}',
          'success': response.statusCode != null,
          'message': 'Endpoint accessible (${response.statusCode})',
          'data': response.data,
        });
      });
    } catch (e) {
      setState(() {
        _testResults.add({
          'name': 'Login Endpoint',
          'endpoint': '${AppConfig.apiUrl}${AppConfig.loginEndpoint}',
          'success': false,
          'message': 'Endpoint failed',
          'error': e.toString(),
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: ProfessionalTheme.backgroundPrimary,
        elevation: 0,
        title: const Text(
          'Backend Connection Test',
          style: TextStyle(
            color: ProfessionalTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.refresh, color: ProfessionalTheme.textPrimary),
            onPressed: _isLoading ? null : _runTests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Configuration Info
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ProfessionalTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: ProfessionalTheme.primaryBrand,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Configuration',
                      style: TextStyle(
                        color: ProfessionalTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildConfigRow(
                  'Environment',
                  AppConfig.isProduction ? 'Production' : 'Development',
                  AppConfig.isProduction
                      ? ProfessionalTheme.errorColor
                      : ProfessionalTheme.successColor,
                ),
                _buildConfigRow('Domain', AppConfig.domain,
                    ProfessionalTheme.textSecondary),
                _buildConfigRow('API Base', AppConfig.apiBaseUrl,
                    ProfessionalTheme.textSecondary),
                _buildConfigRow('API Version', AppConfig.apiVersion,
                    ProfessionalTheme.textSecondary),
              ],
            ),
          ),

          // Status
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                if (_isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _statusColor,
                    ),
                  )
                else
                  Icon(
                    _testResults.any((r) => r['success'] == false)
                        ? Icons.error
                        : Icons.check_circle,
                    color: _statusColor,
                    size: 20,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _status,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Test Results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _testResults.length,
              itemBuilder: (context, index) {
                final result = _testResults[index];
                return _buildTestResultCard(result);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: ProfessionalTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResultCard(Map<String, dynamic> result) {
    final isSuccess = result['success'] == true;
    final color = isSuccess
        ? ProfessionalTheme.successColor
        : ProfessionalTheme.errorColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ProfessionalTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: color,
          size: 24,
        ),
        title: Text(
          result['name'],
          style: const TextStyle(
            color: ProfessionalTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          result['message'],
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ProfessionalTheme.backgroundPrimary.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Endpoint', result['endpoint']),
                if (result['error'] != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Error', result['error']),
                ],
                if (result['data'] != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Response:',
                    style: TextStyle(
                      color: ProfessionalTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ProfessionalTheme.backgroundPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result['data'].toString(),
                      style: const TextStyle(
                        color: ProfessionalTheme.textTertiary,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            color: ProfessionalTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: ProfessionalTheme.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
