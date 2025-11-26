import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screen_protector/screen_protector.dart';
import '../services/api_client.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class VideoProtectionService {
  static final VideoProtectionService _instance =
      VideoProtectionService._internal();
  factory VideoProtectionService() => _instance;
  VideoProtectionService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  Timer? _heartbeatTimer;
  String? _currentSessionId;
  String? _currentVideoId;

  // Initialize video protection
  Future<void> initialize() async {
    // Skip video protection on web platform
    if (kIsWeb) {
      print('⚠️ Video protection is not available on web platform');
      return;
    }

    await _enableScreenshotProtection();
    await _enableScreenRecordingProtection();
    _startHeartbeat();
  }

  // Enable screenshot protection
  Future<void> _enableScreenshotProtection() async {
    try {
      // Prevent screenshots on both Android and iOS using screen_protector
      await ScreenProtector.preventScreenshotOn();
      print('✅ Screenshot protection enabled');
    } catch (e) {
      print('❌ Failed to enable screenshot protection: $e');
    }
  }

  // Enable screen recording protection
  Future<void> _enableScreenRecordingProtection() async {
    if (Platform.isIOS) {
      try {
        // Detect screen recording on iOS
        ScreenProtector.addListener(() {
          _onScreenRecordingDetected();
        }, (isCaptured) {
          if (isCaptured) {
            _onScreenRecordingDetected();
          }
        });
      } catch (e) {
        print('Failed to setup recording detection: $e');
      }
    } else if (Platform.isAndroid) {
      // Android screen recording detection
      _detectAndroidScreenRecording();
    }
  }

  // Detect Android screen recording
  void _detectAndroidScreenRecording() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentVideoId != null) {
        _checkForScreenRecordingApps();
      }
    });
  }

  // Check for known screen recording apps
  Future<void> _checkForScreenRecordingApps() async {
    if (!Platform.isAndroid) return;

    try {
      // List of known screen recording package names
      final screenRecordingApps = [
        'com.duapps.recorder',
        'com.hecorat.screenrecorder',
        'com.mobzapp.screenrecorder',
        'com.nll.screenrecorder',
        'com.kimcy929.screenrecorder',
        'com.icecoldapps.screenrecorderpr',
        'com.blogspot.byterevapps.lollipopscreenrecorder',
        'com.az.screen.recorder',
        'com.xiaomi.screenrecorder',
      ];

      // Check if any recording app is running
      // This would require platform channel implementation
      for (final app in screenRecordingApps) {
        final isRunning = await _isAppRunning(app);
        if (isRunning) {
          _onScreenRecordingDetected();
          break;
        }
      }
    } catch (e) {
      print('Error checking for recording apps: $e');
    }
  }

  // Check if app is running (requires platform channel)
  Future<bool> _isAppRunning(String packageName) async {
    // This would require native Android implementation
    // For now, returning false
    return false;
  }

  // Handle screen recording detection
  void _onScreenRecordingDetected() {
    print('⚠️ Screen recording detected!');

    // Stop video playback
    _stopVideoPlayback();

    // Report to server
    _reportSecurityViolation('screen_recording');

    // Show warning to user
    _showSecurityWarning();
  }

  // Generate secure video URL with token
  Future<String> getSecureVideoUrl(String videoId, String originalUrl) async {
    // On web, return original URL (no platform-specific protection)
    if (kIsWeb) {
      print('🌐 Using original video URL on web platform');
      return originalUrl;
    }

    try {
      // Get device fingerprint
      final deviceFingerprint = await _getDeviceFingerprint();

      // Generate session ID
      _currentSessionId = _generateSessionId();
      _currentVideoId = videoId;

      // Request secure URL from backend
      final response = await ApiClient().dio.post('/video/secure-url', data: {
        'video_id': videoId,
        'device_fingerprint': deviceFingerprint,
        'session_id': _currentSessionId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      final secureUrl = response.data['secure_url'];
      final token = response.data['token'];
      final expiresAt = response.data['expires_at'];

      // Start heartbeat to maintain session
      _startHeartbeat();

      // Return secure HLS URL with token
      return '$secureUrl?token=$token&expires=$expiresAt&session=$_currentSessionId';
    } catch (e) {
      print('Failed to get secure URL: $e');
      return originalUrl; // Fallback to original
    }
  }

  // Get unique device fingerprint
  Future<String> _getDeviceFingerprint() async {
    // On web, return web-based fingerprint
    if (kIsWeb) {
      try {
        final webInfo = await _deviceInfo.webBrowserInfo;
        final fingerprint = '${webInfo.userAgent}|${webInfo.browserName}';
        final bytes = utf8.encode(fingerprint);
        final digest = sha256.convert(bytes);
        return digest.toString();
      } catch (e) {
        return 'web-unknown';
      }
    }

    try {
      String deviceId = '';
      String model = '';
      String os = '';

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        model = androidInfo.model;
        os = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        model = iosInfo.model;
        os = 'iOS ${iosInfo.systemVersion}';
      }

      // Create fingerprint hash
      final fingerprint = '$deviceId|$model|$os';
      final bytes = utf8.encode(fingerprint);
      final digest = sha256.convert(bytes);

      return digest.toString();
    } catch (e) {
      print('Failed to generate device fingerprint: $e');
      return 'unknown';
    }
  }

  // Generate unique session ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    final sessionString = '$timestamp|$random';
    final bytes = utf8.encode(sessionString);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 32);
  }

  // Start heartbeat to maintain session
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentSessionId != null && _currentVideoId != null) {
        _sendHeartbeat();
      }
    });
  }

  // Send heartbeat to server
  Future<void> _sendHeartbeat() async {
    if (_currentSessionId == null || _currentVideoId == null) return;

    try {
      await ApiClient().dio.post('/video/heartbeat', data: {
        'session_id': _currentSessionId,
        'video_id': _currentVideoId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Heartbeat failed: $e');
    }
  }

  // Report security violation to server
  Future<void> _reportSecurityViolation(String violationType) async {
    try {
      final deviceFingerprint = await _getDeviceFingerprint();

      await ApiClient().dio.post('/security/violation', data: {
        'type': violationType,
        'session_id': _currentSessionId,
        'video_id': _currentVideoId,
        'device_fingerprint': deviceFingerprint,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Failed to report violation: $e');
    }
  }

  // Stop video playback
  void _stopVideoPlayback() {
    // This would trigger video player to stop
    // Implement based on your video player
    _currentVideoId = null;
  }

  // Show security warning to user
  void _showSecurityWarning() {
    // This would show a dialog or notification
    // Implement based on your UI requirements
  }

  // Clean up session when video ends
  Future<void> endVideoSession() async {
    if (_currentSessionId != null && _currentVideoId != null) {
      try {
        await ApiClient().dio.post('/video/end-session', data: {
          'session_id': _currentSessionId,
          'video_id': _currentVideoId,
        });
      } catch (e) {
        print('Failed to end session: $e');
      }
    }

    _currentSessionId = null;
    _currentVideoId = null;
    _heartbeatTimer?.cancel();
  }

  // Disable protection (for non-video content)
  Future<void> disableProtection() async {
    // Skip on web
    if (kIsWeb) {
      return;
    }

    try {
      await ScreenProtector.preventScreenshotOff();
      print('✅ Screenshot protection disabled');
    } catch (e) {
      print('❌ Failed to disable protection: $e');
    }
  }

  // Clean up resources
  void dispose() {
    _heartbeatTimer?.cancel();
    endVideoSession();
    disableProtection();
  }
}
