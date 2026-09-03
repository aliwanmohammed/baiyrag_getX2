import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_radius.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../../core/models/product_model.dart';
import '../widgets/product_details_sheet.dart';
import 'product_card_container.dart';
import 'product_favorite_button.dart';
import '../models/product_unit_model.dart';

import 'product_image.dart';
import 'product_info.dart';
import 'product_cart_control.dart';
import '../../auth/utils/auth_gate.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_spacing.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final offeredUnit = product.units.cast<ProductUnitModel?>().firstWhere(
          (unit) => unit?.offer != null,
          orElse: () => null,
        );
    final offer = offeredUnit?.offer;

    return ProductCardContainer(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: .92,
            maxChildSize: .96,
            minChildSize: .55,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.sheet),
                  ),
                ),
                child: ProductDetailsSheet(product: product),
              );
            },
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ProductImage(
                    image: product.image,
                    heroTag: 'product_${product.id}',
                  ),
                ),
                if (offer != null)
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: offer.isGift
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            offer.isGift
                                ? Icons.card_giftcard_rounded
                                : offer.isPercentage
                                    ? Icons.percent_rounded
                                    : Icons.local_offer_rounded,
                            size: 10,
                            color: offer.isGift
                                ? Theme.of(context).colorScheme.onTertiary
                                : Theme.of(context).colorScheme.onError,
                          ),
                          SizedBox(width: 2),
                          Text(
                            offer.isGift
                                ? lang.t('gift')
                                : offer.isPercentage
                                    ? lang.t('discount')
                                    : lang.t('special_offer'),
                            style: AppTypography.caption.copyWith(
                              color: offer.isGift
                                  ? Theme.of(context).colorScheme.onTertiary
                                  : Theme.of(context).colorScheme.onError,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Obx(() {
                    final favoritesController = Get.find<FavoritesController>();
                    return ProductFavoriteButton(
                      isFavorite: favoritesController.isFavorite(product.id),
                      onTap: () {
                        AuthGate.check(
                          context,
                          onAuthenticated: () =>
                              favoritesController.toggle(product.id),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: ProductInfo(
              product: product,
              quantityWidget: ProductCartControl(product: product),
            ),
          ),
        ],
      ),
    );
  }
}
