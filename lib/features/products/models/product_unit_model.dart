import '../../../core/utils/json_parser.dart';

class ProductUnitModel {
  final String id;

  final String nameAr;
  final String nameEn;

  final int quantity;
  final String barcode;
  final double price;

  final int soldQuantityLast2Days;
  final int buyersCountLast2Days;

  final double originalPrice;
  final double discount;
  final double finalPrice;

  const ProductUnitModel({
    required this.id,
    this.nameAr = '',
    this.nameEn = '',
    this.quantity = 0,
    required this.barcode,
    required this.price,
    this.soldQuantityLast2Days = 0,
    this.buyersCountLast2Days = 0,
    this.originalPrice = 0,
    this.discount = 0,
    this.finalPrice = 0,
  });

  /// اسم الوحدة حسب اللغة الحالية.
  String get unitName {
    return JsonParser.currentLanguage == 'ar' ? nameAr : nameEn;
  }

  factory ProductUnitModel.fromJson(Map<String, dynamic> json) {
    return ProductUnitModel(
      id: JsonParser.string(json['id']),
      nameAr: JsonParser.string(json['name_ar']),
      nameEn: JsonParser.string(json['name_en']),
      quantity: JsonParser.intValue(json['quantity']),
      barcode: JsonParser.string(json['barcode']),
      price: JsonParser.doubleValue(json['price']),
      soldQuantityLast2Days: JsonParser.intValue(
        json['sold_quantity_last_2_days'],
      ),
      buyersCountLast2Days: JsonParser.intValue(
        json['buyers_count_last_2_days'],
      ),
      originalPrice: JsonParser.doubleValue(
        json['original_price'],
      ),
      discount: JsonParser.doubleValue(
        json['discount'],
      ),
      finalPrice: JsonParser.doubleValue(
        json['final_price'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'quantity': quantity,
      'barcode': barcode,
      'price': price,
      'sold_quantity_last_2_days': soldQuantityLast2Days,
      'buyers_count_last_2_days': buyersCountLast2Days,
      'original_price': originalPrice,
      'discount': discount,
      'final_price': finalPrice,
    };
  }

  @override
  String toString() {
    return 'ProductUnitModel('
        'id: $id, '
        'unitName: $unitName, '
        'quantity: $quantity, '
        'barcode: $barcode, '
        'price: $price, '
        'soldQuantityLast2Days: $soldQuantityLast2Days, '
        'buyersCountLast2Days: $buyersCountLast2Days'
        ')';
  }
}
