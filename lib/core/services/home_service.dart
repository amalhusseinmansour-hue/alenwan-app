// lib/core/services/home_service.dart
import 'package:dio/dio.dart';
import 'api_client.dart';

class HomeService {
  final Dio _dio = ApiClient().dio;

  /// Get all home content in one request
  /// Uses /api/home endpoint that returns sliders, live streams, movies, series, etc.
  Future<Map<String, dynamic>> fetchHomeContent() async {
    try {
      final response = await _dio.get('/home');

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception('فشل تحميل محتوى الصفحة الرئيسية');
    } catch (e) {
      print('HomeService Error: $e');
      throw Exception('فشل تحميل محتوى الصفحة الرئيسية: $e');
    }
  }

  /// Parse sliders from home response
  List<Map<String, dynamic>> getSliders(Map<String, dynamic> homeData) {
    final sliders = homeData['sliders'];
    if (sliders is List) {
      return sliders.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Parse live streams from home response
  List<Map<String, dynamic>> getLiveStreams(Map<String, dynamic> homeData) {
    final liveNow = homeData['live_now'];
    if (liveNow is List) {
      return liveNow.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Parse upcoming streams
  List<Map<String, dynamic>> getUpcomingStreams(Map<String, dynamic> homeData) {
    final upcoming = homeData['upcoming_streams'];
    if (upcoming is List) {
      return upcoming.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Parse featured movies
  List<Map<String, dynamic>> getFeaturedMovies(Map<String, dynamic> homeData) {
    final movies = homeData['featured_movies'];
    if (movies is List) {
      return movies.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Parse trending movies
  List<Map<String, dynamic>> getTrendingMovies(Map<String, dynamic> homeData) {
    final movies = homeData['trending_movies'];
    if (movies is List) {
      return movies.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Parse latest series
  List<Map<String, dynamic>> getLatestSeries(Map<String, dynamic> homeData) {
    final series = homeData['latest_series'];
    if (series is List) {
      return series.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Parse categories
  List<Map<String, dynamic>> getCategories(Map<String, dynamic> homeData) {
    final categories = homeData['categories'];
    if (categories is List) {
      return categories.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
