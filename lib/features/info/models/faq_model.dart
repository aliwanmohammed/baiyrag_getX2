import '../../../core/utils/json_parser.dart';

class FaqModel {
  final String id;
  final String questionAr;
  final String questionEn;
  final String answerAr;
  final String answerEn;
  final bool isActive;

  const FaqModel({required this.id, required this.questionAr, required this.questionEn, required this.answerAr, required this.answerEn, this.isActive = true});

  factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
    id: JsonParser.string(json['id']),
    questionAr: JsonParser.string(json['question_ar']),
    questionEn: JsonParser.string(json['question_en']),
    answerAr: JsonParser.string(json['answer_ar']),
    answerEn: JsonParser.string(json['answer_en']),
    isActive: JsonParser.boolValue(json['is_active'] ?? json['status'] ?? true),
  );

  String question(bool isArabic) => isArabic ? questionAr : questionEn;
  String answer(bool isArabic) => isArabic ? answerAr : answerEn;
}
