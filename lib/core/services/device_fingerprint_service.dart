import 'dart:io' show Platform;
import 'package:universal_platform/universal_platform.dart';
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
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
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
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    final platform = kIsWeb ? 'web' : Platform.operatingSystem;

    final idString = '$platform-$timestamp-$random';
    final bytes = utf8.encode(idString);
    final digest = sha256.convert(bytes);

    _cachedDeviceId = digest.toString().substring(0, 32);

    // Store for future use
    await prefs.setString('device_unique_id', _cachedDeviceId!);

    return _cachedDeviceId!;
  }

  // Get detailed device information
  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) return _cachedDeviceInfo!;

    _cachedDeviceInfo = await _getDeviceInfo();
    return _cachedDeviceInfo!;
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    Map<String, dynamic> deviceData = {};

    try {
      if (!kIsWeb && UniversalPlatform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData = {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'device': androidInfo.device,
          'id': androidInfo.id,
          'android_id': androidInfo.id,
          'os_version': androidInfo.version.release,
          'sdk_int': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'display': androidInfo.display,
          'hardware': androidInfo.hardware,
          'product': androidInfo.product,
          'is_physical': androidInfo.isPhysicalDevice,
        };
      } else if (!kIsWeb && UniversalPlatform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData = {
          'platform': 'iOS',
          'model': iosInfo.model,
          'manufacturer': 'Apple',
          'device': iosInfo.name,
          'id': iosInfo.identifierForVendor ?? 'unknown',
          'os_version': iosInfo.systemVersion,
          'system_name': iosInfo.systemName,
          'localized_model': iosInfo.localizedModel,
          'is_physical': iosInfo.isPhysicalDevice,
        };
      } else if (!kIsWeb && UniversalPlatform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        deviceData = {
          'platform': 'Windows',
          'model': windowsInfo.computerName,
          'manufacturer': 'PC',
          'device': windowsInfo.computerName,
          'id': windowsInfo.computerName,
          'os_version': windowsInfo.majorVersion.toString(),
          'build_number': windowsInfo.buildNumber.toString(),
          'product_name': windowsInfo.productName,
        };
      } else if (!kIsWeb && UniversalPlatform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        deviceData = {
          'platform': 'macOS',
          'model': macInfo.model,
          'manufacturer': 'Apple',
          'device': macInfo.computerName,
          'id': macInfo.systemGUID ?? 'unknown',
          'os_version': macInfo.majorVersion.toString(),
          'arch': macInfo.arch,
          'kernel_version': macInfo.kernelVersion,
        };
      } else if (!kIsWeb && UniversalPlatform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        deviceData = {
          'platform': 'Linux',
          'model': linuxInfo.name,
          'manufacturer': 'Linux',
          'device': linuxInfo.name,
          'id': linuxInfo.machineId ?? 'unknown',
          'os_version': linuxInfo.version ?? 'unknown',
          'pretty_name': linuxInfo.prettyName,
        };
      } else if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceData = {
          'platform': 'Web',
          'model': webInfo.browserName.name,
          'manufacturer': 'Browser',
          'device': webInfo.userAgent ?? 'unknown',
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'os_version': webInfo.platform ?? 'unknown',
          'browser': webInfo.browserName.name,
          'user_agent': webInfo.userAgent,
          'vendor': webInfo.vendor,
          'language': webInfo.language,
        };
      }
    } catch (e) {
      print('Error getting device info: $e');
      deviceData = {
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        'model': 'Unknown',
        'manufacturer': 'Unknown',
        'device': 'Unknown',
        'id': 'unknown',
        'os_version': 'unknown',
      };
    }

    return deviceData;
  }

  // Get fallback fingerprint if generation fails
  Future<String> _getFallbackFingerprint() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get stored fingerprint
    String? stored = prefs.getString('device_fingerprint');
    if (stored != null) {
      _cachedFingerprint = stored;
      return stored;
    }

    // Generate a random one as last resort
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    final fingerprint = digest.toString();

    _cachedFingerprint = fingerprint;
    await prefs.setString('device_fingerprint', fingerprint);

    return fingerprint;
  }

  // Get device name for display
  Future<String> getDeviceName() async {
    final info = await getDeviceInfo();
    final platform = info['platform'] ?? 'Unknown';
    final model = info['model'] ?? 'Device';

    if (platform == 'Web') {
      return '${info['browser']} Browser';
    }

    return '$model ($platform)';
  }

  // Clear cached data
  void clearCache() {
    _cachedFingerprint = null;
    _cachedDeviceId = null;
    _cachedDeviceInfo = null;
  }

  // Check if device is trusted
  Future<bool> isDeviceTrusted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('device_trusted') ?? false;
  }

  // Mark device as trusted
  Future<void> trustDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('device_trusted', true);
  }
}
