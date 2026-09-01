import '../../../../core/pagination/pagination_meta.dart';
import 'package:bhm_supermarket/core/models/product_model.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/repositories/product_repository.dart';
import '../../models/product_upsert_request.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  // In-memory cache for product details. This prevents repeated GET /products/{id}
  // requests when multiple features need the same product during one app session.
  final Map<String, ProductModel> _productCache = {};
  final Map<String, Future<ApiResponse<ProductModel>>> _inFlight = {};

  @override
  Future<ApiResponse<PaginatedResult<List<ProductModel>>>> getProducts({
    String? categoryId,
    String? search,
    int page = 1,
  }) {
    return _remote.fetchProducts(
      categoryId: categoryId,
      search: search,
      page: page,
    );
  }

  @override
  Future<ApiResponse<ProductModel>> getProductById(String id) {
    final cached = _productCache[id];
    if (cached != null) {
      return Future.value(ApiResponse.success(cached));
    }

    final pending = _inFlight[id];
    if (pending != null) return pending;

    final request = _remote.fetchProduct(id);
    _inFlight[id] = request;

    return request.then((response) {
      if (response.isSuccess && response.data != null) {
        _productCache[id] = response.data!;
      }
      return response;
    }).whenComplete(() {
      _inFlight.remove(id);
    });
  }

  @override
  Future<ApiResponse<ProductModel>> createProduct(
    ProductUpsertRequest request,
  ) {
    return _remote.createProduct(request);
  }

  @override
  Future<ApiResponse<ProductModel>> updateProduct(
    String id,
    ProductUpsertRequest request,
  ) {
    return _remote.updateProduct(id, request);
  }
}
