// lib/main.dart
import 'dart:async';
import 'package:alenwan/controllers/downloads_controller.dart';
import 'package:alenwan/core/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'app.dart';

// Controllers
import 'controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/documentary_controller.dart';
import 'controllers/recommendation_controller.dart';
import 'controllers/sport_controller.dart';
import 'controllers/cartoon_controller.dart';
import 'controllers/live_controller.dart';
import 'controllers/movie_controller.dart';
import 'controllers/series_controller.dart';
import 'controllers/subscription_controller.dart';
import 'controllers/platinum_controller.dart';
import 'controllers/recent_controller.dart';
import 'controllers/home_sections_controller.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/channel_controller.dart';
import 'controllers/search_controller.dart';

// Services
import 'core/services/platinum_service.dart';
import 'core/services/recent_service.dart';
import 'core/services/home_sections_service.dart';

late SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase (skip on web for development)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase initialization error: $e');
      // Continue without Firebase if it fails
    }
  } else {
    print('Skipping Firebase initialization on web platform');
  }

  prefs = await SharedPreferences.getInstance();

  final savedToken = prefs.getString('token') ?? prefs.getString('auth_token');
  if (savedToken != null && savedToken.isNotEmpty) {
    await ApiClient().refreshAuthHeader();
  }
  final savedLanguage = prefs.getString('language') ?? 'ar';
  final startLocale = Locale(savedLanguage);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: startLocale,
      useOnlyLangCode: true,
      saveLocale: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeController()),
          ChangeNotifierProvider(
            create: (_) => AuthController(initialToken: savedToken),
          ),
          ChangeNotifierProvider(create: (_) => HomeController()..loadData()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => DocumentaryController()),
          ChangeNotifierProvider(create: (_) => SportController()),
          ChangeNotifierProvider(create: (_) => CartoonController()),
          ChangeNotifierProvider(create: (_) => LiveController()),
          ChangeNotifierProvider(create: (_) => ChannelController()),

          ChangeNotifierProvider(create: (_) => MovieController()),
          ChangeNotifierProvider(create: (_) => SeriesController()),
          ChangeNotifierProvider(create: (_) => SubscriptionController()),
          ChangeNotifierProvider(create: (_) => AppSearchController()),
          ChangeNotifierProxyProvider<AuthController, FavoritesController>(
            create: (_) => FavoritesController(),
            update: (_, auth, fav) {
              fav ??= FavoritesController();
              fav.setAuth(
                token: auth.token,
                userId: auth.user?['id'] as int?, // لو عندك userId
                load: true,
              );
              return fav;
            },
          ),

          ChangeNotifierProvider(
            create: (_) =>
                PlatinumController(service: PlatinumService())..load(),
          ),
          ChangeNotifierProvider(
            create: (_) => RecentController(service: RecentService())..load(),
          ),
          ChangeNotifierProvider(
            create: (_) =>
                HomeSectionsController(service: HomeSectionsService())..load(),
          ),
          ChangeNotifierProvider(
            create: (_) => SettingsController(prefs: prefs),
          ),
          Provider<SharedPreferences>.value(value: prefs),
          ChangeNotifierProvider(create: (_) => RecommendationController()),
          ChangeNotifierProvider(
            create: (_) => DownloadsController()..loadDownloads(),
          ),
        ],
        child: const App(),
      ),
    ),
  );
}
