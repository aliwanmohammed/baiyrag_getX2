import 'package:get/get.dart';

import '../domain/repositories/coupon_repository.dart';
import '../models/coupon_model.dart';

class CouponController extends GetxController {
  CouponController(this._repository);

  final CouponRepository _repository;

  List<CouponModel> _coupons = [];
  CouponModel? _selectedCoupon;

  bool _loading = false;
  bool _saving = false;
  String? _error;

  List<CouponModel> get coupons => _coupons;
  CouponModel? get selectedCoupon => _selectedCoupon;

  bool get loading => _loading;
  bool get saving => _saving;
  String? get error => _error;

  bool get isEmpty => !_loading && _coupons.isEmpty && _error == null;

  // ─────────────────────────────────────────────────────────────
  // Load coupons
  // ─────────────────────────────────────────────────────────────

  Future<void> loadCoupons() async {
    _loading = true;
    _error = null;
    update();

    final response = await _repository.getCoupons();

    if (response.isSuccess) {
      _coupons = response.data ?? [];
    } else {
      _coupons = [];
      _error = response.message;
    }

    _loading = false;
    update();
  }

  Future<void> reload() => loadCoupons();

  // ─────────────────────────────────────────────────────────────
  // Load single coupon
  // ─────────────────────────────────────────────────────────────

  Future<void> loadCoupon(String id) async {
    _selectedCoupon = null;
    _error = null;
    update();

    final response = await _repository.getCoupon(id);

    if (response.isSuccess) {
      _selectedCoupon = response.data;
    } else {
      _error = response.message;
    }

    update();
  }

  // ─────────────────────────────────────────────────────────────
  // Create
  // ─────────────────────────────────────────────────────────────

  Future<String?> createCoupon({
    required String code,
    required String type,
    required double value,
    double? minOrderAmount,
    int? usageLimit,
    DateTime? startsAt,
    DateTime? expiresAt,
    bool isActive = true,
  }) async {
    _saving = true;
    _error = null;
    update();

    final response = await _repository.createCoupon(
      code: code,
      type: type,
      value: value,
      minOrderAmount: minOrderAmount,
      usageLimit: usageLimit,
      startsAt: startsAt,
      expiresAt: expiresAt,
      isActive: isActive,
    );

    _saving = false;

    if (!response.isSuccess) {
      _error = response.message;
      update();
      return response.message;
    }

    await loadCoupons();

    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // Update
  // ─────────────────────────────────────────────────────────────

  Future<String?> updateCoupon({
    required String id,
    required String code,
    required String type,
    required double value,
    double? minOrderAmount,
    int? usageLimit,
    DateTime? startsAt,
    DateTime? expiresAt,
    bool isActive = true,
  }) async {
    _saving = true;
    _error = null;
    update();

    final response = await _repository.updateCoupon(
      id: id,
      code: code,
      type: type,
      value: value,
      minOrderAmount: minOrderAmount,
      usageLimit: usageLimit,
      startsAt: startsAt,
      expiresAt: expiresAt,
      isActive: isActive,
    );

    _saving = false;

    if (!response.isSuccess) {
      _error = response.message;
      update();
      return response.message;
    }

    await loadCoupons();

    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // Delete
  // ─────────────────────────────────────────────────────────────

  Future<String?> deleteCoupon(String id) async {
    _saving = true;
    _error = null;
    update();

    final response = await _repository.deleteCoupon(id);

    _saving = false;

    if (!response.isSuccess) {
      _error = response.message;
      update();
      return response.message;
    }

    _coupons.removeWhere((coupon) => coupon.id == id);

    if (_selectedCoupon?.id == id) {
      _selectedCoupon = null;
    }

    update();

    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // Toggle active
  // ─────────────────────────────────────────────────────────────

  Future<String?> toggleCoupon({
    required String id,
    required bool isActive,
  }) async {
    _saving = true;
    _error = null;
    update();

    final response = await _repository.toggleCoupon(id: id, isActive: isActive);

    _saving = false;

    if (!response.isSuccess) {
      _error = response.message;
      update();
      return response.message;
    }

    final index = _coupons.indexWhere((coupon) => coupon.id == id);

    if (index != -1) {
      final updated = response.data;

      if (updated != null) {
        _coupons[index] = updated;
      }
    }

    if (_selectedCoupon?.id == id && response.data != null) {
      _selectedCoupon = response.data;
    }

    update();

    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // Check coupon — Checkout
  // ─────────────────────────────────────────────────────────────

  Future<ApiCouponCheckResult?> checkCoupon({
    required String code,
    required double orderAmount,
  }) async {
    _error = null;
    update();

    final response = await _repository.checkCoupon(
      code: code,
      orderAmount: orderAmount,
    );

    if (!response.isSuccess || response.data == null) {
      _error = response.message;
      update();
      return null;
    }

    return ApiCouponCheckResult.fromJson(response.data!);
  }

  void clearError() {
    _error = null;
    update();
  }
}

// ─────────────────────────────────────────────────────────────
// Coupon check result
// ─────────────────────────────────────────────────────────────

class ApiCouponCheckResult {
  final bool valid;
  final double discountAmount;
  final String? message;

  const ApiCouponCheckResult({
    required this.valid,
    required this.discountAmount,
    this.message,
  });


  factory ApiCouponCheckResult.fromJson(Map<String, dynamic> json) {
    final rawDiscount = json['discount_amount'];

    double discount = 0;

    if (rawDiscount is num) {
      discount = rawDiscount.toDouble();
    } else if (rawDiscount != null) {
      discount = double.tryParse(rawDiscount.toString()) ?? 0;
    }

    final code = json['code']?.toString();

    return ApiCouponCheckResult(
      valid: code != null && code.isNotEmpty,
      discountAmount: discount,
      message: json['message']?.toString(),
    );
  }
}
