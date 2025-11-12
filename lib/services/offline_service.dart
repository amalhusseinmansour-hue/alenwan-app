// lib/services/offline_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

enum OfflineContentType {
  movie,
  series,
  episode,
  documentary,
  cartoon,
}

class OfflineContent {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? videoUrl;
  final OfflineContentType type;
  final DateTime downloadDate;
  final int fileSize;
  final String localPath;
  final Map<String, dynamic> metadata;

  OfflineContent({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.videoUrl,
    required this.type,
    required this.downloadDate,
    required this.fileSize,
    required this.localPath,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'type': type.toString(),
      'downloadDate': downloadDate.toIso8601String(),
      'fileSize': fileSize,
      'localPath': localPath,
      'metadata': metadata,
    };
  }

  factory OfflineContent.fromJson(Map<String, dynamic> json) {
    return OfflineContent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      type: OfflineContentType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => OfflineContentType.movie,
      ),
      downloadDate: DateTime.parse(json['downloadDate']),
      fileSize: json['fileSize'],
      localPath: json['localPath'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class DownloadProgress {
  final String contentId;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final DownloadStatus status;
  final String? error;

  DownloadProgress({
    required this.contentId,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.status,
    this.error,
  });
}

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

class OfflineService extends ChangeNotifier {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Dio _dio = Dio();

  // Connection state
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  // Downloaded content
  final Map<String, OfflineContent> _downloadedContent = {};
  List<OfflineContent> get downloadedContent =>
      _downloadedContent.values.toList();

  // Download queue and progress
  final Map<String, CancelToken> _downloadTokens = {};
  final Map<String, DownloadProgress> _downloadProgress = {};
  Map<String, DownloadProgress> get downloadProgress =>
      Map.unmodifiable(_downloadProgress);

  // Cache management
  int _maxCacheSize = 5 * 1024 * 1024 * 1024; // 5GB default
  int get maxCacheSize => _maxCacheSize;
  int _currentCacheSize = 0;
  int get currentCacheSize => _currentCacheSize;

  // Pending sync operations
  final List<Map<String, dynamic>> _pendingSyncOperations = [];
  List<Map<String, dynamic>> get pendingSyncOperations =>
      List.unmodifiable(_pendingSyncOperations);

  static const String _cacheKey = 'offline_content_cache';
  static const String _settingsKey = 'offline_settings';
  static const String _syncQueueKey = 'sync_queue';

  Future<void> initialize() async {
    try {
      // Initialize connectivity monitoring
      await _initializeConnectivity();

      // Load cached content
      await _loadCachedContent();

      // Load pending sync operations
      await _loadPendingSyncOperations();

      // Calculate current cache size
      await _calculateCacheSize();

      // Load settings
      await _loadSettings();

      debugPrint('OfflineService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing OfflineService: $e');
    }
  }

  Future<void> _initializeConnectivity() async {
    // Check initial connectivity status
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = !connectivityResult.contains(ConnectivityResult.none);

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final wasOnline = _isOnline;
        _isOnline = !results.contains(ConnectivityResult.none);

        if (!wasOnline && _isOnline) {
          // Back online - sync pending operations
          await _syncPendingOperations();
        }

        notifyListeners();
      },
    );
  }

