class CouponTotals {
  CouponTotals._();

  static bool isCouponCurrent({
    required double? appliedSubtotal,
    required double currentSubtotal,
  }) {
    if (appliedSubtotal == null) return false;

    return (appliedSubtotal - currentSubtotal).abs() < 0.000001;
  }

  static double effectiveCouponDiscount({
    required double apiDiscountAmount,
    required double currentSubtotal,
    required double? appliedSubtotal,
  }) {
    if (!isCouponCurrent(
      appliedSubtotal: appliedSubtotal,
      currentSubtotal: currentSubtotal,
    )) {
      return 0;
    }

    return apiDiscountAmount.clamp(0, currentSubtotal).toDouble();
  }
}
