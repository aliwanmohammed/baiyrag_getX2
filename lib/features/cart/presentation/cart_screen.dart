import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:bhm_supermarket/core/widgets/app_page_header.dart';
import 'package:bhm_supermarket/features/navigation/controllers/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_error_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../../ads/models/offer_model.dart';
import '../../ads/controllers/offers_controller.dart';
import '../controllers/cart_controller.dart';
import '../../auth/utils/auth_gate.dart';
import '../widgets/cart_item_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _synced = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_synced && mounted) {
        _synced = true;
        await Get.find<CartController>().loadFromServer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
        builder: (_) =>
            GetBuilder<OffersController>(builder: (_) => _buildGetX0(context)));
  }

  Widget _buildGetX0(BuildContext context) {
    final cart = Get.find<CartController>();
    final offers = Get.find<OffersController>();
    final colorScheme = Theme.of(context).colorScheme;

    final giftRewards = offers.giftRewardsFor(
      cart.items.map(
        (item) => OfferCartLine(
          productId: item.product.id,
          unitId: item.unit.id,
          quantity: item.quantity,
        ),
      ),
    );

    if (cart.isLoading && cart.isEmpty) {
      return Scaffold(
        body: AppLoading.fullPage(message: lang.t('loading_cart')),
      );
    }

    if (cart.error != null && cart.isEmpty) {
      return Scaffold(
        body: AppErrorState(
          title: lang.t('cart_load_error'),
          message: cart.error!,
          onRetry: cart.loadFromServer,
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppPageHeader(
        title: lang.t('cart'),
        showBack: false,
        actions: [
          if (cart.isNotEmpty)
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  title: Text(lang.t('clear_cart')),
                  content: Text(lang.t('clear_cart_confirm')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(lang.t('cancel')),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await cart.clear();
                      },
                      child: Text(
                        lang.t('delete'),
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
              icon: AppIcon(
                Icons.delete_outline,
                size: AppIconSize.small,
                color: colorScheme.error,
              ),
              label: Text(
                lang.t('clear'),
                style: TextStyle(color: colorScheme.error, fontSize: 13),
              ),
            ),
        ],
      ),
      body: AppConstrainedContent(
        child: cart.isEmpty
            ? RefreshIndicator(
                onRefresh: cart.loadFromServer,
                color: colorScheme.primary,
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 420,
                      child: AppEmptyState(
                        icon: Icons.shopping_bag_outlined,
                        title: lang.t('cart_empty'),
                        subtitle: lang.t('add_products_home'),
                        actionLabel: lang.t('shop_now'),
                        onAction: () {
                          Get.find<NavigationController>().changeTab(0);
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Items list
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      itemCount: cart.items.length + giftRewards.length,
                      itemBuilder: (context, index) {
                        if (index >= cart.items.length) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _GiftRewardCard(
                              reward: giftRewards[index - cart.items.length],
                            ),
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: CartItemCard(
                            item: cart.items[index],
                            onIncrease: () async {
                              await cart.increase(index);
                            },
                            onDecrease: () async {
                              await cart.decrease(index);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // Summary card
                  Container(
                    margin: EdgeInsets.all(AppSpacing.md),
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.06), // Intentional shadow
                          blurRadius: 20,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          lang.t('subtotal'),
                          '${cart.originalSubtotal.toStringAsFixed(0)} ر.ي',
                        ),
                        if (cart.offerDiscount > 0) ...[
                          SizedBox(height: AppSpacing.xs),
                          _SummaryRow(
                            lang.t('discount'),
                            '-${cart.offerDiscount.toStringAsFixed(0)} ر.ي',
                            valueColor: AppColors.success,
                          ),
                        ],
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang.t('total_products'),
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${cart.subtotal.toStringAsFixed(0)} ر.ي',
                              style: AppTypography.titleLarge.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        AppButton(
                          onPressed: () {
                            AuthGate.check(
                              context,
                              destination: AppRoutes.checkout,
                              onAuthenticated: () {
                                context.push(AppRoutes.checkout);
                              },
                            );
                          },
                          icon: AppIcon(
                            Icons.arrow_back_ios_rounded,
                            size: AppIconSize.small,
                            directionSensitive: true,
                          ),
                          text: lang.t('continue_checkout'),
                          size: AppButtonSize.large,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTypography.bodyMedium
                .copyWith(color: colorScheme.onSurfaceVariant)),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(color: valueColor),
        ),
      ],
    );
  }
}

class _GiftRewardCard extends StatelessWidget {
  final GiftRewardModel reward;

  const _GiftRewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    final successColor = AppColors.success;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: successColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: successColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          AppIcon(Icons.card_giftcard_rounded, color: successColor),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('free_gift'),
                  style: AppTypography.titleSmall.copyWith(
                    color: successColor,
                  ),
                ),
                SizedBox(height: 2),
                Text('${reward.gift.productName} × ${reward.quantity}'),
              ],
            ),
          ),
          Text(
            '0 ر.ي',
            style: AppTypography.titleSmall.copyWith(
              color: successColor,
            ),
          ),
        ],
      ),
    );
  }
}
