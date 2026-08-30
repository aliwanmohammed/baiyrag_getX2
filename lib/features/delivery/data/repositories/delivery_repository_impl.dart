// import 'package:bhm_supermarket/features/delivery/data/datasources/delivery_remote_datasource.dart';

// import '../../../../core/network/api_response.dart';
// import '../../domain/repositories/delivery_repository.dart';
// import '../../models/delivery_order_model.dart';

// class DeliveryRepositoryImpl implements DeliveryRepository {
//   DeliveryRepositoryImpl(this._remote);

//   final DeliveryRemoteDataSource _remote;

//   @override
//   Future<ApiResponse<List<DeliveryOrderModel>>> getAvailableOrders() {
//     return _remote.fetchAvailableOrders();
//   }

//   @override
//   Future<ApiResponse<List<DeliveryOrderModel>>> getOrders() {
//     return _remote.fetchOrders();
//   }

//   @override
//   Future<ApiResponse<DeliveryOrderModel>> getOrderById(
//     String id,
//   ) {
//     return _remote.fetchOrderById(id);
//   }

//   @override
//   Future<ApiResponse<DeliveryOrderModel>> claimOrder(
//     String id,
//   ) {
//     return _remote.claimOrder(id);
//   }
// }

import 'package:bhm_supermarket/features/delivery/data/datasources/delivery_remote_datasource.dart';

import '../../../../core/network/api_response.dart';

import '../../domain/repositories/delivery_repository.dart';

import '../../models/delivery_order_model.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl(this._remote);

  final DeliveryRemoteDataSource _remote;

  @override
  Future<ApiResponse<List<DeliveryOrderModel>>> getAvailableOrders() {
    return _remote.fetchAvailableOrders();
  }

  @override
  Future<ApiResponse<List<DeliveryOrderModel>>> getOrders() {
    return _remote.fetchOrders();
  }

  @override
  Future<ApiResponse<DeliveryOrderModel>> getOrderById(
    String id,
  ) {
    return _remote.fetchOrderById(id);
  }

  @override
  Future<ApiResponse<DeliveryOrderModel>> claimOrder(
    String id,
  ) {
    return _remote.claimOrder(id);
  }

  @override
  Future<ApiResponse<DeliveryOrderModel>> updateOrderStatus(
    String id, {
    required String status,
    required String paymentStatus,
  }) {
    return _remote.updateOrderStatus(
      id,
      status: status,
      paymentStatus: paymentStatus,
    );
  }
}
