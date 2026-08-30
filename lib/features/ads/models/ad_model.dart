// import '../../../core/utils/json_parser.dart';

// class AdModel {
//   final String id;
//   final String titleAr;
//   final String titleEn;
//   final String descriptionAr;
//   final String descriptionEn;
//   final String image;
//   final String url;
//   final bool isActive;
//   final int sortOrder;

//   const AdModel({
//     required this.id,
//     required this.titleAr,
//     required this.titleEn,
//     required this.descriptionAr,
//     required this.descriptionEn,
//     required this.image,
//     required this.url,
//     required this.isActive,
//     required this.sortOrder,
//   });

//   String get title => JsonParser.currentLanguage == 'ar' ? titleAr : titleEn;

//   String get description =>
//       JsonParser.currentLanguage == 'ar' ? descriptionAr : descriptionEn;

//   factory AdModel.fromJson(Map<String, dynamic> json) {
//     return AdModel(
//       id: JsonParser.string(json['id']),
//       titleAr: JsonParser.string(json['title_ar']),
//       titleEn: JsonParser.string(json['title_en']),
//       descriptionAr: JsonParser.string(json['description_ar']),
//       descriptionEn: JsonParser.string(json['description_en']),
//       image: JsonParser.string(json['image']),
//       url: JsonParser.string(json['url']),
//       isActive: JsonParser.boolValue(json['is_active']),
//       sortOrder: JsonParser.intValue(json['sort_order']),
//     );
//   }
//   AdModel copyWith({
//     String? id,
//     String? titleAr,
//     String? titleEn,
//     String? descriptionAr,
//     String? descriptionEn,
//     String? image,
//     String? url,
//     bool? isActive,
//     int? sortOrder,
//   }) {
//     return AdModel(
//       id: id ?? this.id,
//       titleAr: titleAr ?? this.titleAr,
//       titleEn: titleEn ?? this.titleEn,
//       descriptionAr: descriptionAr ?? this.descriptionAr,
//       descriptionEn: descriptionEn ?? this.descriptionEn,
//       image: image ?? this.image,
//       url: url ?? this.url,
//       isActive: isActive ?? this.isActive,
//       sortOrder: sortOrder ?? this.sortOrder,
//     );
//   }
// }

import '../../../core/utils/json_parser.dart';

class AdModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String image;
  final String url;
  final bool isActive;
  final int sortOrder;

  const AdModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.image,
    required this.url,
    required this.isActive,
    required this.sortOrder,
  });

  String get title => JsonParser.currentLanguage == 'ar' ? titleAr : titleEn;

  String get description =>
      JsonParser.currentLanguage == 'ar' ? descriptionAr : descriptionEn;

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: JsonParser.string(json['id']),
      titleAr: JsonParser.string(json['title_ar']),
      titleEn: JsonParser.string(json['title_en']),
      descriptionAr: JsonParser.string(json['description_ar']),
      descriptionEn: JsonParser.string(json['description_en']),
      image: _normalizeImageUrl(JsonParser.string(json['image'])),
      url: JsonParser.string(json['url']),
      isActive: JsonParser.boolValue(json['is_active']),
      sortOrder: JsonParser.intValue(json['sort_order']),
    );
  }

  static String _normalizeImageUrl(String image) {
    if (image.isEmpty) {
      return '';
    }

    if (image.startsWith('http://localhost/')) {
      return image.replaceFirst(
        'http://localhost',
        'https://backend-albarqy.onrender.com',
      );
    }

    if (image.startsWith('https://localhost/')) {
      return image.replaceFirst(
        'https://localhost',
        'https://backend-albarqy.onrender.com',
      );
    }

    if (image.startsWith('http://127.0.0.1/')) {
      return image.replaceFirst(
        'http://127.0.0.1',
        'https://backend-albarqy.onrender.com',
      );
    }

    if (image.startsWith('https://127.0.0.1/')) {
      return image.replaceFirst(
        'https://127.0.0.1',
        'https://backend-albarqy.onrender.com',
      );
    }

    return image;
  }
}