  Future<void> _loadCachedContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);

      if (cachedData != null) {
        final List<dynamic> contentList = json.decode(cachedData);
        for (final item in contentList) {
          final content = OfflineContent.fromJson(item);
          // Verify file still exists
          if (await File(content.localPath).exists()) {
            _downloadedContent[content.id] = content;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading cached content: $e');
    }
  }

  Future<void> _loadPendingSyncOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncData = prefs.getString(_syncQueueKey);

      if (syncData != null) {
        final List<dynamic> operations = json.decode(syncData);
        _pendingSyncOperations.clear();
        _pendingSyncOperations.addAll(operations.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Error loading pending sync operations: $e');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsData = prefs.getString(_settingsKey);

      if (settingsData != null) {
        final Map<String, dynamic> settings = json.decode(settingsData);
        _maxCacheSize = settings['maxCacheSize'] ?? _maxCacheSize;
      }
    } catch (e) {
      debugPrint('Error loading offline settings: $e');
    }
  }

  Future<void> _calculateCacheSize() async {
    int totalSize = 0;
    for (final content in _downloadedContent.values) {
      try {
        final file = File(content.localPath);
        if (await file.exists()) {
          final fileStat = await file.stat();
          totalSize += fileStat.size;
        }
      } catch (e) {
        debugPrint('Error calculating size for ${content.localPath}: $e');
      }
    }
    _currentCacheSize = totalSize;
  }

  // Download management
  Future<bool> downloadContent({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required String videoUrl,
    required OfflineContentType type,
    Map<String, dynamic> metadata = const {},
  }) async {
    if (_downloadedContent.containsKey(id)) {
      throw Exception('Content already downloaded');
    }

    if (_downloadTokens.containsKey(id)) {
      throw Exception('Download already in progress');
    }

    try {
      // Check if we have enough space
      await _ensureCacheSpace();

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Create unique filename
      final fileName = '${id}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = '${downloadsDir.path}/$fileName';

      // Create cancel token
      final cancelToken = CancelToken();
      _downloadTokens[id] = cancelToken;

      // Initialize progress
      _downloadProgress[id] = DownloadProgress(
        contentId: id,
        progress: 0.0,
        downloadedBytes: 0,
        totalBytes: 0,
        status: DownloadStatus.pending,
      );
      notifyListeners();

      // Start download
      await _dio.download(
        videoUrl,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _downloadProgress[id] = DownloadProgress(
              contentId: id,
              progress: progress,
              downloadedBytes: received,
              totalBytes: total,
              status: DownloadStatus.downloading,
            );
            notifyListeners();
          }
        },
      );

      // Get file size
      final file = File(filePath);
      final fileSize = await file.length();

      // Create offline content
      final offlineContent = OfflineContent(
        id: id,
        title: title,
        description: description,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        type: type,
        downloadDate: DateTime.now(),
        fileSize: fileSize,
        localPath: filePath,
        metadata: metadata,
      );

      // Save to cache
      _downloadedContent[id] = offlineContent;
      await _saveCachedContent();

      // Update cache size
      _currentCacheSize += fileSize;

      // Update progress to completed
      _downloadProgress[id] = DownloadProgress(
        contentId: id,
        progress: 1.0,
        downloadedBytes: fileSize,
        totalBytes: fileSize,
        status: DownloadStatus.completed,
      );

      // Clean up
      _downloadTokens.remove(id);

      notifyListeners();
      return true;
    } catch (e) {
      // Handle download error
      _downloadProgress[id] = DownloadProgress(
        contentId: id,
        progress: 0.0,
        downloadedBytes: 0,
        totalBytes: 0,
        status: DownloadStatus.failed,
        error: e.toString(),
      );

      _downloadTokens.remove(id);
      notifyListeners();
      return false;
    }
  }

  Future<void> pauseDownload(String contentId) async {
    final cancelToken = _downloadTokens[contentId];
    if (cancelToken != null) {
      cancelToken.cancel();
      _downloadTokens.remove(contentId);

      if (_downloadProgress.containsKey(contentId)) {
        final currentProgress = _downloadProgress[contentId]!;
        _downloadProgress[contentId] = DownloadProgress(
          contentId: contentId,
          progress: currentProgress.progress,
          downloadedBytes: currentProgress.downloadedBytes,
          totalBytes: currentProgress.totalBytes,
          status: DownloadStatus.paused,
        );
        notifyListeners();
      }
    }
  }

  Future<void> cancelDownload(String contentId) async {
    final cancelToken = _downloadTokens[contentId];
    if (cancelToken != null) {
      cancelToken.cancel();
      _downloadTokens.remove(contentId);
    }

    // Remove partial file if it exists
    final content = _downloadedContent[contentId];
    if (content != null) {
      final file = File(content.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    _downloadProgress.remove(contentId);
    _downloadedContent.remove(contentId);
    await _saveCachedContent();
    notifyListeners();
  }

  Future<void> deleteDownload(String contentId) async {
    final content = _downloadedContent[contentId];
    if (content == null) return;

    try {
      // Delete file
      final file = File(content.localPath);
      if (await file.exists()) {
        await file.delete();
        _currentCacheSize -= content.fileSize;
      }

      // Remove from cache
      _downloadedContent.remove(contentId);
      _downloadProgress.remove(contentId);

      await _saveCachedContent();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting download: $e');
    }
  }

  // Cache management
  Future<void> _ensureCacheSpace() async {
    // Simple LRU eviction - remove oldest downloads if needed
    while (_currentCacheSize > _maxCacheSize * 0.8) {
      final oldestContent = _downloadedContent.values
          .reduce((a, b) => a.downloadDate.isBefore(b.downloadDate) ? a : b);

      await deleteDownload(oldestContent.id);

      if (_downloadedContent.isEmpty) break;
    }
  }

  Future<void> clearAllDownloads() async {
    final contentIds = _downloadedContent.keys.toList();
    for (final id in contentIds) {
      await deleteDownload(id);
    }
  }

  Future<void> setMaxCacheSize(int sizeInBytes) async {
    _maxCacheSize = sizeInBytes;
    await _saveSettings();
    await _ensureCacheSpace();
    notifyListeners();
  }

  // Sync operations for when back online
  Future<void> addPendingSyncOperation(Map<String, dynamic> operation) async {
    _pendingSyncOperations.add({
      ...operation,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _savePendingSyncOperations();
  }

  Future<void> _syncPendingOperations() async {
    if (_pendingSyncOperations.isEmpty || !_isOnline) return;

    final operationsToSync =
        List<Map<String, dynamic>>.from(_pendingSyncOperations);

    for (final operation in operationsToSync) {
      try {
        // Process sync operation based on type
        await _processSyncOperation(operation);
        _pendingSyncOperations.remove(operation);
      } catch (e) {
        debugPrint('Error syncing operation: $e');
        // Keep operation in queue for retry
      }
    }

    await _savePendingSyncOperations();
    notifyListeners();
  }

  Future<void> _processSyncOperation(Map<String, dynamic> operation) async {
    final type = operation['type'];

    switch (type) {
      case 'favorite':
        await _syncFavorite(operation);
        break;
      case 'watchlist':
        await _syncWatchlist(operation);
        break;
      case 'watch_progress':
        await _syncWatchProgress(operation);
        break;
      case 'rating':
        await _syncRating(operation);
        break;
      default:
        debugPrint('Unknown sync operation type: $type');
    }
  }

  Future<void> _syncFavorite(Map<String, dynamic> operation) async {
    // Implement favorite sync logic
    final contentId = operation['contentId'];
    final isFavorite = operation['isFavorite'];

    // Make API call to sync favorite status
    await _dio.post('/api/favorites', data: {
      'content_id': contentId,
      'is_favorite': isFavorite,
    });
  }

  Future<void> _syncWatchlist(Map<String, dynamic> operation) async {
    // Implement watchlist sync logic
    final contentId = operation['contentId'];
    final isInWatchlist = operation['isInWatchlist'];

    await _dio.post('/api/watchlist', data: {
      'content_id': contentId,
      'is_in_watchlist': isInWatchlist,
    });
  }

  Future<void> _syncWatchProgress(Map<String, dynamic> operation) async {
    // Implement watch progress sync logic
    final contentId = operation['contentId'];
    final progress = operation['progress'];
    final duration = operation['duration'];

    await _dio.post('/api/watch-progress', data: {
      'content_id': contentId,
      'progress': progress,
      'duration': duration,
    });
  }

  Future<void> _syncRating(Map<String, dynamic> operation) async {
    // Implement rating sync logic
    final contentId = operation['contentId'];
    final rating = operation['rating'];

    await _dio.post('/api/ratings', data: {
      'content_id': contentId,
      'rating': rating,
    });
  }

  // Persistence methods
  Future<void> _saveCachedContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contentList =
          _downloadedContent.values.map((content) => content.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(contentList));
    } catch (e) {
      debugPrint('Error saving cached content: $e');
    }
  }

  Future<void> _savePendingSyncOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_syncQueueKey, json.encode(_pendingSyncOperations));
    } catch (e) {
      debugPrint('Error saving pending sync operations: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = {
        'maxCacheSize': _maxCacheSize,
      };
      await prefs.setString(_settingsKey, json.encode(settings));
    } catch (e) {
      debugPrint('Error saving offline settings: $e');
    }
  }

  // Utility methods
  bool isContentDownloaded(String contentId) {
    return _downloadedContent.containsKey(contentId);
  }

  OfflineContent? getOfflineContent(String contentId) {
    return _downloadedContent[contentId];
  }

  bool isDownloadInProgress(String contentId) {
    return _downloadTokens.containsKey(contentId);
  }

  DownloadProgress? getDownloadProgress(String contentId) {
    return _downloadProgress[contentId];
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  double get cacheUsagePercentage {
    if (_maxCacheSize == 0) return 0;
    return (_currentCacheSize / _maxCacheSize).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}

// Extension for easy access
extension OfflineServiceExtension on BuildContext {
  OfflineService get offlineService => OfflineService();
}
