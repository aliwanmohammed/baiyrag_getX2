import 'package:bhm_supermarket/core/widgets/app_page_header.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../models/order_model.dart';
import '../models/order_status.dart';
// unused
import '../utils/payment_method_text.dart';
import '../widgets/order_progress.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppPageHeader(
        title: 'تفاصيل الطلب',
      ),
      body: SafeArea(
        child: AppConstrainedContent(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // ================================================================
              // معلومات الطلب الأساسية
              // ================================================================
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  title: Text(
                    order.orderNumber,
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(order.createdAt, style: AppTypography.bodyMedium),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: order.statusEnum.color.withValues(
                        alpha: .15,
                      ),
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
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ================================================================
              // حالة الطلب
              // ================================================================
              Text(
                'حالة الطلب',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: AppSpacing.md),

              OrderProgress(
                status: order.status,
              ),

              const SizedBox(height: AppSpacing.xl),

              // ================================================================
              // معلومات الطلب
              // ================================================================
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _infoRow(
                        'رقم الطلب',
                        order.orderNumber,
                        colorScheme,
                      ),
                      _infoRow(
                        'طريقة الدفع',
                        paymentMethodText(order.paymentMethod),
                        colorScheme,
                      ),
                      _infoRow(
                        'حالة الدفع',
                        order.paymentStatus.toLowerCase() == 'pending'
                            ? 'قيد الانتظار'
                            : order.paymentStatus,
                        colorScheme,
                      ),
                      _infoRow(
                        'العنوان',
                        order.location.address,
                        colorScheme,
                      ),
                      if (order.notes != null && order.notes!.trim().isNotEmpty)
                        _infoRow(
                          'ملاحظات',
                          order.notes!,
                          colorScheme,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ================================================================
              // المنتجات
              // ================================================================
              Text(
                'المنتجات',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: AppSpacing.sm),

              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(AppSpacing.sm),
                      leading: CircleAvatar(
                        backgroundColor: item.isGift ? AppColors.success.withValues(alpha: 0.1) : colorScheme.surfaceContainerHighest,
                        child: Icon(
                          item.isGift ? Icons.card_giftcard : Icons.shopping_bag_outlined,
                          color: item.isGift ? AppColors.success : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.product?.nameAr ?? 'منتج غير متوفر',
                              style: AppTypography.bodyLarge,
                            ),
                          ),
                          if (item.isGift)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                'هدية',
                                style: AppTypography.labelSmall.copyWith(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          '${item.unit?.unitName ?? 'غير معروف'} • ${item.price} ر.ي',
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '× ${item.quantity}',
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.total} ر.ي',
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ================================================================
              // ملخص الأسعار
              // ================================================================
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      // المجموع قبل الخصم
                      _priceRow(
                        'المجموع',
                        order.subtotal,
                      ),

                      // رسوم التوصيل
                      _priceRow(
                        'التوصيل',
                        order.deliveryFee,
                      ),

                      // الخصم العام
                      if (order.discount > 0)
                        _priceRow(
                          'الخصم',
                          -order.discount,
                          color: AppColors.success,
                        ),

                      // خصم الكوبون
                      if (order.couponDiscount > 0)
                        _priceRow(
                          'خصم الكوبون',
                          -order.couponDiscount,
                          color: AppColors.success,
                        ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Divider(),
                      ),

                      // الإجمالي النهائي القادم من Backend
                      _priceRow(
                        'الإجمالي',
                        order.total,
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // معلومات
  // ==========================================================================

  Widget _infoRow(
    String title,
    String value,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // الأسعار
  // ==========================================================================

  Widget _priceRow(
    String title,
    double value, {
    bool bold = false,
    Color? color,
  }) {
    final style = AppTypography.bodyMedium.copyWith(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: style,
          ),
          Text(
            '${value.toStringAsFixed(2)} ر.ي',
            style: style,
          ),
        ],
      ),
    );
  }
}
