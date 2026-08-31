import '../../../core/utils/json_parser.dart';

class ContactInfoModel {
  final String id;
  final String type;
  final String titleAr;
  final String titleEn;
  final String valueAr;
  final String valueEn;
  final bool isActive;

  const ContactInfoModel({required this.id, required this.type, required this.titleAr, required this.titleEn, required this.valueAr, required this.valueEn, this.isActive = true});

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) => ContactInfoModel(
    id: JsonParser.string(json['id']),
    type: JsonParser.string(json['type']),
    titleAr: JsonParser.string(json['title_ar']),
    titleEn: JsonParser.string(json['title_en']),
    valueAr: JsonParser.string(json['value_ar']),
    valueEn: JsonParser.string(json['value_en']),
    isActive: JsonParser.boolValue(json['is_active'] ?? json['status'] ?? true),
  );

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
  String value(bool isArabic) => isArabic ? valueAr : valueEn;
}
