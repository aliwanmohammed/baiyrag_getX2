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
        'تمت إضافة ${product.name} × ${controller.quantity} إلى السلة',
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

    final offerUnit = selected == null
        ? null
        : Get.find<OffersController>().productUnitOffer(
            productId: currentProduct?.id ?? '',
            unitId: selected.id,
          );

    final favoritesController = Get.find<FavoritesController>();
    final isFav =
        currentProduct != null && favoritesController.isFavorite(currentProduct.id);
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
                  leading: const AppBackButtonOverlay(),
                  actions: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(top: 10, start: 6),
                      child: Material(
                        color: Theme.of(context).cardColor,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          icon: const AppIcon(Icons.share_outlined),
                          onPressed: () {
                            // سيتم ربط المشاركة لاحقاً
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsetsDirectional.only(
                        top: 10,
                        start: 12,
                        end: AppSpacing.md,
                      ),
                      child: Material(
                        color: Theme.of(context).cardColor,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          onPressed: currentProduct == null
                              ? null
                              : () {
                                  favoritesController.toggle(currentProduct.id);
                                },
                          icon: AppIcon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? AppColors.error : AppColors.textSecondary,
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
                        Container(color: Colors.white),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(30, 90, 30, 50),
                          child: Hero(
                            tag: 'product_${widget.productId}',
                            child: (currentProduct == null ||
                                    currentProduct.image.isEmpty)
                                ? const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 130,
                                    color: Colors.grey,
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
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //-----------------------------------------------------
                          // Category
                          //-----------------------------------------------------
                          Container(
                            padding: const EdgeInsets.symmetric(
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

                          const SizedBox(height: AppSpacing.md),

                          //-----------------------------------------------------
                          // Product Name
                          //-----------------------------------------------------
                          Text(
                            currentProduct.name,
                            style: AppTypography.headlineLarge,
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          const SizedBox(height: AppSpacing.xl),

                          //-----------------------------------------------------
                          // Price Card
                          //-----------------------------------------------------
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.local_offer_outlined,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: AppSpacing.md),
                                      Text(
                                        "أفضل سعر",
                                        style: AppTypography.titleLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          //-----------------------------------------------------
                          // Product Information
                          //-----------------------------------------------------
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                _DetailRow(
                                  "رقم الصنف",
                                  currentProduct.uniqueNumber,
                                ),
                                if (currentProduct.defaultUnit != null)
                                  _DetailRow(
                                    "باركود الوحدة الافتراضية",
                                    currentProduct.defaultUnit!.barcode,
                                  ),
                                _DetailRow(
                                  "القسم",
                                  currentProduct.categoryName,
                                ),
                                _DetailRow(
                                  "الحالة",
                                  currentProduct.isAvailable
                                      ? "متوفر"
                                      : "غير متوفر",
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xxl),
                          if (units.isNotEmpty) ...[
                            Text(
                              "اختر الوحدة",
                              style: AppTypography.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppAdaptiveGrid(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: units.length,
                              minItemWidth: 160.0, // Intentional component dimension to fit 2 on mobile
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
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.ease,
                                    padding: const EdgeInsets.all(14),
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
                                                offset: const Offset(0, 5),
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
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          unit.quantity.toString(),
                                          style: AppTypography.bodySmall,
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
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
                            const SizedBox(height: AppSpacing.xxl),
                          ],

                          if (currentProduct.description.isNotEmpty) ...[
                            Text("وصف المنتج", style: AppTypography.titleLarge),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.md),
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
                            const SizedBox(height: AppSpacing.xl),
                          ],
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
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
                                        "الكمية",
                                        style: AppTypography.titleMedium,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        "يمكنك زيادة أو تقليل الكمية",
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

                          const SizedBox(height: AppSpacing.xl),
                          if (related.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xxl),
                            Text(
                              'منتجات ذات صلة',
                              style: AppTypography.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              height: 240,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: related.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: AppSpacing.md),
                                itemBuilder: (_, i) => SizedBox(
                                  width: 150,
                                  child: ProductCard(product: related[i]),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.massive),
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
                              title: 'تعذر تحميل المنتج',
                              subtitle: error,
                              actionLabel: 'إعادة المحاولة',
                              onAction: () => Get.find<ProductController>()
                                  .loadProduct(widget.productId),
                            )
                          : const Center(child: AppLoading()),
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
                padding: const EdgeInsets.symmetric(
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
                          Text("الإجمالي", style: AppTypography.bodySmall),
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
                          text: "إضافة إلى السلة",
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
