// lib/core/services/home_service.dart
import 'package:dio/dio.dart';
import 'api_client.dart';

class HomeService {
  final Dio _dio = ApiClient().dio;

  /// Get all home content in one request
  /// Uses /api/home endpoint that returns sliders, live streams, movies, series, etc.
  Future<Map<String, dynamic>> fetchHomeContent({bool isGuest = false}) async {
    if (isGuest) {
      return fetchGuestHomeContent();
    }

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

  /// Fetch content for guests using specific guest endpoints
  Future<Map<String, dynamic>> fetchGuestHomeContent() async {
    try {
      print('🔵 [HomeService] Fetching guest content...');
      
      // Execute requests in parallel for better performance
      final results = await Future.wait([
        _dio.get('/guest/sliders'),
        _dio.get('/guest/movies'),
        _dio.get('/guest/series'),
        _dio.get('/guest/categories'),
      ]);

      // Helper to extract data safely
      List<dynamic> extractData(Response response) {
        if (response.data is Map && response.data['success'] == true) {
          return response.data['data'] ?? [];
        }
        return [];
      }

      final sliders = extractData(results[0]);
      final movies = extractData(results[1]);
      final series = extractData(results[2]);
      final categories = extractData(results[3]);

      print('✅ [HomeService] Guest content fetched successfully');

      // Construct a response structure similar to /home
      return {
        'sliders': sliders,
        'featured_movies': movies, // Using movies as featured
        'trending_movies': movies, // Using movies as trending for now
        'latest_series': series,
        'categories': categories,
        'live_now': [], // Live streams might not be available for guests yet
        'upcoming_streams': [],
      };
    } catch (e) {
      print('❌ [HomeService] Guest fetch error: $e');
      // Return empty structure instead of throwing to allow app to open
      return {
        'sliders': [],
        'featured_movies': [],
        'trending_movies': [],
        'latest_series': [],
        'categories': [],
        'live_now': [],
        'upcoming_streams': [],
      };
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
