import 'package:alenwan/views/live/live_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:alenwan/views/home/home_screen.dart';

import 'package:alenwan/views/downloads/downloads_screen.dart';
import 'package:alenwan/views/profile/profile_screen.dart';
import 'package:alenwan/views/search/search_screen.dart';
import 'package:alenwan/views/common/custom_bottom_nav.dart';
import 'package:alenwan/controllers/subscription_controller.dart';
import 'package:alenwan/controllers/auth_controller.dart';
import 'package:alenwan/widgets/pwa_install_prompt.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const DownloadsScreen(),
    const LivePageScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for smooth transitions
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    _transitionController.forward();

    // Load subscription status on app start (only if not in guest mode)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      if (!authController.isGuestMode && authController.token != null) {
        context.read<SubscriptionController>().load();
      }
    });
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index != _currentIndex) {
      _transitionController.reset();
      setState(() {
        _currentIndex = index;
      });
      _transitionController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              );
            },
          ),
          // PWA Install Prompt (only on web)
          if (kIsWeb) const PWAInstallPrompt(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
