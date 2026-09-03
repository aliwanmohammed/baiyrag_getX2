import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/widgets/app_cached_image.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../models/cart_item_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              width: 72, // Intentional component dimension
              height: 72, // Intentional component dimension
              color: colorScheme.surfaceContainerHighest,
              child: item.product.image.isEmpty
                  ? Center(
                      child: Text('🛍️',
                          style: TextStyle(
                              fontSize: 32)), // Intentional component dimension
                    )
                  : AppCachedImage(
                      imageUrl: item.product.image,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2, // Intentional component dimension
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        item.unit.unitName,
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (item.hasDiscount)
                      Text(
                        (item.originalPrice * item.quantity).toStringAsFixed(0),
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      '${item.totalPrice.toStringAsFixed(0)} ر.ي',
                      style: AppTypography.titleMedium.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Quantity controls
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          _QtyBtn(
                            icon: Icons.remove_rounded,
                            onTap: onDecrease,
                            semanticLabel: lang.t('decrease_quantity'),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                            child: Text(
                              '${item.quantity}',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _QtyBtn(
                            icon: Icons.add_rounded,
                            onTap: onIncrease,
                            isAdd: true,
                            semanticLabel: lang.t('increase_quantity'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isAdd;
  final String semanticLabel;
  const _QtyBtn({
    required this.icon,
    required this.onTap,
    this.isAdd = false,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // INTENTIONAL TOUCH TARGET EXCEPTION: Kept 34x34 to avoid visual drift in card height.
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isAdd ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: AppIcon(
            icon,
            size: AppIconSize.small,
            color: isAdd ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
