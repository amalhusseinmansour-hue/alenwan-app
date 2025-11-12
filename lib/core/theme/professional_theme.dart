import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Professional streaming platform theme with red brand colors
class ProfessionalTheme {
  // Brand Colors - Red palette with your preferred color
  static const Color primaryBrand = Color(0xFFa20136); // Your preferred red
  static const Color primaryBrandLight = Color(0xCCa20136); // 80% opacity
  static const Color secondaryBrand = Color(0xFF8e0030); // Deep red
  static const Color accentBrand = Color(0xFFd91e63); // Light red

  // Background Colors - Ultra dark for cinematic feel
  static const Color backgroundPrimary = Color(0xFF0A0A0F); // Near black
  static const Color backgroundSecondary = Color(0xFF12121A); // Dark surface
  static const Color backgroundElevated = Color(0xFF1A1A25); // Elevated surface
  static const Color backgroundOverlay = Color(0xFF1E1E2B); // Modal/overlay

  // Surface Colors with subtle gradients
  static const Color surfaceCard = Color(0xFF16161E);
  static const Color surfaceHover = Color(0xFF1F1F2A);
  static const Color surfaceActive = Color(0xFF252535);

  // Text Colors - High contrast for readability
  static const Color textPrimary = Color(0xFFF7F7F8); // Pure white
  static const Color textSecondary = Color(0xFFB4B4C4); // Muted text
  static const Color textTertiary = Color(0xFF7A7A8E); // Subtle text
  static const Color textInverse = Color(0xFF0A0A0F); // Dark text on light

  // Accent Colors for categories and states
  static const Color accentRed = Color(0xFFEF4444); // Live/New
  static const Color accentGreen = Color(0xFF10B981); // Success
  static const Color accentGold = Color(0xFFF59E0B); // Premium
  static const Color accentBlue = Color(0xFF3B82F6); // Info
  static const Color accentPink = Color(0xFFEC4899); // Kids
  static const Color accentCyan = Color(0xFF06B6D4); // Sports

  // Semantic Colors
  static const Color errorColor = Color(0xFFDC2626);
  static const Color warningColor = Color(0xFFFBBF24);
  static const Color successColor = Color(0xFF16A34A);
  static const Color infoColor = Color(0xFF0284C7);

