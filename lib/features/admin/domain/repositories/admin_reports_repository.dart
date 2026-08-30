import '../../models/admin_reports_model.dart';

abstract class AdminReportsRepository {
  Future<SalesReport> getSales({
    String? from,
    String? to,
  });

  Future<CustomersReport> getCustomers();

  Future<ProductsReport> getProducts();

  Future<OrdersReport> getOrders({
    String? from,
    String? to,
  });

  Future<List<DeliveryDriverReport>> getDeliveryDrivers({
    String? from,
    String? to,
  });

  Future<DeliveryDriverDetailsReport> getDeliveryDriver(
    int id, {
    String? from,
    String? to,
  });

  Future<LocationsReport> getLocations();
}
