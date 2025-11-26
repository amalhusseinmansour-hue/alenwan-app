// lib/views/podcasts/podcasts_screen.dart
import 'dart:ui' as ui;
import 'package:alenwan/controllers/cartoon_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/professional_theme.dart';
import '../../routes/app_routes.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/podcast_controller.dart';
import '../../controllers/documentary_controller.dart';
import '../../controllers/sport_controller.dart';
import '../../controllers/movie_controller.dart';
import '../../controllers/series_controller.dart';

import '../home/app_drawer.dart';
import 'podcasts_content.dart';

class PodcastsScreen extends StatelessWidget {
  const PodcastsScreen({super.key});

  static const Map<String, String> navItems = {
    'الرئيسية': AppRoutes.home,
    'المسلسلات': AppRoutes.allSeries,
    'الأفلام': AppRoutes.allMovies,
    'الرياضة': AppRoutes.allSports,
    'الوثائقيات': AppRoutes.allDocumentaries,
    'الأطفال': AppRoutes.allCartoons,
    'البودكاست': AppRoutes.allPodcasts,
  };

  // اسم المسار الحالي
  String _currentRoute(BuildContext context) =>
      ModalRoute.of(context)?.settings.name ?? '';

  // التنقل الذكي: لا تنتقل لنفس الصفحة + استبدال الصفحة الحالية + إغلاق الدرج لو مفتوح
  void _go(BuildContext context, String route) {
    final current = _currentRoute(context);
    if (current == route) return;

    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.isDrawerOpen ?? false) {
      Navigator.of(context).pop(); // يغلق الدرج
    }

    // استبدال بدل التكديس
    Navigator.of(context).pushReplacementNamed(route);
  }

  // زر عنصر في شريط التنقل (يقرر المحدّد تلقائيًا)
  Widget _navItem(
    BuildContext context, {
    required String title,
    required String route,
  }) {
    final current = _currentRoute(context);
    final selected = current == route ||
        (route == AppRoutes.home && (current.isEmpty || current == '/'));

    return InkWell(
      onTap: () => _go(context, route),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? ProfessionalTheme.primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: ProfessionalTheme.primaryColor.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? ProfessionalTheme.primaryColor
                : ProfessionalTheme.textPrimary,
            fontSize: 15,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, bool wide) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
              color: ProfessionalTheme.surfaceColor.withValues(alpha: 0.30)),
        ),
      ),
      leading: !wide
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu,
                    color: ProfessionalTheme.textPrimary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      title: Row(
        children: [
          // الشعار يعود للرئيسية
          InkWell(
            onTap: () => _go(context, AppRoutes.home),
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/logo-alenwan.jpeg', height: 36),
          ),
          if (wide)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final e in navItems.entries)
                      _navItem(context, title: e.key, route: e.value),
                  ],
                ),
              ),
            )
          else
            const Spacer(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search,
                    color: ProfessionalTheme.textPrimary, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.person_outline,
                  color: ProfessionalTheme.textPrimary,
                  size: 22,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine text direction based on current locale
    final isArabic = context.locale.languageCode == 'ar';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeController()..loadData()),
        ChangeNotifierProvider(
          create: (_) => PodcastController()..loadPodcasts(),
        ),
        ChangeNotifierProvider(create: (_) => SportController()),
        ChangeNotifierProvider(create: (_) => CartoonController()),
        ChangeNotifierProvider(create: (_) => DocumentaryController()),
        ChangeNotifierProvider(create: (_) => MovieController()),
        ChangeNotifierProvider(create: (_) => SeriesController()),
      ],
      child: Directionality(
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 1100;
            return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: ProfessionalTheme.backgroundColor,
              drawer: !wide ? const AppDrawer() : null,
              appBar: _appBar(context, wide),
              body: Stack(
                children: [
                  // خلفية آمنة بدون أصول مفقودة
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ProfessionalTheme.backgroundColor,
                            ProfessionalTheme.surfaceColor,
                            ProfessionalTheme.backgroundColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: const Padding(
                        padding: EdgeInsets.only(top: kToolbarHeight + 60),
                        child: PodcastsContent(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
