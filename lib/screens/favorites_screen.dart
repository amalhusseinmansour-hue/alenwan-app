import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, movie, series, cartoon, etc.

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      await _favoritesService.init();
      final favorites = await _favoritesService.getFavorites();

      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredFavorites {
    if (_selectedFilter == 'all') {
      return _favorites;
    }
    return _favorites.where((item) => item['type'] == _selectedFilter).toList();
  }

  Future<void> _removeFromFavorites(int id, String type) async {
    final removed = await _favoritesService.removeFromFavorites(
      id: id,
      type: type,
    );

    if (removed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الإزالة من المفضلة'),
          duration: Duration(seconds: 2),
        ),
      );
      _loadFavorites(); // Reload
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'المفضلة',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildFilterChips(),
                    Expanded(child: _buildFavoritesList()),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد عناصر في المفضلة',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'أضف أفلام ومسلسلات لمشاهدتها لاحقاً',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'الكل', 'value': 'all'},
      {'label': 'أفلام', 'value': 'movie'},
      {'label': 'مسلسلات', 'value': 'series'},
      {'label': 'كرتون', 'value': 'cartoon'},
      {'label': 'وثائقي', 'value': 'documentary'},
      {'label': 'بودكاست', 'value': 'podcast'},
      {'label': 'رياضة', 'value': 'sport'},
      {'label': 'بث مباشر', 'value': 'livestream'},
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['value']!;
                });
              },
              selectedColor: const Color(0xFFE50914),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
              backgroundColor: Colors.grey[850],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesList() {
    final favorites = _filteredFavorites;

    if (favorites.isEmpty) {
      return Center(
        child: Text(
          'لا توجد عناصر في هذا التصنيف',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        return _buildFavoriteCard(item);
      },
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item) {
    final imageUrl = item['imageUrl'] ?? 'https://via.placeholder.com/300x450';

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to detail screen based on type
        print('Navigate to ${item['type']} ${item['id']}');
      },
      child: Stack(
        children: [
          // Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Remove button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeFromFavorites(item['id'], item['type']),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // Title
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTypeLabel(item['type']),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
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

  String _getTypeLabel(String type) {
    switch (type) {
      case 'movie':
        return 'فيلم';
      case 'series':
        return 'مسلسل';
      case 'cartoon':
        return 'كرتون';
      case 'documentary':
        return 'وثائقي';
      case 'podcast':
        return 'بودكاست';
      case 'sport':
        return 'رياضة';
      case 'livestream':
        return 'بث مباشر';
      default:
        return type;
    }
  }
}
