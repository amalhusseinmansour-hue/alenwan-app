import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DeviceFingerprintService {
  static final DeviceFingerprintService _instance =
      DeviceFingerprintService._internal();
  factory DeviceFingerprintService() => _instance;
  DeviceFingerprintService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _cachedFingerprint;
  String? _cachedDeviceId;
  Map<String, dynamic>? _cachedDeviceInfo;

  // Generate unique device fingerprint
  Future<String> getDeviceFingerprint() async {
    if (_cachedFingerprint != null) return _cachedFingerprint!;

    try {
      final deviceInfo = await _getDeviceInfo();

      // Create a unique string from device properties
      final fingerprintData = {
        'platform': _getPlatformName(),
        'model': deviceInfo['model'],
        'manufacturer': deviceInfo['manufacturer'],
        'device': deviceInfo['device'],
        'id': deviceInfo['id'],
        'os_version': deviceInfo['os_version'],
      };

      // Generate SHA256 hash
      final bytes = utf8.encode(json.encode(fingerprintData));
      final digest = sha256.convert(bytes);
      _cachedFingerprint = digest.toString();

      // Store locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_fingerprint', _cachedFingerprint!);

      return _cachedFingerprint!;
    } catch (e) {
      print('Error generating device fingerprint: $e');
      // Fallback to stored or random
      return await _getFallbackFingerprint();
    }
  }

  // Get platform name safely for web
  String _getPlatformName() {
    if (kIsWeb) {
      return 'web';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return 'windows';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'macos';
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      return 'linux';
    }
    return 'unknown';
  }

  // Get or generate device ID
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    final prefs = await SharedPreferences.getInstance();

    // Check if we have a stored device ID
    String? storedId = prefs.getString('device_unique_id');

    if (storedId != null) {
      _cachedDeviceId = storedId;
      return storedId;
    }

    // Generate new device ID
    try {
      final deviceInfo = await _getDeviceInfo();
      final id = deviceInfo['id'] ?? _generateRandomId();

      _cachedDeviceId = id;
      await prefs.setString('device_unique_id', id);

      return id;
    } catch (e) {
      print('Error getting device ID: $e');
      // Generate and store random ID
      final randomId = _generateRandomId();
      _cachedDeviceId = randomId;
      await prefs.setString('device_unique_id', randomId);
      return randomId;
    }
  }

  // Get detailed device information
  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) return _cachedDeviceInfo!;

    _cachedDeviceInfo = await _getDeviceInfo();
    return _cachedDeviceInfo!;
  }

  // Get device name for display
  Future<String> getDeviceName() async {
    try {
      final deviceInfo = await _getDeviceInfo();
      final platform = deviceInfo['platform'] ?? 'Unknown';
      final model = deviceInfo['model'] ?? 'Device';

      if (platform == 'web') {
        final browserName = deviceInfo['browser_name'] ?? 'Browser';
        return '$browserName on Web';
      } else if (platform == 'ios' || platform == 'android') {
        return '${deviceInfo['manufacturer'] ?? ''} $model'.trim();
      } else {
        return '${deviceInfo['device'] ?? model}';
      }
    } catch (e) {
      return 'Unknown Device';
    }
  }

  // Internal method to get device info
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return {
          'platform': 'web',
          'model': webInfo.browserName.toString(),
          'manufacturer': webInfo.vendor ?? 'Unknown',
          'device': 'Web Browser',
          'id': webInfo.userAgent?.hashCode.toString() ?? _generateRandomId(),
          'os_version': webInfo.platform ?? 'Unknown',
          'browser_name': webInfo.browserName.toString(),
          'user_agent': webInfo.userAgent,
        };
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'device': androidInfo.device,
          'id': androidInfo.id,
          'os_version': androidInfo.version.release,
          'sdk_int': androidInfo.version.sdkInt,
        };
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'manufacturer': 'Apple',
          'device': iosInfo.name,
          'id': iosInfo.identifierForVendor ?? _generateRandomId(),
          'os_version': iosInfo.systemVersion,
        };
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return {
          'platform': 'windows',
          'model': windowsInfo.computerName,
          'manufacturer': 'Microsoft',
          'device': 'Windows PC',
          'id': windowsInfo.deviceId,
          'os_version': windowsInfo.productName,
        };
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        return {
          'platform': 'macos',
          'model': macInfo.model,
          'manufacturer': 'Apple',
          'device': macInfo.computerName,
          'id': macInfo.systemGUID ?? _generateRandomId(),
          'os_version': macInfo.osRelease,
        };
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return {
          'platform': 'linux',
          'model': linuxInfo.name,
          'manufacturer': 'Linux',
          'device': linuxInfo.prettyName,
          'id': linuxInfo.machineId ?? _generateRandomId(),
          'os_version': linuxInfo.version,
        };
      }

      // Fallback
      return {
        'platform': 'unknown',
        'model': 'Unknown',
        'manufacturer': 'Unknown',
        'device': 'Unknown',
        'id': _generateRandomId(),
        'os_version': 'Unknown',
      };
    } catch (e) {
      print('Error getting device info: $e');
      return {
        'platform': _getPlatformName(),
        'model': 'Unknown',
        'manufacturer': 'Unknown',
        'device': 'Unknown',
        'id': _generateRandomId(),
        'os_version': 'Unknown',
      };
    }
  }

  // Get fallback fingerprint
  Future<String> _getFallbackFingerprint() async {
    final prefs = await SharedPreferences.getInstance();

    // Check for stored fingerprint
    String? stored = prefs.getString('device_fingerprint');
    if (stored != null) {
      return stored;
    }

    // Generate random fingerprint
    final random = _generateRandomId();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    final fingerprint = digest.toString();

    await prefs.setString('device_fingerprint', fingerprint);
    return fingerprint;
  }

  // Generate random ID
  String _generateRandomId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString() + DateTime.now().microsecond.toString();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  // Clear cached data
  void clearCache() {
    _cachedFingerprint = null;
    _cachedDeviceId = null;
    _cachedDeviceInfo = null;
  }

  // Check if device is registered
  Future<bool> isDeviceRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('device_token');
  }

  // Get device registration token
  Future<String?> getDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_token');
  }

  // Save device registration token
  Future<void> saveDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_token', token);
  }

  // Remove device registration
  Future<void> removeDeviceRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('device_token');
    await prefs.remove('device_registered_at');
  }
}
