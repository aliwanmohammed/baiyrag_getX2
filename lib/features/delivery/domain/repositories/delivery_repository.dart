// import '../../../../core/network/api_response.dart';
// import '../../models/delivery_order_model.dart';

// abstract class DeliveryRepository {
//   Future<ApiResponse<List<DeliveryOrderModel>>> getAvailableOrders();

//   Future<ApiResponse<List<DeliveryOrderModel>>> getOrders();

//   Future<ApiResponse<DeliveryOrderModel>> getOrderById(
//     String id,
//   );

//   Future<ApiResponse<DeliveryOrderModel>> claimOrder(
//     String id,
//   );
// }

import '../../../../core/network/api_response.dart';
import '../../models/delivery_order_model.dart';

abstract class DeliveryRepository {
  Future<ApiResponse<List<DeliveryOrderModel>>> getAvailableOrders();

  Future<ApiResponse<List<DeliveryOrderModel>>> getOrders();

  Future<ApiResponse<DeliveryOrderModel>> getOrderById(
    String id,
  );

  Future<ApiResponse<DeliveryOrderModel>> claimOrder(
    String id,
  );

  Future<ApiResponse<DeliveryOrderModel>> updateOrderStatus(
    String id, {
    required String status,
    required String paymentStatus,
  });
}
