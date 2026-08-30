import '../../domain/repositories/admin_reports_repository.dart';
import '../../models/admin_reports_model.dart';
import '../datasources/admin_reports_remote_datasource.dart';

class AdminReportsRepositoryImpl implements AdminReportsRepository {
  final AdminReportsRemoteDataSource remoteDataSource;

  AdminReportsRepositoryImpl(this.remoteDataSource);

  @override
  Future<SalesReport> getSales({
    String? from,
    String? to,
  }) {
    return remoteDataSource.getSales(
      from: from,
      to: to,
    );
  }

  @override
  Future<CustomersReport> getCustomers() {
    return remoteDataSource.getCustomers();
  }

  @override
  Future<ProductsReport> getProducts() {
    return remoteDataSource.getProducts();
  }

  @override
  Future<OrdersReport> getOrders({
    String? from,
    String? to,
  }) {
    return remoteDataSource.getOrders(
      from: from,
      to: to,
    );
  }

  @override
  Future<List<DeliveryDriverReport>> getDeliveryDrivers({
    String? from,
    String? to,
  }) {
    return remoteDataSource.getDeliveryDrivers(
      from: from,
      to: to,
    );
  }

  @override
  Future<DeliveryDriverDetailsReport> getDeliveryDriver(
    int id, {
    String? from,
    String? to,
  }) {
    return remoteDataSource.getDeliveryDriver(
      id,
      from: from,
      to: to,
    );
  }

  @override
  Future<LocationsReport> getLocations() {
    return remoteDataSource.getLocations();
  }
}
