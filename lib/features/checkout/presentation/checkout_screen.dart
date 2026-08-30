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
        'تغيرت محتويات السلة، يرجى إعادة التحقق من الكوبون.',
        title: 'انتهت صلاحية الكوبون',
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
            'يُرجى الانتظار حتى اكتمال إرسال الطلب...',
            duration: const Duration(seconds: 2),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppPageHeader(title: ('إتمام الطلب')),
        body: SafeArea(
          child: AppConstrainedContent(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── القسم الثاني: العنوان ──────────────────────────────
                  _sectionTitle('عنوان التوصيل'),
                  const SizedBox(height: AppSpacing.md),
                  if (addressController.selectedAddress != null) ...[
                    AddressCard(address: addressController.selectedAddress!),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        variant: AppButtonVariant.outlined,
                        icon: const AppIcon(Icons.edit_location_alt, size: AppIconSize.small),
                        text: "تغيير أو إضافة عنوان",
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
                      padding: const EdgeInsets.all(AppSpacing.lg),
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
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  "لا يوجد عنوان",
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            "أضف عنوان التوصيل لإكمال الطلب",
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              text: "إضافة عنوان توصيل",
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

                  const SizedBox(height: AppSpacing.xl),

                  // ── القسم الثالث: طريقة الدفع ─────────────────────────
                  _sectionTitle('طريقة الدفع'),
                  const SizedBox(height: AppSpacing.md),
                  PaymentMethodSelector(
                    selectedMethod: checkout.paymentMethod,
                    onChanged: (method) {
                      setState(() {
                        checkout.setPaymentMethod(method);
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── كوبون الخصم ───────────────────────────────────────
                  _sectionTitle('كوبون الخصم'),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: checkout.couponTextController,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            hintText: 'أدخل كود الخصم',
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
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
                              : const Text("تطبيق"),
                        ),
                      ),
                    ],
                  ),
                  if (couponNeedsRecheck) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'تغيرت قيمة السلة، أعد تطبيق الكوبون للتحقق من الخصم.',
                      style: AppTypography.labelMedium.copyWith(color: colorScheme.error),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // ── القسم الرابع: ملخص الطلب ──────────────────────────
                  _sectionTitle('ملخص الطلب'),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        ...cart.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Divider(),
                        ),
                        _summaryRow('المجموع', cart.subtotal),
                        if (couponDiscount > 0)
                          _summaryRow(
                            'خصم الكوبون',
                            -couponDiscount,
                            color: AppColors.success,
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('رسوم التوصيل', style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant)),
                              Text('تُحدد عند إنشاء الطلب', style: AppTypography.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          child: Center(
                            child: Text(
                              'سيتم عرض الإجمالي النهائي في تفاصيل الطلب',
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

                  const SizedBox(height: AppSpacing.xl),

                  //---------------------------  ملاحظات الطلب  ---------------------------
                  _sectionTitle('ملاحظات الطلب'),
                  const SizedBox(height: AppSpacing.md),

                  TextField(
                    controller: checkout.notesTextController,
                    minLines: 3,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'اكتب أي ملاحظات حول الطلب...',
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
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 30), // Intentional spacing before submit

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
                              'تأكيد الطلب',
                              style: AppTypography.titleMedium.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
