import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_radius.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../../core/models/product_model.dart';
import '../widgets/product_details_sheet.dart';
import 'product_card_container.dart';
import 'product_favorite_button.dart';
import 'product_image.dart';
import 'product_info.dart';
import 'product_cart_control.dart';
import '../../auth/utils/auth_gate.dart';
import '../../ads/controllers/offers_controller.dart';
import '../../ads/models/offer_model.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_spacing.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
  return GetBuilder<OffersController>(
    builder: (_) => _buildGetX0(context),
  );
  }

  Widget _buildGetX0(BuildContext context) {
    final defaultUnit = product.defaultUnit;
    OfferProductUnitModel? promoUnit;
    OfferModel? promoOffer;
    GiftRewardModel? giftReward;
    OfferModel? giftOffer;

    if (defaultUnit != null) {
      final offersController = Get.find<OffersController>();

      promoUnit = offersController.productUnitOffer(
        productId: product.id,
        unitId: defaultUnit.id,
      );

      if (promoUnit != null) {
         try {
           promoOffer = offersController.offers.firstWhere((o) => o.productUnits.any((u) => u.id == promoUnit!.id));
         } catch (_) {}
      }

      final fakeLine = OfferCartLine(
        productId: product.id,
        unitId: defaultUnit.id,
        quantity: 99999,
      );
      final rewards = offersController.giftRewardsFor([fakeLine]);
      if (rewards.isNotEmpty) {
         giftReward = rewards.first;
         try {
           giftOffer = offersController.offers.firstWhere((o) => o.id == giftReward!.offerId);
         } catch (_) {}
      }
    }

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

                /// Badges
                if (promoOffer != null || giftOffer != null)
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (promoOffer != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  promoOffer.type == 'percentage'
                                      ? Icons.percent_rounded
                                      : promoOffer.type == 'gift'
                                          ? Icons.card_giftcard_rounded
                                          : Icons.local_offer_rounded,
                                  size: 10,
                                  color: Theme.of(context).colorScheme.onError,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  promoOffer.type == 'percentage'
                                      ? 'خصم'
                                      : promoOffer.type == 'gift'
                                          ? 'هدية'
                                          : 'عرض خاص',
                                  style: AppTypography.caption.copyWith(
                                    color: Theme.of(context).colorScheme.onError,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (promoOffer != null && giftOffer != null)
                          const SizedBox(height: 4),
                        if (giftOffer != null && giftReward != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.card_giftcard_rounded,
                                  size: 10,
                                  color: Theme.of(context).colorScheme.onTertiary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'هدية +${giftReward.gift.quantity}',
                                  style: AppTypography.caption.copyWith(
                                    color: Theme.of(context).colorScheme.onTertiary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                /// Favorite
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
                          onAuthenticated: () {
                            favoritesController.toggle(product.id);
                          },
                        );
                      },
                    );
                  }),
                ),



                /// Add button (Removed from here, now unified inside ProductInfo)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
