import '../../../../core/api/api_endpoints.dart';
import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/pagination/pagination_meta.dart';
import '../../../../core/utils/json_parser.dart';
import '../../models/order_model.dart';

class OrderRemoteDataSource extends BaseRemoteDataSource {
  OrderRemoteDataSource(super.dio);

  Future<ApiResponse<PaginatedResult<List<OrderModel>>>> getOrders({int page = 1}) =>
      getWithMeta<List<OrderModel>>(
        ApiEndpoints.myOrders,
        query: {'page': page},
        parser: (json) => JsonParser.list(
          json,
          (e) => OrderModel.fromJson(JsonParser.map(e)),
        ),
      );

  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required String locationId,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    String? couponCode,
    String? notes,
  }) {
    return postEnvelope<Map<String, dynamic>>(
      ApiEndpoints.orders,
      data: {
        'location_id': locationId,
        'payment_method': paymentMethod,
        'items': items,
        if (couponCode != null && couponCode.isNotEmpty)
          'coupon_code': couponCode,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
      parser: (json) => JsonParser.map(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> trackOrder(String orderNumber) =>
      getEnvelope<Map<String, dynamic>>(
        ApiEndpoints.orderTrack(orderNumber),
        parser: (json) => JsonParser.map(json),
      );
}
