import '../../../../app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../address/controllers/address_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../coupons/controllers/coupon_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../orders/domain/repositories/order_repository.dart';
import '../models/coupon_totals.dart';
import '../models/payment_method.dart';

class CheckoutController extends GetxController {
  CheckoutController(this._orderRepository, this._cart, this._address, this._coupon, this._orders);
  final OrderRepository _orderRepository;
  final CartController _cart;
  final AddressController _address;
  final CouponController _coupon;
  final OrdersController _orders;

  final couponTextController = TextEditingController();
  final notesTextController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  double _discountAmount = 0;
  double? _couponSubtotal;
  String? _appliedCouponCode;
  bool _couponLoading = false;
  bool _isPlacing = false;

  PaymentMethod get paymentMethod => _paymentMethod;
  double get discountAmount => _discountAmount;
  double? get couponSubtotal => _couponSubtotal;
  String? get appliedCouponCode => _appliedCouponCode;
  bool get couponLoading => _couponLoading;
  bool get isPlacing => _isPlacing;
  bool get addressRequired => _address.selectedAddress == null;
  double get effectiveCouponDiscount => CouponTotals.effectiveCouponDiscount(
        apiDiscountAmount: _discountAmount,
        currentSubtotal: _cart.subtotal,
        appliedSubtotal: _couponSubtotal,
      );
  bool get couponNeedsRecheck => _appliedCouponCode != null &&
      !CouponTotals.isCouponCurrent(appliedSubtotal: _couponSubtotal, currentSubtotal: _cart.subtotal);

  @override
  void onClose() {
    couponTextController.dispose();
    notesTextController.dispose();
    super.onClose();
  }

  void setPaymentMethod(PaymentMethod method) {
    if (_paymentMethod == method) return;
    _paymentMethod = method;
    update();
  }

  Future<CouponActionResult> applyCoupon() async {
    final code = couponTextController.text.trim().toUpperCase();
    if (code.isEmpty) return CouponActionResult.failure(lang.t('enter_coupon_first'));
    _couponLoading = true;
    update();
    try {
      final result = await _coupon.checkCoupon(code: code, orderAmount: _cart.subtotal);
      if (result == null || !result.valid) {
        _discountAmount = 0;
        _couponSubtotal = null;
        _appliedCouponCode = null;
        return CouponActionResult.failure(result?.message ?? _coupon.error ?? lang.t('invalid_coupon'), title: lang.t('invalid_coupon'));
      }
      _discountAmount = result.discountAmount.clamp(0, _cart.subtotal).toDouble();
      _couponSubtotal = _cart.subtotal;
      _appliedCouponCode = code;
      return CouponActionResult.success(lang.t('coupon_applied_dynamic', {'amount': result.discountAmount.toStringAsFixed(0)}), title: lang.t('coupon_applied'));
    } catch (_) {
      return CouponActionResult.failure(lang.t('coupon_validation_error'));
    } finally {
      _couponLoading = false;
      update();
    }
  }

  Future<CheckoutActionResult> placeOrder() async {
    if (couponNeedsRecheck) return CheckoutActionResult.failure(lang.t('cart_changed_coupon'), title: lang.t('coupon_expired'));
    if (_address.selectedAddress == null) return CheckoutActionResult.addressRequired();
    if (_cart.isEmpty) {
      return CheckoutActionResult.failure(lang.t('cart_empty'));
    }

    final orderItems = [
      for (final item in _cart.items)
        {
          'product_id': item.product.id,
          'unit_id': item.unit.id,
          'quantity': item.quantity,
        },
    ];

    if (orderItems.isEmpty) {
      return CheckoutActionResult.failure(lang.t('cart_must_have_product'));
    }
    if (_isPlacing) return CheckoutActionResult.failure(lang.t('order_submission_in_progress'));

    _isPlacing = true;
    update();
    try {
      final response = await _orderRepository.createOrder(
        locationId: _address.selectedAddress!.id,
        paymentMethod: _paymentMethod.apiValue,
        notes: notesTextController.text.trim().isEmpty ? null : notesTextController.text.trim(),
        couponCode: _appliedCouponCode,
        items: orderItems,
      );
      if (!response.success) {
        return CheckoutActionResult.failure(response.message.isEmpty ? lang.t('order_create_failed') : response.message, title: lang.t('order_submit_failed'));
      }
      await _cart.clear();
      try { await _orders.reload(); } catch (_) {}
      return CheckoutActionResult.success(response.data?['order_number']?.toString() ?? '');
    } catch (_) {
      return CheckoutActionResult.failure(lang.t('order_submit_error'), title: lang.t('order_submit_failed'));
    } finally {
      _isPlacing = false;
      update();
    }
  }
}

class CouponActionResult {
  CouponActionResult._(this.success, this.message, this.title);
  CouponActionResult.success(String message, {String? title}) : this._(true, message, title);
  CouponActionResult.failure(String message, {String? title}) : this._(false, message, title);
  final bool success;
  final String message;
  final String? title;
}

class CheckoutActionResult {
  CheckoutActionResult._({required this.success, required this.addressRequired, this.message, this.title, this.orderNumber});
  CheckoutActionResult.success(String orderNumber) : this._(success: true, addressRequired: false, orderNumber: orderNumber);
  CheckoutActionResult.failure(String message, {String? title}) : this._(success: false, addressRequired: false, message: message, title: title);
  CheckoutActionResult.addressRequired() : this._(success: false, addressRequired: true);
  final bool success;
  final bool addressRequired;
  final String? message;
  final String? title;
  final String? orderNumber;
}
