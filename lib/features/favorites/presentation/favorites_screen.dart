import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_error_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/widgets/app_message.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/favorites_controller.dart';
import '../../products/widgets/products_grid.dart';
import '../../ads/controllers/offers_controller.dart';

/// Favorites screen backed by [FavoritesController].
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _synced = false;

  @override
  void initState() {
    super.initState();
    // نجلب بيانات المفضلة من السيرفر عند أول ظهور لشاشة المفضلة.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_synced && mounted) {
        _synced = true;
        Get.find<FavoritesController>().loadFromServer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
  return GetBuilder<FavoritesController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final favoritesController = Get.find<FavoritesController>();
    final cartProv = Get.find<CartController>();
    final favProducts = favoritesController.products;
    final colorScheme = Theme.of(context).colorScheme;

    if (favoritesController.isLoading && favProducts.isEmpty) {
      return const Scaffold(
        body: AppLoading.fullPage(message: 'جاري تحميل المفضلة...'),
      );
    }

    if (favoritesController.error != null && favProducts.isEmpty) {
      return Scaffold(
        body: AppErrorState(
          title: 'تعذر تحميل المفضلة',
          message: favoritesController.error!,
          onRetry: favoritesController.loadFromServer,
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('المفضلة'),
            if (favProducts.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${favProducts.length}',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (favProducts.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                for (final p in favProducts) {
                  final unit = p.units.isEmpty ? null : p.units.first;
                  if (unit != null) {
                    final offerUnit = Get.find<OffersController>().productUnitOffer(
                          productId: p.id,
                          unitId: unit.id,
                        );
                    cartProv.addItem(
                      product: p,
                      unit: unit,
                      unitPrice: offerUnit?.price ?? unit.price,
                      originalPrice: offerUnit?.oldPrice ?? unit.price,
                    );
                  }
                }
                AppMessage.success(
                  context,
                  'تمت إضافة ${favProducts.length} منتج للسلة',
                );
              },
              icon: AppIcon(Icons.shopping_cart_outlined, size: AppIconSize.small),
              label: Text(
                'نقل الكل للسلة',
                style: AppTypography.labelLarge,
              ),
            ),
        ],
      ),
      body: AppConstrainedContent(
        child: RefreshIndicator(
          onRefresh: favoritesController.loadFromServer,
          color: colorScheme.primary,
          child: favProducts.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(
                      height: 420,
                      child: AppEmptyState(
                        icon: Icons.favorite_rounded,
                        title: 'المفضلة فارغة',
                        subtitle: 'اضغط على قلب أي منتج لإضافته هنا',
                      ),
                    ),
                  ],
                )
              : ProductsGrid(
                  products: favProducts,
                  shrinkWrap: false,
                  physics: const AlwaysScrollableScrollPhysics(),
                ),
        ),
      ),
    );
  }
}
