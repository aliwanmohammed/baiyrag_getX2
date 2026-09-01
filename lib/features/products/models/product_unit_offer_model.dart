import '../../../core/utils/json_parser.dart';

/// Offer data embedded in a product unit response.
/// The backend attaches an offer to the exact unit it applies to.
class ProductUnitOfferModel {
  final String id;
  final String type;
  final double? value;
  final int? buyQuantity;
  final int giftQuantity;
  final String? giftProductId;
  final String giftProductNameAr;
  final String giftProductNameEn;
  final String? giftUnitId;
  final String giftUnitNameAr;
  final String giftUnitNameEn;
  final String? startDate;
  final String? endDate;

  const ProductUnitOfferModel({
    required this.id,
    required this.type,
    this.value,
    this.buyQuantity,
    this.giftQuantity = 0,
    this.giftProductId,
    this.giftProductNameAr = '',
    this.giftProductNameEn = '',
    this.giftUnitId,
    this.giftUnitNameAr = '',
    this.giftUnitNameEn = '',
    this.startDate,
    this.endDate,
  });

  bool get isGift => type == 'gift';
  bool get isPercentage => type == 'percentage';
  bool get isFixed => type == 'fixed';

  String get giftProductName =>
      JsonParser.currentLanguage == 'ar' ? giftProductNameAr : giftProductNameEn;

  String get giftUnitName =>
      JsonParser.currentLanguage == 'ar' ? giftUnitNameAr : giftUnitNameEn;

  factory ProductUnitOfferModel.fromJson(Map<String, dynamic> json) {
    final giftProduct = json['gift_product'] is Map
        ? Map<String, dynamic>.from(json['gift_product'] as Map)
        : <String, dynamic>{};

    return ProductUnitOfferModel(
      id: JsonParser.string(json['id']),
      type: JsonParser.string(json['type']),
      value: json['value'] == null ? null : JsonParser.doubleValue(json['value']),
      buyQuantity: json['buy_quantity'] == null
          ? null
          : JsonParser.intValue(json['buy_quantity']),
      giftQuantity: JsonParser.intValue(json['gift_quantity']),
      giftProductId: giftProduct['product_id'] == null
          ? null
          : JsonParser.string(giftProduct['product_id']),
      giftProductNameAr: JsonParser.string(giftProduct['product_name_ar']),
      giftProductNameEn: JsonParser.string(giftProduct['product_name_en']),
      giftUnitId: giftProduct['unit_id'] == null
          ? null
          : JsonParser.string(giftProduct['unit_id']),
      giftUnitNameAr: JsonParser.string(giftProduct['unit_name_ar']),
      giftUnitNameEn: JsonParser.string(giftProduct['unit_name_en']),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
    );
  }
}
