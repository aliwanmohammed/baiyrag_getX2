import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/widgets/app_button.dart';
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                width: double.infinity,
                child: AppCachedImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              AppPrice(price: product.price),
              const SizedBox(height: 15),
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 25),
              AppButton(
                icon: Icons.shopping_cart_outlined,
                text: "إضافة إلى السلة",
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
                      content: Text("${product.name} تمت إضافته إلى السلة"),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
