import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_client.dart';
import 'device_fingerprint_service.dart';
import 'dart:async';

class DeviceManager extends ChangeNotifier {
  static final DeviceManager _instance = DeviceManager._internal();
  factory DeviceManager() => _instance;
  DeviceManager._internal();

  final DeviceFingerprintService _fingerprintService =
      DeviceFingerprintService();
  ApiClient? __apiClient;

  ApiClient get _apiClient {
    __apiClient ??= ApiClient();
    return __apiClient!;
  }

  // Device status
  bool _isRegistered = false;
  bool _isActive = false;
  bool _isBlocked = false;
  String? _deviceToken;
  DateTime? _lastVerification;
  Timer? _verificationTimer;

  // Registered devices list
  List<DeviceInfo> _registeredDevices = [];
  DeviceInfo? _currentDevice;

  // Getters
  bool get isRegistered => _isRegistered;
  bool get isActive => _isActive;
  bool get isBlocked => _isBlocked;
  String? get deviceToken => _deviceToken;
  List<DeviceInfo> get registeredDevices => _registeredDevices;
  DeviceInfo? get currentDevice => _currentDevice;

  // Initialize device management
  Future<void> initialize() async {
    try {
      // Get stored device token
      final prefs = await SharedPreferences.getInstance();
      _deviceToken = prefs.getString('device_token');

      if (_deviceToken != null) {
        // Verify existing device
        await verifyDevice();
      } else {
        // Register new device
        await registerDevice();
      }

      // Start periodic verification
      _startPeriodicVerification();
    } catch (e) {
      print('Device initialization error: $e');
    }
  }

  // Register device with backend
  Future<bool> registerDevice() async {
    try {
      // Get device fingerprint and info
      final fingerprint = await _fingerprintService.getDeviceFingerprint();
      final deviceId = await _fingerprintService.getDeviceId();
      final deviceInfo = await _fingerprintService.getDeviceInfo();
      final deviceName = await _fingerprintService.getDeviceName();

      // Send registration request
      final response = await _apiClient.dio.post('/api/device/register', data: {
        'device_id': deviceId,
        'fingerprint': fingerprint,
        'device_name': deviceName,
        'platform': deviceInfo['platform'],
        'model': deviceInfo['model'],
        'os_version': deviceInfo['os_version'],
        'metadata': deviceInfo,
      });

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'success') {
          // Device registered successfully
          _deviceToken = data['device_token'];
          _isRegistered = true;
          _isActive = true;
          _isBlocked = false;

          // Store device token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('device_token', _deviceToken!);

          // Update current device info
          _currentDevice = DeviceInfo.fromJson(data['device']);

          notifyListeners();
          return true;
        } else if (data['status'] == 'limit_exceeded') {
          // Device limit exceeded
          _isBlocked = true;
          _handleDeviceLimitExceeded(data);
          return false;
        } else if (data['status'] == 'replaced') {
          // This device replaced another
          _isRegistered = true;
          _isActive = true;
          _deviceToken = data['device_token'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('device_token', _deviceToken!);

          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('Device registration error: $e');
    }

    return false;
  }

  // Verify device is still active
  Future<bool> verifyDevice() async {
    try {
      if (_deviceToken == null) {
        return await registerDevice();
      }

      final fingerprint = await _fingerprintService.getDeviceFingerprint();

      final response = await _apiClient.dio.post('/api/device/verify', data: {
        'device_token': _deviceToken,
        'fingerprint': fingerprint,
      });

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'active') {
          _isActive = true;
          _isBlocked = false;
          _lastVerification = DateTime.now();
          notifyListeners();
          return true;
        } else if (data['status'] == 'blocked') {
          _isActive = false;
          _isBlocked = true;
          _handleDeviceBlocked(data['reason']);
          return false;
        } else if (data['status'] == 'invalid') {
          // Token invalid, re-register
          _deviceToken = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('device_token');
          return await registerDevice();
        }
      }
    } catch (e) {
      print('Device verification error: $e');
    }

