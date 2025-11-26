// lib/core/widgets/web_mobile_wrapper.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Wrapper that makes the app look like a mobile app on web browsers
/// by constraining the width to mobile dimensions
class WebMobileWrapper extends StatelessWidget {
  final Widget child;
  final double mobileMaxWidth;
  final bool centerOnWeb;

  const WebMobileWrapper({
    super.key,
    required this.child,
    this.mobileMaxWidth = 450.0,
    this.centerOnWeb = true,
  });

  @override
  Widget build(BuildContext context) {
    // On mobile platforms, return child as-is
    if (!kIsWeb) {
      print('📱 WebMobileWrapper: Not on web, returning child as-is');
      return child;
    }

    print('🌐 WebMobileWrapper: On web platform, applying mobile layout');

    // On web, make it look EXACTLY like mobile app (450px centered)
    return LayoutBuilder(
      builder: (context, constraints) {
        print(
            '📐 Screen width: ${constraints.maxWidth}px, Mobile max: ${mobileMaxWidth}px');

        // If screen is wider than mobile, center and constrain to mobile size
        if (constraints.maxWidth > mobileMaxWidth && centerOnWeb) {
          print(
              '✅ Applying centered mobile layout (${mobileMaxWidth}px width)');
          return Container(
            color: Colors.black, // Black background on sides
            child: Center(
              child: Container(
                width: mobileMaxWidth, // 450px width
                height: constraints.maxHeight, // Full height
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipRect(
                  child: child,
                ),
              ),
            ),
          );
        }

        // If screen is mobile-sized, show normally
        print('📱 Screen is mobile-sized, showing full width');
        return child;
      },
    );
  }
}
