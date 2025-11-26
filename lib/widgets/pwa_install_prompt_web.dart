import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';

class PWAInstallPrompt extends StatefulWidget {
  const PWAInstallPrompt({super.key});

  @override
  State<PWAInstallPrompt> createState() => _PWAInstallPromptState();
}

class _PWAInstallPromptState extends State<PWAInstallPrompt> {
  bool _showInstall = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _checkInstallAvailability();
    }
  }

  Future<void> _checkInstallAvailability() async {
    // Check if user already dismissed the prompt
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool('pwa_install_dismissed') ?? false;

    if (dismissed) {
      setState(() => _dismissed = true);
      return;
    }

    // Check if PWA is already installed
    if (html.window.matchMedia('(display-mode: standalone)').matches) {
      print('✅ PWA is already installed');
      return;
    }

    // Listen for the PWA install available event
    html.window.addEventListener('pwaInstallAvailable', (_) {
      if (mounted && !_dismissed) {
        setState(() => _showInstall = true);
      }
    });

    // Listen for PWA installed event
    html.window.addEventListener('pwaInstalled', (_) {
      if (mounted) {
        setState(() => _showInstall = false);
      }
    });
  }

  Future<void> _showInstallPrompt() async {
    try {
      // Call the JavaScript function to show install prompt
      js.context.callMethod('showPWAInstall', []);
      print('Install prompt triggered');
    } catch (e) {
      print('Error showing install prompt: $e');
    }
  }

  Future<void> _dismissPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pwa_install_dismissed', true);
    setState(() {
      _showInstall = false;
      _dismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !_showInstall || _dismissed) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1a1a2e),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                const Color(0xFF1a1a2e),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.install_mobile,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Text
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'أضف للشاشة الرئيسية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'للوصول السريع والتجربة الأفضل',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Install Button
                  ElevatedButton(
                    onPressed: _showInstallPrompt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'تثبيت',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Close Button
                  TextButton(
                    onPressed: _dismissPrompt,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: const Text(
                      'لاحقاً',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
