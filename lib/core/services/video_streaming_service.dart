import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:video_player/video_player.dart';

class VideoStreamingService extends ChangeNotifier {
  static final VideoStreamingService _instance =
      VideoStreamingService._internal();
  factory VideoStreamingService() => _instance;
  VideoStreamingService._internal();

  // Video quality levels
  static const Map<String, VideoQuality> qualityLevels = {
    '240p': VideoQuality(height: 240, bitrate: 400000, label: '240p'),
    '360p': VideoQuality(height: 360, bitrate: 700000, label: '360p'),
    '480p': VideoQuality(height: 480, bitrate: 1000000, label: '480p'),
    '720p': VideoQuality(height: 720, bitrate: 2500000, label: '720p HD'),
    '1080p':
        VideoQuality(height: 1080, bitrate: 5000000, label: '1080p Full HD'),
    '1440p': VideoQuality(height: 1440, bitrate: 8000000, label: '1440p 2K'),
    '2160p': VideoQuality(height: 2160, bitrate: 15000000, label: '2160p 4K'),
  };

  // Current settings
  VideoQuality _currentQuality = qualityLevels['720p']!;
  bool _autoQuality = true;
  bool _saveDataMode = false;
  double _playbackSpeed = 1.0;
  final bool _enableSubtitles = true;

  // Network monitoring
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  ConnectionQuality _connectionQuality = ConnectionQuality.good;

  // Buffering settings
  Duration _bufferDuration = const Duration(seconds: 30);
  Duration _minBufferDuration = const Duration(seconds: 10);
  Duration _maxBufferDuration = const Duration(minutes: 2);

  // Cache settings
  final int _maxCacheSize = 500 * 1024 * 1024; // 500MB
  final Map<String, CachedVideo> _videoCache = {};

  // Playback statistics
  final Map<String, PlaybackStats> _playbackStats = {};

  // Getters
  VideoQuality get currentQuality => _currentQuality;
  bool get autoQuality => _autoQuality;
  bool get saveDataMode => _saveDataMode;
  double get playbackSpeed => _playbackSpeed;
  bool get enableSubtitles => _enableSubtitles;
  ConnectionQuality get connectionQuality => _connectionQuality;

  // Initialize service
  void initialize() {
    _startNetworkMonitoring();
    _loadUserPreferences();
  }

