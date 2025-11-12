// lib/controllers/movie_controller.dart
import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';
import '../core/services/movie_service.dart';

class MovieController extends ChangeNotifier {
  final MovieService _service = MovieService();

  final List<MovieModel> _movies = [];
  List<MovieModel> get movies => List.unmodifiable(_movies);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _error;
  String? get error => _error;

  String? _nextPageUrl;

  /// Getter موحد لحالة الإنشغال
  bool get isBusy => _isLoading || _isLoadingMore;

  MovieController() {
    loadMovies(reset: true);
  }

  Future<void> loadMovies(
      {bool reset = false, bool onlyPublished = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    if (reset) {
      _movies.clear();
      _nextPageUrl = null;
    }
    notifyListeners();

    try {
      final page = await _service.fetchMoviesPage(
        nextPageUrl: _nextPageUrl,
        onlyPublished: onlyPublished,
      );
      _mergePage(page.items);
      _nextPageUrl = page.next;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_nextPageUrl == null || _isLoadingMore) return;
    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final page = await _service.fetchMoviesPage(nextPageUrl: _nextPageUrl);
      _mergePage(page.items);
      _nextPageUrl = page.next;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// تحديث عنصر واحد (مثلاً عند فتح صفحة التفاصيل نريد playback)
  Future<MovieModel?> hydrateById(int id) async {
    try {
      final fresh = await _service.fetchMovieDetails(id);
      final idx = _movies.indexWhere((m) => m.id == id);
      if (idx >= 0) {
        _movies[idx] = fresh;
      } else {
        _movies.add(fresh);
      }
      notifyListeners();
      return fresh;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      // fallback: رجع نسخة الكاش لو موجودة
      try {
        return _movies.firstWhere((m) => m.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  /// مُساعد داخلي لدمج الصفحة بدون تكرار
  void _mergePage(List<MovieModel> items) {
    final byId = {for (final m in _movies) m.id: m};
    for (final m in items) {
      byId[m.id] = m; // آخر نسخة تطغى
    }
    _movies
      ..clear()
      ..addAll(byId.values);
  }

  /// إعادة ضبط الخطأ
  void resetError() {
    _error = null;
    notifyListeners();
  }
}
