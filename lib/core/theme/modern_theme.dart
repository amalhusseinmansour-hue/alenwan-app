// Re-export ProfessionalTheme as ModernTheme for compatibility
import 'package:flutter/material.dart';
import 'professional_theme.dart';

// Alias for backward compatibility
class ModernTheme extends ProfessionalTheme {
  // Forward all static methods to ProfessionalTheme
  static TextStyle subtitle1({BuildContext? context, Color? color, FontWeight? fontWeight, double? fontSize, double? height, double? letterSpacing}) =>
      ProfessionalTheme.subtitle1(context: context, color: color, fontWeight: fontWeight, fontSize: fontSize, height: height, letterSpacing: letterSpacing);

  static TextStyle subtitle2({BuildContext? context, Color? color, FontWeight? fontWeight, double? fontSize, double? height, double? letterSpacing}) =>
      ProfessionalTheme.subtitle2(context: context, color: color, fontWeight: fontWeight, fontSize: fontSize, height: height, letterSpacing: letterSpacing);

  static TextStyle headline1({BuildContext? context, Color? color, FontWeight? fontWeight, double? fontSize, double? height, double? letterSpacing}) =>
      ProfessionalTheme.headline1(context: context, color: color);

  static TextStyle headline2({BuildContext? context, Color? color, FontWeight? fontWeight, double? fontSize, double? height, double? letterSpacing}) =>
      ProfessionalTheme.headline2(context: context, color: color, fontWeight: fontWeight, fontSize: fontSize, height: height, letterSpacing: letterSpacing);

  static TextStyle headline3({BuildContext? context, Color? color, FontWeight? fontWeight, double? fontSize, double? height, double? letterSpacing}) =>
      ProfessionalTheme.headline3(context: context, color: color, fontWeight: fontWeight, fontSize: fontSize, height: height, letterSpacing: letterSpacing);

  static TextStyle caption({BuildContext? context, Color? color, FontWeight? fontWeight, double? fontSize, double? height, double? letterSpacing}) =>
      ProfessionalTheme.caption(context: context, color: color, fontWeight: fontWeight, fontSize: fontSize, height: height, letterSpacing: letterSpacing);

  static TextStyle body1({BuildContext? context, Color? color, FontWeight? fontWeight, double? fontSize, double? height, double? letterSpacing}) =>
      ProfessionalTheme.body1(context: context, color: color, fontWeight: fontWeight, fontSize: fontSize, height: height, letterSpacing: letterSpacing);

  static TextStyle body2({BuildContext? context, Color? color, FontWeight? fontWeight, double? fontSize, double? height, double? letterSpacing}) =>
      ProfessionalTheme.body2(context: context, color: color, fontWeight: fontWeight, fontSize: fontSize, height: height, letterSpacing: letterSpacing);

  static TextStyle getTextStyle({BuildContext? context, Color? color, FontWeight? fontWeight, double? fontSize, double? height, double? letterSpacing, TextStyle? baseStyle}) =>
      ProfessionalTheme.getTextStyle(context: context, color: color, fontWeight: fontWeight, fontSize: fontSize, height: height, letterSpacing: letterSpacing);

  // Forward color properties as const
  static const Color primaryColor = ProfessionalTheme.primaryBrand;
  static const Color secondaryColor = ProfessionalTheme.secondaryBrand;
  static const Color backgroundColor = ProfessionalTheme.backgroundPrimary;
  static const Color surfaceColor = ProfessionalTheme.backgroundSecondary;
  static const Color textPrimary = ProfessionalTheme.textPrimary;
  static const Color textSecondary = ProfessionalTheme.textSecondary;
  static const Color textTertiary = ProfessionalTheme.textTertiary;
  static const Color accentColor = ProfessionalTheme.primaryBrand;

  // Forward text styles
  static TextStyle get bodyMedium => ProfessionalTheme.bodyMedium();
  static TextStyle get bodySmall => ProfessionalTheme.bodySmall();
  static TextStyle get headlineSmall => ProfessionalTheme.headlineSmall();

  // Forward other properties
  static BorderRadius get mediumRadius => ProfessionalTheme.mediumRadius;
  static List<BoxShadow> get cardShadow => ProfessionalTheme.cardShadow;

  // Forward decoration methods
  static BoxDecoration glassDecoration({BorderRadius? borderRadius, List<BoxShadow>? boxShadow}) =>
      ProfessionalTheme.glassMorphism;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      ProfessionalTheme.primaryBrand,
      ProfessionalTheme.accentCyan,
    ],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      ProfessionalTheme.secondaryBrand,
      ProfessionalTheme.accentBlue,
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      ProfessionalTheme.backgroundPrimary,
      ProfessionalTheme.backgroundSecondary,
    ],
  );

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;  // Alias for spacingSm
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusSmall = 8.0;  // Alias for radiusSm
  static const double radiusMd = 12.0;
  static const double radiusMedium = 12.0;  // Alias for radiusMd
  static const double radiusLg = 16.0;
  static const double radiusLarge = 16.0;  // Alias for radiusLg
  static const double radiusXl = 20.0;
  static const double radiusXLarge = 24.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Additional spacing aliases
  static const double spacingXS = 4.0;  // Alias for spacingXs
  static const double spacingM = 16.0;  // Alias for spacingMd
  static const double spacingL = 24.0;  // Alias for spacingLg
  static const double spacingXL = 32.0;  // Alias for spacingXl

  // Animation duration alias
  static const Duration animationNormal = animationMedium;

  // Glow shadow for effects
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.6),
      blurRadius: 40,
      spreadRadius: 10,
    ),
  ];

  // Primary shadow for cards and elevated elements
  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 10),
    ),
  ];

  // Widget methods
  static Widget animatedBackground({Widget? child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: darkGradient,
      ),
      child: child,
    );
  }

  static Widget particleOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
          ],
        ),
      ),
    );
  }

  // Modern card decoration
  static BoxDecoration modernCard({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? surfaceColor,
      borderRadius: borderRadius ?? BorderRadius.circular(radiusMd),
      boxShadow: boxShadow ?? cardShadow,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
    );
  }

  // Gradient button widget
  static Widget gradientButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool isPrimary = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary ? primaryGradient : null,
        color: isPrimary ? null : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radiusLarge),
        border: Border.all(
          color: isPrimary ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(radiusLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: spacingL,
              vertical: spacingM,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: spacingS),
                ],
                Text(
                  label,
                  style: subtitle1(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}