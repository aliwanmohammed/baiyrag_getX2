import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:bhm_supermarket/app/theme/app_radius.dart';
import 'package:bhm_supermarket/app/theme/app_shadows.dart';
import 'package:bhm_supermarket/app/theme/app_spacing.dart';
import 'package:bhm_supermarket/app/theme/app_typography.dart';
import 'package:bhm_supermarket/app/widgets/app_quantity_selector.dart';
import 'package:bhm_supermarket/app/widgets/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../controllers/product_controller.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_message.dart';
import '../../../app/widgets/app_back_button.dart';
import '../../../app/widgets/app_button.dart';
import '../../../app/widgets/app_cached_image.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../ads/controllers/offers_controller.dart';
import '../widgets/product_card.dart';

/// Full product details screen with unit selection and related products.
class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  /// Tracks whether loadProduct() has been dispatched.
  /// Prevents showing the error state before the first API call starts.

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.find<ProductController>().loadProduct(widget.productId);
    });
  }

  Future<void> _addToCart() async {
    final controller = Get.find<ProductController>();

    final product = controller.product;

    final selected = controller.selectedUnit;

    if (product == null || selected == null) return;

    final offerUnit = Get.find<OffersController>().productUnitOffer(
      productId: product.id,
      unitId: selected.id,
    );

    final response = await Get.find<CartController>().addItem(
      product: product,
      unit: selected,
      unitPrice: offerUnit?.price ?? selected.price,
      originalPrice: offerUnit?.oldPrice ?? selected.price,
      quantity: controller.quantity,
    );

    if (!mounted) return;

    if (response.isSuccess) {
      AppMessage.success(
        context,
        lang.t('product_added_dynamic',
            {'product': product.name, 'quantity': controller.quantity}),
      );
      Navigator.pop(context);
    } else {
      AppMessage.error(context, response.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
        builder: (_) => GetBuilder<FavoritesController>(
            builder: (_) => GetBuilder<OffersController>(
                builder: (_) => _buildGetX0(context))));
  }

  Widget _buildGetX0(BuildContext context) {
    final controller = Get.find<ProductController>();

    final product = controller.product;
    final currentProduct = product;

    final units = controller.units;

    final related = controller.related;

    final selected = controller.selectedUnit;

    final selectedIndex = controller.selectedUnitIndex;

    final error = controller.error;

    // First load must always occupy the page with a real loading state.
    if (controller.isLoading && currentProduct == null) {
      return Scaffold(
        body: AppLoading.fullPage(message: lang.t('loading_product')),
      );
    }

    if (error != null && currentProduct == null) {
      return Scaffold(
        body: AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: lang.t('product_load_error'),
          subtitle: error,
          actionLabel: lang.t('retry'),
          onAction: () => controller.loadProduct(widget.productId),
        ),
      );
    }

    final offerUnit = selected == null
        ? null
        : Get.find<OffersController>().productUnitOffer(
            productId: currentProduct?.id ?? '',
            unitId: selected.id,
          );

    final favoritesController = Get.find<FavoritesController>();
    final isFav = currentProduct != null &&
        favoritesController.isFavorite(currentProduct.id);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 360,
                  pinned: true,
                  elevation: 0,
                  stretch: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  leading: AppBackButtonOverlay(),
                  actions: [
                    Container(
                      margin: EdgeInsetsDirectional.only(top: 10, start: 6),
                      child: Material(
                        color: Theme.of(context).cardColor,
                        shape: CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          icon: AppIcon(Icons.share_outlined),
                          onPressed: () {
                            // سيتم ربط المشاركة لاحقاً
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsetsDirectional.only(
                        top: 10,
                        start: 12,
                        end: AppSpacing.md,
                      ),
                      child: Material(
                        color: Theme.of(context).cardColor,
                        shape: CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          onPressed: currentProduct == null
                              ? null
                              : () {
                                  favoritesController.toggle(currentProduct.id);
                                },
                          icon: AppIcon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav
                                ? AppColors.error
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: Theme.of(context).colorScheme.surface),
                        Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(30, 90, 30, 50),
                          child: Hero(
                            tag: 'product_${widget.productId}',
                            child: (currentProduct == null ||
                                    currentProduct.image.isEmpty)
                                ? Icon(
                                    Icons.inventory_2_outlined,
                                    size: 130,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  )
                                : AppCachedImage(
                                    imageUrl: currentProduct.image,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (currentProduct != null)
                  SliverToBoxAdapter(
                      child: AppConstrainedContent(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //-----------------------------------------------------
                          // Category
                          //-----------------------------------------------------
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(
                                AppRadius.xxl,
                              ),
                            ),
                            child: Text(
                              currentProduct.categoryName,
                              style: AppTypography.bodySmall,
                            ),
                          ),

                          SizedBox(height: AppSpacing.md),

                          //-----------------------------------------------------
                          // Product Name
                          //-----------------------------------------------------
                          Text(
                            currentProduct.name,
                            style: AppTypography.headlineLarge,
                          ),

                          SizedBox(height: AppSpacing.sm),

                          SizedBox(height: AppSpacing.xl),

                          //-----------------------------------------------------
                          // Price Card
                          //-----------------------------------------------------
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: .05),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: .15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (offerUnit?.hasDiscount == true)
                                        Text(
                                          "${offerUnit!.oldPrice.toStringAsFixed(0)} ر.ي",
                                          style: AppTypography.oldPrice,
                                        ),
                                      Text(
                                        "${selected?.price.toStringAsFixed(0) ?? currentProduct.price.toStringAsFixed(0)} ر.ي",
                                        style: AppTypography.priceLarge,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.local_offer_outlined,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: AppSpacing.md),
                                      Text(
                                        lang.t('best_price'),
                                        style: AppTypography.titleLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: AppSpacing.xxl),

                          //-----------------------------------------------------
                          // Product Information
                          //-----------------------------------------------------
                          Container(
                            padding: EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                _DetailRow(
                                  lang.t('item_number'),
                                  currentProduct.uniqueNumber,
                                ),
                                if (selected != null)
                                  _DetailRow(
                                    lang.t('unit_barcode'),
                                    selected.barcode,
                                  ),
                                _DetailRow(
                                  lang.t('category'),
                                  currentProduct.categoryName,
                                ),
                                _DetailRow(
                                  lang.t('status'),
                                  currentProduct.isAvailable
                                      ? lang.t('in_stock')
                                      : lang.t('out_of_stock'),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: AppSpacing.xxl),
                          if (units.isNotEmpty) ...[
                            Text(
                              lang.t('select_unit'),
                              style: AppTypography.titleLarge,
                            ),
                            SizedBox(height: AppSpacing.md),
                            AppAdaptiveGrid(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: units.length,
                              minItemWidth:
                                  160.0, // Intentional component dimension to fit 2 on mobile
                              childAspectRatio: 2.4,
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              itemBuilder: (_, i) {
                                final unit = units[i];

                                final selectedUnit = selectedIndex == i;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  onTap: () {
                                    Get.find<ProductController>().selectUnit(
                                      i,
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 250),
                                    curve: Curves.ease,
                                    padding: EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: selectedUnit
                                          ? AppColors.primary.withValues(
                                              alpha: .08,
                                            )
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.md,
                                      ),
                                      border: Border.all(
                                        width: selectedUnit ? 2 : 1,
                                        color: selectedUnit
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                      boxShadow: selectedUnit
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withValues(alpha: .12),
                                                blurRadius: 14,
                                                offset: Offset(0, 5),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          unit.unitName,
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                            color: selectedUnit
                                                ? AppColors.primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                          ),
                                        ),
                                        SizedBox(height: AppSpacing.xs),
                                        Text(
                                          unit.quantity.toString(),
                                          style: AppTypography.bodySmall,
                                        ),
                                        SizedBox(height: AppSpacing.sm),
                                        Text(
                                          "${unit.price.toStringAsFixed(0)} ر.ي",
                                          style: AppTypography.priceMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: AppSpacing.xxl),
                          ],

                          if (currentProduct.description.isNotEmpty) ...[
                            Text(lang.t('product_description'),
                                style: AppTypography.titleLarge),
                            SizedBox(height: AppSpacing.md),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                boxShadow: AppShadows.card,
                              ),
                              child: Text(
                                currentProduct.description,
                                style: AppTypography.bodyMedium.copyWith(
                                  height: 1.8,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.xl),
                          ],
                          Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              boxShadow: AppShadows.card,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lang.t('quantity'),
                                        style: AppTypography.titleMedium,
                                      ),
                                      SizedBox(height: AppSpacing.xs),
                                      Text(
                                        lang.t('quantity_hint'),
                                        style: AppTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                AppQuantitySelector(
                                  quantity: controller.quantity,
                                  onDecrease: controller.decreaseQuantity,
                                  onIncrease: controller.increaseQuantity,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: AppSpacing.xl),
                          if (related.isNotEmpty) ...[
                            SizedBox(height: AppSpacing.xxl),
                            Text(
                              lang.t('related_products'),
                              style: AppTypography.titleLarge,
                            ),
                            SizedBox(height: AppSpacing.md),
                            SizedBox(
                              height: 240,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: related.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: AppSpacing.md),
                                itemBuilder: (_, i) => SizedBox(
                                  width: 150,
                                  child: ProductCard(product: related[i]),
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: AppSpacing.massive),
                        ],
                      ),
                    ),
                  ))
                else
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: error != null
                          ? AppEmptyState(
                              icon: Icons.warning_rounded,
                              title: lang.t('product_load_error'),
                              subtitle: error,
                              actionLabel: lang.t('retry'),
                              onAction: () => Get.find<ProductController>()
                                  .loadProduct(widget.productId),
                            )
                          : Center(child: AppLoading()),
                    ),
                  ),
              ],
            ),
          ),
          if (selected != null)
            SafeArea(
              top: false,
              child: Container(
                height: AppSizes.bottomBarHeight,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    //------------------------------------------
                    // PRICE
                    //------------------------------------------
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lang.t('total'), style: AppTypography.bodySmall),
                          Text(
                            "${((offerUnit?.price ?? selected.price) * controller.quantity).toStringAsFixed(0)} ر.ي",
                            style: AppTypography.priceLarge,
                          ),
                        ],
                      ),
                    ),

                    //------------------------------------------
                    // BUTTON
                    //------------------------------------------
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: AppSizes.buttonHeight,
                        child: AppButton(
                          text: lang.t('add_to_cart'),
                          icon: Icons.shopping_cart_checkout_rounded,
                          onPressed: _addToCart,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: AppSpacing.huge,
            child: Text(label, style: AppTypography.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
