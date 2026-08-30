// import '../../../../core/api/api_endpoints.dart';
// import '../../../../core/datasource/base_remote_datasource.dart';
// import '../../../../core/models/product_model.dart';
// import '../../../../core/network/api_response.dart';
// import '../../../../core/utils/json_parser.dart';
// import '../../../../core/pagination/pagination_meta.dart';

// class ProductRemoteDataSource extends BaseRemoteDataSource {
//   ProductRemoteDataSource(super.dio);

//   Future<ApiResponse<PaginatedResult<List<ProductModel>>>> fetchProducts({
//     String? categoryId,
//     String? search,
//     int page = 1,
//     bool? isBestSeller,
//     bool? isFlashDeal,
//     bool? isRecommended,
//   }) {
//     return getWithMeta<List<ProductModel>>(
//       ApiEndpoints.products,
//       query: {
//         if (categoryId != null && categoryId.isNotEmpty)
//           'category_id': categoryId,
//         if (search != null && search.isNotEmpty) 'search': search,
//         if (isBestSeller == true) 'is_best_seller': 1,
//         if (isFlashDeal == true) 'is_flash_deal': 1,
//         if (isRecommended == true) 'is_recommended': 1,
//         'page': page,
//       },
//       parser: (json) => JsonParser.list(json, ProductModel.fromJson),
//     );
//   }

//   Future<ApiResponse<ProductModel>> fetchProduct(String id) {
//     return getPaginated<ProductModel>(
//       ApiEndpoints.product(id),
//       parser: (json) => ProductModel.fromJson(JsonParser.map(json)),
//     );
//   }
// }

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/pagination/pagination_meta.dart';
import '../../../../core/utils/json_parser.dart';

class ProductRemoteDataSource extends BaseRemoteDataSource {
  ProductRemoteDataSource(super.dio);

  // ===========================================================================
  // Products
  // ===========================================================================

  Future<ApiResponse<PaginatedResult<List<ProductModel>>>> fetchProducts({
    String? categoryId,
    String? search,
    int page = 1,
    bool? isBestSeller,
    bool? isFlashDeal,
    bool? isRecommended,
  }) {
    return getWithMeta<List<ProductModel>>(
      ApiEndpoints.products,
      query: {
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,

        if (search != null && search.isNotEmpty) 'search': search,

        // هذه الفلاتر غير موجودة في Response الحالي،
        // لكن نتركها هنا إذا كان الـBackend يدعمها في query.
        if (isBestSeller == true) 'is_best_seller': 1,

        if (isFlashDeal == true) 'is_flash_deal': 1,

        if (isRecommended == true) 'is_recommended': 1,

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
