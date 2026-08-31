import 'product_unit_input_model.dart';

/// Request payload used by the Products API for create/update.
///
/// The API contract intentionally keeps barcode inside each unit. There is
/// no product-level barcode in this request.
class ProductUpsertRequest {
  final int categoryId;
  final String nameEn;
  final String nameAr;
  final String uniqueNumber;
  final String? descriptionEn;
  final String? descriptionAr;
  final bool? status;
  final List<ProductUnitInputModel> units;

  const ProductUpsertRequest({
    required this.categoryId,
    required this.nameEn,
    required this.nameAr,
    required this.uniqueNumber,
    this.descriptionEn,
    this.descriptionAr,
    this.status,
    required this.units,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name_en': nameEn,
      'name_ar': nameAr,
      'unique_number': uniqueNumber,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      if (status != null) 'status': status,
      'units': units.map((unit) => unit.toJson()).toList(),
    };
  }
}