  // Premium Gradients
  static LinearGradient get premiumGradient => const LinearGradient(
        colors: [primaryBrand, accentBrand],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get darkGradient => LinearGradient(
        colors: [
          backgroundPrimary,
          backgroundSecondary.withOpacity(0.9),
          backgroundPrimary,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static LinearGradient get cardGradient => LinearGradient(
        colors: [
          surfaceCard.withOpacity(0.9),
          surfaceCard.withOpacity(0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get shimmerGradient => LinearGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Premium Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: primaryBrand.withOpacity(0.1),
          blurRadius: 30,
          offset: const Offset(0, 15),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: primaryBrand.withOpacity(0.4),
          blurRadius: 25,
          offset: const Offset(0, 10),
          spreadRadius: -5,
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: accentBrand.withOpacity(0.6),
          blurRadius: 40,
          spreadRadius: 10,
        ),
      ];

  // Border Radius - Modern rounded corners
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusRound = 999.0;

  // Spacing System
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 400);
  static const Duration durationSlow = Duration(milliseconds: 600);
  static const Duration durationXSlow = Duration(milliseconds: 1000);

  // Typography System
  static TextStyle displayLarge({Color? color, FontWeight? weight}) =>
      TextStyle(
        fontSize: 56,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle displayMedium({Color? color, FontWeight? weight}) =>
      TextStyle(
        fontSize: 45,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle displaySmall({Color? color, FontWeight? weight}) =>
      TextStyle(
        fontSize: 36,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? textPrimary,
        letterSpacing: -0.25,
        height: 1.25,
      );

  static TextStyle headlineLarge({Color? color, FontWeight? weight}) =>
      TextStyle(
        fontSize: 32,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? textPrimary,
        letterSpacing: -0.25,
        height: 1.3,
      );

  static TextStyle headlineMedium({Color? color, FontWeight? weight}) =>
      TextStyle(
        fontSize: 28,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? textPrimary,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle headlineSmall({Color? color, FontWeight? weight}) =>
      TextStyle(
        fontSize: 24,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? textPrimary,
        height: 1.35,
      );

  static TextStyle titleLarge({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 20,
        fontWeight: weight ?? FontWeight.w500,
        color: color ?? textPrimary,
        height: 1.4,
      );

  static TextStyle titleMedium({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 16,
        fontWeight: weight ?? FontWeight.w500,
        color: color ?? textPrimary,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle titleSmall({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 14,
        fontWeight: weight ?? FontWeight.w500,
        color: color ?? textPrimary,
        letterSpacing: 0.1,
        height: 1.45,
      );

  static TextStyle bodyLarge({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 16,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? textPrimary,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 14,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? textPrimary,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle bodySmall({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 12,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? textSecondary,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle labelLarge({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 14,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? textPrimary,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle labelMedium({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 12,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? textSecondary,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle labelSmall({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 10,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? textTertiary,
        letterSpacing: 0.5,
        height: 1.4,
      );

  // Compatibility with old theme methods
  static TextStyle headline1({BuildContext? context, Color? color}) =>
      headlineLarge(color: color);
  static TextStyle headline2(
          {BuildContext? context,
          Color? color,
          FontWeight? fontWeight,
          double? fontSize,
          double? height,
          double? letterSpacing}) =>
      headlineMedium(color: color, weight: fontWeight);
  static TextStyle headline3(
          {BuildContext? context,
          Color? color,
          FontWeight? fontWeight,
          double? fontSize,
          double? height,
          double? letterSpacing}) =>
      headlineSmall(color: color, weight: fontWeight);
  static TextStyle subtitle1(
          {BuildContext? context,
          Color? color,
          FontWeight? fontWeight,
          double? fontSize,
          double? height,
          double? letterSpacing}) =>
      titleMedium(color: color, weight: fontWeight);
  static TextStyle subtitle2(
          {BuildContext? context,
          Color? color,
          FontWeight? fontWeight,
          double? fontSize,
          double? height,
          double? letterSpacing}) =>
      titleSmall(color: color, weight: fontWeight);

  static TextStyle body1({
    BuildContext? context,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color ?? textPrimary,
        height: height ?? 1.5,
        letterSpacing: letterSpacing ?? 0.1,
      );

  static TextStyle body2({
    BuildContext? context,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 12,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color ?? textSecondary,
        height: height ?? 1.5,
        letterSpacing: letterSpacing ?? 0.1,
      );

  static TextStyle caption({
    BuildContext? context,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 10,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color ?? textTertiary,
        height: height ?? 1.4,
        letterSpacing: letterSpacing ?? 0.5,
      );

  static TextStyle getTextStyle({
    BuildContext? context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? textPrimary,
        height: height,
        letterSpacing: letterSpacing,
      );

  // Component Decorations
  static BoxDecoration get glassMorphism => BoxDecoration(
        color: surfaceCard.withOpacity(0.4),
        borderRadius: BorderRadius.circular(radiusL),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: cardShadow,
      );

  static BoxDecoration get premiumCard => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            surfaceCard.withOpacity(0.9),
            surfaceCard.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radiusL),
        border: Border.all(
          color: primaryBrand.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: cardShadow,
      );

  // Utility Properties
  static BorderRadius get mediumRadius => BorderRadius.circular(radiusM);
  static const Color accentColor = primaryBrand;
  static Color get primaryColor => primaryBrand;
  static Color get secondaryColor => secondaryBrand;
  static Color get backgroundColor => backgroundPrimary;
  static Color get surfaceColor => backgroundSecondary;
  static const Color cardColor = surfaceCard;

  // Common Widgets
  static Widget shimmerEffect({
    required Widget child,
    required bool isLoading,
  }) {
    if (!isLoading) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: shimmerGradient,
            ),
          ),
        ),
      ],
    );
  }

  static Widget premiumBadge({String text = 'PREMIUM'}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: space8,
        vertical: space4,
      ),
      decoration: BoxDecoration(
        gradient: premiumGradient,
        borderRadius: BorderRadius.circular(radiusS),
      ),
      child: Text(
        text,
        style: labelSmall(color: textPrimary, weight: FontWeight.w700),
      ),
    );
  }

  static Widget liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: space8,
        vertical: space4,
      ),
      decoration: BoxDecoration(
        color: accentRed,
        borderRadius: BorderRadius.circular(radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: space4),
          Text(
            'LIVE',
            style: labelSmall(color: textPrimary, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  static Widget categoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radiusRound),
      child: AnimatedContainer(
        duration: durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: space16,
          vertical: space8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? premiumGradient : null,
          color: isSelected ? null : surfaceCard,
          borderRadius: BorderRadius.circular(radiusRound),
          border: Border.all(
            color:
                isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: labelMedium(
            color: isSelected ? textPrimary : textSecondary,
            weight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Old compatibility properties
  static BoxDecoration glassDecoration({
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) =>
      BoxDecoration(
        gradient: cardGradient,
        borderRadius: borderRadius ?? mediumRadius,
        boxShadow: boxShadow ?? cardShadow,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      );

  // Animation helpers
  static const Duration animationFast = durationFast;
  static const Duration animationNormal = durationMedium;
  static const Duration animationSlow = durationSlow;

  // Spacing helpers
  static const double spacingXS = space4;
  static const double spacingS = space8;
  static const double spacingM = space16;
  static const double spacingL = space24;
  static const double spacingXL = space32;

  // Radius helpers
  static const double radiusSmall = radiusS;
  static const double radiusMedium = radiusM;
  static const double radiusLarge = radiusL;
  static const double radiusXLarge = radiusXL;

  // Gradient helpers
  static LinearGradient get primaryGradient => premiumGradient;
  static LinearGradient get backgroundGradient => darkGradient;

  // Shadow helpers
  static List<BoxShadow> get primaryShadow => cardShadow;

  // Accent color helper
  static const Color accentOrange = accentGold;
}

// Modern animated background painter
class AnimatedBackgroundPainter extends CustomPainter {
  final double animation;
  final Color color1;
  final Color color2;

  AnimatedBackgroundPainter({
    required this.animation,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          math.sin(animation * 2 * math.pi) * 0.5,
          math.cos(animation * 2 * math.pi) * 0.5,
        ),
        radius: 1.5,
        colors: [
          color1.withOpacity(0.3),
          color2.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
