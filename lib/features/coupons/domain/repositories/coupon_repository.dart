import '../../../../core/network/api_response.dart';
import '../../models/coupon_model.dart';

abstract class CouponRepository {
  /// جلب جميع الكوبونات — لوحة الإدارة
  Future<ApiResponse<List<CouponModel>>> getCoupons();

  /// جلب كوبون واحد
  Future<ApiResponse<CouponModel>> getCoupon(String id);

  /// إنشاء كوبون
  Future<ApiResponse<CouponModel>> createCoupon({
    required String code,
    required String type,
    required double value,
    double? minOrderAmount,
    int? usageLimit,
    DateTime? startsAt,
    DateTime? expiresAt,
    bool isActive = true,
  });

  /// تعديل كوبون
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
  });

  /// حذف كوبون
  Future<ApiResponse<void>> deleteCoupon(String id);

  /// تفعيل / تعطيل كوبون
  Future<ApiResponse<CouponModel>> toggleCoupon({
    required String id,
    required bool isActive,
  });

  /// التحقق من الكوبون أثناء Checkout
  Future<ApiResponse<Map<String, dynamic>>> checkCoupon({
    required String code,
    required double orderAmount,
  });
}
