import '../../../core/utils/json_parser.dart';

class AboutUsModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final bool isActive;

  const AboutUsModel({required this.id, required this.titleAr, required this.titleEn, required this.descriptionAr, required this.descriptionEn, this.isActive = true});

  factory AboutUsModel.fromJson(Map<String, dynamic> json) => AboutUsModel(
    id: JsonParser.string(json['id']),
    titleAr: JsonParser.string(json['title_ar']),
    titleEn: JsonParser.string(json['title_en']),
    descriptionAr: JsonParser.string(json['description_ar']),
    descriptionEn: JsonParser.string(json['description_en']),
    isActive: JsonParser.boolValue(json['status'] ?? json['is_active'] ?? true),
  );

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
  String description(bool isArabic) => isArabic ? descriptionAr : descriptionEn;
}