  // Start network monitoring
  void _startNetworkMonitoring() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionQuality(results.first);
      if (_autoQuality) {
        _adjustQualityForNetwork();
      }
    });
  }

  // Update connection quality based on network type
  void _updateConnectionQuality(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        _connectionQuality = ConnectionQuality.excellent;
        break;
      case ConnectivityResult.mobile:
        _connectionQuality = ConnectionQuality.good;
        break;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.other:
        _connectionQuality = ConnectionQuality.poor;
        break;
      case ConnectivityResult.none:
        _connectionQuality = ConnectionQuality.offline;
        break;
      default:
        _connectionQuality = ConnectionQuality.unknown;
    }
    notifyListeners();
  }

  // Load user preferences
  Future<void> _loadUserPreferences() async {
    // Load from SharedPreferences
    // This would be implemented with actual preference loading
  }

  // Get optimal quality for current network
  VideoQuality getOptimalQuality() {
    if (_saveDataMode) {
      return qualityLevels['360p']!;
    }

    switch (_connectionQuality) {
      case ConnectionQuality.excellent:
        return qualityLevels['1080p']!;
      case ConnectionQuality.good:
        return qualityLevels['720p']!;
      case ConnectionQuality.moderate:
        return qualityLevels['480p']!;
      case ConnectionQuality.poor:
        return qualityLevels['360p']!;
      case ConnectionQuality.offline:
        return qualityLevels['240p']!;
      default:
        return qualityLevels['480p']!;
    }
  }

  // Adjust quality based on network
  void _adjustQualityForNetwork() {
    if (!_autoQuality) return;

    final optimal = getOptimalQuality();
    if (optimal != _currentQuality) {
      _currentQuality = optimal;
      notifyListeners();
    }
  }

  // Set video quality manually
  void setQuality(VideoQuality quality) {
    _currentQuality = quality;
    _autoQuality = false;
    notifyListeners();
  }

  // Toggle auto quality
  void toggleAutoQuality() {
    _autoQuality = !_autoQuality;
    if (_autoQuality) {
      _adjustQualityForNetwork();
    }
    notifyListeners();
  }

  // Toggle save data mode
  void toggleSaveDataMode() {
    _saveDataMode = !_saveDataMode;
    if (_saveDataMode) {
      _currentQuality = qualityLevels['360p']!;
    } else if (_autoQuality) {
      _adjustQualityForNetwork();
    }
    notifyListeners();
  }

  // Set playback speed
  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed.clamp(0.25, 2.0);
    notifyListeners();
  }

  // Get stream URL with quality
  String getStreamUrl(String baseUrl, VideoQuality quality) {
    // Append quality parameters to URL
    final uri = Uri.parse(baseUrl);
    final params = Map<String, String>.from(uri.queryParameters);
    params['quality'] = quality.label;
    params['bitrate'] = quality.bitrate.toString();

    return uri.replace(queryParameters: params).toString();
  }

  // Preload video for smoother playback
  Future<void> preloadVideo(String videoId, String url) async {
    if (_videoCache.containsKey(videoId)) {
      return; // Already cached
    }

    try {
      // Create a video player controller for preloading
      final controller = VideoPlayerController.network(url);
      await controller.initialize();

      _videoCache[videoId] = CachedVideo(
        controller: controller,
        cachedAt: DateTime.now(),
        size: 0, // Would calculate actual size
      );

      // Clean cache if needed
      _cleanCacheIfNeeded();
    } catch (e) {
      print('Failed to preload video: $e');
    }
  }

  // Get cached video controller
  VideoPlayerController? getCachedVideo(String videoId) {
    final cached = _videoCache[videoId];
    if (cached != null) {
      cached.lastAccessed = DateTime.now();
      return cached.controller;
    }
    return null;
  }

  // Clean cache if size exceeds limit
  void _cleanCacheIfNeeded() {
    int totalSize = 0;
    for (final cached in _videoCache.values) {
      totalSize += cached.size;
    }

    if (totalSize > _maxCacheSize) {
      // Remove least recently used videos
      final sortedEntries = _videoCache.entries.toList()
        ..sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));

      while (totalSize > _maxCacheSize * 0.8 && sortedEntries.isNotEmpty) {
        final entry = sortedEntries.removeAt(0);
        entry.value.controller.dispose();
        _videoCache.remove(entry.key);
        totalSize -= entry.value.size;
      }
    }
  }

  // Track playback statistics
  void trackPlayback(String videoId, PlaybackEvent event) {
    _playbackStats[videoId] ??= PlaybackStats(videoId: videoId);
    final stats = _playbackStats[videoId]!;

    switch (event.type) {
      case PlaybackEventType.start:
        stats.playCount++;
        stats.lastPlayed = DateTime.now();
        break;
      case PlaybackEventType.pause:
        stats.pauseCount++;
        break;
      case PlaybackEventType.resume:
        // Handle resume event
        break;
      case PlaybackEventType.seek:
        // Handle seek event
        break;
      case PlaybackEventType.buffering:
        stats.bufferingEvents++;
        stats.totalBufferingTime += event.duration ?? Duration.zero;
        break;
      case PlaybackEventType.error:
        stats.errorCount++;
        break;
      case PlaybackEventType.complete:
        stats.completions++;
        break;
      case PlaybackEventType.qualityChange:
        stats.qualityChanges++;
        break;
    }

    // Update watch time
    if (event.duration != null) {
      stats.totalWatchTime += event.duration!;
    }
  }

  // Get playback statistics for a video
  PlaybackStats? getPlaybackStats(String videoId) {
    return _playbackStats[videoId];
  }

  // Get buffering configuration
  Map<String, Duration> getBufferingConfig() {
    return {
      'buffer': _bufferDuration,
      'minBuffer': _minBufferDuration,
      'maxBuffer': _maxBufferDuration,
    };
  }

  // Set buffering configuration
  void setBufferingConfig({
    Duration? buffer,
    Duration? minBuffer,
    Duration? maxBuffer,
  }) {
    if (buffer != null) _bufferDuration = buffer;
    if (minBuffer != null) _minBufferDuration = minBuffer;
    if (maxBuffer != null) _maxBufferDuration = maxBuffer;
    notifyListeners();
  }

  // Get recommended videos to preload
  List<String> getRecommendedPreloads(
      String currentVideoId, List<String> playlist) {
    final recommendations = <String>[];

    // Find current video index
    final currentIndex = playlist.indexOf(currentVideoId);
    if (currentIndex == -1) return recommendations;

    // Preload next 2 videos
    for (int i = 1; i <= 2 && currentIndex + i < playlist.length; i++) {
      recommendations.add(playlist[currentIndex + i]);
    }

    return recommendations;
  }

  // Clean up resources
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    for (final cached in _videoCache.values) {
      cached.controller.dispose();
    }
    _videoCache.clear();
    super.dispose();
  }
}

// Video Quality Model
class VideoQuality {
  final int height;
  final int bitrate;
  final String label;

  const VideoQuality({
    required this.height,
    required this.bitrate,
    required this.label,
  });
}

// Connection Quality Enum
enum ConnectionQuality {
  excellent,
  good,
  moderate,
  poor,
  offline,
  unknown,
}

// Cached Video Model
class CachedVideo {
  final VideoPlayerController controller;
  final DateTime cachedAt;
  DateTime lastAccessed;
  final int size;

  CachedVideo({
    required this.controller,
    required this.cachedAt,
    required this.size,
  }) : lastAccessed = cachedAt;
}

// Playback Statistics Model
class PlaybackStats {
  final String videoId;
  int playCount = 0;
  int pauseCount = 0;
  int bufferingEvents = 0;
  int errorCount = 0;
  int completions = 0;
  int qualityChanges = 0;
  Duration totalWatchTime = Duration.zero;
  Duration totalBufferingTime = Duration.zero;
  DateTime? lastPlayed;

  PlaybackStats({required this.videoId});

  double get completionRate {
    if (playCount == 0) return 0;
    return completions / playCount;
  }

  double get averageBufferingTime {
    if (bufferingEvents == 0) return 0;
    return totalBufferingTime.inSeconds / bufferingEvents;
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'playCount': playCount,
      'pauseCount': pauseCount,
      'bufferingEvents': bufferingEvents,
      'errorCount': errorCount,
      'completions': completions,
      'qualityChanges': qualityChanges,
      'totalWatchTime': totalWatchTime.inSeconds,
      'totalBufferingTime': totalBufferingTime.inSeconds,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'completionRate': completionRate,
      'averageBufferingTime': averageBufferingTime,
    };
  }
}

// Playback Event Model
class PlaybackEvent {
  final PlaybackEventType type;
  final DateTime timestamp;
  final Duration? duration;
  final Map<String, dynamic>? metadata;

  PlaybackEvent({
    required this.type,
    DateTime? timestamp,
    this.duration,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
}

// Playback Event Types
enum PlaybackEventType {
  start,
  pause,
  resume,
  buffering,
  error,
  complete,
  qualityChange,
  seek,
}
