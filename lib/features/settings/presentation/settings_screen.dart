import 'package:bhm_supermarket/core/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../app/localization/language_controller.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/design_system/components/app_icon.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
  return GetBuilder<ThemeController>(
    builder: (_) => GetBuilder<LanguageController>(
    builder: (_) => _buildGetX0(context)));
  }

  Widget _buildGetX0(BuildContext context) {
    final theme = Get.find<ThemeController>();
    final lang = Get.find<LanguageController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppPageHeader(title: 'الإعدادات'),
      body: AppConstrainedContent(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            // المظهر
            const _SectionHeader('المظهر والواجهة'),
            SwitchListTile(
              secondary: AppIcon(
                theme.isDark ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
              title: Text('الوضع الليلي', style: AppTypography.titleMedium),
              subtitle: Text(
                theme.isDark ? 'مفعّل' : 'معطّل',
                style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              value: theme.isDark,
              activeThumbColor: colorScheme.primary,
              onChanged: theme.setDark,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            ),
            ListTile(
              leading: AppIcon(Icons.language, color: colorScheme.primary, size: AppIconSize.medium),
              title: Text('اللغة', style: AppTypography.titleMedium),
              subtitle: Text(
                lang.isArabic ? 'العربية' : 'English',
                style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              trailing: ToggleButtons(
                borderRadius: AppRadius.mdRadius,
                isSelected: [lang.isArabic, lang.isEnglish],
                selectedColor: colorScheme.onPrimary,
                fillColor: colorScheme.primary,
                color: colorScheme.onSurface,
                onPressed: (i) => i == 0 ? lang.setArabic() : lang.setEnglish(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Text(
                      'ع',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Text(
                      'EN',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: AppSpacing.xl),

            // الحساب
            const _SectionHeader('الحساب'),
            ListTile(
              leading: AppIcon(
                Icons.notifications_outlined,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
              title: Text('الإشعارات', style: AppTypography.titleMedium),
              trailing: AppIcon(Icons.chevron_left, color: colorScheme.outline, size: AppIconSize.medium, directionSensitive: true),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              onTap: () => context.push(AppRoutes.notifications),
            ),
            ListTile(
              leading: AppIcon(
                Icons.location_on_outlined,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
              title: Text('عناوين التوصيل', style: AppTypography.titleMedium),
              trailing: AppIcon(Icons.chevron_left, color: colorScheme.outline, size: AppIconSize.medium, directionSensitive: true),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              onTap: () => context.push(AppRoutes.addresses),
            ),
            const Divider(height: AppSpacing.xl),

            // معلومات
            const _SectionHeader('معلومات'),
            ListTile(
              leading: AppIcon(Icons.info_outline, color: colorScheme.primary, size: AppIconSize.medium),
              title: Text('من نحن', style: AppTypography.titleMedium),
              trailing: AppIcon(Icons.chevron_left, color: colorScheme.outline, size: AppIconSize.medium, directionSensitive: true),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              onTap: () => context.push(AppRoutes.aboutUs),
            ),
            ListTile(
              leading: AppIcon(
                Icons.privacy_tip_outlined,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
              title: Text('سياسة الخصوصية', style: AppTypography.titleMedium),
              trailing: AppIcon(Icons.chevron_left, color: colorScheme.outline, size: AppIconSize.medium, directionSensitive: true),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              onTap: () => context.push(AppRoutes.privacyPolicy),
            ),
            ListTile(
              leading: AppIcon(
                Icons.description_outlined,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
              title: Text('شروط الاستخدام', style: AppTypography.titleMedium),
              trailing: AppIcon(Icons.chevron_left, color: colorScheme.outline, size: AppIconSize.medium, directionSensitive: true),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              onTap: () => context.push(AppRoutes.termsOfUse),
            ),
            const Divider(height: AppSpacing.xl),

            // الإصدار
            ListTile(
              leading: AppIcon(Icons.info_outline, color: colorScheme.onSurfaceVariant, size: AppIconSize.medium),
              title: Text(
                'إصدار التطبيق',
                style: AppTypography.titleMedium.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              trailing: Text(
                'v1.0.0',
                style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
