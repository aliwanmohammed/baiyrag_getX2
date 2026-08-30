import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/widgets/app_price.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/models/product_model.dart';

class ProductInfo extends StatelessWidget {
  final ProductModel product;
  final Widget? quantityWidget;

  const ProductInfo({
    super.key,
    required this.product,
    this.quantityWidget,
  });

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final defaultUnit = product.units.isEmpty ? null : product.units.first;



    final price = defaultUnit != null && defaultUnit.finalPrice > 0
        ? defaultUnit.finalPrice
        : (defaultUnit?.price ?? product.price);

    final double? oldPrice = defaultUnit != null && defaultUnit.originalPrice > price
        ? defaultUnit.originalPrice
        : null;

    final hasDiscount = oldPrice != null && oldPrice > price;

    final soldQuantity = defaultUnit?.soldQuantityLast2Days ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (soldQuantity > 200)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  Icons.local_fire_department_rounded,
                  size: AppIconSize.small,
                  color: AppColors.discount,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    'تم شراؤه +$soldQuantity مرة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.discount,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        if (defaultUnit != null && defaultUnit.quantity > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
            child: Text(
              'الكمية: ${defaultUnit.quantity}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppPrice(
                    price: price,
                    crossAxisAlignment:
                        rtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  ),
                  if (hasDiscount)
                    Text(
                      '${oldPrice.toStringAsFixed(0)} ر.ي',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.discount,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.discount,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            if (quantityWidget != null) quantityWidget!,
          ],
        ),
      ],
    );
  }
}
