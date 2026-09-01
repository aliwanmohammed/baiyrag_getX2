import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/widgets/app_button.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/localization/language_controller.dart';
import '../../../app/widgets/app_cached_image.dart';
import '../../../app/widgets/app_price.dart';
import '../../../core/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../ads/controllers/offers_controller.dart';

class ProductQuickView extends StatelessWidget {
  final ProductModel product;

  const ProductQuickView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<LanguageController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      padding: EdgeInsets.all(20),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 220,
                width: double.infinity,
                child: AppCachedImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              AppPrice(price: product.price),
              SizedBox(height: 15),
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 25),
              AppButton(
                icon: Icons.shopping_cart_outlined,
                text: lang.t('add_to_cart'),
                onPressed: () {
                  if (product.units.isEmpty) return;

                  final unit = product.units.first;
                  final offerUnit = Get.find<OffersController>().productUnitOffer(
                        productId: product.id,
                        unitId: unit.id,
                      );

                  Get.find<CartController>().addItem(
                        product: product,
                        unit: unit,
                        unitPrice: offerUnit?.price ?? unit.price,
                        originalPrice: offerUnit?.oldPrice ?? unit.price,
                      );

                  // Capture before pop to avoid stale context
                  final scaffoldMsg = ScaffoldMessenger.of(context);
                  Navigator.pop(context);

                  scaffoldMsg.showSnackBar(
                    SnackBar(
                      content: Text('${product.name} ${lang.t('added_to_cart')}'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
