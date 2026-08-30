import 'package:dio/dio.dart';
import '../../models/admin_reports_model.dart';

class AdminReportsRemoteDataSource {
  final Dio dio;

  AdminReportsRemoteDataSource(this.dio);

  Future<SalesReport> getSales({
    String? from,
    String? to,
  }) async {
    final response = await dio.get(
      '/reports/sales',
      queryParameters: _dateParams(from, to),
    );

    return SalesReport.fromJson(
      _data(response),
    );
  }

  Future<CustomersReport> getCustomers() async {
    final response = await dio.get('/reports/customers');

    return CustomersReport.fromJson(
      _data(response),
    );
  }

  Future<ProductsReport> getProducts() async {
    final response = await dio.get('/reports/products');

    return ProductsReport.fromJson(
      _data(response),
    );
  }

  Future<OrdersReport> getOrders({
    String? from,
    String? to,
  }) async {
    final response = await dio.get(
      '/reports/orders',
      queryParameters: _dateParams(from, to),
    );

    return OrdersReport.fromJson(
      _data(response),
    );
  }

  Future<List<DeliveryDriverReport>> getDeliveryDrivers({
    String? from,
    String? to,
  }) async {
    final response = await dio.get(
      '/reports/delivery-drivers',
      queryParameters: _dateParams(from, to),
    );

    final data = response.data['data'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) => DeliveryDriverReport.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<DeliveryDriverDetailsReport> getDeliveryDriver(
    int id, {
    String? from,
    String? to,
  }) async {
    final response = await dio.get(
      '/reports/delivery-drivers/$id',
      queryParameters: _dateParams(from, to),
    );

    return DeliveryDriverDetailsReport.fromJson(
      _data(response),
    );
  }

  Future<LocationsReport> getLocations() async {
    final response = await dio.get('/reports/locations');

    return LocationsReport.fromJson(
      _data(response),
    );
  }

  Map<String, dynamic>? _dateParams(
    String? from,
    String? to,
  ) {
    final params = <String, dynamic>{};

    if (from != null && from.isNotEmpty) {
      params['from'] = from;
    }

    if (to != null && to.isNotEmpty) {
      params['to'] = to;
    }

    return params.isEmpty ? null : params;
  }

  Map<String, dynamic> _data(Response response) {
    return Map<String, dynamic>.from(
      response.data['data'] ?? {},
    );
  }
}
