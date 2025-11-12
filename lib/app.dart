// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'config/themes.dart';
import 'routes/app_routes.dart';
import 'controllers/theme_controller.dart';
import 'core/widgets/web_mobile_wrapper.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ALENWAN PLAY PLUS',

      // Full responsive design for PWA - mobile view on web
      builder: (builderContext, child) {
        if (kIsWeb && child != null) {
          return WebMobileWrapper(
            mobileMaxWidth: 450,
            centerOnWeb: true,
            child: child,
          );
        }
        return child ?? const SizedBox();
      },

      // ✅ Localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // ✅ RTL Support - Arabic text direction
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null && locale.languageCode == 'ar') {
          return const Locale('ar');
        }
        return const Locale('en');
      },

      // ✅ Themes with dynamic font based on locale
      theme: AppThemes.getTheme(context),
      darkTheme: AppThemes.getTheme(context),
      themeMode: themeController.themeMode,

      // ✅ Routes
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
