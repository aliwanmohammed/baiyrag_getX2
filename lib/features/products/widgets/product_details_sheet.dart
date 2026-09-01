import 'package:flutter/material.dart';
import '../../../core/widgets/loading_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/widgets/app_cached_image.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/product_unit_offer_model.dart';
import '../../../core/widgets/app_message.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../models/product_unit_model.dart';
import '../controllers/product_controller.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ProductDetailsSheet
// ══════════════════════════════════════════════════════════════════════════════

/// Bottom-sheet احترافي لعرض تفاصيل المنتج.
///
/// إذا كانت وحدات المنتج محملة مسبقاً في [product.units]، يُستخدم
/// [ProductController.setProduct] لتجنب طلب API إضافي.
/// في حال لم تكن الوحدات متوفرة يُجرى [ProductController.loadProduct].
class ProductDetailsSheet extends StatefulWidget {
  final ProductModel product;
  final int initialUnitIndex;

  const ProductDetailsSheet({
    super.key,
    required this.product,
    this.initialUnitIndex = 0,
  });

  @override
  State<ProductDetailsSheet> createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<ProductDetailsSheet> {
  int _imageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = Get.find<ProductController>();
      if (widget.product.units.isNotEmpty) {
        // الوحدات موجودة → لا حاجة لطلب API
        controller.setProduct(widget.product);
        if (widget.initialUnitIndex > 0 &&
            widget.initialUnitIndex < widget.product.units.length) {
          controller.selectUnit(widget.initialUnitIndex);
        }
      } else {
        // الوحدات غير موجودة → جلب من API
        controller.loadProduct(widget.product.id);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Cart Actions ─────────────────────────────────────────────────────────

  Future<void> _addToCart() async {
    final productController = Get.find<ProductController>();
    final selectedUnit = productController.selectedUnit;

    if (selectedUnit == null) {
      return;
    }

    final cart = Get.find<CartController>();

    final currentQuantity = cart.getProductQuantity(
      widget.product.id,
      selectedUnit.id,
    );

    // المنتج موجود بالفعل في السلة.
    // الزيادة تتم من زر +.
    if (currentQuantity > 0) {
      if (mounted) {
        context.pop();
      }
      return;
    }

    final unitPrice = selectedUnit.finalPrice > 0
        ? selectedUnit.finalPrice
        : selectedUnit.price;
    final originalPrice = selectedUnit.originalPrice > unitPrice
        ? selectedUnit.originalPrice
        : unitPrice;

    final response = await cart.addItem(
      product: widget.product,
      unit: selectedUnit,
      originalPrice: originalPrice,
      unitPrice: unitPrice,
      quantity: 1,
    );

    if (!mounted) return;

    if (!response.isSuccess) {
      AppMessage.error(
        context,
        response.message.isNotEmpty
            ? response.message
            : 'حدث خطأ، حاول مرة أخرى',
      );
      return;
    }

    final productName = widget.product.name;
    final unitName = selectedUnit.unitName;

    context.pop();

    AppMessage.success(
      context,
      'تمت إضافة $productName ($unitName) للسلة',
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
        builder: (_) => GetBuilder<FavoritesController>(
            builder: (_) => GetBuilder<CartController>(
                builder: (_) => _buildGetX0(context))));
  }

  Widget _buildGetX0(BuildContext context) {
    final controller = Get.find<ProductController>();
    final isFavorite =
        Get.find<FavoritesController>().isFavorite(widget.product.id);

    final units = controller.units;
    final selectedUnit = controller.selectedUnit;

    final cartQuantity = selectedUnit == null
        ? 0
        : Get.find<CartController>().getProductQuantity(
            widget.product.id,
            selectedUnit.id,
          );

    final images = widget.product.images;

    final isQuantityProcessing = selectedUnit == null
        ? false
        : Get.find<CartController>().isItemProcessing(
            widget.product.id,
            selectedUnit.id,
          );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Drag Handle ────────────────────────────────────────────────
            const _DragHandle(),

            // ── Scrollable Content ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة المنتج
                    _ImageSection(
                      images: images,
                      productId: widget.product.id,
                      isFavorite: isFavorite,
                      currentIndex: _imageIndex,
                      pageController: _pageController,
                      onPageChanged: (i) => setState(() => _imageIndex = i),
                      onClose: () => context.pop(),
                      onFavoriteToggle: () => Get.find<FavoritesController>()
                          .toggle(widget.product.id),
                    ),

                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // التصنيف
                          if (widget.product.categoryName.isNotEmpty) ...[
                            _CategoryChip(label: widget.product.categoryName),
                            const SizedBox(height: AppSpacing.sm),
                          ],

                          // اسم المنتج
                          Text(
                            widget.product.name,
                            style: AppTypography.headlineSmall,
                          ),

                          // الوصف
                          if (widget.product.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              widget.product.description,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.65,
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.lg),

                          // ── قسم الوحدات ──────────────────────────────
                          if (controller.isLoading)
                            const _UnitsLoadingState()
                          else if (controller.error != null)
                            _UnitsErrorState(error: controller.error!)
                          else if (units.isNotEmpty)
                            _UnitsSection(
                              units: units,
                              selectedIndex: controller.selectedUnitIndex,
                              onSelect: (i) =>
                                  Get.find<ProductController>().selectUnit(i),
                            )
                          else
                            const _NoUnitsWarning(),

                          // مسافة لشريط الأسفل
                          const SizedBox(height: 110),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Action Bar ──────────────────────────────────────────
            if (selectedUnit != null)
              _BottomBar(
                selectedUnit: selectedUnit,
                price: selectedUnit.finalPrice > 0
                    ? selectedUnit.finalPrice
                    : selectedUnit.price,
                oldPrice: selectedUnit.originalPrice >
                        (selectedUnit.finalPrice > 0
                            ? selectedUnit.finalPrice
                            : selectedUnit.price)
                    ? selectedUnit.originalPrice
                    : null,
                quantity: cartQuantity,
                isLoading: isQuantityProcessing,
                onIncrease: () async {
                  final cart = Get.find<CartController>();

                  await cart.setQuantity(
                    productId: widget.product.id,
                    unitId: selectedUnit.id,
                    quantity: cartQuantity + 1,
                  );
                },
                onDecrease: () async {
                  final cart = Get.find<CartController>();

                  if (cartQuantity <= 0) {
                    return;
                  }

                  await cart.setQuantity(
                    productId: widget.product.id,
                    unitId: selectedUnit.id,
                    quantity: cartQuantity - 1,
                  );
                },
                onAddToCart: _addToCart,
              )
            else if (!controller.isLoading)
              const _UnavailableBottomBar(),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _DragHandle
// ══════════════════════════════════════════════════════════════════════════════

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.outline,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _ImageSection
// ══════════════════════════════════════════════════════════════════════════════

class _ImageSection extends StatelessWidget {
  final String productId;

  final List<String> images;
  final bool isFavorite;
  final int currentIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onClose;
  final VoidCallback onFavoriteToggle;

  const _ImageSection({
    required this.images,
    required this.productId,
    required this.isFavorite,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.onClose,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = images.isNotEmpty;

    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          // ── الصورة / المعرض ──────────────────────────────────────────
          if (hasImages)
            PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemCount: images.length,
              itemBuilder: (_, i) => Hero(
                tag: 'product_$productId',
                child: AppCachedImage(
                  imageUrl: images[i],
                  width: double.infinity,
                  height: 260,
                  radius: 0,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                child: Icon(
                  Icons.shopping_bag_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),

          // ── Dot Indicators (عند تعدد الصور) ─────────────────────────
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: currentIndex == i ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: currentIndex == i
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),

          // ── زر الإغلاق ───────────────────────────────────────────────
          PositionedDirectional(
            top: 12,
            start: 12,
            child: _CircleButton(icon: Icons.close_rounded, onTap: onClose),
          ),

          // ── زر المفضلة ───────────────────────────────────────────────
          PositionedDirectional(
            top: 12,
            end: 12,
            child: _CircleButton(
              icon: isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: isFavorite ? AppColors.favorite : null,
              onTap: onFavoriteToggle,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _CircleButton
// ══════════════════════════════════════════════════════════════════════════════

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: AppIcon(
            icon,
            size: AppIconSize.medium,
            color: iconColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _CategoryChip
// ══════════════════════════════════════════════════════════════════════════════

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: AppColors.primaryDark),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _UnitsSection
// ══════════════════════════════════════════════════════════════════════════════

class _UnitsSection extends StatelessWidget {
  final List<ProductUnitModel> units;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _UnitsSection({
    required this.units,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const AppIcon(
              Icons.layers_outlined,
              size: AppIconSize.small,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text('اختر الوحدة', style: AppTypography.titleSmall),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Text('${units.length}', style: AppTypography.badge),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(units.length, (i) {
          final unit = units[i];
          final offer = unit.offer;
          final price = unit.finalPrice > 0 ? unit.finalPrice : unit.price;
          final oldPrice =
              unit.originalPrice > price ? unit.originalPrice : null;

          return _UnitCard(
            unit: unit,
            price: price,
            oldPrice: oldPrice,
            promoOffer: offer,
            isSelected: selectedIndex == i,
            onTap: () => onSelect(i),
          );
        }),
      ],
    );
  }
}

class _UnitCard extends StatelessWidget {
  final ProductUnitModel unit;
  final double price;
  final double? oldPrice;
  final ProductUnitOfferModel? promoOffer;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitCard({
    required this.unit,
    required this.price,
    required this.oldPrice,
    this.promoOffer,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = oldPrice != null && oldPrice! > price;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryExtraLight
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.outline,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? const AppIcon(Icons.check_rounded,
                          size: AppIconSize.small, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              unit.unitName,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleSmall.copyWith(
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (promoOffer != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: promoOffer!.isGift
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                promoOffer!.isPercentage
                                    ? 'خصم'
                                    : promoOffer!.isGift
                                        ? 'هدية'
                                        : 'عرض خاص',
                                style: AppTypography.caption.copyWith(
                                  color: promoOffer!.isGift
                                      ? Theme.of(context).colorScheme.onTertiary
                                      : Theme.of(context).colorScheme.onError,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (unit.quantity > 1) ...[
                        const SizedBox(height: 2),
                        Text('${unit.quantity}',
                            style: AppTypography.bodySmall),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasDiscount)
                      Text(
                        '${oldPrice!.toStringAsFixed(2)} ر.ي',
                        style: AppTypography.caption.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textHint,
                        ),
                      ),
                    Text(
                      '${price.toStringAsFixed(2)} ر.ي',
                      style: AppTypography.priceMedium.copyWith(
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.price,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (promoOffer?.isGift == true &&
                promoOffer!.giftProductName.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      size: 17,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'هدية: ${promoOffer!.giftProductName}'
                        '${promoOffer!.giftUnitName.isNotEmpty ? ' (${promoOffer!.giftUnitName})' : ''}'
                        '${promoOffer!.giftQuantity > 0 ? ' × ${promoOffer!.giftQuantity}' : ''}',
                        style: AppTypography.bodySmall.copyWith(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _BottomBar
// ══════════════════════════════════════════════════════════════════════════════

class _BottomBar extends StatelessWidget {
  final ProductUnitModel selectedUnit;
  final double price;
  final double? oldPrice;
  final int quantity;
  final bool isLoading;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onAddToCart;

  const _BottomBar({
    required this.selectedUnit,
    required this.price,
    this.oldPrice,
    required this.quantity,
    required this.isLoading,
    required this.onIncrease,
    required this.onDecrease,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final isInCart = quantity > 0;
    final effectiveQuantity = quantity > 0 ? quantity : 1;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        bottomPadding + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _QuantitySelector(
            quantity: quantity,
            onIncrease: onIncrease,
            onDecrease: onDecrease,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (oldPrice != null && oldPrice! > price)
                  Text(
                    '${(oldPrice! * effectiveQuantity).toStringAsFixed(2)} ر.ي',
                    style: AppTypography.caption.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textHint,
                    ),
                  ),
                Text(
                  '${(price * effectiveQuantity).toStringAsFixed(2)} ر.ي',
                  style: AppTypography.priceLarge,
                ),
                Text(
                  selectedUnit.unitName,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: isLoading ? null : onAddToCart,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
              ),
              icon: isLoading
                  ? const AppLoading(
                      type: AppLoadingType.bars,
                      size: 18,
                      color: Colors.white,
                    )
                  : AppIcon(
                      isInCart
                          ? Icons.check_rounded
                          : Icons.shopping_cart_outlined,
                      size: AppIconSize.medium,
                    ),
              label: Text(
                isLoading
                    ? 'جاري التحديث...'
                    : isInCart
                        ? 'تم تحديث السلة'
                        : 'أضف للسلة',
                style: AppTypography.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _QuantitySelector
// ══════════════════════════════════════════════════════════════════════════════

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QuantitySelector({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.add_rounded,
            onTap: onIncrease,
          ),
          SizedBox(
            width: 36,
            child: Center(
              child: Text(
                '$quantity',
                style: AppTypography.titleSmall,
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.remove_rounded,
            onTap: quantity > 0 ? onDecrease : null,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: AppIcon(
          icon,
          size: AppIconSize.small,
          color: onTap != null ? AppColors.primary : AppColors.textHint,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// State Widgets
// ══════════════════════════════════════════════════════════════════════════════

class _UnitsLoadingState extends StatelessWidget {
  const _UnitsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}

class _UnitsErrorState extends StatelessWidget {
  final String error;
  const _UnitsErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const AppIcon(Icons.error_outline_rounded,
              color: AppColors.error, size: AppIconSize.medium),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              error.isNotEmpty ? error : 'تعذر تحميل بيانات المنتج',
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoUnitsWarning extends StatelessWidget {
  const _NoUnitsWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const AppIcon(Icons.info_outline_rounded,
              color: AppColors.warning, size: AppIconSize.medium),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'لم يتم ربط وحدات بهذا المنتج بعد.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailableBottomBar extends StatelessWidget {
  const _UnavailableBottomBar();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.lg, AppSpacing.md,
          AppSpacing.lg, bottomPadding + AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIcon(Icons.block_rounded,
              color: AppColors.textHint, size: AppIconSize.small),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'هذا المنتج غير متاح للشراء حالياً',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
