import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/widgets/app_page_header.dart';

class NotificationModel {
  final String title;
  final String body;
  final DateTime date;
  final bool read;

  const NotificationModel({
    required this.title,
    required this.body,
    required this.date,
    this.read = false,
  });
}

/// شاشة الإشعارات: العروض والتنبيهات (الصفحة رقم 15 في الوثيقة).
/// حالياً تعرض بيانات تجريبية إلى حين توفر API الإشعارات.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = <NotificationModel>[
      NotificationModel(
        title: 'عرض خاص اليوم!',
        body: 'خصم 20% على جميع منتجات الألبان حتى نهاية اليوم.',
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        title: 'تم شحن طلبك',
        body: 'طلبك رقم #1042 خرج للتوصيل الآن.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        read: true,
      ),
    ];

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppPageHeader(title: 'الإشعارات'),
      body: AppConstrainedContent(
        child: notifications.isEmpty
            ? const AppEmptyState(
                icon: Icons.notifications_off_outlined,
                title: 'لا توجد إشعارات',
                subtitle: 'لا توجد إشعارات حالياً',
              )
            : RefreshIndicator(
                onRefresh: () async {
                  // Notifications API response is not wired in this project yet.
                  // Keep the gesture ready without inventing a backend contract.
                  await Future<void>.delayed(const Duration(milliseconds: 350));
                },
                color: colorScheme.primary,
                child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    color: colorScheme.surface,
                    margin: EdgeInsets.zero,
                    child: Material(
                      color: n.read ? Colors.transparent : colorScheme.primary.withValues(alpha: 0.06),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        leading: AppIcon(
                          Icons.notifications_outlined,
                          color: colorScheme.primary,
                          size: AppIconSize.medium,
                        ),
                        title: Text(
                          n.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            n.body,
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        trailing: !n.read
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
                ),
      ),
    );
  }
}
