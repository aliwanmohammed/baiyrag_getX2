import '../../../core/utils/json_parser.dart';

class DeliveryOrderModel {
  final String id;
  final String orderNumber;

  final DeliveryCustomerModel? customer;
  final DeliveryLocationModel? location;
  final DeliveryDriverModel? deliveryDriver;

  final List<DeliveryOrderItemModel> items;

  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final double couponDiscount;

  final String paymentMethod;
  final String paymentStatus;
  final String status;

  final DeliveryCouponModel? coupon;

  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const DeliveryOrderModel({
    required this.id,
    required this.orderNumber,
    this.customer,
    this.location,
    this.deliveryDriver,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.couponDiscount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.coupon,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  String get customerName => customer?.name ?? '';

  String get customerPhone => customer?.phone ?? '';

  String get address => location?.address ?? '';

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final locationJson = json['location'];
    final driverJson = json['delivery_driver'];
    final couponJson = json['coupon'];

    final itemsJson = json['items'];

    return DeliveryOrderModel(
      id: JsonParser.string(json['id']),
      orderNumber: JsonParser.string(
        json['order_number'] ?? json['number'] ?? json['id'],
      ),
      customer: userJson is Map
          ? DeliveryCustomerModel.fromJson(Map<String, dynamic>.from(userJson))
          : null,
      location: locationJson is Map
          ? DeliveryLocationModel.fromJson(
              Map<String, dynamic>.from(locationJson),
            )
          : null,
      deliveryDriver: driverJson is Map
          ? DeliveryDriverModel.fromJson(Map<String, dynamic>.from(driverJson))
          : null,
      items: itemsJson is List
          ? itemsJson
              .whereType<Map>()
              .map(
                (item) => DeliveryOrderItemModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      subtotal: JsonParser.doubleValue(json['subtotal']),
      deliveryFee: JsonParser.doubleValue(json['delivery_fee']),
      discount: JsonParser.doubleValue(json['discount']),
      total: JsonParser.doubleValue(json['total'] ?? json['grand_total']),
      couponDiscount: JsonParser.doubleValue(json['coupon_discount']),
      paymentMethod: JsonParser.string(json['payment_method']),
      paymentStatus: JsonParser.string(json['payment_status']),
      status: JsonParser.string(json['status']),
      coupon: couponJson is Map
          ? DeliveryCouponModel.fromJson(Map<String, dynamic>.from(couponJson))
          : null,
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  DeliveryOrderModel copyWith({String? status, String? paymentStatus}) {
    return DeliveryOrderModel(
      id: id,
      orderNumber: orderNumber,
      customer: customer,
      location: location,
      deliveryDriver: deliveryDriver,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      couponDiscount: couponDiscount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      coupon: coupon,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Customer
// ══════════════════════════════════════════════════════════════════════════════

class DeliveryCustomerModel {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;

  const DeliveryCustomerModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
  });

  factory DeliveryCustomerModel.fromJson(Map<String, dynamic> json) {
    return DeliveryCustomerModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: JsonParser.string(json['name']),
      email: JsonParser.string(json['email']),
      phone: json['phone']?.toString(),
      role: JsonParser.string(json['role']),
      isActive: json['is_active'] == true,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Location
// ══════════════════════════════════════════════════════════════════════════════

class DeliveryLocationModel {
  final int? id;
  final String title;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const DeliveryLocationModel({
    this.id,
    required this.title,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  factory DeliveryLocationModel.fromJson(Map<String, dynamic> json) {
    return DeliveryLocationModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      title: JsonParser.string(json['title']),
      address: JsonParser.string(json['address']),
      latitude: _nullableDouble(json['latitude']),
      longitude: _nullableDouble(json['longitude']),
      isDefault: json['is_default'] == true,
    );
  }

  static double? _nullableDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Delivery Driver
// ══════════════════════════════════════════════════════════════════════════════

class DeliveryDriverModel {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String role;

  const DeliveryDriverModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
  });

  factory DeliveryDriverModel.fromJson(Map<String, dynamic> json) {
    return DeliveryDriverModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: JsonParser.string(json['name']),
      email: JsonParser.string(json['email']),
      phone: json['phone']?.toString(),
      role: JsonParser.string(json['role']),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Order Item
// ══════════════════════════════════════════════════════════════════════════════

class DeliveryOrderItemModel {
  final int? id;
  final DeliveryProductModel? product;
  final DeliveryUnitModel? unit;

  final int quantity;
  final double price;
  final double total;
  final bool isGift;

  const DeliveryOrderItemModel({
    this.id,
    this.product,
    this.unit,
    required this.quantity,
    required this.price,
    required this.total,
    required this.isGift,
  });

  factory DeliveryOrderItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    final unitJson = json['unit'];

    return DeliveryOrderItemModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      product: productJson is Map
          ? DeliveryProductModel.fromJson(
              Map<String, dynamic>.from(productJson),
            )
          : null,
      unit: unitJson is Map
          ? DeliveryUnitModel.fromJson(Map<String, dynamic>.from(unitJson))
          : null,
      quantity: _intValue(json['quantity']),
      price: JsonParser.doubleValue(json['price']),
      total: JsonParser.doubleValue(json['total']),
      isGift: json['is_gift'] == true,
    );
  }

  static int _intValue(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Product
// ══════════════════════════════════════════════════════════════════════════════

class DeliveryProductModel {
  final int? id;
  final String nameAr;
  final String nameEn;
  final String uniqueNumber;
  final String barcode;

  const DeliveryProductModel({
    this.id,
    required this.nameAr,
    required this.nameEn,
    required this.uniqueNumber,
    required this.barcode,
  });

  factory DeliveryProductModel.fromJson(Map<String, dynamic> json) {
    return DeliveryProductModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      nameAr: JsonParser.string(json['name_ar']),
      nameEn: JsonParser.string(json['name_en']),
      uniqueNumber: JsonParser.string(json['unique_number']),
      barcode: JsonParser.string(json['barcode']),
    );
  }

  String get displayName {
    if (nameAr.isNotEmpty) return nameAr;
    return nameEn;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Unit
// ══════════════════════════════════════════════════════════════════════════════

class DeliveryUnitModel {
  final int? id;
  final String nameAr;
  final String nameEn;
  final String symbol;

  const DeliveryUnitModel({
    this.id,
    required this.nameAr,
    required this.nameEn,
    required this.symbol,
  });

  factory DeliveryUnitModel.fromJson(Map<String, dynamic> json) {
    return DeliveryUnitModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      nameAr: JsonParser.string(json['name_ar']),
      nameEn: JsonParser.string(json['name_en']),
      symbol: JsonParser.string(json['symbol']),
    );
  }

  String get displayName {
    if (nameAr.isNotEmpty) return nameAr;
    if (nameEn.isNotEmpty) return nameEn;
    return symbol;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Coupon
// ══════════════════════════════════════════════════════════════════════════════

class DeliveryCouponModel {
  final int? id;
  final String code;
  final String type;
  final double value;

  const DeliveryCouponModel({
    this.id,
    required this.code,
    required this.type,
    required this.value,
  });

  factory DeliveryCouponModel.fromJson(Map<String, dynamic> json) {
    return DeliveryCouponModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      code: JsonParser.string(json['code']),
      type: JsonParser.string(json['type']),
      value: JsonParser.doubleValue(json['value']),
    );
  }
}
