import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing favorites and downloads/my list using SharedPreferences
class FavoritesService {
  static const String _favoritesKey = 'user_favorites';
  static const String _downloadsKey = 'user_downloads';

  // Singleton pattern
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure preferences are loaded
  Future<SharedPreferences> get prefs async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ═══════════════════════════════════════════════════════════
  // FAVORITES
  // ═══════════════════════════════════════════════════════════

  /// Get all favorites
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final p = await prefs;
    final String? favoritesJson = p.getString(_favoritesKey);

    if (favoritesJson == null || favoritesJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(favoritesJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error decoding favorites: $e');
      return [];
    }
  }

  /// Add item to favorites
  Future<bool> addToFavorites({
    required int id,
    required String title,
    required String type, // 'movie', 'series', 'cartoon', 'documentary', 'podcast', 'sport', 'livestream'
    String? imageUrl,
    String? description,
  }) async {
    final p = await prefs;
    final favorites = await getFavorites();

    // Check if already exists
    final exists = favorites.any((item) =>
      item['id'] == id && item['type'] == type
    );

    if (exists) {
      return false; // Already in favorites
    }

    // Add new favorite
    favorites.add({
      'id': id,
      'title': title,
      'type': type,
      'imageUrl': imageUrl,
      'description': description,
      'addedAt': DateTime.now().toIso8601String(),
    });

    // Save to preferences
    final encoded = json.encode(favorites);
    return await p.setString(_favoritesKey, encoded);
  }

  /// Remove item from favorites
  Future<bool> removeFromFavorites({
    required int id,
    required String type,
  }) async {
    final p = await prefs;
    final favorites = await getFavorites();

    // Remove the item
    favorites.removeWhere((item) =>
      item['id'] == id && item['type'] == type
    );

    // Save to preferences
    final encoded = json.encode(favorites);
    return await p.setString(_favoritesKey, encoded);
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite({
    required int id,
    required String title,
    required String type,
    String? imageUrl,
    String? description,
  }) async {
    final isFav = await isFavorite(id: id, type: type);

    if (isFav) {
      await removeFromFavorites(id: id, type: type);
      return false; // Removed
    } else {
      await addToFavorites(
        id: id,
        title: title,
        type: type,
        imageUrl: imageUrl,
        description: description,
      );
      return true; // Added
    }
  }

  /// Check if item is in favorites
  Future<bool> isFavorite({
    required int id,
    required String type,
  }) async {
    final favorites = await getFavorites();
    return favorites.any((item) =>
      item['id'] == id && item['type'] == type
    );
  }

  /// Clear all favorites
  Future<bool> clearFavorites() async {
    final p = await prefs;
    return await p.remove(_favoritesKey);
  }

  /// Get favorites count
  Future<int> getFavoritesCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  // ═══════════════════════════════════════════════════════════
  // DOWNLOADS / MY LIST
  // ═══════════════════════════════════════════════════════════

  /// Get all downloads/my list
  Future<List<Map<String, dynamic>>> getDownloads() async {
    final p = await prefs;
    final String? downloadsJson = p.getString(_downloadsKey);

    if (downloadsJson == null || downloadsJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(downloadsJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error decoding downloads: $e');
      return [];
    }
  }

  /// Add item to downloads/my list
  Future<bool> addToDownloads({
    required int id,
    required String title,
    required String type, // 'movie', 'series', 'cartoon', 'documentary', 'podcast', 'sport', 'livestream'
    String? imageUrl,
    String? description,
    String? videoUrl,
  }) async {
    final p = await prefs;
    final downloads = await getDownloads();

    // Check if already exists
    final exists = downloads.any((item) =>
      item['id'] == id && item['type'] == type
    );

    if (exists) {
      return false; // Already in downloads
    }

    // Add new download
    downloads.add({
      'id': id,
      'title': title,
      'type': type,
      'imageUrl': imageUrl,
      'description': description,
      'videoUrl': videoUrl,
      'addedAt': DateTime.now().toIso8601String(),
    });

    // Save to preferences
    final encoded = json.encode(downloads);
    return await p.setString(_downloadsKey, encoded);
  }

  /// Remove item from downloads/my list
  Future<bool> removeFromDownloads({
    required int id,
    required String type,
  }) async {
    final p = await prefs;
    final downloads = await getDownloads();

    // Remove the item
    downloads.removeWhere((item) =>
      item['id'] == id && item['type'] == type
    );

    // Save to preferences
    final encoded = json.encode(downloads);
    return await p.setString(_downloadsKey, encoded);
  }

  /// Toggle download/my list status
  Future<bool> toggleDownload({
    required int id,
    required String title,
    required String type,
    String? imageUrl,
    String? description,
    String? videoUrl,
  }) async {
    final isInList = await isInDownloads(id: id, type: type);

    if (isInList) {
      await removeFromDownloads(id: id, type: type);
      return false; // Removed
    } else {
      await addToDownloads(
        id: id,
        title: title,
        type: type,
        imageUrl: imageUrl,
        description: description,
        videoUrl: videoUrl,
      );
      return true; // Added
    }
  }

  /// Check if item is in downloads/my list
  Future<bool> isInDownloads({
    required int id,
    required String type,
  }) async {
    final downloads = await getDownloads();
    return downloads.any((item) =>
      item['id'] == id && item['type'] == type
    );
  }

  /// Clear all downloads/my list
  Future<bool> clearDownloads() async {
    final p = await prefs;
    return await p.remove(_downloadsKey);
  }

  /// Get downloads count
  Future<int> getDownloadsCount() async {
    final downloads = await getDownloads();
    return downloads.length;
  }

  // ═══════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════

  /// Get favorites by type
  Future<List<Map<String, dynamic>>> getFavoritesByType(String type) async {
    final favorites = await getFavorites();
    return favorites.where((item) => item['type'] == type).toList();
  }

  /// Get downloads by type
  Future<List<Map<String, dynamic>>> getDownloadsByType(String type) async {
    final downloads = await getDownloads();
    return downloads.where((item) => item['type'] == type).toList();
  }

  /// Clear all data
  Future<void> clearAll() async {
    await clearFavorites();
    await clearDownloads();
  }
}
