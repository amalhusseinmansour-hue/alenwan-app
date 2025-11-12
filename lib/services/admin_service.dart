import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../config.dart';

class AdminService {
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

  // ============= Dashboard Statistics =============

  static Future<Map<String, dynamic>?> getDashboardStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/v1/admin/dashboard/stats'),
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
      print('Get dashboard stats failed: $e');
      return null;
    }
  }

  // ============= Users Management =============

  static Future<Map<String, dynamic>?> getUsers({
    required String token,
    int page = 1,
    String search = '',
    Map<String, dynamic>? filters,
  }) async {
    try {
      var uri = Uri.parse('$apiUrl/v1/admin/users');

      final queryParams = {
        'page': page.toString(),
        if (search.isNotEmpty) 'search': search,
        if (filters != null) ...filters.map((k, v) => MapEntry(k, v.toString())),
      };

      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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
      print('Get users failed: $e');
      return null;
    }
  }

  static Future<bool> updateUser({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/v1/admin/users/$id'),
        headers: _headersWithAuth(token),
        body: json.encode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update user failed: $e');
      return false;
    }
  }

  static Future<bool> deleteUser({
    required String token,
    required int id,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/v1/admin/users/$id'),
        headers: _headersWithAuth(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete user failed: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserDetails({
    required String token,
    required int id,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/v1/admin/users/$id'),
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
      print('Get user details failed: $e');
      return null;
    }
  }

  // ============= Subscriptions Management =============

  static Future<Map<String, dynamic>?> getSubscriptions({
    required String token,
    int page = 1,
    Map<String, dynamic>? filters,
  }) async {
    try {
      var uri = Uri.parse('$apiUrl/v1/admin/subscriptions');

      final queryParams = {
        'page': page.toString(),
        if (filters != null) ...filters.map((k, v) => MapEntry(k, v.toString())),
      };

      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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
      print('Get subscriptions failed: $e');
      return null;
    }
  }

  static Future<bool> updateSubscription({
    required String token,
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/v1/admin/subscriptions/$userId'),
        headers: _headersWithAuth(token),
        body: json.encode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update subscription failed: $e');
      return false;
    }
  }

  // ============= Payments Management =============

  static Future<Map<String, dynamic>?> getPayments({
    required String token,
    int page = 1,
    Map<String, dynamic>? filters,
  }) async {
    try {
      var uri = Uri.parse('$apiUrl/v1/admin/payments');

      final queryParams = {
        'page': page.toString(),
        if (filters != null) ...filters.map((k, v) => MapEntry(k, v.toString())),
      };

      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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
      print('Get payments failed: $e');
      return null;
    }
  }

  // ============= Revenue Reports =============

  static Future<Map<String, dynamic>?> getRevenueReport({
    required String token,
    String? startDate,
    String? endDate,
    String period = 'monthly', // monthly, yearly
  }) async {
    try {
      var uri = Uri.parse('$apiUrl/v1/admin/revenue/report');

      final queryParams = {
        'period': period,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };

      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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
      print('Get revenue report failed: $e');
      return null;
    }
  }

  // ============= Content Management =============

  static Future<Map<String, dynamic>?> getContent({
    required String token,
    int page = 1,
    String type = 'all', // all, movie, series
    String search = '',
    Map<String, dynamic>? filters,
  }) async {
    try {
      var uri = Uri.parse('$apiUrl/v1/admin/content');

      final queryParams = {
        'page': page.toString(),
        'type': type,
        if (search.isNotEmpty) 'search': search,
        if (filters != null) ...filters.map((k, v) => MapEntry(k, v.toString())),
      };

      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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
      print('Get content failed: $e');
      return null;
    }
  }

  // ============= Movies Management =============

  static Future<Map<String, dynamic>?> createMovie({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/v1/admin/movies'),
        headers: _headersWithAuth(token),
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['data'];
        }
      }
      return null;
    } catch (e) {
      print('Create movie failed: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateMovie({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/v1/admin/movies/$id'),
        headers: _headersWithAuth(token),
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['data'];
        }
      }
      return null;
    } catch (e) {
      print('Update movie failed: $e');
      return null;
    }
  }

  static Future<bool> deleteMovie({
    required String token,
    required int id,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/v1/admin/movies/$id'),
        headers: _headersWithAuth(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete movie failed: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getMovieDetails({
    required String token,
    required int id,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/v1/admin/movies/$id'),
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
      print('Get movie details failed: $e');
      return null;
    }
  }

  // ============= Series Management =============

  static Future<Map<String, dynamic>?> createSeries({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/v1/admin/series'),
        headers: _headersWithAuth(token),
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['data'];
        }
      }
      return null;
    } catch (e) {
      print('Create series failed: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateSeries({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/v1/admin/series/$id'),
        headers: _headersWithAuth(token),
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['data'];
        }
      }
      return null;
    } catch (e) {
      print('Update series failed: $e');
      return null;
    }
  }

  static Future<bool> deleteSeries({
    required String token,
    required int id,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/v1/admin/series/$id'),
        headers: _headersWithAuth(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete series failed: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getSeriesDetails({
    required String token,
    required int id,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/v1/admin/series/$id'),
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
      print('Get series details failed: $e');
      return null;
    }
  }

  // ============= Media Upload =============

  static Future<Map<String, dynamic>?> uploadMedia({
    required String token,
    required String filePath,
    required String type, // image, video, poster, thumbnail
  }) async {
    try {
      final dio = Dio();

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'type': type,
      });

      final response = await dio.post(
        '$apiUrl/v1/admin/media/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Upload media failed: $e');
      return null;
    }
  }

  // ============= Episodes Management (for Series) =============

  static Future<Map<String, dynamic>?> createEpisode({
    required String token,
    required int seriesId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/v1/admin/series/$seriesId/episodes'),
        headers: _headersWithAuth(token),
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['data'];
        }
      }
      return null;
    } catch (e) {
      print('Create episode failed: $e');
      return null;
    }
  }

  static Future<bool> updateEpisode({
    required String token,
    required int seriesId,
    required int episodeId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/v1/admin/series/$seriesId/episodes/$episodeId'),
        headers: _headersWithAuth(token),
        body: json.encode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update episode failed: $e');
      return false;
    }
  }

  static Future<bool> deleteEpisode({
    required String token,
    required int seriesId,
    required int episodeId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/v1/admin/series/$seriesId/episodes/$episodeId'),
        headers: _headersWithAuth(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete episode failed: $e');
      return false;
    }
  }

  // ============= Export Data =============

  static Future<String?> exportPaymentsCSV({
    required String token,
    Map<String, dynamic>? filters,
  }) async {
    try {
      var uri = Uri.parse('$apiUrl/v1/admin/payments/export/csv');

      if (filters != null) {
        final queryParams = filters.map((k, v) => MapEntry(k, v.toString()));
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: _headersWithAuth(token),
      );

      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      print('Export payments CSV failed: $e');
      return null;
    }
  }
}
