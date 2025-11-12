// lib/controllers/search_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:dio/dio.dart';
import '../models/search_hit.dart';
import '../core/services/api_client.dart'; // 👈 نستعمل ApiClient
import '../widgets/advanced_search_filters.dart';

class AppSearchController extends ChangeNotifier {
  final String? Function()? tokenProvider;

  AppSearchController({this.tokenProvider});

  Dio get _dio => ApiClient().dio; // 👈 نستعمل نفس الـ client

  String _query = '';
  String get query => _query;

  String? _error;
  String? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SearchHit> _results = [];
  List<SearchHit> get results => _results;
  bool get hasResults => _results.isNotEmpty;
  bool get hasQuery => _query.trim().isNotEmpty;

  Timer? _debounce;

  /// ضبط قيمة البحث مع الـ debounce
  void setQuery(String v) {
    _query = v;
    _debounce?.cancel();

    if (_query.trim().isEmpty) {
      _results = [];
      _error = null;
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () => search());
    notifyListeners();
  }

  /// ضبط قيمة البحث مع الفلاتر والـ debounce
  void setQueryWithFilters(String v, SearchFilters filters) {
    _query = v;
    _debounce?.cancel();

    if (_query.trim().isEmpty) {
      _results = [];
      _error = null;
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () => searchWithFilters(filters));
    notifyListeners();
  }

  /// تنفيذ البحث
  Future<void> search() async {
    await searchWithFilters(const SearchFilters());
  }

  /// تنفيذ البحث مع الفلاتر
  Future<void> searchWithFilters(SearchFilters filters) async {
    if (_query.trim().isEmpty) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // إضافة الـ Bearer token إذا موجود
      final token = tokenProvider?.call();
      if (token != null && token.isNotEmpty) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      } else {
        _dio.options.headers.remove('Authorization');
      }

      // Build query parameters with filters
      final queryParams = <String, dynamic>{
        'q': _query,
      };

      // Add filter parameters if they're not empty/default
      final filterData = filters.toJson();
      filterData.forEach((key, value) {
        if (value != null && _isFilterValueSignificant(key, value)) {
          queryParams[key] = value;
        }
      });

      final res = await _dio.get(
        '/search',
        queryParameters: queryParams,
      );

      final raw = res.data;

      // Handle the actual API response structure:
      // {"success": true, "query": "...", "data": {"movies": [], "series": [], "live_streams": []}}
      final List<SearchHit> combinedResults = [];

      if (raw is Map && raw['data'] is Map) {
        final data = raw['data'] as Map<String, dynamic>;

        // Extract movies
        if (data['movies'] is List) {
          for (var item in data['movies']) {
            if (item is Map) {
              final hit = SearchHit.fromJson({
                ...Map<String, dynamic>.from(item),
                'type': 'movie',
              });
              combinedResults.add(hit);
            }
          }
        }

        // Extract series
        if (data['series'] is List) {
          for (var item in data['series']) {
            if (item is Map) {
              final hit = SearchHit.fromJson({
                ...Map<String, dynamic>.from(item),
                'type': 'series',
              });
              combinedResults.add(hit);
            }
          }
        }

        // Extract live_streams
        if (data['live_streams'] is List) {
          for (var item in data['live_streams']) {
            if (item is Map) {
              final hit = SearchHit.fromJson({
                ...Map<String, dynamic>.from(item),
                'type': 'livestream',
              });
              combinedResults.add(hit);
            }
          }
        }

        // Extract documentaries if exists
        if (data['documentaries'] is List) {
          for (var item in data['documentaries']) {
            if (item is Map) {
              final hit = SearchHit.fromJson({
                ...Map<String, dynamic>.from(item),
                'type': 'documentary',
              });
              combinedResults.add(hit);
            }
          }
        }

        // Extract cartoons if exists
        if (data['cartoons'] is List) {
          for (var item in data['cartoons']) {
            if (item is Map) {
              final hit = SearchHit.fromJson({
                ...Map<String, dynamic>.from(item),
                'type': 'cartoon',
              });
              combinedResults.add(hit);
            }
          }
        }

        // Extract sports if exists
        if (data['sports'] is List) {
          for (var item in data['sports']) {
            if (item is Map) {
              final hit = SearchHit.fromJson({
                ...Map<String, dynamic>.from(item),
                'type': 'sport',
              });
              combinedResults.add(hit);
            }
          }
        }
      } else if (raw is Map && raw['results'] is List) {
        // Fallback: handle old API format if it exists
        final list = raw['results'] as List;
        combinedResults.addAll(
          list.map((e) => SearchHit.fromJson(Map<String, dynamic>.from(e)))
        );
      }

      _results = combinedResults;

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _isLoading = false;
      _error = e.response?.statusCode == 401
          ? 'Unauthenticated'
          : e.message ?? 'Network error';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Check if filter value is significant (not default)
  bool _isFilterValueSignificant(String key, dynamic value) {
    switch (key) {
      case 'categories':
      case 'genres':
        return value is List && value.isNotEmpty;
      case 'year_from':
        return value != 1990;
      case 'year_to':
        return value != 2024;
      case 'min_rating':
        return value > 0;
      case 'duration_from':
        return value > 0;
      case 'duration_to':
        return value < 300;
      case 'language':
        return value != null && value.toString().isNotEmpty;
      case 'sort_by':
        return value != 'latest';
      default:
        return true;
    }
  }

  void clearSearch() {
    _query = '';
    _results = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
