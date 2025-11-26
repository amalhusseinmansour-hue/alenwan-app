import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device_fingerprint_service.dart';
import 'device_manager.dart';

class DeviceAuthInterceptor extends Interceptor {
  final DeviceFingerprintService _fingerprintService = DeviceFingerprintService();
  final DeviceManager _deviceManager = DeviceManager();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Add device information to all API requests
      final deviceId = await _fingerprintService.getDeviceId();
      final fingerprint = await _fingerprintService.getDeviceFingerprint();
      final deviceToken = _deviceManager.deviceToken;

      // Add device headers
      options.headers['X-Device-ID'] = deviceId;
      options.headers['X-Device-Fingerprint'] = fingerprint;

      if (deviceToken != null && deviceToken.isNotEmpty) {
        options.headers['X-Device-Token'] = deviceToken;
      }

      // Add platform info
      final deviceInfo = await _fingerprintService.getDeviceInfo();
      options.headers['X-Device-Platform'] = deviceInfo['platform'] ?? 'unknown';
      options.headers['X-Device-Model'] = deviceInfo['model'] ?? 'unknown';

      handler.next(options);
    } catch (e) {
      print('Error adding device headers: $e');
      // Continue with request even if device headers fail
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check for device-related responses
    if (response.data is Map) {
      final data = response.data as Map;

      // Check if device was blocked
      if (data['device_blocked'] == true) {
        _handleDeviceBlocked(data);
      }

      // Check if device limit exceeded
      if (data['device_limit_exceeded'] == true) {
        _handleDeviceLimitExceeded(data);
      }

      // Check if new device token issued
      if (data['new_device_token'] != null) {
        _updateDeviceToken(data['new_device_token']);
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle device-specific errors
    if (err.response?.statusCode == 403) {
      final data = err.response?.data;

      if (data is Map) {
        if (data['error'] == 'device_blocked') {
          _handleDeviceBlocked(data);
        } else if (data['error'] == 'device_limit_exceeded') {
          _handleDeviceLimitExceeded(data);
        } else if (data['error'] == 'invalid_device_token') {
          _handleInvalidDeviceToken();
        }
      }
    }

    handler.next(err);
  }

  void _handleDeviceBlocked(Map data) {
    _deviceManager.clearDeviceToken();
    // Trigger logout or show blocked screen
    DeviceEventBus().emit(DeviceEvent.blocked, data);
  }

  void _handleDeviceLimitExceeded(Map data) {
    // Show device management screen
    DeviceEventBus().emit(DeviceEvent.limitExceeded, data);
  }

  void _handleInvalidDeviceToken() {
    // Re-register device
    _deviceManager.registerDevice();
  }

  void _updateDeviceToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_token', newToken);
  }
}

// Event bus for device events
class DeviceEventBus {
  static final DeviceEventBus _instance = DeviceEventBus._internal();
  factory DeviceEventBus() => _instance;
  DeviceEventBus._internal();

  final Map<DeviceEvent, List<Function>> _listeners = {};

  void on(DeviceEvent event, Function callback) {
    _listeners[event] ??= [];
    _listeners[event]!.add(callback);
  }

  void off(DeviceEvent event, Function callback) {
    _listeners[event]?.remove(callback);
  }

  void emit(DeviceEvent event, [dynamic data]) {
    _listeners[event]?.forEach((callback) {
      callback(data);
    });
  }
}

enum DeviceEvent {
  blocked,
  limitExceeded,
  tokenInvalid,
  newDevice,
  removed,
}