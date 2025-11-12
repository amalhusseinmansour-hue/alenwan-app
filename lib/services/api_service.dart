import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/movie.dart';
import '../config.dart';
import '../core/services/device_fingerprint_service.dart';
import '../core/services/auth_service.dart';

class ApiService {
  static String get baseUrl => AppConfig.domain;
  static String get apiUrl => AppConfig.apiBaseUrl;

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> _headersWithAuth(String token) {
    return {
      ..._headers,
      'Authorization': 'Bearer $token',
    };
  }

  // Get stored token
  static Future<String?> getToken() async {
    return await AuthService.getToken();
  }

  // Test connection to Laravel backend
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test-connection'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Authentication methods
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final deviceService = DeviceFingerprintService();
      final deviceId = await deviceService.getDeviceId();
      final deviceInfo = await deviceService.getDeviceInfo();

      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
          'device_id': deviceId,
          'device_name': deviceInfo['name'] ?? 'Unknown Device',
          'device_type': deviceInfo['type'] ?? 'mobile',
          'platform': deviceInfo['platform'] ?? 'unknown',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Login failed: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    try {
      final deviceService = DeviceFingerprintService();
      final deviceId = await deviceService.getDeviceId();
      final deviceInfo = await deviceService.getDeviceInfo();

      final response = await http.post(
        Uri.parse('$apiUrl/auth/register'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'device_id': deviceId,
          'device_name': deviceInfo['name'] ?? 'Unknown Device',
          'device_type': deviceInfo['type'] ?? 'mobile',
          'platform': deviceInfo['platform'] ?? 'unknown',
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Registration failed: $e');
      return null;
    }
  }

  static Future<User?> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/auth/me'),
        headers: _headersWithAuth(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return User.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Get current user failed: $e');
      return null;
    }
  }

  static Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/logout'),
        headers: _headersWithAuth(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Logout failed: $e');
      return false;
    }
  }

  // Movie methods
  static Future<List<Movie>> getMovies({int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/movies?page=$page&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> moviesJson = data['data'];
          return moviesJson.map((json) => Movie.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Get movies failed: $e');
      return [];
    }
  }

  static Future<List<Movie>> getFeaturedMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/movies/featured'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> moviesJson = data['data'];
          return moviesJson.map((json) => Movie.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Get featured movies failed: $e');
      return [];
    }
  }

  static Future<List<Movie>> getTrendingMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/movies/trending'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> moviesJson = data['data'];
          return moviesJson.map((json) => Movie.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Get trending movies failed: $e');
      return [];
    }
  }

  // Get movie details with related content, comments count, and favorite status
  static Future<Map<String, dynamic>?> getMovieDetails(int id, {String? token}) async {
    try {
      final headers = token != null ? _headersWithAuth(token) : _headers;

      final response = await http.get(
        Uri.parse('$apiUrl/movies/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Get movie details failed: $e');
      return null;
    }
  }

  // Legacy method - kept for backward compatibility
  static Future<Movie?> getMovie(int id) async {
    try {
      final details = await getMovieDetails(id);
      if (details != null) {
        return Movie.fromJson(details);
      }
      return null;
    } catch (e) {
      print('Get movie failed: $e');
      return null;
    }
  }

  static Future<String?> getMovieStreamingUrl(int movieId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/movies/$movieId/stream'),
        headers: _headersWithAuth(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data']['streaming_url'];
        }
      }
      return null;
    } catch (e) {
      print('Get streaming URL failed: $e');
      return null;
    }
  }

  static Future<bool> toggleMovieFavorite(int movieId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/movies/$movieId/favorite'),
        headers: _headersWithAuth(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Toggle favorite failed: $e');
      return false;
    }
  }

  // Subscription methods
  static Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/subscription/plans'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Get subscription plans failed: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getCurrentSubscription(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/subscription/current'),
        headers: _headersWithAuth(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Get current subscription failed: $e');
      return null;
    }
  }

  // Content API methods for Laravel backend
  static Future<List<dynamic>> getContentMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/content/movies'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Get content movies failed: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getContentSeries() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/content/series'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Get content series failed: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getContentLiveStreams() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/content/live-streams'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Get content live streams failed: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getContentChannels() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/content/channels'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Get content channels failed: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getContentBanners() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/content/banners'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Get content banners failed: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getContentCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/content/categories'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Get content categories failed: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> searchContent(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/content/search?q=${Uri.encodeComponent(query)}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['results'];
        }
      }
      return null;
    } catch (e) {
      print('Search content failed: $e');
      return null;
    }
  }

  // Delete Account
  static Future<bool> deleteAccount(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/auth/account'),
        headers: _headersWithAuth(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete account failed: $e');
      return false;
    }
  }

  // Generic API call method
  static Future<Map<String, dynamic>?> apiCall({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$apiUrl/$endpoint');
      final headers = token != null ? _headersWithAuth(token) : _headers;

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        print('API call failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('API call error: $e');
      return null;
    }
  }
}