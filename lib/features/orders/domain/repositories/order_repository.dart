import 'package:bhm_supermarket/core/network/api_response.dart';
import '../../../../core/pagination/pagination_meta.dart';
import '../../models/order_model.dart';

abstract class OrderRepository {
  Future<ApiResponse<PaginatedResult<List<OrderModel>>>> getOrders({int page = 1});

  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required String locationId,
    required String paymentMethod,
    String? notes,
    String? couponCode,
    required List<Map<String, dynamic>> items,
  });
}
