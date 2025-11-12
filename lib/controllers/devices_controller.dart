import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:alenwan/core/services/api_client.dart';

class DeviceItem {
  final int id;
  final String name;
  final String platform;
  final DateTime linkedAt;

  DeviceItem({
    required this.id,
    required this.name,
    required this.platform,
    required this.linkedAt,
  });

  factory DeviceItem.fromJson(Map<String, dynamic> j) {
    int parseId(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    DateTime parseDate(dynamic v) => DateTime.tryParse('$v') ?? DateTime.now();

    return DeviceItem(
      id: parseId(j['id']),
      name: j['name']?.toString() ?? j['model']?.toString() ?? 'Unnamed device',
      platform: j['platform']?.toString() ?? j['os']?.toString() ?? '—',
      linkedAt: parseDate(j['linked_at'] ?? j['created_at']),
    );
  }
}

class DevicesController extends ChangeNotifier {
  final Dio _dio = ApiClient().dio;

  List<DeviceItem> devices = [];
  bool isLoading = false;
  String? error;

  /// ✅ جلب الأجهزة
  Future<void> load() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final res = await _dio.get('/devices');
      final list = (res.data['data'] ?? res.data ?? []) as List;
      devices = list
          .map((e) => DeviceItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      error = _prettyErr(e, fallback: 'فشل تحميل الأجهزة');
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ ربط جهاز جديد بالكود
  Future<bool> link(String code) async {
    try {
      final res = await _dio.post('/devices/link', data: {'code': code});
      if (res.data is Map && (res.data['device'] != null)) {
        devices.insert(0,
            DeviceItem.fromJson(Map<String, dynamic>.from(res.data['device'])));
      } else {
        await load(); // إعادة تحميل في حالة الرد مختلف
      }
      notifyListeners();
      return true;
    } on DioException catch (e) {
      error = _prettyErr(e, fallback: 'فشل ربط الجهاز');
      notifyListeners();
      return false;
    }
  }

  /// ✅ إعادة تسمية جهاز
  Future<bool> rename(int id, String newName) async {
    try {
      await _dio.patch('/devices/$id', data: {'name': newName});
      final i = devices.indexWhere((d) => d.id == id);
      if (i != -1) {
        devices[i] = DeviceItem(
          id: devices[i].id,
          name: newName,
          platform: devices[i].platform,
          linkedAt: devices[i].linkedAt,
        );
        notifyListeners();
      }
      return true;
    } on DioException catch (e) {
      error = _prettyErr(e, fallback: 'فشل إعادة التسمية');
      notifyListeners();
      return false;
    }
  }

  /// ✅ حذف جهاز
  Future<bool> unlink(int id) async {
    try {
      await _dio.delete('/devices/$id');
      devices.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      error = _prettyErr(e, fallback: 'فشل حذف الجهاز');
      notifyListeners();
      return false;
    }
  }

  /// 🟠 Helper: استخراج رسالة الخطأ
  String _prettyErr(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    return e.message ?? fallback;
  }
}
