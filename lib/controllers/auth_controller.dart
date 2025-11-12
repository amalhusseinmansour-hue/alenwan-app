import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../core/services/api_client.dart';
import '../core/services/auth_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();

  // Getter for authService
  AuthService get authService => _authService;

  String? _token;
  Map<String, dynamic>? _user;
  String? _error;
  bool _isLoading = false;
  bool _bootstrapped = false;
  bool _hasActiveSubscription = false;
  bool _isGuestMode = false;

  bool get bootstrapped => _bootstrapped;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get hasActiveSubscription => _hasActiveSubscription;
  bool get isGuestMode => _isGuestMode;
  bool get isLoggedIn => _token != null && !_isGuestMode;

  AuthController({String? initialToken}) {
    _token = initialToken;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user was in guest mode
    _isGuestMode = prefs.getBool('guest_mode') ?? false;

    _token ??= prefs.getString('token') ?? prefs.getString('auth_token');

    if (_token?.isNotEmpty == true) {
      await ApiClient().refreshAuthHeader();
    }

    final cached = prefs.getString('user_cache');
    if (cached != null) _user = jsonDecode(cached);

    if (_token != null && !_isGuestMode) {
      final data = await _authService.fetchUserProfile();
      if (data != null) {
        _user = data;
        await _saveUser(data);

        // Check subscription status
        _hasActiveSubscription = data['subscription']?['is_active'] ?? false;

        // Save subscription status
        await prefs.setBool('has_subscription', _hasActiveSubscription);
      }
    }

    _bootstrapped = true;
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await ApiClient().refreshAuthHeader();
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('auth_token');
  }

  Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_cache', jsonEncode(user));
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> register(
      String name,
      String email,
      String password,
      String phone,
      ) async {
    _setLoading(true);
    clearError();

    final res = await _authService.register(name, email, password, phone);
    if (res['success'] == true) {
      _token = res['token'];
      _user = res['user'];
      if (_token != null) await _saveToken(_token!);
      if (_user != null) await _saveUser(_user!);
    } else {
      _error = res['error'];
    }

    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    clearError();

    final res = await _authService.login(email, password);
    if (res['success'] == true) {
      _token = res['token'];
      _user = res['user'];
      if (_token != null) await _saveToken(_token!);
      if (_user != null) await _saveUser(_user!);
      _setLoading(false);
      return true;
    } else {
      _error = res['error'];
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _user = null;
    _isGuestMode = false;
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('guest_mode');
    notifyListeners();
  }

  // Guest Mode Methods
  Future<void> loginAsGuest() async {
    _isGuestMode = true;
    _token = null;
    _user = null;
    _hasActiveSubscription = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guest_mode', true);

    notifyListeners();
  }

  Future<void> exitGuestMode() async {
    _isGuestMode = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('guest_mode');

    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final res = await _authService.forgotPassword(email);
      return res['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await _authService.resetPassword(
      token: token,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (res['success'] == true) {
      return true;
    } else {
      _error = res['message'] ?? "خطأ غير معروف";
      notifyListeners();
      return false;
    }
  }

  // ---------------------------
  // Google Sign-In
  // ---------------------------
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web Client ID for web platform
    clientId: kIsWeb
        ? "106732785676-lkplddjjjl2g8gq53sc5kv3l3ghivphs.apps.googleusercontent.com"
        : null,
    // Server Client ID (Web client ID) for Android/iOS to get ID tokens
    serverClientId: !kIsWeb
        ? "106732785676-lkplddjjjl2g8gq53sc5kv3l3ghivphs.apps.googleusercontent.com"
        : null,
  );

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      clearError();

      print('🔵 [GoogleSignIn] Starting Google Sign-In...');

      final account = await _googleSignIn.signIn();

      if (account == null) {
        print('❌ [GoogleSignIn] User canceled sign-in');
        _error = "تم إلغاء تسجيل الدخول";
        return false;
      }

      print('✅ [GoogleSignIn] Account selected: ${account.email}');
      print('🔵 [GoogleSignIn] Getting authentication...');

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      print('🔵 [GoogleSignIn] idToken: ${idToken != null ? "Present (${idToken.substring(0, 20)}...)" : "NULL"}');
      print('🔵 [GoogleSignIn] accessToken: ${accessToken != null ? "Present" : "NULL"}');

      if (idToken == null && accessToken == null) {
        print('❌ [GoogleSignIn] No tokens received from Google');
        _error = "لم يرجع Google أي idToken أو accessToken";
        return false;
      }

      print('🔵 [GoogleSignIn] Sending to backend...');
      print('   - Provider: google');
      print('   - Email: ${account.email}');
      print('   - Name: ${account.displayName}');
      print('   - Google ID: ${account.id}');

      final res = await _authService.socialLogin(
        provider: 'google',
        idToken: idToken,
        accessToken: accessToken,
        name: account.displayName,
        email: account.email,
        avatar: account.photoUrl,
        googleId: account.id,
      );

      print('🔵 [GoogleSignIn] Backend response:');
      print('   - success: ${res['success']}');
      print('   - token: ${res['token'] != null ? "Present" : "NULL"}');
      print('   - user: ${res['user'] != null ? "Present" : "NULL"}');
      print('   - message: ${res['message']}');

      if (res['success'] == true && res['token'] != null) {
        _token = res['token'];
        _user = res['user'];
        await _saveToken(_token!);
        await _saveUser(_user!);
        print('✅ [GoogleSignIn] Login successful!');
        return true;
      } else {
        _error = res['message'] ?? res['error'] ?? 'فشل تسجيل الدخول عبر Google';
        print('❌ [GoogleSignIn] Login failed: $_error');
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('❌ [GoogleSignIn] Exception: $e');
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // ---------------------------
  // Apple Sign-In
  // ---------------------------
  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      clearError();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Extract user information
      String? email = credential.email;
      String? name;

      if (credential.givenName != null || credential.familyName != null) {
        name = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
      }

      // Call backend with Apple credentials
      final res = await _authService.socialLogin(
        provider: 'apple',
        idToken: credential.identityToken,
        authCode: credential.authorizationCode,
        name: name,
        email: email,
        appleUserId: credential.userIdentifier,
      );

      if (res['success'] == true && res['token'] != null) {
        _token = res['token'];
        _user = res['user'];
        await _saveToken(_token!);
        await _saveUser(_user!);
        return true;
      } else {
        _error = res['message'] ?? 'فشل تسجيل الدخول عبر Apple';
        return false;
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        _error = "تم إلغاء تسجيل الدخول";
      } else if (e.code == AuthorizationErrorCode.failed) {
        _error = "فشل التحقق من Apple";
      } else {
        _error = "خطأ في تسجيل الدخول عبر Apple";
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // ---------------------------
  // 📱 Phone / WhatsApp OTP
  // ---------------------------
  Future<bool> requestOtp({required String phone, String channel = 'sms'}) async {
    try {
      _setLoading(true);
      clearError();
      final ok =
      await _authService.requestOtp(phone: phone, channel: channel);
      return ok;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> verifyOtp({required String phone, required String otp}) async {
    _setLoading(true);
    clearError();
    final res = await _authService.verifyOtp(phone: phone, otp: otp);
    if (res['success'] == true && res['token'] != null) {
      _token = res['token'];
      _user = res['user'];
      await _saveToken(_token!);
      await _saveUser(_user!);
      _setLoading(false);
      return true;
    } else {
      _error = res['error'];
      _setLoading(false);
      return false;
    }
  }
}
