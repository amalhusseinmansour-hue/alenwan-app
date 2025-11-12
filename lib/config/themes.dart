import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  // Get font style based on locale with Noto Kufi Arabic
  static TextStyle getTextStyle(BuildContext context, {
    double fontSize = 14,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    final locale = context.locale;
    final isArabic = locale.languageCode == 'ar';

    // ✨ استخدام Noto Kufi Arabic للنصوص العربية
    if (isArabic) {
      return GoogleFonts.notoKufiArabic(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? Colors.white,
        letterSpacing: letterSpacing,
        height: height ?? 1.6,
      );
    }

    // استخدام Roboto للإنجليزية
    return GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? Colors.white,
      letterSpacing: letterSpacing,
      height: height ?? 1.4,
    );
  }

  // Netflix-inspired theme with Arabic support
  static ThemeData getTheme(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFA20136), // Updated brand color
        secondary: Colors.white,
        surface: Color(0xFF141414),
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: getTextStyle(
          context,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF141414),
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA20136),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: getTextStyle(
            context,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFA20136),
          textStyle: getTextStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFA20136)),
          textStyle: getTextStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFA20136), width: 2),
        ),
        hintStyle: getTextStyle(
          context,
          color: Colors.white54,
        ),
        labelStyle: getTextStyle(
          context,
          color: Colors.white70,
        ),
      ),
      textTheme: TextTheme(
        // Display styles
        displayLarge: getTextStyle(
          context,
          fontSize: isArabic ? 40 : 36,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: getTextStyle(
          context,
          fontSize: isArabic ? 34 : 32,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: getTextStyle(
          context,
          fontSize: isArabic ? 30 : 28,
          fontWeight: FontWeight.w600,
        ),

        // Headline styles
        headlineLarge: getTextStyle(
          context,
          fontSize: isArabic ? 28 : 26,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: getTextStyle(
          context,
          fontSize: isArabic ? 24 : 22,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: getTextStyle(
          context,
          fontSize: isArabic ? 20 : 18,
          fontWeight: FontWeight.w600,
        ),

        // Title styles
        titleLarge: getTextStyle(
          context,
          fontSize: isArabic ? 20 : 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: getTextStyle(
          context,
          fontSize: isArabic ? 18 : 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: getTextStyle(
          context,
          fontSize: isArabic ? 16 : 14,
          fontWeight: FontWeight.w500,
        ),

        // Body styles
        bodyLarge: getTextStyle(
          context,
          fontSize: isArabic ? 18 : 16,
        ),
        bodyMedium: getTextStyle(
          context,
          fontSize: isArabic ? 16 : 14,
          color: Colors.white70,
        ),
        bodySmall: getTextStyle(
          context,
          fontSize: isArabic ? 14 : 12,
          color: Colors.white60,
        ),

        // Label styles
        labelLarge: getTextStyle(
          context,
          fontSize: isArabic ? 16 : 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        labelMedium: getTextStyle(
          context,
          fontSize: isArabic ? 14 : 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: getTextStyle(
          context,
          fontSize: isArabic ? 12 : 10,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Static themes for backward compatibility
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFA20136),
        secondary: Colors.white,
        surface: Color(0xFF141414),
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF141414),
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA20136),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}

// Helper class for simplified theme access (compatibility)
class AppThemeOld {
  static TextStyle getTextStyle({
    BuildContext? context,
    double fontSize = 14,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    // Use context if provided
    if (context != null) {
      return AppThemes.getTextStyle(
        context,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    // Fallback for calls without context - استخدام Noto Kufi Arabic
    return GoogleFonts.notoKufiArabic(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? Colors.white,
      letterSpacing: letterSpacing,
      height: height ?? 1.6,
    );
  }
}