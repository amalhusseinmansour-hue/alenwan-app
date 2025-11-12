import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/modern_bottom_nav.dart';
import 'home/modern_home_screen.dart';
import 'explore/explore_screen.dart';
import 'live/live_screen.dart';
import 'downloads/downloads_screen.dart';
import 'profile/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const ModernHomeScreen(),
    const ExploreScreen(),
    const LiveScreen(),
    const DownloadsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    // Set system UI
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: _screens,
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ModernBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                _pageController.jumpToPage(index);
                _onPageChanged(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
