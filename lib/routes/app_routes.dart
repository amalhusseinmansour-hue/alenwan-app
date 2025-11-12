// Flutter & Core
import 'package:alenwan/models/channel_model.dart';
import 'package:flutter/material.dart';
import 'package:alenwan/core/widgets/auth_guard.dart';

// Models
import 'package:alenwan/models/movie_model.dart';
import 'package:alenwan/models/sport_model.dart';

// Views - Auth
import 'package:alenwan/views/auth/login_screen.dart';
import 'package:alenwan/views/auth/register_screen.dart';
import 'package:alenwan/views/auth/forgot_password_screen.dart';
import 'package:alenwan/views/auth/reset_password_screen.dart';

// Views - Main & Splash
import 'package:alenwan/views/main_screen.dart';
import 'package:alenwan/views/splash/splash_screen.dart';

// Views - Movies
import 'package:alenwan/views/movie/movies_screen.dart';
import 'package:alenwan/views/movie/movie_details_screen.dart';

// Views - Series
import 'package:alenwan/views/series/series_screen.dart';
import 'package:alenwan/views/series/series_details_screen.dart';

// Views - Sports
import 'package:alenwan/views/sports/sports_screen.dart';
import 'package:alenwan/views/sports/sport_details_screen.dart';

// Views - Cartoons
import 'package:alenwan/views/cartoons/all_cartoons_screen.dart';
import 'package:alenwan/views/cartoons/cartoon_details/cartoon_details.dart';

// Views - Documentaries
import 'package:alenwan/views/documentaries/documentaries_screen.dart';
import 'package:alenwan/views/documentaries/documentaries_details_screen.dart';

// Views - Podcasts
import 'package:alenwan/views/podcasts/podcasts_screen.dart';
import 'package:alenwan/views/podcasts/podcast_details_screen.dart';

// Views - Others
import 'package:alenwan/views/live/live_page_screen.dart';
import 'package:alenwan/views/downloads/downloads_screen.dart';
import 'package:alenwan/views/favorites/favorites_screen.dart';
import 'package:alenwan/views/language/language_selection_screen.dart';
import 'package:alenwan/views/settings/settings_screen.dart';
import 'package:alenwan/views/settings/devices_screen.dart';
import 'package:alenwan/views/profile/profile_screen.dart';
import 'package:alenwan/views/profile/change_password_screen.dart';
import 'package:alenwan/views/search/search_screen.dart';
import 'package:alenwan/views/subscription/subscription_screen.dart';
import 'package:alenwan/views/subscription/subscription_plans_screen.dart';
import 'package:alenwan/views/subscription/subscription_management_screen.dart';
import 'package:alenwan/views/subscription/payment_webview_screen.dart';
import 'package:alenwan/views/payment/paymob_iframe_screen.dart';
import 'package:alenwan/views/payment/payment_history_screen.dart';
import '../services/paymob_service.dart' hide SubscriptionPlan;

import '../models/live_stream_model.dart';
import '../views/live/live_stream_screen.dart';
import '../views/live/channel_details_screen.dart';
import '../screens/backend_test_screen.dart';

// Admin Screens
import '../views/admin/admin_dashboard_screen.dart';
import '../views/admin/admin_users_screen.dart';
import '../views/admin/admin_content_screen.dart';
import '../views/admin/admin_movie_form_screen.dart';
import '../views/admin/admin_series_form_screen.dart';
import '../views/admin/admin_subscriptions_screen.dart';
import '../views/admin/admin_payments_screen.dart';
import '../views/admin/admin_revenue_screen.dart';

class AppRoutes {
  // ثوابت المسارات
  static const String splash = '/';
  static const String home = '/home';
  static const String main = '/main';

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String movieDetails = '/movie-details';
  static const String seriesDetails = '/series-details';
  static const String sportDetails = '/sport-details';
  static const String cartoonDetails = '/cartoon-details';
  static const String documentaryDetails = '/documentary-details';
  static const String podcastDetails = '/podcast-details';

  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String downloads = '/downloads';
  static const String devices = '/devices';
  static const String changePassword = '/change-password';

  static const String languageSelection = '/language-selection';
  static const String search = '/search';
  static const String subscription = '/subscription';
  static const String liveStream = '/livestream';
  static const String liveStreamDetails = '/livestream-details';
  static const channelDetails = '/channel-details'; // 👈 جديد

