import '../models/product_unit_model.dart';
import '../domain/repositories/product_repository.dart';

class ProductUnitsRepository {
  final ProductRepository productRepository;

  ProductUnitsRepository(this.productRepository);

  Future<List<ProductUnitModel>> getUnitsByProductId(String productId) async {
    try {
      final response = await productRepository.getProductById(productId);

      if (!response.isSuccess || response.data == null) {
        return [];
      }

      return response.data!.units;
    } catch (_) {
      return [];
    }
  }

  /// يبحث عن المنتج بواسطة unique_number،
  /// ثم يعيد وحداته من ProductModel.
  Future<List<ProductUnitModel>> getUnitsByUniqueNumber(String uniqueNumber) async {
    try {
      final response = await productRepository.getProducts(search: uniqueNumber);

      if (!response.isSuccess) {
        return [];
      }

      final products = response.data?.items ?? [];

      for (final product in products) {
        if (product.uniqueNumber == uniqueNumber) {
          return product.units;
        }
      }

      return [];
    } catch (_) {
      return [];
    }
  }
}
