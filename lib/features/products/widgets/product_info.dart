import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/widgets/app_price.dart';
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

    final double? oldPrice =
        defaultUnit != null && defaultUnit.originalPrice > price
            ? defaultUnit.originalPrice
            : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        if (oldPrice != null ||
            (defaultUnit != null && defaultUnit.quantity > 0))
          Padding(
            padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (oldPrice != null)
                  Text(
                    '${oldPrice.toStringAsFixed(2)} ر.ي',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.discount,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.discount,
                      fontSize: 10,
                    ),
                  ),
                if (oldPrice != null &&
                    defaultUnit != null &&
                    defaultUnit.quantity > 0)
                  const SizedBox(width: 8),
                if (defaultUnit != null && defaultUnit.quantity > 0)
                  Flexible(
                    child: Text(
                      lang.t(
                          'quantity_value', {'quantity': defaultUnit.quantity}),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
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
