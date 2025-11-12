import 'package:flutter/foundation.dart';
import 'package:alenwan/core/services/platinum_service.dart';
import '../models/media_item.dart';
import '../models/documentary_model.dart';
import '../models/sport_model.dart';
import '../models/live_stream_model.dart';

class PlatinumController with ChangeNotifier {
  final PlatinumService service;

  PlatinumController({required this.service});

  List<MediaItem> platinumMovies = [];
  List<MediaItem> platinumSeries = [];
  List<Documentary> platinumDocs = [];
  List<LiveStreamModel> platinumLive = [];
  List<MediaItem> platinumCartoons = [];
  List<SportModel> platinumSports = [];

  bool isLoading = false;
  String? error;

  // helpers
  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  Future<void> load() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final resp = await service.fetchPlatinum();

      // Movies
      platinumMovies = resp.movies
          .map<MediaItem>((m) => MediaItem(
                id: _toInt(m['id']),
                title: m['title'] ?? '',
                posterUrl: m['posterUrl'] ??
                    m['poster_url'] ??
                    m['thumbnail'] ??
                    'https://via.placeholder.com/300x450',
                imageUrl: m['imageUrl'] ??
                    m['poster_url'] ??
                    m['posterUrl'] ??
                    'https://via.placeholder.com/300x450',
                year: _toIntOrNull(m['year']),
                type: MediaType.movie,
              ))
          .toList();

      // Series
      platinumSeries = resp.series
          .map<MediaItem>((s) => MediaItem(
                id: _toInt(s['id']),
                title: s['title'] ?? '',
                posterUrl: s['posterUrl'] ??
                    s['poster_url'] ??
                    s['thumbnail'] ??
                    'https://via.placeholder.com/300x450',
                imageUrl: s['imageUrl'] ??
                    s['poster_url'] ??
                    s['posterUrl'] ??
                    'https://via.placeholder.com/300x450',
                year: _toIntOrNull(s['year']),
                type: MediaType.series,
              ))
          .toList();

      // Documentaries
      platinumDocs = resp.documentaries
          .map<Documentary>((d) => Documentary(
                id: _toInt(d['id']),
                title: d['title'] ?? '',
                description: d['description'] ?? '',
                posterPath: d['poster_path'] ?? d['posterPath'] ?? '',
                bannerPath: d['banner_path'] ?? d['bannerPath'] ?? '',
                videoPath: d['video_path'] ?? d['videoPath'] ?? '',
                isPublished: d['is_published'] == true || d['is_published'] == 1,
                isPremium: d['is_premium'] == true || d['is_premium'] == 1,
                isFeatured: d['is_featured'] == true || d['is_featured'] == 1,
                releaseYear: _toInt(d['release_year'] ?? d['year']),
                rating: (d['rating'] is String)
                    ? (double.tryParse(d['rating']) ?? 0.0)
                    : (d['rating'] ?? 0.0),
                type: d['type']?.toString(),
                presenter: d['presenter']?.toString(),
                guest: d['guest']?.toString(),
                producer: d['producer']?.toString(),
                director: d['director']?.toString(),
                narrator: d['narrator']?.toString(),
                intro: d['intro']?.toString(),
                subscriptionTier: 'platinum',
              ))
          .toList();

      // Live
      platinumLive = resp.liveStreams
          .map<LiveStreamModel>((l) => LiveStreamModel(
                id: _toInt(l['id']),
                title: l['title'] ?? '',
                thumbnail: l['thumbnail'] ?? l['posterUrl'] ?? l['imageUrl'],
                videoUrl: l['video_url'],
                streamUrl: l['stream_url'] ?? '',
                channelName: l['channel_name'] ?? '',
                sourceType: l['source_type'] ?? 'wirestream',
                startsAt: l['starts_at'] ?? '',
                isPaid:
                    (l['is_paid'] is bool) ? l['is_paid'] : (l['is_paid'] == 1),
                viewersCount: _toInt(l['viewers_count']),
                description: '',
              ))
          .toList();

      // Cartoons
      platinumCartoons = resp.cartoons
          .map<MediaItem>((c) => MediaItem(
                id: _toInt(c['id']),
                title: c['title'] ?? '',
                posterUrl: c['posterUrl'] ??
                    c['poster_url'] ??
                    c['thumbnail'] ??
                    'https://via.placeholder.com/300x450',
                imageUrl: c['imageUrl'] ??
                    c['poster_url'] ??
                    c['posterUrl'] ??
                    'https://via.placeholder.com/300x450',
                year: _toIntOrNull(c['year']),
                type: MediaType.cartoon,
              ))
          .toList();

      // Sports
      platinumSports = resp.sports
          .map<SportModel>((sp) => SportModel(
                id: _toInt(sp['id']),
                title: sp['title'] ?? '',
                description: sp['description'],
                posterUrl:
                    sp['poster_url'] ?? sp['posterUrl'] ?? sp['posterUrl'],
                bannerUrl: sp['banner_url'] ?? sp['bannerUrl'],
                videoUrl: sp['video_url'] ?? sp['videoUrl'],
                status: sp['status'] ?? 'upcoming',
                languageId: _toInt(sp['language_id'] ?? sp['languageId'] ?? 1),
                releaseYear: _toIntOrNull(sp['release_year']),
                rating: (sp['rating'] is String)
                    ? double.tryParse(sp['rating'])
                    : sp['rating'],
                categoryId: _toInt(sp['category_id'] ?? sp['categoryId'] ?? 0),
              ))
          .toList();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
