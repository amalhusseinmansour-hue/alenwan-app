import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class VimeoService extends ChangeNotifier {
  static final VimeoService _instance = VimeoService._internal();
  factory VimeoService() => _instance;
  VimeoService._internal();

  final ApiClient _apiClient = ApiClient();
  final Dio _dio = Dio();

  // Cache for video configs
  final Map<String, VimeoVideoConfig> _videoConfigCache = {};

  // Watch progress tracking
  final Map<String, int> _watchProgress = {};

  // Get video configuration from Vimeo via Backend API
  Future<VimeoVideoConfig?> getVideoConfig(String vimeoId) async {
    // Check cache first
    if (_videoConfigCache.containsKey(vimeoId)) {
      print('📦 Using cached config for Vimeo ID: $vimeoId');
      return _videoConfigCache[vimeoId];
    }

    try {
      print('🎬 Fetching Vimeo config from backend for ID: $vimeoId');

      // Use backend API to get video config (supports private videos)
      final response = await _apiClient.dio.post('/vimeo/get-url', data: {
        'vimeo_id': vimeoId,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        print('✅ Successfully got Vimeo config from backend');

        // Parse qualities from backend response
        List<VideoQuality> qualities = [];
        final qualitiesData = data['qualities'] as List? ?? [];
        for (var q in qualitiesData) {
          qualities.add(VideoQuality(
            quality: q['quality'] ?? '720p',
            url: q['url'] ?? '',
            width: q['width'] ?? 0,
            height: q['height'] ?? 0,
            bitrate: q['bitrate'] ?? 0,
          ));
        }

        final config = VimeoVideoConfig(
          videoId: vimeoId,
          title: data['title'] ?? 'Untitled',
          description: data['description'],
          duration: data['duration'] ?? 0,
          thumbnail: data['thumbnail'],
          hlsUrl: data['hls_url'],
          qualities: qualities,
          canDownload: data['can_download'] ?? false,
        );

        _videoConfigCache[vimeoId] = config;
        print('📦 Cached Vimeo config for ID: $vimeoId');
        return config;
      } else {
        print('❌ Backend returned success=false');
      }
    } catch (e) {
      print('❌ Failed to get video config from backend: $e');

      // Fallback: Try direct Vimeo API (only works for public videos)
      try {
        print('🔄 Trying direct Vimeo API as fallback...');
        return await _getVideoConfigDirect(vimeoId);
      } catch (fallbackError) {
        print('❌ Fallback also failed: $fallbackError');
      }
    }

    return null;
  }

  // Fallback method: Direct Vimeo API (only works for public videos)
  Future<VimeoVideoConfig?> _getVideoConfigDirect(String vimeoId) async {
    try {
      final url = "https://player.vimeo.com/video/$vimeoId/config";
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;

        // Extract video information
        final videoInfo = data['video'] ?? {};
        final request = data['request'] ?? {};
        final files = request['files'] ?? {};

        // Get progressive MP4 URLs
        List<VideoQuality> qualities = [];
        final progressive = files['progressive'] as List? ?? [];
        for (var file in progressive) {
          qualities.add(VideoQuality(
            quality: '${file['height']}p',
            url: file['url'],
            width: file['width'] ?? 0,
            height: file['height'] ?? 0,
            bitrate: file['bitrate'] ?? 0,
          ));
        }

        // Sort by quality (highest first)
        qualities.sort((a, b) => b.height.compareTo(a.height));

        // Get HLS URL
        String? hlsUrl;
        final hls = files['hls'] ?? {};
        final cdns = hls['cdns'] ?? {};
        if (cdns.isNotEmpty) {
          final defaultCdn = hls['default_cdn'];
          if (defaultCdn != null && cdns[defaultCdn] != null) {
            hlsUrl = cdns[defaultCdn]['url'];
          } else if (cdns.values.isNotEmpty) {
            hlsUrl = (cdns.values.first as Map)['url'];
          }
        }

        // Get thumbnail
        final thumbs = request['thumb'] ?? {};
        String? thumbnail = thumbs['url'];

        final config = VimeoVideoConfig(
          videoId: vimeoId,
          title: videoInfo['title'] ?? 'Untitled',
          description: videoInfo['description'],
          duration: videoInfo['duration'] ?? 0,
          thumbnail: thumbnail,
          hlsUrl: hlsUrl,
          qualities: qualities,
          canDownload: videoInfo['allow_downloads'] ?? false,
        );

        _videoConfigCache[vimeoId] = config;
        return config;
      }
    } catch (e) {
      print('Direct Vimeo API failed: $e');
    }

    return null;
  }

  // Get video URL with backend integration
  Future<Map<String, String?>> getVideoUrl(String vimeoId) async {
    try {
      // First try to get from backend (for tracking and security)
      final response = await _apiClient.dio.post('/vimeo/get-url', data: {
        'vimeo_id': vimeoId,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'mp4Url': response.data['mp4_url'],
          'hlsUrl': response.data['hls_url'],
        };
      }
    } catch (e) {
      print('Backend fetch failed, trying direct: $e');
    }

    // Fallback to direct Vimeo API
    final config = await getVideoConfig(vimeoId);
    if (config != null) {
      return {
        'mp4Url':
            config.qualities.isNotEmpty ? config.qualities.first.url : null,
        'hlsUrl': config.hlsUrl,
      };
    }

    return {'mp4Url': null, 'hlsUrl': null};
  }

  // Get adaptive streaming URL based on connection
  Future<String?> getAdaptiveStreamUrl(String vimeoId,
      {String? preferredQuality}) async {
    final config = await getVideoConfig(vimeoId);
    if (config == null) return null;

    // If HLS is available, use it for adaptive streaming
    if (config.hlsUrl != null) {
      return config.hlsUrl;
    }

    // Otherwise, select best quality MP4
    if (config.qualities.isNotEmpty) {
      if (preferredQuality != null) {
        final quality = config.qualities.firstWhere(
          (q) => q.quality == preferredQuality,
          orElse: () => config.qualities.first,
        );
        return quality.url;
      }
      return config.qualities.first.url;
    }

    return null;
  }

  // Track video progress
  Future<void> trackProgress(
      String vimeoId, String contentId, int position, int duration) async {
    _watchProgress[vimeoId] = position;

    // Save to backend
    try {
      await _apiClient.dio.post('/user/track-progress', data: {
        'vimeo_id': vimeoId,
        'content_id': contentId,
        'position': position,
        'duration': duration,
        'percentage': (position / duration * 100).round(),
      });
    } catch (e) {
      print('Failed to track progress: $e');
    }

    notifyListeners();
  }

  // Get last watch position
  int getLastPosition(String vimeoId) {
    return _watchProgress[vimeoId] ?? 0;
  }

  // Get continue watching list
  Future<List<ContinueWatching>> getContinueWatching() async {
    try {
      final response = await _apiClient.dio.get('/user/continue-watching');

      if (response.statusCode == 200) {
        return (response.data['items'] as List)
            .map((item) => ContinueWatching.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Failed to get continue watching: $e');
    }

    return [];
  }

  // Mark as watched
  Future<void> markAsWatched(String vimeoId, String contentId) async {
    try {
      await _apiClient.dio.post('/user/mark-watched', data: {
        'vimeo_id': vimeoId,
        'content_id': contentId,
      });
    } catch (e) {
      print('Failed to mark as watched: $e');
    }
  }

  // Get video thumbnail with multiple sizes
  String getVideoThumbnail(String vimeoId, {String size = '1280x720'}) {
    // Use Vimeo thumbnail service
    return 'https://vumbnail.com/${vimeoId}_$size.jpg';
  }

  // Download video for offline viewing
  Future<bool> downloadVideo(String vimeoId, String contentId) async {
    final config = await getVideoConfig(vimeoId);
    if (config == null || !config.canDownload) {
      return false;
    }

    // Get download URL (medium quality for storage efficiency)
    String? downloadUrl;
    if (config.qualities.length > 1) {
      // Get middle quality
      final midIndex = config.qualities.length ~/ 2;
      downloadUrl = config.qualities[midIndex].url;
    } else if (config.qualities.isNotEmpty) {
      downloadUrl = config.qualities.first.url;
    }

    if (downloadUrl != null) {
      // Trigger download through download manager
      // Implementation depends on your download service
      return true;
    }

    return false;
  }

  // Clear cache
  void clearCache() {
    _videoConfigCache.clear();
    _watchProgress.clear();
  }
}

// Video configuration model
class VimeoVideoConfig {
  final String videoId;
  final String title;
  final String? description;
  final int duration;
  final String? thumbnail;
  final String? hlsUrl;
  final List<VideoQuality> qualities;
  final bool canDownload;

  VimeoVideoConfig({
    required this.videoId,
    required this.title,
    this.description,
    required this.duration,
    this.thumbnail,
    this.hlsUrl,
    required this.qualities,
    this.canDownload = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'description': description,
      'duration': duration,
      'thumbnail': thumbnail,
      'hlsUrl': hlsUrl,
      'qualities': qualities.map((q) => q.toJson()).toList(),
      'canDownload': canDownload,
    };
  }
}

// Video quality model
class VideoQuality {
  final String quality;
  final String url;
  final int width;
  final int height;
  final int bitrate;

  VideoQuality({
    required this.quality,
    required this.url,
    required this.width,
    required this.height,
    required this.bitrate,
  });

  String get label {
    if (height >= 2160) return '4K';
    if (height >= 1440) return '2K';
    if (height >= 1080) return 'Full HD';
    if (height >= 720) return 'HD';
    if (height >= 480) return 'SD';
    return '${height}p';
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'url': url,
      'width': width,
      'height': height,
      'bitrate': bitrate,
    };
  }
}

// Continue watching model
class ContinueWatching {
  final String id;
  final String contentId;
  final String vimeoId;
  final String title;
  final String? thumbnail;
  final String contentType;
  final int position;
  final int duration;
  final int percentage;
  final DateTime lastWatched;
  final Map<String, dynamic>? metadata;

  ContinueWatching({
    required this.id,
    required this.contentId,
    required this.vimeoId,
    required this.title,
    this.thumbnail,
    required this.contentType,
    required this.position,
    required this.duration,
    required this.percentage,
    required this.lastWatched,
    this.metadata,
  });

  factory ContinueWatching.fromJson(Map<String, dynamic> json) {
    return ContinueWatching(
      id: json['id'] ?? '',
      contentId: json['content_id'] ?? '',
      vimeoId: json['vimeo_id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'],
      contentType: json['content_type'] ?? 'movie',
      position: json['position'] ?? 0,
      duration: json['duration'] ?? 0,
      percentage: json['percentage'] ?? 0,
      lastWatched:
          DateTime.tryParse(json['last_watched'] ?? '') ?? DateTime.now(),
      metadata: json['metadata'],
    );
  }

  bool get isCompleted => percentage >= 90;

  String get remainingTime {
    final remaining = duration - position;
    final minutes = remaining ~/ 60;
    if (minutes > 60) {
      final hours = minutes ~/ 60;
      return '${hours}h ${minutes % 60}m left';
    }
    return '${minutes}m left';
  }
}
