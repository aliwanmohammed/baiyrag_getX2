import 'package:bhm_supermarket/core/network/api_response.dart';
import 'package:bhm_supermarket/core/pagination/pagination_meta.dart';
import 'package:bhm_supermarket/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:bhm_supermarket/features/orders/domain/repositories/order_repository.dart';
import 'package:bhm_supermarket/features/orders/models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResponse<PaginatedResult<List<OrderModel>>>> getOrders({int page = 1}) {
    return _remoteDataSource.getOrders(page: page);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required String locationId,
    required String paymentMethod,
    String? notes,
    String? couponCode,
    required List<Map<String, dynamic>> items,
  }) {
    return _remoteDataSource.createOrder(
      locationId: locationId,
      paymentMethod: paymentMethod,
      notes: notes,
      items: items,
      couponCode: couponCode,
    );
  }
}
