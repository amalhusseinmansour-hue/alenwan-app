import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WatchlistController extends ChangeNotifier {
  static final WatchlistController _instance = WatchlistController._internal();
  factory WatchlistController() => _instance;
  WatchlistController._internal();

  final Set<String> _watchlistIds = {};
  final List<Map<String, dynamic>> _watchlistItems = [];

  bool _isInitialized = false;

  Set<String> get watchlistIds => _watchlistIds;
  List<Map<String, dynamic>> get watchlistItems => _watchlistItems;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load watchlist IDs
      final watchlistJson = prefs.getString('watchlist_ids');
      if (watchlistJson != null) {
        final List<dynamic> watchlistList = json.decode(watchlistJson);
        _watchlistIds.addAll(watchlistList.cast<String>());
      }

      // Load watchlist items
      final watchlistItemsJson = prefs.getString('watchlist_items');
      if (watchlistItemsJson != null) {
        final List<dynamic> items = json.decode(watchlistItemsJson);
        _watchlistItems.addAll(items.cast<Map<String, dynamic>>());
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing watchlist controller: $e');
    }
  }

  bool isInWatchlist(String contentId) {
    return _watchlistIds.contains(contentId);
  }

  Future<void> toggleWatchlist(String contentId, Map<String, dynamic> contentData) async {
    try {
      if (_watchlistIds.contains(contentId)) {
        // Remove from watchlist
        _watchlistIds.remove(contentId);
        _watchlistItems.removeWhere((item) => item['id'] == contentId);
      } else {
        // Add to watchlist
        _watchlistIds.add(contentId);

        // Add content data with timestamp
        final itemData = {
          'id': contentId,
          'title': contentData['title'] ?? '',
          'thumbnail': contentData['thumbnail'] ?? '',
          'description': contentData['description'] ?? '',
          'type': contentData['type'] ?? 'video',
          'addedAt': DateTime.now().toIso8601String(),
          ...contentData,
        };

        _watchlistItems.add(itemData);
      }

      // Save to local storage
      await _saveWatchlist();
      notifyListeners();
    } catch (e) {
      print('Error toggling watchlist: $e');
    }
  }

  Future<void> _saveWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('watchlist_ids', json.encode(_watchlistIds.toList()));
      await prefs.setString('watchlist_items', json.encode(_watchlistItems));
    } catch (e) {
      print('Error saving watchlist: $e');
    }
  }

  Future<void> clearWatchlist() async {
    _watchlistIds.clear();
    _watchlistItems.clear();
    await _saveWatchlist();
    notifyListeners();
  }

  Future<void> removeFromWatchlist(String contentId) async {
    _watchlistIds.remove(contentId);
    _watchlistItems.removeWhere((item) => item['id'] == contentId);
    await _saveWatchlist();
    notifyListeners();
  }
}