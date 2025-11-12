import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

/// Widget for favorite and my list buttons
/// Can be used in any detail screen (movies, series, cartoons, etc.)
class FavoriteAndListButtons extends StatefulWidget {
  final int contentId;
  final String contentType; // 'movie', 'series', 'cartoon', 'documentary', 'podcast', 'sport', 'livestream'
  final String contentTitle;
  final String? imageUrl;
  final String? description;
  final String? videoUrl;

  const FavoriteAndListButtons({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.contentTitle,
    this.imageUrl,
    this.description,
    this.videoUrl,
  });

  @override
  State<FavoriteAndListButtons> createState() => _FavoriteAndListButtonsState();
}

class _FavoriteAndListButtonsState extends State<FavoriteAndListButtons> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _isInList = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);

    try {
      await _favoritesService.init();

      final isFav = await _favoritesService.isFavorite(
        id: widget.contentId,
        type: widget.contentType,
      );

      final inList = await _favoritesService.isInDownloads(
        id: widget.contentId,
        type: widget.contentType,
      );

      setState(() {
        _isFavorite = isFav;
        _isInList = inList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking favorite/list status: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await _favoritesService.toggleFavorite(
      id: widget.contentId,
      title: widget.contentTitle,
      type: widget.contentType,
      imageUrl: widget.imageUrl,
      description: widget.description,
    );

    setState(() => _isFavorite = newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'تمت الإضافة إلى المفضلة' : 'تمت الإزالة من المفضلة',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: newStatus ? Colors.green : Colors.grey[700],
        ),
      );
    }
  }

  Future<void> _toggleList() async {
    final newStatus = await _favoritesService.toggleDownload(
      id: widget.contentId,
      title: widget.contentTitle,
      type: widget.contentType,
      imageUrl: widget.imageUrl,
      description: widget.description,
      videoUrl: widget.videoUrl,
    );

    setState(() => _isInList = newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'تمت الإضافة إلى قائمتي' : 'تمت الإزالة من قائمتي',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: newStatus ? Colors.green : Colors.grey[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Favorite button
        _buildActionButton(
          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
          label: 'المفضلة',
          onTap: _toggleFavorite,
          isActive: _isFavorite,
          activeColor: Colors.red,
        ),
        const SizedBox(width: 12),
        // My list button
        _buildActionButton(
          icon: _isInList ? Icons.check : Icons.add,
          label: 'قائمتي',
          onTap: _toggleList,
          isActive: _isInList,
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.2)
              : Colors.grey[800]?.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? activeColor : Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : Colors.white,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact version for smaller screens
class FavoriteAndListIconButtons extends StatefulWidget {
  final int contentId;
  final String contentType;
  final String contentTitle;
  final String? imageUrl;
  final String? description;
  final String? videoUrl;

  const FavoriteAndListIconButtons({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.contentTitle,
    this.imageUrl,
    this.description,
    this.videoUrl,
  });

  @override
  State<FavoriteAndListIconButtons> createState() =>
      _FavoriteAndListIconButtonsState();
}

class _FavoriteAndListIconButtonsState
    extends State<FavoriteAndListIconButtons> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _isInList = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      await _favoritesService.init();

      final isFav = await _favoritesService.isFavorite(
        id: widget.contentId,
        type: widget.contentType,
      );

      final inList = await _favoritesService.isInDownloads(
        id: widget.contentId,
        type: widget.contentType,
      );

      if (mounted) {
        setState(() {
          _isFavorite = isFav;
          _isInList = inList;
        });
      }
    } catch (e) {
      print('Error checking status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await _favoritesService.toggleFavorite(
      id: widget.contentId,
      title: widget.contentTitle,
      type: widget.contentType,
      imageUrl: widget.imageUrl,
      description: widget.description,
    );

    setState(() => _isFavorite = newStatus);
  }

  Future<void> _toggleList() async {
    final newStatus = await _favoritesService.toggleDownload(
      id: widget.contentId,
      title: widget.contentTitle,
      type: widget.contentType,
      imageUrl: widget.imageUrl,
      description: widget.description,
      videoUrl: widget.videoUrl,
    );

    setState(() => _isInList = newStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: Icon(
            _isInList ? Icons.check_circle : Icons.add_circle_outline,
            color: _isInList ? Colors.green : Colors.white,
          ),
          onPressed: _toggleList,
        ),
      ],
    );
  }
}
