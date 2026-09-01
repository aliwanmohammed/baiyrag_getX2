import '../../../../app/localization/lang.dart';
import 'package:bhm_supermarket/features/orders/utils/payment_method_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_button.dart';
import '../models/order_model.dart';
import '../models/order_status.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.orderNumber,
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.createdAt,
                    style: AppTypography.bodyMedium,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: order.statusEnum.color.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                  ),
                  child: Text(
                    order.statusEnum.label,
                    style: AppTypography.labelLarge.copyWith(
                      color: order.statusEnum.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              "الإجمالي : ${order.total} ر.ي",
              style: AppTypography.bodyMedium,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              "الدفع : ${paymentMethodText(order.paymentMethod)}",
              style: AppTypography.bodyMedium,
            ),
            SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: AppButton(
                onPressed: () {
                  context.push(AppRoutes.orderDetails, extra: order);
                },
                text: lang.t('order_details'),
                size: AppButtonSize.large,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
