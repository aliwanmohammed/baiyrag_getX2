import 'package:bhm_supermarket/app/localization/lang.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/product_model.dart';
import '../../../core/network/api_response.dart';
import '../../ads/controllers/offers_controller.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../cart/controllers/cart_controller.dart';

class ProductAddButton extends StatelessWidget {
  final ProductModel product;

  const ProductAddButton({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          final selectedUnit =
              product.units.isEmpty ? null : product.units.first;

          final offerUnit = selectedUnit == null
              ? null
              : Get.find<OffersController>().productUnitOffer(
                  productId: product.id,
                  unitId: selectedUnit.id,
                );

          final response = selectedUnit == null
              ? ApiResponse.failure(lang.t('unit_not_selected'))
              : await Get.find<CartController>().addItem(
                  product: product,
                  unit: selectedUnit,
                  unitPrice: offerUnit?.price ?? selectedUnit.price,
                  originalPrice: offerUnit?.oldPrice ?? selectedUnit.price,
                );

          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.isSuccess
                    ? lang.t('added_product_dynamic', {'product': product.name})
                    : response.message,
              ),
            ),
          );
        },
        child: Ink(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Color(0xff39BFE7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppIcon(
            Icons.add_rounded,
            color: Color(0xff39BFE7),
            size: AppIconSize.small,
          ),
        ),
      ),
    );
  }
}
