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
    if (code.isEmpty) return const CouponActionResult.failure('أدخل كود الكوبون أولاً');
    _couponLoading = true;
    update();
    try {
      final result = await _coupon.checkCoupon(code: code, orderAmount: _cart.subtotal);
      if (result == null || !result.valid) {
        _discountAmount = 0;
        _couponSubtotal = null;
        _appliedCouponCode = null;
        return CouponActionResult.failure(result?.message ?? _coupon.error ?? 'الكوبون غير صالح', title: 'كوبون غير صالح');
      }
      _discountAmount = result.discountAmount.clamp(0, _cart.subtotal).toDouble();
      _couponSubtotal = _cart.subtotal;
      _appliedCouponCode = code;
      return CouponActionResult.success('تم تطبيق الكوبون، الخصم ${result.discountAmount.toStringAsFixed(0)} ر.ي', title: 'تم تطبيق الكوبون ✓');
    } catch (_) {
      return const CouponActionResult.failure('تعذر التحقق من الكوبون');
    } finally {
      _couponLoading = false;
      update();
    }
  }

  Future<CheckoutActionResult> placeOrder() async {
    if (couponNeedsRecheck) return const CheckoutActionResult.failure('تغيرت محتويات السلة، يرجى إعادة التحقق من الكوبون.', title: 'انتهت صلاحية الكوبون');
    if (_address.selectedAddress == null) return const CheckoutActionResult.addressRequired();
    if (_cart.isEmpty) return const CheckoutActionResult.failure('السلة فارغة');
    if (_isPlacing) return const CheckoutActionResult.failure('يوجد طلب قيد الإرسال');

    _isPlacing = true;
    update();
    try {
      final response = await _orderRepository.createOrder(
        locationId: _address.selectedAddress!.id,
        paymentMethod: _paymentMethod.apiValue,
        notes: notesTextController.text.trim().isEmpty ? null : notesTextController.text.trim(),
        couponCode: _appliedCouponCode,
        items: [
          for (final item in _cart.items)
            {'product_id': item.product.id, 'unit_id': item.unit.id, 'quantity': item.quantity},
        ],
      );
      if (!response.success) {
        return CheckoutActionResult.failure(response.message.isEmpty ? 'فشل إنشاء الطلب، حاول مرة أخرى' : response.message, title: 'فشل إرسال الطلب');
      }
      await _cart.clear();
      try { await _orders.reload(); } catch (_) {}
      return CheckoutActionResult.success(response.data?['order_number']?.toString() ?? '');
    } catch (_) {
      return const CheckoutActionResult.failure('حدث خطأ أثناء إرسال الطلب، حاول مرة أخرى.', title: 'فشل إرسال الطلب');
    } finally {
      _isPlacing = false;
      update();
    }
  }
}

class CouponActionResult {
  const CouponActionResult._(this.success, this.message, this.title);
  const CouponActionResult.success(String message, {String? title}) : this._(true, message, title);
  const CouponActionResult.failure(String message, {String? title}) : this._(false, message, title);
  final bool success;
  final String message;
  final String? title;
}

class CheckoutActionResult {
  const CheckoutActionResult._({required this.success, required this.addressRequired, this.message, this.title, this.orderNumber});
  const CheckoutActionResult.success(String orderNumber) : this._(success: true, addressRequired: false, orderNumber: orderNumber);
  const CheckoutActionResult.failure(String message, {String? title}) : this._(success: false, addressRequired: false, message: message, title: title);
  const CheckoutActionResult.addressRequired() : this._(success: false, addressRequired: true);
  final bool success;
  final bool addressRequired;
  final String? message;
  final String? title;
  final String? orderNumber;
}
