import 'package:flutter/material.dart';
import '../core/services/home_service.dart';

class HomeController extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  String? _error;

  // Home content sections
  List<Map<String, dynamic>> _sliders = [];
  List<Map<String, dynamic>> _liveNow = [];
  List<Map<String, dynamic>> _upcomingStreams = [];
  List<Map<String, dynamic>> _featuredMovies = [];
  List<Map<String, dynamic>> _trendingMovies = [];
  List<Map<String, dynamic>> _latestSeries = [];
  List<Map<String, dynamic>> _categories = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String, dynamic>> get sliders => _sliders;
  List<Map<String, dynamic>> get liveNow => _liveNow;
  List<Map<String, dynamic>> get upcomingStreams => _upcomingStreams;
  List<Map<String, dynamic>> get featuredMovies => _featuredMovies;
  List<Map<String, dynamic>> get trendingMovies => _trendingMovies;
  List<Map<String, dynamic>> get latestSeries => _latestSeries;
  List<Map<String, dynamic>> get categories => _categories;

  // For backward compatibility with existing UI
  List<Map<String, dynamic>> get trendingNow => _trendingMovies;
  List<Map<String, dynamic>> get recommended => _featuredMovies;
  List<Map<String, dynamic>> get newReleases => _latestSeries;
  List<Map<String, dynamic>> get popularSeries => _latestSeries;

  HomeController() {
    // loadData will be called from main.dart
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all home content in one request
      final homeData = await _homeService.fetchHomeContent();

      // Parse different sections
      _sliders = _homeService.getSliders(homeData);
      _liveNow = _homeService.getLiveStreams(homeData);
      _upcomingStreams = _homeService.getUpcomingStreams(homeData);
      _featuredMovies = _homeService.getFeaturedMovies(homeData);
      _trendingMovies = _homeService.getTrendingMovies(homeData);
      _latestSeries = _homeService.getLatestSeries(homeData);
      _categories = _homeService.getCategories(homeData);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async => loadData();

  void resetError() {
    _error = null;
    notifyListeners();
  }
}
