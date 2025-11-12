import 'package:dio/dio.dart';
import 'api_client.dart';

class SliderService {
  final Dio _dio = ApiClient().dio;

  /// Get all active sliders from API
  Future<List<Map<String, dynamic>>> getSliders() async {
    try {
      print('🎬 Fetching sliders from API...');
      final res = await _dio.get('/sliders?locale=ar');

      print('📡 Sliders API Response: ${res.data}');

      if (res.data['success'] == true && res.data['data'] is List) {
        final sliders = List<Map<String, dynamic>>.from(res.data['data']);
        print('✅ Got ${sliders.length} sliders');

        // Log first slider details
        if (sliders.isNotEmpty) {
          final first = sliders[0];
          print('📸 First slider:');
          print('  - Title: ${first['title']}');
          print('  - Image: ${first['image']}');
          print('  - URL: ${first['url']}');
          print('  - Video URL: ${first['video_url']}');
        }

        return sliders;
      }

      print('❌ API returned success=false or invalid data');
      return [];
    } catch (e) {
      print('❌ Error fetching sliders: $e');
      return [];
    }
  }

  /// Get active banner/slider for hero section
  Future<Map<String, String?>> getActiveBannerFromSlider() async {
    try {
      final sliders = await getSliders();

      if (sliders.isEmpty) {
        return {
          'image': null,
          'url': null,
          'title': null,
        };
      }

      // Get first active slider
      final slider = sliders.first;

      return {
        'image': slider['image']?.toString(),
        'url': slider['url']?.toString(),
        'title': slider['title']?.toString(),
      };
    } catch (e) {
      print('Error getting active banner: $e');
      return {
        'image': null,
        'url': null,
        'title': null,
      };
    }
  }
}
