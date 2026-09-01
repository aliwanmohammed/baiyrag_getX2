import '../../../../app/localization/lang.dart';
import 'package:bhm_supermarket/app/router/app_routes.dart';
import 'package:bhm_supermarket/core/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/loading_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../ads/models/offer_model.dart';
import '../../ads/controllers/offers_controller.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart'; // Retained for semantic fallbacks
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/widgets/app_message.dart';
import '../../address/controllers/address_controller.dart';
import '../../address/widgets/address_card.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';

import '../models/coupon_totals.dart';
import '../widgets/payment_method_selector.dart';


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  CheckoutController get controller => Get.find<CheckoutController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (controller) => _buildCheckout(context, controller),
    );
  }

  Future<void> _applyCoupon() async {
    final result = await controller.applyCoupon();
    if (!mounted) return;
    if (result.success) {
      AppMessage.success(context, result.message, title: result.title);
    } else {
      AppMessage.error(context, result.message, title: result.title);
    }
  }

  Future<void> _placeOrder() async {
    if (controller.couponNeedsRecheck) {
      AppMessage.warning(
        context,
        lang.t('cart_changed_coupon'),
        title: lang.t('coupon_expired'),
      );
      return;
    }

    if (controller.addressRequired) {
      final created = await context.push<bool>(AppRoutes.addresses, extra: true);
      if (!mounted) return;
      if (created == true) {
        await Get.find<AddressController>().loadAddresses();
      }
      if (Get.find<AddressController>().selectedAddress == null) return;
    }

    final result = await controller.placeOrder();
    if (!mounted) return;
    if (!result.success) {
      if (result.message != null) {
        AppMessage.error(context, result.message!, title: result.title);
      }
      return;
    }
    context.go(AppRoutes.orderSuccess, extra: result.orderNumber ?? '');
  }

  Widget _buildCheckout(BuildContext context, CheckoutController checkout) {
    final addressController = Get.find<AddressController>();
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
    final couponDiscount = CouponTotals.effectiveCouponDiscount(
      apiDiscountAmount: checkout.discountAmount,
      currentSubtotal: cart.subtotal,
      appliedSubtotal: checkout.couponSubtotal,
    );
    final couponNeedsRecheck = checkout.appliedCouponCode != null &&
        !CouponTotals.isCouponCurrent(
          appliedSubtotal: checkout.couponSubtotal,
          currentSubtotal: cart.subtotal,
        );

    return PopScope(
      canPop: !checkout.isPlacing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && checkout.isPlacing) {
          AppMessage.info(
            context,
            lang.t('please_wait_order'),
            duration: Duration(seconds: 2),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppPageHeader(title: (lang.t('checkout'))),
        body: SafeArea(
          child: AppConstrainedContent(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── القسم الثاني: العنوان ──────────────────────────────
                  _sectionTitle(lang.t('delivery_address')),
                  SizedBox(height: AppSpacing.md),
                  if (addressController.selectedAddress != null) ...[
                    AddressCard(address: addressController.selectedAddress!),
                    SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        variant: AppButtonVariant.outlined,
                        icon: AppIcon(Icons.edit_location_alt, size: AppIconSize.small),
                        text: lang.t('change_or_add_address'),
                        size: AppButtonSize.large,
                        onPressed: () async {
                          final addressController = Get.find<AddressController>();

                          final result = await context.push<bool>(
                            AppRoutes.addresses,
                            extra: true,
                          );

                          if (!mounted) return;

                          if (result == true) {
                            await addressController.loadAddresses();
                          }
                        },
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppIcon(Icons.location_off, color: colorScheme.onSurfaceVariant, size: AppIconSize.medium),
                              SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  lang.t('no_address'),
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            lang.t('add_delivery_address_hint'),
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              text: lang.t('add_delivery_address'),
                              size: AppButtonSize.large,
                              onPressed: () async {
                                final addressController =
                                    Get.find<AddressController>();

                                final result = await context.push<bool>(
                                  AppRoutes.addresses,
                                  extra: true,
                                );

                                if (!mounted) return;

                                if (result == true) {
                                  await addressController.loadAddresses();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: AppSpacing.xl),

                  // ── القسم الثالث: طريقة الدفع ─────────────────────────
                  _sectionTitle(lang.t('payment_method')),
                  SizedBox(height: AppSpacing.md),
                  PaymentMethodSelector(
                    selectedMethod: checkout.paymentMethod,
                    onChanged: (method) {
                      setState(() {
                        checkout.setPaymentMethod(method);
                      });
                    },
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // ── كوبون الخصم ───────────────────────────────────────
                  _sectionTitle(lang.t('coupon')),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: checkout.couponTextController,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            hintText: lang.t('enter_coupon'),
                            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide(color: colorScheme.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide(color: colorScheme.outlineVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 100,
                        height: 52, // Intentional component dimension
                        child: ElevatedButton(
                          onPressed: checkout.couponLoading ? null : _applyCoupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: checkout.couponLoading
                              ? AppLoading(
                                  type: AppLoadingType.bars,
                                  size: 20,
                                  color: colorScheme.onPrimary,
                                )
                              : Text(lang.t('apply')),
                        ),
                      ),
                    ],
                  ),
                  if (couponNeedsRecheck) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      lang.t('cart_changed_reapply_coupon'),
                      style: AppTypography.labelMedium.copyWith(color: colorScheme.error),
                    ),
                  ],

                  SizedBox(height: AppSpacing.xl),

                  // ── القسم الرابع: ملخص الطلب ──────────────────────────
                  _sectionTitle(lang.t('order_summary')),
                  SizedBox(height: AppSpacing.md),
                  Container(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        ...cart.items.map(
                          (item) => Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.product.name} × ${item.quantity}',
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                                Text(
                                  '${item.totalPrice.toStringAsFixed(0)} ر.ي',
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...giftRewards.map(
                          (reward) => Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'هدية مجانية: ${reward.gift.productName} × ${reward.quantity}',
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '0 ر.ي',
                                  style: AppTypography.bodyMedium.copyWith(color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Divider(),
                        ),
                        _summaryRow(lang.t('subtotal'), cart.subtotal),
                        if (couponDiscount > 0)
                          _summaryRow(
                            lang.t('coupon_discount'),
                            -couponDiscount,
                            color: AppColors.success,
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(lang.t('delivery_fee'), style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant)),
                              Text(lang.t('delivery_fee_at_order'), style: AppTypography.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Divider(),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          child: Center(
                            child: Text(
                              lang.t('final_total_in_details'),
                              style: AppTypography.labelLarge.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  //---------------------------  ملاحظات الطلب  ---------------------------
                  _sectionTitle(lang.t('order_notes')),
                  SizedBox(height: AppSpacing.md),

                  TextField(
                    controller: checkout.notesTextController,
                    minLines: 3,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: lang.t('order_notes_hint'),
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      contentPadding: EdgeInsets.all(AppSpacing.md),
                      alignLabelWithHint: true,
                    ),
                  ),

                  SizedBox(height: 30), // Intentional spacing before submit

                  // ── زر تأكيد الطلب ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54, // Intentional component dimension
                    child: ElevatedButton(
                      onPressed: checkout.isPlacing ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: checkout.isPlacing
                          ? AppLoading(
                              type: AppLoadingType.bars,
                              size: 24,
                              color: colorScheme.onPrimary,
                            )
                          : Text(
                              lang.t('place_order'),
                              style: AppTypography.titleMedium.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ), // end Scaffold
      ), // end PopScope
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _summaryRow(
    String label,
    double value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: color,
          )),
          Text(
            '${value.toStringAsFixed(0)} ر.ي',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            )
          ),
        ],
      ),
    );
  }
}
