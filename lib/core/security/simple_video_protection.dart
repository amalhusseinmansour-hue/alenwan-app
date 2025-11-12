import 'dart:io';
import 'package:screen_protector/screen_protector.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart'; // Temporarily disabled
import 'package:device_info_plus/device_info_plus.dart';
import '../services/api_client.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SimpleVideoProtection {
  static final SimpleVideoProtection _instance =
      SimpleVideoProtection._internal();
  factory SimpleVideoProtection() => _instance;
  SimpleVideoProtection._internal();

  bool _isProtected = false;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Enable all protection features
  Future<void> enableProtection() async {
    if (_isProtected) return;

    try {
      if (Platform.isAndroid) {
        // Prevent screenshots and screen recording on Android
        // await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE); // Temporarily disabled

        // Additional Android protection
        // await FlutterWindowManager.addFlags(
        //     FlutterWindowManager.FLAG_KEEP_SCREEN_ON); // Temporarily disabled
      } else if (Platform.isIOS) {
        // Enable iOS protection
        await ScreenProtector.preventScreenshotOn();

        // Detect screen recording on iOS
        ScreenProtector.addListener(() {
          print('Screen recording detected on iOS!');
          _handleViolation();
        }, (isCaptured) {
          if (isCaptured) {
            print('Screen capture detected on iOS!');
            _handleViolation();
          }
        });
      }

      _isProtected = true;
      print('✅ Video protection enabled');
    } catch (e) {
      print('❌ Failed to enable protection: $e');
    }
  }

  // Disable protection when leaving video player
  Future<void> disableProtection() async {
    if (!_isProtected) return;

    try {
      if (Platform.isAndroid) {
        // await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE); // Temporarily disabled
        // await FlutterWindowManager.clearFlags(
        //     FlutterWindowManager.FLAG_KEEP_SCREEN_ON); // Temporarily disabled
      } else if (Platform.isIOS) {
        await ScreenProtector.preventScreenshotOff();
      }

      _isProtected = false;
      print('✅ Video protection disabled');
    } catch (e) {
      print('❌ Failed to disable protection: $e');
    }
  }

  // Get device fingerprint for tracking
  Future<String> getDeviceFingerprint() async {
    try {
      String deviceId = '';
      String model = '';

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        model = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
        model = iosInfo.model;
      }

      final fingerprint = '$deviceId|$model';
      final bytes = utf8.encode(fingerprint);
      final digest = sha256.convert(bytes);

      return digest.toString().substring(0, 16);
    } catch (e) {
      return 'unknown';
    }
  }

  // Get secure video URL from your Laravel backend
  Future<String?> getSecureVideoUrl(int videoId) async {
    try {
      final deviceFingerprint = await getDeviceFingerprint();

      final response =
          await ApiClient().dio.post('/video/secure-stream', data: {
        'video_id': videoId,
        'device_id': deviceFingerprint,
        'platform': Platform.operatingSystem,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      if (response.statusCode == 200) {
        final url = response.data['url'];
        final token = response.data['token'];

        // Add token to URL
        return '$url?token=$token&device=$deviceFingerprint';
      }
    } catch (e) {
      print('Failed to get secure URL: $e');
    }
    return null;
  }

  // Report violation to your Laravel backend
  Future<void> _handleViolation() async {
    try {
      final deviceFingerprint = await getDeviceFingerprint();

      await ApiClient().dio.post('/security/report-violation', data: {
        'type': 'screen_recording',
        'device_id': deviceFingerprint,
        'platform': Platform.operatingSystem,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Failed to report violation: $e');
    }
  }

  // Check if protection is active
  bool get isProtected => _isProtected;
}
