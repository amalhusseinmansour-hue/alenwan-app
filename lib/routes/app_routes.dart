// Flutter & Core
import 'package:alenwan/models/channel_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Models
import 'package:alenwan/models/movie_model.dart';
import 'package:alenwan/models/sport_model.dart';

// Views - Auth
import 'package:alenwan/views/auth/login_screen.dart';
import 'package:alenwan/views/auth/register_screen.dart';
import 'package:alenwan/views/auth/forgot_password_screen.dart';
import 'package:alenwan/views/auth/reset_password_screen.dart';
import 'package:alenwan/views/admin/admin_login_screen.dart';

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
import 'package:alenwan/views/subscription/payment_webview_screen_web_stub.dart'
    if (dart.library.html) 'package:alenwan/views/subscription/payment_webview_screen_web.dart';
import 'package:alenwan/views/payment/paymob_iframe_screen.dart';
import 'package:alenwan/views/payment/payment_history_screen.dart';
import '../services/paymob_service.dart' hide SubscriptionPlan;

import '../models/live_stream_model.dart';
import '../views/live/live_stream_screen.dart';
import '../views/live/channel_details_screen.dart';
import '../screens/backend_test_screen.dart';
import '../screens/backend_diagnostic_tool.dart';

// Admin Screens
import '../views/admin/admin_dashboard_screen.dart';
import '../views/admin/admin_users_screen.dart';
import '../views/admin/admin_content_screen.dart';
import '../views/admin/admin_movie_form_screen.dart';
import '../views/admin/admin_series_form_screen.dart';
import '../views/admin/admin_subscriptions_screen.dart';
import '../views/admin/admin_payments_screen.dart';
import '../views/admin/admin_revenue_screen.dart';
import '../views/admin/admin_vimeo_bulk_import_screen.dart';


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
  static const String backendDiagnostic = '/backend-diagnostic';

  // Payment & Subscription Routes
  static const String subscriptionPlans = '/subscription-plans';
  static const String paymentCheckout = '/payment-checkout';
  static const String paymobIframe = '/paymob-iframe';
  static const String paymentWebview = '/payment-webview';
  static const String paymentHistory = '/payment-history';
  static const String subscriptionManagement = '/subscription-management';

  // Admin Routes
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminContent = '/admin/content';
  static const String adminMovieAdd = '/admin/movie/add';
  static const String adminMovieEdit = '/admin/movie/edit';
  static const String adminSeriesAdd = '/admin/series/add';
  static const String adminSeriesEdit = '/admin/series/edit';
  static const String adminVimeoImport = '/admin/vimeo-import';
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
            final fragUri =
                Uri.tryParse(frag.isEmpty ? '/' : frag) ?? Uri.parse('/');
            final token = fragUri.queryParameters['token'] ?? '';
            final email = fragUri.queryParameters['email'] ?? '';
            return ResetPasswordScreen(token: token, email: email);
          } catch (e) {
            return const Scaffold(
              body: Center(
                child: Text('Error: Invalid reset password link'),
              ),
            );
          }
        },
        languageSelection: (_) => const LanguageSelectionScreen(),

        // محمية بـ AuthGuard - تم إزالة الحماية مؤقتاً للسماح بوضع الضيف
        main: (_) => const MainScreen(),
        home: (_) => const MainScreen(),
        favorites: (_) => const FavoritesScreen(),
        profile: (_) => const ProfileScreen(),
        settings: (_) => const SettingsScreen(),
        downloads: (_) => const DownloadsScreen(),
        devices: (_) => const DevicesScreen(),
        changePassword: (_) => const ChangePasswordScreen(),

        allSeries: (_) => const SeriesScreen(),
        allMovies: (_) => const MoviesScreen(),
        allSports: (_) => const SportsScreen(),
        allCartoons: (_) => const AllCartoonsScreen(),
        allDocumentaries: (_) => const DocumentariesScreen(),
        allPodcasts: (_) => const PodcastsScreen(),

        backendTest: (_) => const BackendTestScreen(),
        backendDiagnostic: (_) => const BackendDiagnosticTool(),
        search: (_) => const SearchScreen(),
        subscription: (_) => const SubscriptionScreen(),
        liveStream: (_) => const LivePageScreen(),

        // Payment & Subscription Routes
        subscriptionPlans: (_) => const SubscriptionPlansScreen(),
        subscriptionManagement: (_) => const SubscriptionManagementScreen(),
        paymentHistory: (_) => const PaymentHistoryScreen(),
        // paymentCheckout route removed - using paymentWebview instead
        paymobIframe: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is PaymentInitResponse) {
            return PaymobIframeScreen(paymentData: args);
          }
          return const Scaffold(
            body: Center(
              child: Text('Error: Invalid payment data'),
            ),
          );
        },
        paymentWebview: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is Map && args['url'] != null) {
            return kIsWeb
                ? PaymentWebViewScreenWeb(paymentUrl: args['url'] as String)
                : PaymentWebViewScreen(paymentUrl: args['url'] as String);
          }
          return const Scaffold(
            body: Center(
              child: Text('Error: Invalid payment URL'),
            ),
          );
        },
        liveStreamDetails: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;

          if (args is LiveStreamModel) {
            return LiveStreamScreen(stream: args);
          }

          // fallback لو ماجاش stream
          return const Scaffold(
            body: Center(
              child: Text('❌ لا يوجد بث محدد'),
            ),
          );
        },
        channelDetails: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;

          if (args is ChannelModel) {
            return ChannelDetailsScreen(channel: args);
          }

          // fallback لو ماجاش channel
          return const Scaffold(
            body: Center(
              child: Text('❌ لا يوجد قناة محددة'),
            ),
          );
        },

        // تفاصيل
        movieDetails: (context) {
          return Builder(builder: (context) {
            final arg = ModalRoute.of(context)!.settings.arguments;
            if (arg is MovieModel) return MovieDetailsScreen(movie: arg);
            if (arg is int) return MovieDetailsScreen(movieId: arg);
            return const MovieDetailsScreen();
          });
        },
        seriesDetails: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final int id =
              (args is int) ? args : int.tryParse(args?.toString() ?? '') ?? 0;
          if (id == 0) {
            return const Scaffold(
              body: Center(
                child: Text('Error: Invalid series ID'),
              ),
            );
          }
          return SeriesDetailsScreen(seriesId: id);
        },
        sportDetails: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          final int sportId =
              (args is int) ? args : int.tryParse(args?.toString() ?? '') ?? 0;
          return SportDetailsScreen(
            sport: SportModel(
                id: sportId, title: '', categoryId: 0, languageId: 1),
          );
        },
        cartoonDetails: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final int id =
              (args is int) ? args : int.tryParse(args?.toString() ?? '') ?? 0;
          if (id == 0) {
            return const Scaffold(
              body: Center(
                child: Text('Error: Invalid cartoon ID'),
              ),
            );
          }
          return CartoonDetailsScreen(cartoonId: id);
        },
        documentaryDetails: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final int id =
              (args is int) ? args : int.tryParse(args?.toString() ?? '') ?? 0;
          if (id == 0) {
            return const Scaffold(
              body: Center(
                child: Text('Error: Invalid documentary ID'),
              ),
            );
          }
          return DocumentaryDetailsScreen(documentaryId: id);
        },
        podcastDetails: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final int id =
              (args is int) ? args : int.tryParse(args?.toString() ?? '') ?? 0;
          if (id == 0) {
            return const Scaffold(
              body: Center(
                child: Text('Error: Invalid podcast ID'),
              ),
            );
          }
          return PodcastDetailsScreen(podcastId: id);
        },

        // Admin Routes
        adminLogin: (_) => const AdminLoginScreen(),
        adminDashboard: (_) => const AdminDashboardScreen(),
        adminUsers: (_) => const AdminUsersScreen(),
        adminContent: (_) => const AdminContentScreen(),
        adminMovieAdd: (_) => const AdminMovieFormScreen(),
        adminSeriesAdd: (_) => const AdminSeriesFormScreen(),
        adminVimeoImport: (_) => const AdminVimeoBulkImportScreen(),
        adminSubscriptions: (_) => const AdminSubscriptionsScreen(),
        adminPayments: (_) => const AdminPaymentsScreen(),
        adminRevenue: (_) => const AdminRevenueScreen(),
      };

  // Dynamic route handler for admin movie edit
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Handle admin movie edit with ID
    if (settings.name?.startsWith('/admin/movie/edit/') == true) {
      final id = int.tryParse(settings.name!.split('/').last);
      if (id != null) {
        return MaterialPageRoute(
          builder: (_) => AdminMovieFormScreen(movieId: id),
          settings: settings,
        );
      }
    }

    // Handle admin series edit with ID
    if (settings.name?.startsWith('/admin/series/edit/') == true) {
      final id = int.tryParse(settings.name!.split('/').last);
      if (id != null) {
        return MaterialPageRoute(
          builder: (_) => AdminSeriesFormScreen(seriesId: id),
          settings: settings,
        );
      }
    }

    return null;
  }
}
