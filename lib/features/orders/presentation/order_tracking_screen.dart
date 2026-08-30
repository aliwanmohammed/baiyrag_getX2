import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/widgets/app_page_header.dart';

import '../models/order_status.dart';

/// شاشة تتبع الطلب (الصفحة رقم 11 في الوثيقة).
/// تعرض مراحل الطلب بشكل مرئي مع المرحلة الحالية مبرزة.
class OrderTrackingScreen extends StatelessWidget {
  final String orderNumber;
  final OrderStatus currentStatus;

  const OrderTrackingScreen({
    super.key,
    required this.orderNumber,
    this.currentStatus = OrderStatus.preparing,
  });

  @override
  Widget build(BuildContext context) {
    // مراحل الطلب الطبيعية (بدون "ملغي")
    const stages = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    final currentIndex = stages.indexOf(currentStatus);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppPageHeader(title: 'تتبع الطلب #$orderNumber'),
      body: SafeArea(
        child: AppConstrainedContent(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: currentStatus == OrderStatus.cancelled
                ? _buildCancelled(colorScheme)
                : Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      ...List.generate(stages.length, (i) {
                        final isDone = i <= currentIndex;
                        final isActive = i == currentIndex;
                        final isLast = i == stages.length - 1;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // العمود الأيمن: أيقونة + خط
                            Column(
                              children: [
                                _stepCircle(stages[i], isDone, isActive, colorScheme),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: 50,
                                    color: isDone
                                        ? colorScheme.primary
                                        : colorScheme.outlineVariant,
                                  ),
                              ],
                            ),

                            const SizedBox(width: AppSpacing.md),

                            // النص
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stages[i].label,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isDone
                                            ? colorScheme.onSurface
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    if (isActive)
                                      Padding(
                                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                                        child: Text(
                                          'المرحلة الحالية',
                                          style: AppTypography.labelMedium.copyWith(
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 44),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _stepCircle(OrderStatus status, bool isDone, bool isActive, ColorScheme colorScheme) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? colorScheme.primary : colorScheme.surfaceContainerHighest,
        border:
            isActive ? Border.all(color: colorScheme.primary, width: 3) : null,
      ),
      child: AppIcon(
        status.icon,
        color: isDone ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        size: AppIconSize.small,
      ),
    );
  }

  Widget _buildCancelled(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel_outlined, size: 80, color: colorScheme.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            'تم إلغاء الطلب',
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'رقم الطلب: $orderNumber',
            style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
