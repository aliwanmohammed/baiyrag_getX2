import 'package:bhm_supermarket/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/models/product_model.dart';
import 'product_card.dart';

class ProductsGrid extends StatelessWidget {
  final List<ProductModel> products;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ProductsGrid({
    super.key,
    required this.products,
    this.controller,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveGrid(
      // Responsive threshold to ensure 2 wider columns on mobile
      minItemWidth: 140.0,
      // Spacing between the two products in the same row
      spacing: AppSpacing.sm, // 8.0
      runSpacing: AppSpacing.md, // 12.0
      // Aspect ratio accommodating wider ProductCard content
      childAspectRatio: 0.62,
      itemCount: products.length,
      shrinkWrap: shrinkWrap,
      physics: physics,
      controller: controller,
      // Zero horizontal padding inside grid so outer padding is controlled and cards expand
      padding: const EdgeInsets.symmetric(
        horizontal: 0.0,
        vertical: AppSpacing.xs,
      ),
      itemBuilder: (_, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}
