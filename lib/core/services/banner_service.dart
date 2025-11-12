// lib/core/services/banner_playback_service.dart
import 'package:dio/dio.dart';
import 'api_client.dart';

class BannerPlaybackService {
  // 👈 بيستخدم نفس الـ Dio من ApiClient
  final Dio _dio = ApiClient().dio;

  /// يرجع mp4 و/أو hls من الباك-إند
  Future<Map<String, String?>> getActiveBannerPlayback() async {
    final res = await _dio.get('/video-banner/active');

    final banner = Map<String, dynamic>.from(res.data['banner'] ?? {});
    final playback = Map<String, dynamic>.from(banner['playback'] ?? {});

    return {
      'mp4': playback['mp4']?.toString(),
      'hls': playback['hls']?.toString(),
      'title': banner['title']?.toString(),
      'subtitle': banner['subtitle']?.toString(),
    };
  }
}
