import 'package:bhm_supermarket/core/widgets/app_page_header.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/patterns/app_responsive.dart';

/// صفحة نصية عامة تُستخدم لعرض: من نحن، اتصل بنا، الأسئلة الشائعة،
/// سياسة الخصوصية، شروط الاستخدام. هذه الصفحات مذكورة في الوثيقة
/// ("صفحات إضافية مهمة") ولم تكن موجودة في المشروع إطلاقاً.
class StaticInfoScreen extends StatelessWidget {
  final String title;
  final String content;

  const StaticInfoScreen({
    super.key,
    required this.title,
    required this.content,
  });

  /// نسخة جاهزة لصفحة "اتصل بنا" تحتوي على وسائل تواصل بدل النص فقط.
  static Widget contactUs() => const _ContactUsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppPageHeader(title: title),
      body: AppConstrainedContent(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            content,
            style: AppTypography.bodyLarge.copyWith(height: 1.8),
          ),
        ),
      ),
    );
  }
}

class _ContactUsScreen extends StatelessWidget {
  const _ContactUsScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppPageHeader(title: 'اتصل بنا'),
      body: AppConstrainedContent(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            ListTile(
              leading: AppIcon(
                Icons.phone_outlined,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
              title: Text('اتصل بنا', style: AppTypography.titleMedium),
              subtitle: Text(
                '+966 5X XXX XXXX',
                style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            ),
            ListTile(
              leading: AppIcon(
                Icons.email_outlined,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
              title: Text('البريد الإلكتروني', style: AppTypography.titleMedium),
              subtitle: Text(
                'support@bhmmall.com',
                style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            ),
            ListTile(
              leading: AppIcon(
                Icons.location_on_outlined,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
              title: Text('العنوان', style: AppTypography.titleMedium),
              subtitle: Text(
                'المملكة العربية السعودية',
                style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            ),
            ListTile(
              leading: AppIcon(
                Icons.chat_outlined,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
              title: Text('واتساب خدمة العملاء', style: AppTypography.titleMedium),
              subtitle: Text(
                '+966 5X XXX XXXX',
                style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            ),
          ],
        ),
      ),
    );
  }
}
