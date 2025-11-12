import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../core/theme/professional_theme.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool centerTitle;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.ltr;

    return AppBar(
      backgroundColor: ProfessionalTheme.backgroundSecondary,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                color: ProfessionalTheme.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: const Icon(Icons.menu, color: ProfessionalTheme.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      title: Text(
        title,
        style: ProfessionalTheme.headlineMedium(
          color: ProfessionalTheme.textPrimary,
        ),
      ),
      actions: actions ??
          [
            IconButton(
              icon: const Icon(Icons.search, color: ProfessionalTheme.textPrimary),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: ProfessionalTheme.textPrimary),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
            const SizedBox(width: 8),
          ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}