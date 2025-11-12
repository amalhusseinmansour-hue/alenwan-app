// lib/core/services/profile_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:alenwan/core/services/api_client.dart';

class ProfileResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  ProfileResponse({required this.success, this.data, this.error});
}

class ProfileService {
  final Dio _dio = ApiClient().dio;

  /// جلب البروفايل
  Future<ProfileResponse<Map<String, dynamic>>> getProfile() async {
    try {
      final res = await _dio.get('/me');
      final body = res.data;

      // إصلاح: البيانات في body['data']['user'] وليس body['data']
      Map<String, dynamic> user;
      if (body is Map && body['data'] is Map) {
        final data = body['data'] as Map;
        // تحقق إذا كانت البيانات في data.user
        if (data.containsKey('user')) {
          user = Map<String, dynamic>.from(data['user'] as Map);
        } else {
          // إذا كانت البيانات مباشرة في data
          user = Map<String, dynamic>.from(data);
        }
      } else {
        user = Map<String, dynamic>.from(body as Map);
      }

      return ProfileResponse(success: true, data: user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return ProfileResponse(success: false, error: 'unauthorized');
      }
      return ProfileResponse(success: false, error: _handleError(e));
    } catch (e) {
      return ProfileResponse(success: false, error: e.toString());
    }
  }

  /// تحديث البروفايل (مع رفع صورة إن وجدت)
  Future<ProfileResponse<Map<String, dynamic>>> updateProfile({
    String? name,
    String? email,
    File? photoFile,
    Uint8List? photoBytes,
    String? photoFilename,
  }) async {
    try {
      final form = FormData()..fields.add(const MapEntry('_method', 'PUT'));

      if (name != null) form.fields.add(MapEntry('name', name));
      if (email != null) form.fields.add(MapEntry('email', email));

      if (photoFile != null) {
        form.files.add(MapEntry(
          'photo',
          await MultipartFile.fromFile(
            photoFile.path,
            filename: photoFilename ?? photoFile.path.split('/').last,
          ),
        ));
      } else if (photoBytes != null) {
        form.files.add(MapEntry(
          'photo',
          MultipartFile.fromBytes(photoBytes,
              filename: photoFilename ?? 'photo.jpg'),
        ));
      }

      final res = await _dio.post('/profile', data: form);

      final body = res.data;

      // إصلاح: البيانات في body['data']['user'] وليس body['data']
      Map<String, dynamic> user;
      if (body is Map && body['data'] is Map) {
        final data = body['data'] as Map;
        // تحقق إذا كانت البيانات في data.user
        if (data.containsKey('user')) {
          user = Map<String, dynamic>.from(data['user'] as Map);
        } else {
          // إذا كانت البيانات مباشرة في data
          user = Map<String, dynamic>.from(data);
        }
      } else {
        user = Map<String, dynamic>.from(body as Map);
      }

      return ProfileResponse(success: true, data: user);
    } on DioException catch (e) {
      return ProfileResponse(success: false, error: _handleError(e));
    } catch (e) {
      return ProfileResponse(success: false, error: e.toString());
    }
  }

  String _handleError(DioException e) {
    try {
      if (e.response?.data is Map &&
          (e.response!.data as Map).containsKey('errors')) {
        final map = (e.response!.data as Map)['errors'] as Map;
        if (map.values.isNotEmpty) return map.values.first.toString();
      }
      return e.response?.data?['message'] ?? e.message ?? 'فشل الاتصال بالخادم';
    } catch (_) {
      return e.message ?? 'فشل الاتصال بالخادم';
    }
  }
}
