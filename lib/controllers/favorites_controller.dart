// lib/controllers/favorites_controller.dart
import 'dart:convert';
import 'package:alenwan/core/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مفاتيح التخزين المحلي
const String _kCacheKey = 'favorites_cache_v1';
const String _kPendingKey = 'favorites_pending_v1';
const String _kTokenKey = 'token';

class FavoriteItem {
  final int id; // media_id
  final String type; // movie|series|documentary|sport|cartoon|livestream
  final String title;
  final String image; // full url

  FavoriteItem({
    required this.id,
    required this.type,
    required this.title,
    required this.image,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> j) {
    final idStr = (j['media_id'] ?? j['id']).toString();
    return FavoriteItem(
      id: int.tryParse(idStr) ?? 0,
      type: (j['media_type'] ?? j['type'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      image: (j['image'] ?? j['image_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'media_id': id,
    'media_type': type,
    'title': title,
    'image': image,
  };
}

class FavoritesController extends ChangeNotifier {
  final Dio _dio;
  FavoritesController([Dio? dio]) : _dio = dio ?? ApiClient().dio;

  String? _token;
  int? _uid; // ✅ ربط بالمستخدم

  final List<FavoriteItem> _items = [];
  bool isLoading = false;
  String? error;

  // ✅ مفاتيح كاش/طوابير خاصّة بالمستخدم
  String get _cacheKey => '${_kCacheKey}_${_uid ?? 'guest'}';
  String get _pendingKey => '${_kPendingKey}_${_uid ?? 'guest'}';

  List<FavoriteItem> get items => List.unmodifiable(_items);

  Options get _auth => Options(
    headers: {
      'Accept': 'application/json',
      if (_token != null && _token!.isNotEmpty)
        'Authorization': 'Bearer $_token',
    },
  );

  /// ✅ استدعها من الـ Provider لربط الهوية (token + userId)
  Future<void> setAuth({String? token, int? userId, bool load = true}) async {
    _token = token;
    _uid = userId;

    final sp = await SharedPreferences.getInstance();

    if (_token != null && _token!.isNotEmpty) {
      await sp.setString(_kTokenKey, _token!);
      if (_uid != null) await sp.setInt('user_id', _uid!);

      // حمّل الكاش الخاص بهذا المستخدم ثم اطلب من API
      await _hydrateFromCache();
      if (load) await loadFavorites();
    } else {
      // تسجيل خروج: نظّف كل شيء خاص بالمستخدم السابق
      await sp.remove(_kTokenKey);
      await sp.remove('user_id');
      await sp.remove(_cacheKey);
      await sp.remove(_pendingKey);
      _items.clear();
      notifyListeners();
    }
  }

  Future<void> _ensureIdentity() async {
    if (_token != null && _uid != null) return;
    final sp = await SharedPreferences.getInstance();
    _token = _token ?? sp.getString(_kTokenKey);
    _uid = _uid ?? sp.getInt('user_id');
  }

  /// حمّل المفضلات من الكاش المحلي (الخاصة بالمستخدم)
  Future<void> _hydrateFromCache() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      _items.clear();
      notifyListeners();
      return;
    }
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => FavoriteItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _items
        ..clear()
        ..addAll(list);
      notifyListeners();
    } catch (e) {
      debugPrint("Favorites _hydrateFromCache error: $e");
    }
  }

  /// احفظ القائمة في الكاش المحلي (الخاصة بالمستخدم)
  Future<void> _saveCache() async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
    await sp.setString(_cacheKey, raw);
  }

  // طوابير مؤجلة خاصة بالمستخدم
  Future<List<Map<String, dynamic>>> _readPending() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_pendingKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writePending(List<Map<String, dynamic>> ops) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_pendingKey, jsonEncode(ops));
  }

  Future<void> _enqueuePending(Map<String, dynamic> op) async {
    final ops = await _readPending();
    ops.add(op);
    await _writePending(ops);
  }

  /// مزامنة المؤجل
  Future<void> syncPending() async {
    await _ensureIdentity();
    if (_token == null || _token!.isEmpty) return;

    final ops = await _readPending();
    if (ops.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    for (final op in ops) {
      try {
        if (op['op'] == 'add') {
          await _dio.post(
            '/favorites',
            data: {
              'media_id': op['media_id'],
              'media_type': op['media_type'],
            },
            options: _auth,
          );
        } else if (op['op'] == 'remove') {
          await _dio.delete(
            '/favorites',
            data: {
              'media_id': op['media_id'],
              'media_type': op['media_type'],
            },
            options: _auth,
          );
        }
      } catch (e) {
        debugPrint("Favorites syncPending failed: $e");
        remaining.add(op);
      }
    }
    await _writePending(remaining);
  }

  /// تحميل من API (للمستخدم الحالي فقط)
  Future<void> loadFavorites() async {
    await _ensureIdentity();
    if (_token == null || _token!.isEmpty) {
      if (_items.isNotEmpty) {
        _items.clear();
        notifyListeners();
      }
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await _dio.get(
        // ⚠️ بدون /api — الـ baseUrl عادة ينتهي بـ /api
        '/favorites',
        options: _auth,
      );

      final data = (res.data is List)
          ? (res.data as List)
          : (res.data['data'] as List? ?? const []);

      _items
        ..clear()
        ..addAll(
          data.map((e) => FavoriteItem.fromJson(e as Map<String, dynamic>)),
        );

      await _saveCache();
      await syncPending();
    } catch (e) {
      error = 'فشل تحميل المفضلات (يُستخدم الكاش الخاص بك)';
      debugPrint("Favorites loadFavorites error: $e");
      // نُبقي ما في الكاش
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(int id, String type) =>
      _items.any((e) => e.id == id && e.type == type);

  Future<void> toggle({
    required int id,
    required String type,
    required String title,
    required String image,
  }) async {
    await _ensureIdentity();
    if (_token == null || _token!.isEmpty) {
      // ممكن تعرض SnackBar برا الشاشة لو حبيت
      return;
    }

    final exists = isFavorite(id, type);

    // تعديل تفاؤلي
    if (exists) {
      _items.removeWhere((e) => e.id == id && e.type == type);
    } else {
      _items.add(FavoriteItem(id: id, type: type, title: title, image: image));
    }
    await _saveCache();
    notifyListeners();

    try {
      // Use toggle endpoint from new API
      await _dio.post(
        '/favorites/toggle',
        data: {
          'media_id': id,
          'media_type': type,
        },
        options: _auth,
      );
    } catch (e) {
      debugPrint("Favorites toggle failed: $e");
      // لو فشل الاتصال: خزّن العملية مؤجلة للمزامنة لاحقًا
      await _enqueuePending(
        exists
            ? {'op': 'remove', 'media_id': id, 'media_type': type}
            : {
                'op': 'add',
                'media_id': id,
                'media_type': type,
                'title': title,
                'image': image,
              },
      );
    }
  }
}
