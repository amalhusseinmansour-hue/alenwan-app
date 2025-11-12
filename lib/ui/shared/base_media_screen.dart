import 'package:flutter/material.dart';
import '../../views/home/app_drawer.dart';
import 'top_nav_bar.dart';

class BaseMediaScreen extends StatelessWidget {
  const BaseMediaScreen({
    super.key,
    required this.selectedTab, // 'الأفلام'، 'الأطفال' ...
    required this.backgroundAsset, // صورة الخلفية
    required this.child, // محتوى الصفحة
    this.maxContentWidth = 1400,
    this.topPadding = kToolbarHeight + 60,
    this.wideBreakpoint = 1100,
    this.gradient, // اختيارية: override للـ gradient
  });

  final String selectedTab;
  final String backgroundAsset;
  final Widget child;
  final double maxContentWidth;
  final double topPadding;
  final double wideBreakpoint;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= wideBreakpoint;
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          drawer: !isWide ? const AppDrawer() : null,
          appBar: TopNavBar(isWide: isWide, selectedKey: selectedTab),
          body: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(backgroundAsset),
                      fit: BoxFit.cover,
                    ),
                    gradient:
                        gradient ??
                        LinearGradient(
                          colors: [
                            // ignore: deprecated_member_use
                            Colors.black.withValues(alpha: 0.75),
                            // ignore: deprecated_member_use
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.only(top: topPadding),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
