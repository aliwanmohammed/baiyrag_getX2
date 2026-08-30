import '../utils/json_parser.dart';

class CategoryModel {
  final String id;

  final String nameAr;
  final String nameEn;

  final String image;

  final String? parentId;

  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.image,
    this.parentId,
    required this.sortOrder,
  });

  String get name {
    return JsonParser.currentLanguage == 'ar' ? nameAr : nameEn;
  }

  String get imageUrl {
    if (image.isEmpty) {
      return '';
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    return 'https://backend-albarqy.onrender.com/storage/$image';
  }

  factory CategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CategoryModel(
      id: JsonParser.string(json['id']),
      nameAr: JsonParser.string(json['name_ar']),
      nameEn: JsonParser.string(json['name_en']),
      image: JsonParser.string(json['image']),
      parentId: json['parent_id']?.toString(),
      sortOrder: JsonParser.intValue(
        json['sort_order'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'image': image,
      'parent_id': parentId,
      'sort_order': sortOrder,
    };
  }
}
