import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config.dart';

class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({super.key});

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  bool _isLoading = false;
  String _connectionStatus = 'Not tested';
  String _testResult = '';
  List<dynamic> _movies = [];
  List<dynamic> _series = [];
  List<dynamic> _channels = [];
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing...';
    });

    try {
      final isConnected = await ApiService.testConnection();

      setState(() {
        _isLoading = false;
        _connectionStatus = isConnected ? 'Connected ✅' : 'Failed ❌';
        _testResult = isConnected
            ? 'Successfully connected to Laravel backend!'
            : 'Could not connect to Laravel backend. Make sure the server is running on ${AppConfig.domain}';
      });

      if (isConnected) {
        _loadContent();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _connectionStatus = 'Error ❌';
        _testResult = 'Connection error: $e';
      });
    }
  }

  Future<void> _loadContent() async {
    try {
      final movies = await ApiService.getContentMovies();
      final series = await ApiService.getContentSeries();
      final channels = await ApiService.getContentChannels();
      final categories = await ApiService.getContentCategories();

      setState(() {
        _movies = movies;
        _series = series;
        _channels = channels;
        _categories = categories;
      });
    } catch (e) {
      print('Error loading content: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Connection Test'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laravel Backend Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Connection Status: '),
                        if (_isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Text(
                            _connectionStatus,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _connectionStatus.contains('✅')
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Backend URL: ${AppConfig.domain}'),
                    const SizedBox(height: 16),
                    if (_testResult.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _testResult.contains('Successfully')
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          border: Border.all(
                            color: _testResult.contains('Successfully')
                                ? Colors.green
                                : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _testResult,
                          style: TextStyle(
                            color: _testResult.contains('Successfully')
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Testing Connection...'),
                      ],
                    )
                  : const Text('Test Connection Again'),
            ),
            const SizedBox(height: 24),
            if (_connectionStatus.contains('✅')) ...[
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.purple,
                        tabs: [
                          Tab(text: 'Movies'),
                          Tab(text: 'Series'),
                          Tab(text: 'Channels'),
                          Tab(text: 'Categories'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildContentList(_movies, 'movie'),
                            _buildContentList(_series, 'series'),
                            _buildContentList(_channels, 'channel'),
                            _buildCategoriesList(_categories),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Steps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text('• Connection test working'),
                      Text('• Laravel backend server running'),
                      Text('• API endpoints ready for integration'),
                      Text('• Authentication system implemented'),
                      Text('• Movie and content APIs available'),
                      Text('• Ready to replace mock data with real API calls'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList(List<dynamic> items, String type) {
    if (items.isEmpty) {
      return Center(
        child: Text('No $type data available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            leading: item['poster'] != null || item['logo'] != null
                ? Image.network(
                    item['poster'] ?? item['logo'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.movie),
                  )
                : const Icon(Icons.movie),
            title: Text(item['title'] ?? item['name'] ?? 'Unknown'),
            subtitle: Text(
              item['description'] ?? item['category'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: item['is_premium'] == true
                ? const Icon(Icons.star, color: Colors.amber)
                : item['is_hd'] == true
                    ? const Text('HD',
                        style: TextStyle(fontWeight: FontWeight.bold))
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildCategoriesList(List<dynamic> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Text('No categories available'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          color: _parseColor(category['color']),
          child: InkWell(
            onTap: () {},
            child: Center(
              child: Text(
                category['name'] ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || !colorString.startsWith('#')) {
      return Colors.grey;
    }
    try {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }
}
