import 'package:dio/dio.dart';
import 'package:alenwan/core/services/api_client.dart';
import 'package:alenwan/models/movie_model.dart';
import 'package:alenwan/models/movie_page.dart';

class MovieService {
  final Dio _dio = ApiClient().dio;
  String get baseUrl => ApiClient().baseUrl;

  Future<List<MovieModel>> fetchMovies({bool onlyPublished = false}) async {
    try {
      final res = await _dio.get(
        '/movies',
        queryParameters: {'only_published': onlyPublished ? 1 : 0},
      );

      if (res.statusCode == 200) {
        final root = res.data;

        // Handle Laravel pagination: {"success": true, "data": {"data": [...]}}
        final List raw;
        if (root is Map && root['data'] is Map && root['data']['data'] is List) {
          raw = List.from(root['data']['data']);
        } else if (root is Map && root['data'] is List) {
          raw = List.from(root['data']);
        } else if (root is List) {
          raw = root;
        } else {
          raw = [];
        }

        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => MovieModel.fromJson(e))
            .toList();
      }
      throw Exception('فشل تحميل الأفلام: ${res.statusCode}');
    } catch (e) {
      throw Exception('خطأ أثناء تحميل الأفلام: $e');
    }
  }

  Future<MoviePage> fetchMoviesPage({
    String? nextPageUrl,
    bool onlyPublished = false,
  }) async {
    try {
      final res = await _dio.get(
        nextPageUrl ?? '/movies',
        queryParameters: nextPageUrl == null
            ? {'only_published': onlyPublished ? 1 : 0}
            : null,
      );

      if (res.statusCode == 200) {
        final root = res.data;

        // Handle Laravel pagination: {"success": true, "data": {"data": [...], "next_page_url": "..."}}
        List raw = [];
        String? nextUrl;

        if (root is Map && root['data'] is Map && root['data']['data'] is List) {
          final dataMap = root['data'] as Map;
          raw = List.from(dataMap['data']);
          nextUrl = dataMap['next_page_url'] as String?;
        } else if (root is Map && root['data'] is List) {
          raw = List.from(root['data']);
          nextUrl = root['next_page_url'] as String?;
        } else if (root is List) {
          raw = root;
        }

        final movies = raw
            .whereType<Map<String, dynamic>>()
            .map((e) => MovieModel.fromJson(e))
            .toList();

        return MoviePage(items: movies, next: nextUrl);
      }

      throw Exception('فشل تحميل الصفحة: ${res.statusCode}');
    } catch (e) {
      throw Exception('خطأ أثناء تحميل الأفلام: $e');
    }
  }

  Future<MovieModel> fetchMovieDetails(int id) async {
    try {
      final res = await _dio.get('/movies/$id');
      final data = (res.data is Map && res.data['data'] != null)
          ? res.data['data']
          : res.data;

      if (data is Map<String, dynamic>) {
        return MovieModel.fromJson(data);
      }
      throw Exception('شكل الرد غير متوقع');
    } catch (e) {
      throw Exception('خطأ أثناء تحميل تفاصيل الفيلم: $e');
    }
  }
}
