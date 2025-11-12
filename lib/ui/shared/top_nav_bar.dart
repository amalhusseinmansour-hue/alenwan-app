import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavBar({super.key, required this.isWide, required this.selectedKey});

  final bool isWide;
  final String selectedKey;

  static const Map<String, String> _navItems = {
    'الرئيسية': AppRoutes.home,
    'المسلسلات': AppRoutes.allSeries,
    'الأفلام': AppRoutes.allMovies,
    'الرياضة': AppRoutes.allSports,
    'الوثائقيات': AppRoutes.allDocumentaries,
    'الأطفال': AppRoutes.allCartoons,
  };

  Widget _navItem(BuildContext ctx, String title, String route) {
    final selected = title == selectedKey;
    return InkWell(
      onTap: () {
        if (ModalRoute.of(ctx)?.settings.name != route) {
          Navigator.pushNamed(ctx, route);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              // ignore: deprecated_member_use
              selected
                  ? Colors.redAccent.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.redAccent.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.redAccent : Colors.white,
            fontSize: 15,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          // ignore: deprecated_member_use
          child: Container(color: Colors.black.withValues(alpha: 0.3)),
        ),
      ),
      leading: !isWide
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      title: Row(
        children: [
          Image.asset('assets/images/logo-alenwan.jpeg', height: 36),
          if (isWide)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final e in _navItems.entries)
                    _navItem(context, e.key, e.value),
                ],
              ),
            )
          else
            const Spacer(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