  static const String allMovies = '/all-movies';
  static const String allSeries = '/all-series';
  static const String allSports = '/all-sports';
  static const String allCartoons = '/all-cartoons';
  static const String allDocumentaries = '/all-documentaries';
  static const String allPodcasts = '/all-podcasts';

  static const String backendTest = '/backend-test';

  // Payment & Subscription Routes
  static const String subscriptionPlans = '/subscription-plans';
  static const String paymentCheckout = '/payment-checkout';
  static const String paymobIframe = '/paymob-iframe';
  static const String paymentWebview = '/payment-webview';
  static const String paymentHistory = '/payment-history';
  static const String subscriptionManagement = '/subscription-management';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminContent = '/admin/content';
  static const String adminMovieAdd = '/admin/movie/add';
  static const String adminMovieEdit = '/admin/movie/edit';
  static const String adminSeriesAdd = '/admin/series/add';
  static const String adminSeriesEdit = '/admin/series/edit';
  static const String adminSubscriptions = '/admin/subscriptions';
  static const String adminPayments = '/admin/payments';
  static const String adminRevenue = '/admin/revenue';

  // خريطة المسارات
  static Map<String, WidgetBuilder> get routes => {
        // Splash
        splash: (_) => const SplashScreen(),

        // Auth
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        resetPassword: (_) {
          try {
            final frag = Uri.base.fragment;
            final fragUri = Uri.tryParse(frag.isEmpty ? '/' : frag) ?? Uri.parse('/');
            final token = fragUri.queryParameters['token'] ?? '';
            final email = fragUri.queryParameters['email'] ?? '';
            return ResetPasswordScreen(token: token, email: email);
          } catch (e) {
            return const Scaffold(
              body: Center(
                child: Text("Error: Invalid reset password link"),
              ),
            );
          }
        },
        languageSelection: (_) => const LanguageSelectionScreen(),

        // محمية بـ AuthGuard
        main: (_) => const AuthGuard(child: MainScreen()),
        home: (_) => const AuthGuard(child: MainScreen()),
        favorites: (_) => const AuthGuard(child: FavoritesScreen()),
        profile: (_) => const AuthGuard(child: ProfileScreen()),
        settings: (_) => const AuthGuard(child: SettingsScreen()),
        downloads: (_) => const AuthGuard(child: DownloadsScreen()),
        devices: (_) => const AuthGuard(child: DevicesScreen()),
        changePassword: (_) => const AuthGuard(child: ChangePasswordScreen()),

        allSeries: (_) => const AuthGuard(child: SeriesScreen()),
        allMovies: (_) => const AuthGuard(child: MoviesScreen()),
        allSports: (_) => const AuthGuard(child: SportsScreen()),
        allCartoons: (_) => const AuthGuard(child: AllCartoonsScreen()),
        allDocumentaries: (_) => const AuthGuard(child: DocumentariesScreen()),
        allPodcasts: (_) => const AuthGuard(child: PodcastsScreen()),

        backendTest: (_) => const BackendTestScreen(),
        search: (_) => const AuthGuard(child: SearchScreen()),
        subscription: (_) => const AuthGuard(child: SubscriptionScreen()),
        liveStream: (_) => const AuthGuard(child: LivePageScreen()),

        // Payment & Subscription Routes
        subscriptionPlans: (_) => const AuthGuard(child: SubscriptionPlansScreen()),
        subscriptionManagement: (_) => const AuthGuard(child: SubscriptionManagementScreen()),
        paymentHistory: (_) => const AuthGuard(child: PaymentHistoryScreen()),
        // paymentCheckout route removed - using paymentWebview instead
        paymobIframe: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is PaymentInitResponse) {
            return AuthGuard(child: PaymobIframeScreen(paymentData: args));
          }
          return const AuthGuard(
            child: Scaffold(
              body: Center(
                child: Text("Error: Invalid payment data"),
              ),
            ),
          );
        },
        paymentWebview: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is Map && args['url'] != null) {
            return AuthGuard(
              child: PaymentWebViewScreen(paymentUrl: args['url'] as String),
            );
          }
          return const AuthGuard(
            child: Scaffold(
              body: Center(
                child: Text("Error: Invalid payment URL"),
              ),
            ),
          );
        },
        liveStreamDetails: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;

          if (args is LiveStreamModel) {
            return AuthGuard(child: LiveStreamScreen(stream: args));
          }

          // fallback لو ماجاش stream
          return const AuthGuard(
            child: Scaffold(
              body: Center(
                child: Text("❌ لا يوجد بث محدد"),
              ),
            ),
          );
        },
        channelDetails: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;

          if (args is ChannelModel) {
            return AuthGuard(child: ChannelDetailsScreen(channel: args));
          }

          // fallback لو ماجاش channel
          return const AuthGuard(
            child: Scaffold(
              body: Center(
                child: Text("❌ لا يوجد قناة محددة"),
              ),
            ),
          );
        },

        // تفاصيل
        movieDetails: (context) {
          return AuthGuard(
            child: Builder(builder: (context) {
              final arg = ModalRoute.of(context)!.settings.arguments;
              if (arg is MovieModel) return MovieDetailsScreen(movie: arg);
              if (arg is int) return MovieDetailsScreen(movieId: arg);
              return const MovieDetailsScreen();
            }),
          );
        },
        seriesDetails: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final int id = (args is int) ? args : int.tryParse(args?.toString() ?? '') ?? 0;
          if (id == 0) {
            return const AuthGuard(
              child: Scaffold(
                body: Center(
                  child: Text("Error: Invalid series ID"),
                ),
              ),
            );
          }
          return AuthGuard(child: SeriesDetailsScreen(seriesId: id));
        },
        sportDetails: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          final int sportId =
              (args is int) ? args : int.tryParse(args?.toString() ?? '') ?? 0;
          return AuthGuard(
            child: SportDetailsScreen(
              sport: SportModel(
                  id: sportId, title: '', categoryId: 0, languageId: 1),
            ),
          );
        },
        cartoonDetails: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final int id = (args is int) ? args : int.tryParse(args?.toString() ?? '') ?? 0;
          if (id == 0) {
            return const AuthGuard(
              child: Scaffold(
                body: Center(
                  child: Text("Error: Invalid cartoon ID"),
                ),
              ),
            );
          }
          return AuthGuard(child: CartoonDetailsScreen(cartoonId: id));
        },
        documentaryDetails: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final int id = (args is int) ? args : int.tryParse(args?.toString() ?? '') ?? 0;
          if (id == 0) {
            return const AuthGuard(
              child: Scaffold(
                body: Center(
                  child: Text("Error: Invalid documentary ID"),
                ),
              ),
            );
          }
          return AuthGuard(child: DocumentaryDetailsScreen(documentaryId: id));
        },
        podcastDetails: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final int id = (args is int) ? args : int.tryParse(args?.toString() ?? '') ?? 0;
          if (id == 0) {
            return const AuthGuard(
              child: Scaffold(
                body: Center(
                  child: Text("Error: Invalid podcast ID"),
                ),
              ),
            );
          }
          return AuthGuard(child: PodcastDetailsScreen(podcastId: id));
        },

        // Admin Routes
        adminDashboard: (_) => const AuthGuard(child: AdminDashboardScreen()),
        adminUsers: (_) => const AuthGuard(child: AdminUsersScreen()),
        adminContent: (_) => const AuthGuard(child: AdminContentScreen()),
        adminMovieAdd: (_) => const AuthGuard(child: AdminMovieFormScreen()),
        adminSeriesAdd: (_) => const AuthGuard(child: AdminSeriesFormScreen()),
        adminSubscriptions: (_) => const AuthGuard(child: AdminSubscriptionsScreen()),
        adminPayments: (_) => const AuthGuard(child: AdminPaymentsScreen()),
        adminRevenue: (_) => const AuthGuard(child: AdminRevenueScreen()),
      };

  // Dynamic route handler for admin movie edit
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Handle admin movie edit with ID
    if (settings.name?.startsWith('/admin/movie/edit/') == true) {
      final id = int.tryParse(settings.name!.split('/').last);
      if (id != null) {
        return MaterialPageRoute(
          builder: (_) => AuthGuard(child: AdminMovieFormScreen(movieId: id)),
          settings: settings,
        );
      }
    }

    // Handle admin series edit with ID
    if (settings.name?.startsWith('/admin/series/edit/') == true) {
      final id = int.tryParse(settings.name!.split('/').last);
      if (id != null) {
        return MaterialPageRoute(
          builder: (_) => AuthGuard(child: AdminSeriesFormScreen(seriesId: id)),
          settings: settings,
        );
      }
    }

    return null;
  }
}