    return false;
  }

  // Get list of registered devices
  Future<void> fetchRegisteredDevices() async {
    try {
      final response = await _apiClient.dio.get('/api/device/list');

      if (response.statusCode == 200) {
        final devices = (response.data['devices'] as List)
            .map((d) => DeviceInfo.fromJson(d))
            .toList();

        _registeredDevices = devices;

        // Find current device
        final currentFingerprint =
            await _fingerprintService.getDeviceFingerprint();
        _currentDevice = devices.firstWhere(
          (d) => d.fingerprint == currentFingerprint,
          orElse: () => devices.first,
        );

        notifyListeners();
      }
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }

  // Remove a device
  Future<bool> removeDevice(String deviceId) async {
    try {
      final response = await _apiClient.dio.post('/api/device/remove', data: {
        'device_id': deviceId,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Refresh device list
        await fetchRegisteredDevices();

        // If removed current device, clear token
        if (_currentDevice?.id == deviceId) {
          await clearDeviceToken();
        }

        return true;
      }
    } catch (e) {
      print('Error removing device: $e');
    }

    return false;
  }

  // Force logout other devices
  Future<bool> forceLogoutOtherDevices() async {
    try {
      final response =
          await _apiClient.dio.post('/api/device/force-logout', data: {
        'device_token': _deviceToken,
        'keep_current': true,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Refresh device list
        await fetchRegisteredDevices();
        return true;
      }
    } catch (e) {
      print('Error forcing logout: $e');
    }

    return false;
  }

  // Handle device limit exceeded
  void _handleDeviceLimitExceeded(Map<String, dynamic> data) {
    _isBlocked = true;
    _registeredDevices = (data['devices'] as List?)
            ?.map((d) => DeviceInfo.fromJson(d))
            .toList() ??
        [];

    notifyListeners();

    // Notify UI to show device management screen
    _showDeviceLimitDialog();
  }

  // Handle device blocked
  void _handleDeviceBlocked(String reason) {
    _isActive = false;
    _isBlocked = true;
    notifyListeners();

    // Clear stored token
    clearDeviceToken();

    // Notify UI
    _showBlockedDialog(reason);
  }

  // Clear device token
  Future<void> clearDeviceToken() async {
    _deviceToken = null;
    _isRegistered = false;
    _isActive = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('device_token');

    notifyListeners();
  }

  // Start periodic verification
  void _startPeriodicVerification() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) async {
        if (_deviceToken != null) {
          await verifyDevice();
        }
      },
    );
  }

  // Show device limit dialog
  void _showDeviceLimitDialog() {
    // This will be handled by UI layer
    // Emit event or use callback
  }

  // Show blocked dialog
  void _showBlockedDialog(String reason) {
    // This will be handled by UI layer
    // Emit event or use callback
  }

  // Dispose
  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }
}

// Device information model
class DeviceInfo {
  final String id;
  final String deviceId;
  final String fingerprint;
  final String name;
  final String platform;
  final String model;
  final String? osVersion;
  final DateTime registeredAt;
  final DateTime lastActive;
  final bool isActive;
  final bool isCurrent;

  DeviceInfo({
    required this.id,
    required this.deviceId,
    required this.fingerprint,
    required this.name,
    required this.platform,
    required this.model,
    this.osVersion,
    required this.registeredAt,
    required this.lastActive,
    required this.isActive,
    this.isCurrent = false,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['id'] ?? '',
      deviceId: json['device_id'] ?? '',
      fingerprint: json['fingerprint'] ?? '',
      name: json['name'] ?? 'Unknown Device',
      platform: json['platform'] ?? 'Unknown',
      model: json['model'] ?? 'Unknown',
      osVersion: json['os_version'],
      registeredAt:
          DateTime.tryParse(json['registered_at'] ?? '') ?? DateTime.now(),
      lastActive:
          DateTime.tryParse(json['last_active'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? false,
      isCurrent: json['is_current'] ?? false,
    );
  }

  String get displayName {
    if (platform.toLowerCase() == 'android') {
      return '📱 $model';
    } else if (platform.toLowerCase() == 'ios') {
      return '🍎 $model';
    } else if (platform.toLowerCase() == 'web') {
      return '🌐 $name';
    } else if (platform.toLowerCase() == 'windows') {
      return '💻 Windows PC';
    } else if (platform.toLowerCase() == 'macos') {
      return '🖥️ Mac';
    }
    return '📱 $name';
  }

  String get lastActiveText {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(lastActive);
    }
  }
}
