import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppPrice extends StatelessWidget {
  final double price;
  final double? oldPrice;
  final CrossAxisAlignment crossAxisAlignment;

  const AppPrice({
    super.key,
    required this.price,
    this.oldPrice,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;

    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final currentStyle = AppTypography.currentPrice.copyWith(
      color: AppColors.primary,
      fontSize: 18,
      fontWeight: FontWeight.w800,
    );

    final oldStyle = AppTypography.oldPrice.copyWith(
      color: AppColors.textHint,
      fontSize: 11,
      decoration: TextDecoration.lineThrough,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (hasDiscount) ...[
          Text(oldPrice!.toStringAsFixed(0), style: oldStyle),
          const SizedBox(width: 4),
        ],
        Text(
          price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2),
          style: currentStyle,
        ),
        const SizedBox(width: 2),
        Text(
          "ر.ي",
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
