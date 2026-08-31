/// Unit payload expected by POST/PUT /products.
///
/// [unitId] is the catalog unit identifier. [barcode] belongs to this
/// product-unit, not to the parent product.
class ProductUnitInputModel {
  final int unitId;
  final int quantity;
  final String barcode;
  final double price;

  const ProductUnitInputModel({
    required this.unitId,
    required this.quantity,
    required this.barcode,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'unit_id': unitId,
      'quantity': quantity,
      'barcode': barcode,
      'price': price,
    };
  }
}
