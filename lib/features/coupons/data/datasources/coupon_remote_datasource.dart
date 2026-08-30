import '../../../../core/api/api_endpoints.dart';
import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_parser.dart';
import '../../models/coupon_model.dart';

class CouponRemoteDataSource extends BaseRemoteDataSource {
  CouponRemoteDataSource(super.dio);

  /// GET /coupons
  Future<ApiResponse<List<CouponModel>>> getCoupons() {
    return getPaginated<List<CouponModel>>(
      ApiEndpoints.coupons,
      parser: (json) =>
          JsonParser.list(json, (e) => CouponModel.fromJson(JsonParser.map(e))),
    );
  }

  /// GET /coupons/{id}
  Future<ApiResponse<CouponModel>> getCoupon(String id) {
    return getEnvelope<CouponModel>(
      ApiEndpoints.coupon(id),
      parser: (json) => CouponModel.fromJson(JsonParser.map(json)),
    );
  }

  /// POST /coupons
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
    return postEnvelope<CouponModel>(
      ApiEndpoints.coupons,
      data: {
        'code': code,
        'type': type,
        'value': value,
        if (minOrderAmount != null) 'min_order_amount': minOrderAmount,
        if (usageLimit != null) 'usage_limit': usageLimit,
        if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
        if (expiresAt != null) 'expires_at': expiresAt.toIso8601String(),
        'is_active': isActive,
      },
      parser: (json) => CouponModel.fromJson(JsonParser.map(json)),
    );
  }

  /// PUT /coupons/{id}
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
    return putEnvelope<CouponModel>(
      ApiEndpoints.coupon(id),
      data: {
        'code': code,
        'type': type,
        'value': value,
        if (minOrderAmount != null) 'min_order_amount': minOrderAmount,
        if (usageLimit != null) 'usage_limit': usageLimit,
        if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
        if (expiresAt != null) 'expires_at': expiresAt.toIso8601String(),
        'is_active': isActive,
      },
      parser: (json) => CouponModel.fromJson(JsonParser.map(json)),
    );
  }

  /// DELETE /coupons/{id}
  Future<ApiResponse<void>> deleteCoupon(String id) {
    return deleteEnvelope(ApiEndpoints.coupon(id));
  }

  /// PUT /coupons/{id}
  /// تفعيل / تعطيل الكوبون
  Future<ApiResponse<CouponModel>> toggleCoupon({
    required String id,
    required bool isActive,
  }) {
    return putEnvelope<CouponModel>(
      ApiEndpoints.coupon(id),
      data: {'is_active': isActive},
      parser: (json) => CouponModel.fromJson(JsonParser.map(json)),
    );
  }

  /// POST /coupons/check
  Future<ApiResponse<Map<String, dynamic>>> checkCoupon({
    required String code,
    required double orderAmount,
  }) {
    return postEnvelope<Map<String, dynamic>>(
      ApiEndpoints.checkCoupon,
      data: {'coupon_code': code, 'subtotal': orderAmount},
      parser: (json) => JsonParser.map(json),
    );
  }
}
