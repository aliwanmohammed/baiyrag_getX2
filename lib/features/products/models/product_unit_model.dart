import '../../../core/utils/json_parser.dart';
import 'product_unit_offer_model.dart';

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

  /// Offer attached to this exact unit by the backend.
  final ProductUnitOfferModel? offer;

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
    this.offer,
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
      offer: json['offer'] is Map
          ? ProductUnitOfferModel.fromJson(
              Map<String, dynamic>.from(json['offer'] as Map),
            )
          : null,
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
      if (offer != null) 'offer': {
        'id': int.tryParse(offer!.id) ?? offer!.id,
        'type': offer!.type,
        'value': offer!.value,
        'buy_quantity': offer!.buyQuantity,
        'gift_quantity': offer!.giftQuantity,
        'gift_product': {
          'product_id': offer!.giftProductId,
          'unit_id': offer!.giftUnitId,
          'product_name_ar': offer!.giftProductNameAr,
          'product_name_en': offer!.giftProductNameEn,
          'unit_name_ar': offer!.giftUnitNameAr,
          'unit_name_en': offer!.giftUnitNameEn,
        },
        'start_date': offer!.startDate,
        'end_date': offer!.endDate,
      },
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
        'buyersCountLast2Days: $buyersCountLast2Days, '
        ')';
  }
}
