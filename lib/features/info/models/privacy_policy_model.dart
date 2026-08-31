import '../../../core/utils/json_parser.dart';

class PrivacyPolicyModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String contentAr;
  final String contentEn;
  final int sortOrder;
  final bool isActive;

  const PrivacyPolicyModel({required this.id, required this.titleAr, required this.titleEn, required this.contentAr, required this.contentEn, this.sortOrder = 0, this.isActive = true});

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) => PrivacyPolicyModel(
    id: JsonParser.string(json['id']),
    titleAr: JsonParser.string(json['title_ar']),
    titleEn: JsonParser.string(json['title_en']),
    contentAr: JsonParser.string(json['content_ar']),
    contentEn: JsonParser.string(json['content_en']),
    sortOrder: JsonParser.intValue(json['sort_order']),
    isActive: JsonParser.boolValue(json['is_active'] ?? json['status'] ?? true),
  );

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
  String content(bool isArabic) => isArabic ? contentAr : contentEn;
}
