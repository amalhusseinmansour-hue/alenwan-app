# Apple Review - Version 1.0.28 Notes

## Changes Made to Address Review Feedback

### 1. Guideline 4.8 - Sign in with Apple ✅

**Issue:** The app uses Google Sign-In but doesn't offer Sign in with Apple as an alternative.

**Solution:**
- ✅ Added **Sign in with Apple** button in login screen
- ✅ Added **Google Sign-In** button in login screen
- ✅ Both buttons appear on iOS devices
- ✅ Sign in with Apple limits data to name and email only
- ✅ Allows users to hide their email (Apple's privacy feature)
- ✅ No advertising data collection without consent

**Files Modified:**
- `lib/views/auth/login_screen.dart` - Added Apple & Google sign-in handlers
- `lib/views/auth/social_login_buttons.dart` - Created social login buttons
- `lib/controllers/auth_controller.dart` - Sign in with Apple logic (already existed)

---

### 2. Guideline 5.1.1 - Free Access Without Login ✅

**Issue:** App requires users to register before accessing content.

**Solution:**
- ✅ **Auto Guest Mode**: App now automatically enables guest mode on first launch
- ✅ Users can browse all non-premium content **without any registration**
- ✅ Login is **completely optional**
- ✅ Registration only required for:
  - Saving favorites
  - Viewing watch history
  - Accessing premium/subscription content
  - Syncing across devices

**Files Modified:**
- `lib/views/splash/splash_screen.dart` - Auto-enable guest mode

---

## Testing Checklist

### On iOS Device:

1. **First Launch (Guest Mode)**
   - [ ] App opens directly to home screen
   - [ ] Can browse content without login
   - [ ] Can watch free content

2. **Sign in with Apple**
   - [ ] Open Profile → Login
   - [ ] See "Sign in with Apple" button
   - [ ] Click and authenticate with Apple ID
   - [ ] Successfully logged in

3. **Google Sign-In**
   - [ ] See "Google" button
   - [ ] Click and authenticate with Google
   - [ ] Successfully logged in

4. **Guest → Registered User**
   - [ ] Start as guest
   - [ ] Go to Profile
   - [ ] Register or login
   - [ ] Favorites/history now saved

---

## Message for App Review Team

```
Dear App Review Team,

Thank you for your detailed feedback. We have made the following changes to address your concerns:

### 1. Guideline 4.8 - Login Services:
✅ We have added "Sign in with Apple" as a login option alongside Google Sign-In.
✅ Both login options limit data collection to name and email.
✅ Sign in with Apple allows users to keep their email private using Apple's built-in privacy feature.
✅ No data is collected for advertising purposes without user consent.

### 2. Guideline 5.1.1 - Account Sign-In:
✅ Users can now access the app and browse content freely without being required to register or log in.
✅ The app automatically enters "Guest Mode" on first launch.
✅ Users can browse all non-premium content as guests.
✅ Registration is completely optional and only required for account-based features:
   - Saving favorites
   - Viewing watch history
   - Accessing premium/subscription content
   - Syncing across devices

The updated version (1.0.28) is now available for review.

Thank you for your time and consideration.

Best regards,
Alenwan Development Team
```

---

## Build Instructions

### For iOS (on Mac):

```bash
cd /path/to/alenwan
flutter clean
flutter pub get
flutter build ios --release
```

### Important iOS Setup:

1. **In Xcode:**
   - Open `ios/Runner.xcworkspace`
   - Go to **Signing & Capabilities**
   - Ensure **Sign in with Apple** capability is enabled
   - Check that Bundle ID matches App Store Connect

2. **In App Store Connect:**
   - Update version to **1.0.28**
   - Add release notes mentioning the fixes
   - Submit for review

---

## Version Info

- **Version:** 1.0.28
- **Build Number:** 28
- **Previous Version:** 1.0.27
- **Date:** November 16, 2025

---

## Files Changed

1. `lib/views/auth/login_screen.dart`
2. `lib/views/auth/social_login_buttons.dart`
3. `lib/views/splash/splash_screen.dart`
4. `pubspec.yaml` (version bump)

---

## Dependencies

- ✅ `sign_in_with_apple: ^7.0.1` - Already in pubspec.yaml
- ✅ `google_sign_in: ^6.3.0` - Already in pubspec.yaml

---

## No Breaking Changes

✅ All existing functionality remains intact
✅ Existing users will not be affected
✅ Backward compatible with previous versions
