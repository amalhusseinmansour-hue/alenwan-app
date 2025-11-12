// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Burgundy Premium Theme Colors
  static const Color primaryColor = Color(0xFFA20136);
  static const Color secondaryColor = Color(0xFF6B0024);
  static const Color accentColor = Color(0xFFD4024B);
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF151515);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [backgroundColor, surfaceColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Box Shadows
  static final List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primaryColor.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  // Border Radius
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(8));
  static const BorderRadius mediumRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(20));
  static const BorderRadius extraLargeRadius = BorderRadius.all(Radius.circular(30));

  // Text Styles - استخدام Noto Kufi Arabic
  static TextStyle headlineLarge = GoogleFonts.notoKufiArabic(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle headlineMedium = GoogleFonts.notoKufiArabic(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.4,
  );

  static TextStyle headlineSmall = GoogleFonts.notoKufiArabic(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle bodyLarge = GoogleFonts.notoKufiArabic(
    fontSize: 16,
    color: textPrimary,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.notoKufiArabic(
    fontSize: 14,
    color: textSecondary,
    height: 1.6,
  );

  static TextStyle bodySmall = GoogleFonts.notoKufiArabic(
    fontSize: 12,
    color: textTertiary,
    height: 1.5,
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: GoogleFonts.notoKufiArabic().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: headlineMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: mediumRadius,
          ),
          elevation: 4,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: mediumRadius,
        ),
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        onSurface: textPrimary,
        error: Color(0xFFFF3333),
      ),
    );
  }

  // Text Style Helper Method
  static TextStyle getTextStyle({
    required BuildContext context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.notoKufiArabic(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? textPrimary,
      letterSpacing: letterSpacing,
      height: height ?? 1.6,
    );
  }

  // Glass Morphism Effect
  static BoxDecoration glassDecoration({
    Color? color,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white.withOpacity(0.1),
      borderRadius: borderRadius ?? mediumRadius,
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: boxShadow ?? cardShadow,
    );
  }

  // Gradient Button Style
  static BoxDecoration gradientButtonDecoration({
    LinearGradient? gradient,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: borderRadius ?? extraLargeRadius,
      boxShadow: primaryShadow,
    );
  }
}