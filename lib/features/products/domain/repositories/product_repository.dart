import '../../../../core/pagination/pagination_meta.dart';
import 'package:bhm_supermarket/core/models/product_model.dart';
import '../../../../core/network/api_response.dart';
import '../../models/product_upsert_request.dart';

abstract class ProductRepository {
  Future<ApiResponse<PaginatedResult<List<ProductModel>>>> getProducts({
    String? categoryId,
    String? search,
    int page = 1,
  });

  Future<ApiResponse<ProductModel>> getProductById(String id);

  Future<ApiResponse<ProductModel>> createProduct(
    ProductUpsertRequest request,
  );

  Future<ApiResponse<ProductModel>> updateProduct(
    String id,
    ProductUpsertRequest request,
  );
}
