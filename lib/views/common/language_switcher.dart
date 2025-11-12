import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../controllers/settings_controller.dart';
import '../../config/app_colors.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showTitle;
  final bool useIcons;

  const LanguageSwitcher({
    super.key,
    this.showTitle = true,
    this.useIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentLanguage = context.locale.languageCode;
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle) ...[
          Text(
            'language'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // زر اللغة العربية
            _buildLanguageButton(
              context: context,
              title: 'العربية',
              icon: Icons.language,
              languageCode: 'ar',
              isSelected: currentLanguage == 'ar',
              onTap: () => settingsController.setLanguage(context, 'ar'),
            ),
            const SizedBox(width: 16),
            // زر اللغة الإنجليزية
            _buildLanguageButton(
              context: context,
              title: 'English',
              icon: Icons.language,
              languageCode: 'en',
              isSelected: currentLanguage == 'en',
              onTap: () => settingsController.setLanguage(context, 'en'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String languageCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (useIcons) ...[
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
