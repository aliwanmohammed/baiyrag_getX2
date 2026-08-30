import '../../../../core/pagination/pagination_meta.dart';
import 'package:bhm_supermarket/core/models/product_model.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<ApiResponse<PaginatedResult<List<ProductModel>>>> getProducts({
    String? categoryId,
    String? search,
    int page = 1,
    bool? isBestSeller,
    bool? isFlashDeal,
    bool? isRecommended,
  }) {
    return _remote.fetchProducts(
      categoryId: categoryId,
      search: search,
      page: page,
      isBestSeller: isBestSeller,
      isFlashDeal: isFlashDeal,
      isRecommended: isRecommended,
    );
  }

  @override
  Future<ApiResponse<ProductModel>> getProductById(String id) {
    return _remote.fetchProduct(id);
  }
}
