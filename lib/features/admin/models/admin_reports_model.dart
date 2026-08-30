class SalesReport {
  final double totalSales;
  final int totalOrders;

  const SalesReport({
    required this.totalSales,
    required this.totalOrders,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      totalSales: _toDouble(json['total_sales']),
      totalOrders: _toInt(json['total_orders']),
    );
  }
}

class CustomersReport {
  final int totalCustomers;

  const CustomersReport({
    required this.totalCustomers,
  });

  factory CustomersReport.fromJson(Map<String, dynamic> json) {
    return CustomersReport(
      totalCustomers: _toInt(json['total_customers']),
    );
  }
}

class ProductsReport {
  final int totalProducts;

  const ProductsReport({
    required this.totalProducts,
  });

  factory ProductsReport.fromJson(Map<String, dynamic> json) {
    return ProductsReport(
      totalProducts: _toInt(json['total_products']),
    );
  }
}

class OrdersReport {
  final int totalOrders;
  final int pending;
  final int confirmed;
  final int processing;
  final int shipped;
  final int delivered;
  final int cancelled;
  final double totalAmount;

  const OrdersReport({
    required this.totalOrders,
    required this.pending,
    required this.confirmed,
    required this.processing,
    required this.shipped,
    required this.delivered,
    required this.cancelled,
    required this.totalAmount,
  });

  factory OrdersReport.fromJson(Map<String, dynamic> json) {
    return OrdersReport(
      totalOrders: _toInt(json['total_orders']),
      pending: _toInt(json['pending']),
      confirmed: _toInt(json['confirmed']),
      processing: _toInt(json['processing']),
      shipped: _toInt(json['shipped']),
      delivered: _toInt(json['delivered']),
      cancelled: _toInt(json['cancelled']),
      totalAmount: _toDouble(json['total_amount']),
    );
  }
}

class DeliveryDriverReport {
  final int id;
  final String name;
  final String email;
  final int totalOrders;
  final int pendingOrders;
  final int processingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double totalSales;

  const DeliveryDriverReport({
    required this.id,
    required this.name,
    required this.email,
    required this.totalOrders,
    required this.pendingOrders,
    required this.processingOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalSales,
  });

  factory DeliveryDriverReport.fromJson(Map<String, dynamic> json) {
    return DeliveryDriverReport(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      totalOrders: _toInt(json['total_orders']),
      pendingOrders: _toInt(json['pending_orders']),
      processingOrders: _toInt(json['processing_orders']),
      shippedOrders: _toInt(json['shipped_orders']),
      deliveredOrders: _toInt(json['delivered_orders']),
      cancelledOrders: _toInt(json['cancelled_orders']),
      totalSales: _toDouble(json['total_sales']),
    );
  }
}

class DeliveryDriverDetailsReport {
  final int id;
  final String name;
  final String email;

  final int totalOrders;
  final int pending;
  final int processing;
  final int shipped;
  final int delivered;
  final int cancelled;

  final double totalSales;

  const DeliveryDriverDetailsReport({
    required this.id,
    required this.name,
    required this.email,
    required this.totalOrders,
    required this.pending,
    required this.processing,
    required this.shipped,
    required this.delivered,
    required this.cancelled,
    required this.totalSales,
  });

  factory DeliveryDriverDetailsReport.fromJson(
    Map<String, dynamic> json,
  ) {
    final driver = Map<String, dynamic>.from(
      json['driver'] ?? {},
    );

    final orders = Map<String, dynamic>.from(
      json['orders'] ?? {},
    );

    return DeliveryDriverDetailsReport(
      id: _toInt(driver['id']),
      name: driver['name']?.toString() ?? '',
      email: driver['email']?.toString() ?? '',
      totalOrders: _toInt(orders['total']),
      pending: _toInt(orders['pending']),
      processing: _toInt(orders['processing']),
      shipped: _toInt(orders['shipped']),
      delivered: _toInt(orders['delivered']),
      cancelled: _toInt(orders['cancelled']),
      totalSales: _toDouble(json['total_sales']),
    );
  }
}

class LocationsReport {
  final int totalLocations;

  const LocationsReport({
    required this.totalLocations,
  });

  factory LocationsReport.fromJson(Map<String, dynamic> json) {
    return LocationsReport(
      totalLocations: _toInt(json['total_locations']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
