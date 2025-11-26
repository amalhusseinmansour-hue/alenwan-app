// lib/views/home/home_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/professional_theme.dart';
import '../../widgets/common_app_bar.dart';

// Controllers
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/documentary_controller.dart';
import '../../controllers/sport_controller.dart';
import '../../controllers/cartoon_controller.dart';
import '../../controllers/movie_controller.dart';
import '../../controllers/series_controller.dart';

// Widgets
import 'app_drawer.dart';
import 'home_content_enhanced.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Determine text direction based on current locale
    final isArabic = context.locale.languageCode == 'ar';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          final auth = Provider.of<AuthController>(context, listen: false);
          return HomeController()..loadData(isGuest: auth.isGuestMode);
        }),
        ChangeNotifierProvider(create: (_) => DocumentaryController()),
        ChangeNotifierProvider(create: (_) => SportController()),
        ChangeNotifierProvider(create: (_) => CartoonController()),
        ChangeNotifierProvider(create: (_) => MovieController()),
        ChangeNotifierProvider(create: (_) => SeriesController()),
      ],
      child: Directionality(
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: ProfessionalTheme.backgroundColor,
          drawer: const AppDrawer(), // When RTL, drawer automatically appears on right
          appBar: const CommonAppBar(
            title: 'العنوان',
            showBackButton: false,
          ),
          body: const HomeContentEnhanced(),
        ),
      ),
    );
  }
}
