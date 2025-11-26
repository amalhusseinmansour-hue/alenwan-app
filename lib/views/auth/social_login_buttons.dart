import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class SocialLoginRow extends StatelessWidget {
  final VoidCallback? onGoogle;
  final VoidCallback? onApple;
  final VoidCallback? onPhoneOrWhatsApp;

  const SocialLoginRow({
    super.key,
    this.onGoogle,
    this.onApple,
    this.onPhoneOrWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: Colors.white24, thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('أو المتابعة مع',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ),
            Expanded(child: Divider(color: Colors.white24, thickness: 1)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Sign-In
            if (onGoogle != null)
              _SocialCircleButton(
                tooltip: 'Google',
                icon: Icons.g_mobiledata_rounded, // أو استخدم أيقونة أخرى
                backgroundColor: Colors.white,
                onTap: onGoogle,
              ),

            // Apple Sign-In - Show only on iOS or Web
            if (onApple != null && (!kIsWeb && Platform.isIOS || kIsWeb)) ...[
              const SizedBox(width: 20),
              _SocialCircleButton(
                tooltip: 'Apple',
                icon: Icons.apple,
                backgroundColor: Colors.white,
                onTap: onApple,
              ),
            ],

            // Phone/WhatsApp
            if (onPhoneOrWhatsApp != null) ...[
              const SizedBox(width: 20),
              _SocialCircleButton(
                tooltip: 'الهاتف / واتساب',
                icon: Icons.phone_iphone,
                backgroundColor: Colors.white,
                onTap: onPhoneOrWhatsApp,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  final String? asset;
  final IconData? icon;
  final String? tooltip;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _SocialCircleButton({
    this.asset,
    this.icon,
    required this.backgroundColor,
    this.onTap,
    this.tooltip,
  }) : assert(asset != null || icon != null, 'Provide asset or icon');

  @override
  Widget build(BuildContext context) {
    final child = (asset != null)
        ? SizedBox(
        width: 28, height: 28, child: Image.asset(asset!, fit: BoxFit.contain))
        : Icon(icon, size: 28, color: Colors.black);

    final w = GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
    return tooltip == null ? w : Tooltip(message: tooltip!, child: w);
  }
}
