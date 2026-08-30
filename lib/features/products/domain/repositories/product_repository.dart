import '../../../../core/pagination/pagination_meta.dart';
import 'package:bhm_supermarket/core/models/product_model.dart';
import '../../../../core/network/api_response.dart';

abstract class ProductRepository {
  Future<ApiResponse<PaginatedResult<List<ProductModel>>>> getProducts({
    String? categoryId,
    String? search,
    int page = 1,
    bool? isBestSeller,
    bool? isFlashDeal,
    bool? isRecommended,
  });

  Future<ApiResponse<ProductModel>> getProductById(String id);
}
