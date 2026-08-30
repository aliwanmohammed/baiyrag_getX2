import '../../../core/utils/json_parser.dart';

// ══════════════════════════════════════════════════════════════════════════════
// OfferGiftModel
// ══════════════════════════════════════════════════════════════════════════════

class OfferGiftModel {
  final String productUnitId;

  final String productId;
  final String productNameAr;
  final String productNameEn;

  final String unitId;
  final String unitNameAr;
  final String unitNameEn;

  final int unitQuantity;
  final int quantity;

  const OfferGiftModel({
    required this.productUnitId,
    required this.productId,
    required this.productNameAr,
    required this.productNameEn,
    required this.unitId,
    required this.unitNameAr,
    required this.unitNameEn,
    required this.unitQuantity,
    required this.quantity,
  });

  String get productName {
    return JsonParser.currentLanguage == 'ar' ? productNameAr : productNameEn;
  }

  String get unitName {
    return JsonParser.currentLanguage == 'ar' ? unitNameAr : unitNameEn;
  }

  factory OfferGiftModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] is Map
        ? Map<String, dynamic>.from(json['product'] as Map)
        : <String, dynamic>{};

    final unit = json['unit'] is Map
        ? Map<String, dynamic>.from(json['unit'] as Map)
        : <String, dynamic>{};

    return OfferGiftModel(
      productUnitId: JsonParser.string(
        json['product_unit_id'],
      ),
      productId: JsonParser.string(
        product['id'],
      ),
      productNameAr: JsonParser.string(
        product['name_ar'],
      ),
      productNameEn: JsonParser.string(
        product['name_en'],
      ),
      unitId: JsonParser.string(
        unit['id'],
      ),
      unitNameAr: JsonParser.string(
        unit['name_ar'],
      ),
      unitNameEn: JsonParser.string(
        unit['name_en'],
      ),
      unitQuantity: JsonParser.intValue(
        unit['quantity'],
      ),
      quantity: JsonParser.intValue(
        json['quantity'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_unit_id': int.tryParse(productUnitId) ?? productUnitId,
      'product': {
        'id': int.tryParse(productId) ?? productId,
        'name_ar': productNameAr,
        'name_en': productNameEn,
      },
      'unit': {
        'id': int.tryParse(unitId) ?? unitId,
        'name_ar': unitNameAr,
        'name_en': unitNameEn,
        'quantity': unitQuantity,
      },
      'quantity': quantity,
    };
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OfferCartLine
// ══════════════════════════════════════════════════════════════════════════════

class OfferCartLine {
  final String productId;
  final String unitId;
  final int quantity;

  const OfferCartLine({
    required this.productId,
    required this.unitId,
    required this.quantity,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// GiftRewardModel
// ══════════════════════════════════════════════════════════════════════════════

class GiftRewardModel {
  final String offerId;
  final OfferGiftModel gift;
  final int quantity;

  const GiftRewardModel({
    required this.offerId,
    required this.gift,
    required this.quantity,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// OfferProductUnitModel
// ══════════════════════════════════════════════════════════════════════════════

class OfferProductUnitModel {
  final String id;

  final String productId;
  final String productNameAr;
  final String productNameEn;
  final String productImage;

  final String unitId;
  final String unitNameAr;
  final String unitNameEn;
  final int unitQuantity;

  final double oldPrice;
  final double price;

  const OfferProductUnitModel({
    required this.id,
    required this.productId,
    required this.productNameAr,
    required this.productNameEn,
    required this.productImage,
    required this.unitId,
    required this.unitNameAr,
    required this.unitNameEn,
    required this.unitQuantity,
    required this.oldPrice,
    required this.price,
  });

  String get productName {
    return JsonParser.currentLanguage == 'ar' ? productNameAr : productNameEn;
  }

  String get unitName {
    return JsonParser.currentLanguage == 'ar' ? unitNameAr : unitNameEn;
  }

  bool get hasDiscount => oldPrice > price;

  double get discountAmount {
    final value = oldPrice - price;
    return value > 0 ? value : 0;
  }

  factory OfferProductUnitModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final product = json['product'] is Map
        ? Map<String, dynamic>.from(json['product'] as Map)
        : <String, dynamic>{};

    final unit = json['unit'] is Map
        ? Map<String, dynamic>.from(json['unit'] as Map)
        : <String, dynamic>{};

    return OfferProductUnitModel(
      id: JsonParser.string(
        json['id'],
      ),
      productId: JsonParser.string(
        product['id'],
      ),
      productNameAr: JsonParser.string(
        product['name_ar'],
      ),
      productNameEn: JsonParser.string(
        product['name_en'],
      ),
      productImage: JsonParser.string(
        product['image'],
      ),
      unitId: JsonParser.string(
        unit['id'],
      ),
      unitNameAr: JsonParser.string(
        unit['name_ar'],
      ),
      unitNameEn: JsonParser.string(
        unit['name_en'],
      ),
      unitQuantity: JsonParser.intValue(
        unit['quantity'],
      ),
      oldPrice: JsonParser.doubleValue(
        json['old_price'],
      ),
      price: JsonParser.doubleValue(
        json['price'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? id,
      'product': {
        'id': int.tryParse(productId) ?? productId,
        'name_ar': productNameAr,
        'name_en': productNameEn,
        'image': productImage,
      },
      'unit': {
        'id': int.tryParse(unitId) ?? unitId,
        'name_ar': unitNameAr,
        'name_en': unitNameEn,
        'quantity': unitQuantity,
      },
      'old_price': oldPrice,
      'price': price,
    };
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OfferModel
// ══════════════════════════════════════════════════════════════════════════════

class OfferModel {
  final String id;

  final String titleAr;
  final String titleEn;

  final String descriptionAr;
  final String descriptionEn;

  final String image;

  /// fixed / percentage / gift
  final String type;

  /// null for gift offers.
  final double? value;

  final List<OfferProductUnitModel> productUnits;

  final int? buyQuantity;

  final OfferGiftModel? gift;

  final String? startDate;
  final String? endDate;

  final bool isActive;

  final String? createdAt;
  final String? updatedAt;

  const OfferModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.image,
    required this.type,
    this.value,
    required this.productUnits,
    this.buyQuantity,
    this.gift,
    this.startDate,
    this.endDate,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  String get title {
    return JsonParser.currentLanguage == 'ar' ? titleAr : titleEn;
  }

  String get description {
    return JsonParser.currentLanguage == 'ar' ? descriptionAr : descriptionEn;
  }

  bool get isGift => type == 'gift';

  bool get isPercentage => type == 'percentage';

  bool get isFixed => type == 'fixed';

  factory OfferModel.fromJson(
    Map<String, dynamic> json,
  ) {
    OfferGiftModel? gift;

    final giftRaw = json['gift'];

    if (giftRaw is Map) {
      final giftJson = Map<String, dynamic>.from(
        giftRaw,
      );

      giftJson['quantity'] ??= json['gift_quantity'];

      gift = OfferGiftModel.fromJson(
        giftJson,
      );
    }

    return OfferModel(
      id: JsonParser.string(
        json['id'],
      ),
      titleAr: JsonParser.string(
        json['title_ar'],
      ),
      titleEn: JsonParser.string(
        json['title_en'],
      ),
      descriptionAr: JsonParser.string(
        json['description_ar'],
      ),
      descriptionEn: JsonParser.string(
        json['description_en'],
      ),
      image: JsonParser.string(
        json['image'],
      ),
      type: JsonParser.string(
        json['type'],
      ),
      value: json['value'] == null
          ? null
          : JsonParser.doubleValue(
              json['value'],
            ),
      productUnits: JsonParser.list(
        json['product_units'],
        OfferProductUnitModel.fromJson,
      ),
      buyQuantity: json['buy_quantity'] == null
          ? null
          : JsonParser.intValue(
              json['buy_quantity'],
            ),
      gift: gift,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      isActive: JsonParser.boolValue(
        json['is_active'],
      ),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? id,
      'title_ar': titleAr,
      'title_en': titleEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'image': image,
      'type': type,
      'value': value,
      'product_units': productUnits.map((unit) => unit.toJson()).toList(),
      'buy_quantity': buyQuantity,
      'gift': gift?.toJson(),
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
