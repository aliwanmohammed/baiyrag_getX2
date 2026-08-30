import '../../../core/models/product_model.dart';
import '../../../core/utils/json_parser.dart';
import '../../products/models/product_unit_model.dart';

class OrderItemModel {
  final String id;
  final ProductModel? product;
  final ProductUnitModel? unit;
  final int quantity;
  final double price;
  final double total;
  final bool isGift;

  const OrderItemModel({
    required this.id,
    this.product,
    this.unit,
    required this.quantity,
    required this.price,
    required this.total,
    required this.isGift,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: JsonParser.string(json["id"]),
      product: json["product"] != null
          ? ProductModel.fromJson(json["product"])
          : null,
      unit: json["unit"] != null
          ? ProductUnitModel.fromJson(json["unit"])
          : null,
      quantity: JsonParser.intValue(json["quantity"]),
      price: JsonParser.doubleValue(json["price"]),
      total: JsonParser.doubleValue(json["total"]),
      isGift: json["is_gift"] == true || json["is_gift"] == 1,
    );
  }
}
