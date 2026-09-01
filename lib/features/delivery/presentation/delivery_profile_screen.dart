import 'package:bhm_supermarket/core/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../app/localization/language_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/patterns/app_responsive.dart';

class DeliveryProfileScreen extends StatelessWidget {
  const DeliveryProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
  return GetBuilder<AuthController>(
    builder: (_) => GetBuilder<ThemeController>(
    builder: (_) => GetBuilder<LanguageController>(
    builder: (_) => _buildGetX0(context))));
  }

  Widget _buildGetX0(BuildContext context) {
    final user = Get.find<AuthController>().user;
    final theme = Get.find<ThemeController>();
    final lang = Get.find<LanguageController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppPageHeader(title: lang.t('profile'), showBack: false),
      body: AppConstrainedContent(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.lg),
          children: [
            // بطاقة المعلومات
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: AppIcon(
                        Icons.delivery_dining,
                        size: AppIconSize.large,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'سائق التوصيل',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            user?.phone ?? '',
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
  
            // إعدادات
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: AppIcon(Icons.dark_mode_outlined, size: AppIconSize.medium),
                    title: Text(lang.t('dark_mode'), style: AppTypography.bodyLarge),
                    value: theme.isDark,
                    activeThumbColor: colorScheme.primary,
                    onChanged: theme.setDark,
                  ),
                  ListTile(
                    leading: AppIcon(Icons.language, size: AppIconSize.medium),
                    title: Text(lang.t('language'), style: AppTypography.bodyLarge),
                    subtitle: Text(
                      lang.isArabic ? 'العربية' : lang.t('english'),
                      style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    trailing: ToggleButtons(
                      borderRadius: BorderRadius.circular(8),
                      isSelected: [lang.isArabic, lang.isEnglish],
                      onPressed: (i) =>
                          i == 0 ? lang.setArabic() : lang.setEnglish(),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('ع'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('EN'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
  
            // تسجيل الخروج
            ListTile(
              tileColor: colorScheme.error.withValues(alpha: 0.06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: AppIcon(Icons.logout, color: colorScheme.error, size: AppIconSize.medium),
              title: Text(
                lang.t('logout'),
                style: AppTypography.titleMedium.copyWith(color: colorScheme.error),
              ),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: Text(lang.t('logout')),
                      content: Text(lang.t('logout_confirm')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(lang.t('cancel')),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                          ),
                          child: Text(lang.t('logout')),
                        ),
                      ],
                    );
                  },
                );
  
                if (confirmed != true || !context.mounted) return;
  
                await Get.find<AuthController>().logout();
  
                if (!context.mounted) return;
                context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
