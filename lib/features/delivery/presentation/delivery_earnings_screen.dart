import '../../../app/localization/lang.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/widgets/app_page_header.dart';

/// شاشة الأرباح للسائق
class DeliveryEarningsScreen extends StatelessWidget {
  const DeliveryEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppPageHeader(title: lang.t('my_earnings'), showBack: false),
      body: AppConstrainedContent(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _EarningsCard(
                      lang.t('today'),
                      '1,200 ر.ي',
                      Icons.today_outlined,
                      colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _EarningsCard(
                      lang.t('week'),
                      '8,400 ر.ي',
                      Icons.date_range_outlined,
                      colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _EarningsCard(
                      lang.t('month'),
                      '32,000 ر.ي',
                      Icons.calendar_month_outlined,
                      colorScheme.tertiary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _EarningsCard(
                      lang.t('deliveries'),
                      '145 طلب',
                      Icons.delivery_dining_outlined,
                      colorScheme.secondary, // Success semantic replacement
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),

              // Daily breakdown
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  lang.t('last_7_days'),
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              ...[
                _DayRow('الأحد', '1,800 ر.ي', 6),
                _DayRow('الإثنين', '2,100 ر.ي', 7),
                _DayRow('الثلاثاء', '900 ر.ي', 3),
                _DayRow('الأربعاء', '1,500 ر.ي', 5),
                _DayRow('الخميس', '2,400 ر.ي', 8),
                _DayRow('الجمعة', '600 ر.ي', 2),
                _DayRow('السبت', '1,200 ر.ي', 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _EarningsCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(icon, color: color, size: AppIconSize.medium),
            SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final String day, amount;
  final int deliveries;
  const _DayRow(this.day, this.amount, this.deliveries);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              day,
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: deliveries / 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
                minHeight: 8,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            amount,
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            '($deliveries)',
            style: AppTypography.labelSmall.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
