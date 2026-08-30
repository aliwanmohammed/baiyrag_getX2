import '../../../core/models/product_model.dart';
import '../../../core/utils/json_parser.dart';
import '../../products/models/product_unit_model.dart';

class CartItemModel {
  final ProductModel product;
  final String? cartId;
  final ProductUnitModel unit;

  /// السعر الأصلي قبل العرض
  final double originalPrice;

  /// قيمة الخصم
  final double discount;

  /// السعر بعد العرض
  final double unitPrice;

  final int quantity;

  const CartItemModel({
    this.cartId,
    required this.product,
    required this.unit,
    required this.originalPrice,
    required this.discount,
    required this.unitPrice,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(JsonParser.map(json['product'])),
      unit: ProductUnitModel.fromJson(JsonParser.map(json['unit'])),
      cartId: json['id']?.toString(),
      originalPrice: JsonParser.doubleValue(
        json['original_price'] ?? json['price'] ?? json['unit_price'],
      ),
      discount: JsonParser.doubleValue(json['discount']),
      unitPrice: JsonParser.doubleValue(
        json['new_price'] ?? json['price'] ?? json['unit_price'],
      ),
      quantity: JsonParser.intValue(json['quantity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'unit': unit.toJson(),
      'id': cartId,
      'original_price': originalPrice,
      'discount': discount,
      'new_price': unitPrice,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    String? cartId,
    ProductModel? product,
    ProductUnitModel? unit,
    double? originalPrice,
    double? discount,
    double? unitPrice,
    int? quantity,
  }) {
    final newUnitPrice = unitPrice ?? this.unitPrice;
    final newQuantity = quantity ?? this.quantity;

    return CartItemModel(
      cartId: cartId ?? this.cartId,
      product: product ?? this.product,
      unit: unit ?? this.unit,
      originalPrice: originalPrice ?? this.originalPrice,
      discount: discount ?? this.discount,
      unitPrice: newUnitPrice,
      quantity: newQuantity,
    );
  }

  /// [new_price] is a per-unit price. Do not retain a stale line total when
  /// a locally cached item's quantity changes.
  double get totalPrice => unitPrice * quantity;

  double get discountPerUnit => discount > 0
      ? discount
      : (originalPrice - unitPrice).clamp(0, double.infinity).toDouble();

  bool get hasDiscount => discountPerUnit > 0;
}
