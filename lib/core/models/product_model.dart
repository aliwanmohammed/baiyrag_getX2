import 'package:bhm_supermarket/features/products/models/product_unit_model.dart';
import '../utils/json_parser.dart';

class ProductModel {
  final String id;
  final String uniqueNumber;
  final String categoryId;

  final String nameAr;
  final String nameEn;

  final String descriptionAr;
  final String descriptionEn;

  final List<String> images;

  final String categoryNameAr;
  final String categoryNameEn;

  final String barcode;

  /// السعر الافتراضي = سعر أول وحدة.
  final double price;

  /// جميع وحدات المنتج.
  final List<ProductUnitModel> units;

  final String? favoriteId;

  /// يأتي من status في الـAPI.
  final bool isAvailable;

  const ProductModel({
    required this.id,
    required this.uniqueNumber,
    required this.categoryId,
    required this.categoryNameAr,
    required this.categoryNameEn,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.images,
    required this.price,
    required this.barcode,
    required this.units,
    this.favoriteId,
    this.isAvailable = true,
  });

  String get name {
    return JsonParser.currentLanguage == 'ar' ? nameAr : nameEn;
  }

  String get description {
    return JsonParser.currentLanguage == 'ar' ? descriptionAr : descriptionEn;
  }

  String get categoryName {
    return JsonParser.currentLanguage == 'ar' ? categoryNameAr : categoryNameEn;
  }

  String get image {
    return images.isEmpty ? '' : images.first;
  }

  ProductUnitModel? get defaultUnit {
    return units.isNotEmpty ? units.first : null;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final parsedUnits = JsonParser.list(
      json['units'],
      ProductUnitModel.fromJson,
    );

    final firstUnit = parsedUnits.isNotEmpty ? parsedUnits.first : null;

    final parsedImages = <String>[];
    final rawImages = json['images'];

    if (rawImages is List) {
      for (final item in rawImages) {
        if (item is Map) {
          final image = JsonParser.string(
            item['image'] ?? item['url'] ?? item['path'] ?? '',
          );
          if (image.isNotEmpty) {
            parsedImages.add(image);
          }
        } else {
          final image = JsonParser.string(item);
          if (image.isNotEmpty) {
            parsedImages.add(image);
          }
        }
      }
    }

    final category = json['category'] is Map
        ? Map<String, dynamic>.from(json['category'] as Map)
        : <String, dynamic>{};

    return ProductModel(
      id: JsonParser.string(json['id']),
      uniqueNumber: JsonParser.string(json['unique_number']),
      categoryId: JsonParser.string(category['id'] ?? json['category_id']),
      categoryNameAr: JsonParser.string(category['name_ar']),
      categoryNameEn: JsonParser.string(category['name_en']),
      nameAr: JsonParser.string(json['name_ar']),
      nameEn: JsonParser.string(json['name_en']),
      descriptionAr: JsonParser.string(json['description_ar']),
      descriptionEn: JsonParser.string(json['description_en']),
      barcode: JsonParser.string(json['barcode']),
      images: parsedImages,
      units: parsedUnits,
      price: firstUnit?.price ?? 0,
      favoriteId: json['favorite_id']?.toString(),
      isAvailable: JsonParser.boolValue(json['status'] ?? true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? id,
      'unique_number': uniqueNumber,
      'category_id': int.tryParse(categoryId) ?? categoryId,
      'category_name_ar': categoryNameAr,
      'category_name_en': categoryNameEn,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'barcode': barcode,
      'images': images,
      'price': price,
      'favorite_id': favoriteId,
      'is_available': isAvailable,
      'units': units.map((unit) => unit.toJson()).toList(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? uniqueNumber,
    String? categoryId,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    List<String>? images,
    double? price,
    List<ProductUnitModel>? units,
    String? favoriteId,
    bool? isAvailable,
    String? barcode,
    String? categoryNameAr,
    String? categoryNameEn,
  }) {
    return ProductModel(
      id: id ?? this.id,
      uniqueNumber: uniqueNumber ?? this.uniqueNumber,
      categoryId: categoryId ?? this.categoryId,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      categoryNameEn: categoryNameEn ?? this.categoryNameEn,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      images: images ?? this.images,
      price: price ?? this.price,
      units: units ?? this.units,
      favoriteId: favoriteId ?? this.favoriteId,
      isAvailable: isAvailable ?? this.isAvailable,
      barcode: barcode ?? this.barcode,
    );
  }
}
