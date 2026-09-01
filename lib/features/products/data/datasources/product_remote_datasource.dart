import '../../../../core/api/api_endpoints.dart';
import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/pagination/pagination_meta.dart';
import '../../../../core/utils/json_parser.dart';
import '../../models/product_upsert_request.dart';

class ProductRemoteDataSource extends BaseRemoteDataSource {
  ProductRemoteDataSource(super.dio);

  // ===========================================================================
  // Products
  // ===========================================================================

  Future<ApiResponse<PaginatedResult<List<ProductModel>>>> fetchProducts({
    String? categoryId,
    String? search,
    int page = 1,
  }) {
    return getWithMeta<List<ProductModel>>(
      ApiEndpoints.products,
      query: {
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,

        if (search != null && search.isNotEmpty) 'search': search,


        'page': page,
      },
      parser: (json) {
        return JsonParser.list(
          json,
          ProductModel.fromJson,
        );
      },
    );
  }

  // ===========================================================================
  // Create Product
  // ===========================================================================

  Future<ApiResponse<ProductModel>> createProduct(
    ProductUpsertRequest request,
  ) {
    return postEnvelope<ProductModel>(
      ApiEndpoints.products,
      data: request.toJson(),
      parser: (json) => ProductModel.fromJson(JsonParser.map(json)),
    );
  }

  // ===========================================================================
  // Update Product
  // ===========================================================================

  Future<ApiResponse<ProductModel>> updateProduct(
    String id,
    ProductUpsertRequest request,
  ) {
    return putEnvelope<ProductModel>(
      ApiEndpoints.product(id),
      data: request.toJson(),
      parser: (json) => ProductModel.fromJson(JsonParser.map(json)),
    );
  }

  // ===========================================================================
  // Single Product
  // ===========================================================================

  Future<ApiResponse<ProductModel>> fetchProduct(
    String id,
  ) {
    return getPaginated<ProductModel>(
      ApiEndpoints.product(id),
      parser: (json) {
        return ProductModel.fromJson(
          JsonParser.map(json),
        );
      },
    );
  }
}
