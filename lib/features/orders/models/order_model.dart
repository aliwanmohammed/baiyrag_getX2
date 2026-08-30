import '../../../core/utils/json_parser.dart';
import '../../address/models/address_model.dart';
import '../../checkout/models/payment_method.dart';
import 'order_item_model.dart';
import 'order_status.dart';

class OrderModel {
  final String id;
  final String orderNumber;

  final AddressModel location;

  final List<OrderItemModel> items;

  final double subtotal;
  final double deliveryFee;

  /// General/backend discount.
  final double discount;

  /// Discount specifically applied by the coupon.
  final double couponDiscount;

  final double total;

  final String paymentMethod;
  final String paymentStatus;
  final String status;

  OrderStatus get statusEnum => OrderStatusExt.fromString(status);
  PaymentMethod get paymentMethodEnum => PaymentMethodExt.fromString(paymentMethod);

  final String? notes;

  final String createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.location,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.couponDiscount,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: JsonParser.string(json['id']),
      orderNumber: JsonParser.string(json['order_number']),
      location: AddressModel.fromJson(
        JsonParser.map(json['location']),
      ),
      items: JsonParser.list(
        json['items'],
        OrderItemModel.fromJson,
      ),
      subtotal: JsonParser.doubleValue(
        json['subtotal'],
      ),
      deliveryFee: JsonParser.doubleValue(
        json['delivery_fee'],
      ),
      discount: JsonParser.doubleValue(
        json['discount'],
      ),
      couponDiscount: JsonParser.doubleValue(
        json['coupon_discount'],
      ),
      total: JsonParser.doubleValue(
        json['total'],
      ),
      paymentMethod: JsonParser.string(
        json['payment_method'],
      ),
      paymentStatus: JsonParser.string(
        json['payment_status'],
      ),
      status: JsonParser.string(
        json['status'],
      ),
      notes: json['notes']?.toString(),
      createdAt: JsonParser.string(
        json['created_at'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'discount': discount,
      'coupon_discount': couponDiscount,
      'total': total,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
