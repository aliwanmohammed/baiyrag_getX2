import '../../../../core/network/api_response.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../../models/coupon_model.dart';
import '../datasources/coupon_remote_datasource.dart';

class CouponRepositoryImpl implements CouponRepository {
  CouponRepositoryImpl(this._remote);

  final CouponRemoteDataSource _remote;

  @override
  Future<ApiResponse<List<CouponModel>>> getCoupons() {
    return _remote.getCoupons();
  }

  @override
  Future<ApiResponse<CouponModel>> getCoupon(String id) {
    return _remote.getCoupon(id);
  }

  @override
  Future<ApiResponse<CouponModel>> createCoupon({
    required String code,
    required String type,
    required double value,
    double? minOrderAmount,
    int? usageLimit,
    DateTime? startsAt,
    DateTime? expiresAt,
    bool isActive = true,
  }) {
    return _remote.createCoupon(
      code: code,
      type: type,
      value: value,
      minOrderAmount: minOrderAmount,
      usageLimit: usageLimit,
      startsAt: startsAt,
      expiresAt: expiresAt,
      isActive: isActive,
    );
  }

  @override
  Future<ApiResponse<CouponModel>> updateCoupon({
    required String id,
    required String code,
    required String type,
    required double value,
    double? minOrderAmount,
    int? usageLimit,
    DateTime? startsAt,
    DateTime? expiresAt,
    bool isActive = true,
  }) {
    return _remote.updateCoupon(
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
  }

  @override
  Future<ApiResponse<void>> deleteCoupon(String id) {
    return _remote.deleteCoupon(id);
  }

  @override
  Future<ApiResponse<CouponModel>> toggleCoupon({
    required String id,
    required bool isActive,
  }) {
    return _remote.toggleCoupon(id: id, isActive: isActive);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> checkCoupon({
    required String code,
    required double orderAmount,
  }) {
    return _remote.checkCoupon(code: code, orderAmount: orderAmount);
  }
}
