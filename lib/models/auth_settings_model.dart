// Auth Settings Model
class AuthSettingsModel {
  final bool enableGoogleLogin;
  final bool enableAppleLogin;
  final bool enableGuestMode;

  AuthSettingsModel({
    required this.enableGoogleLogin,
    required this.enableAppleLogin,
    required this.enableGuestMode,
  });

  factory AuthSettingsModel.fromJson(Map<String, dynamic> json) {
    return AuthSettingsModel(
      enableGoogleLogin: json['enable_google_login'] as bool? ?? true,
      enableAppleLogin: json['enable_apple_login'] as bool? ?? true,
      enableGuestMode: json['enable_guest_mode'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable_google_login': enableGoogleLogin,
      'enable_apple_login': enableAppleLogin,
      'enable_guest_mode': enableGuestMode,
    };
  }

  // Default settings (all enabled)
  factory AuthSettingsModel.defaultSettings() {
    return AuthSettingsModel(
      enableGoogleLogin: true,
      enableAppleLogin: true,
      enableGuestMode: true,
    );
  }
}
