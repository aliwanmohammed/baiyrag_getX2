import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/network/api_response.dart';

class FavoritesRemoteDataSource extends BaseRemoteDataSource {
  FavoritesRemoteDataSource(super.dio);

  Future<ApiResponse<List<ProductModel>>> getFavorites() {
    return getPaginated(
      '/favorites',
      parser: (json) {
        return (json as List).map((e) {
          final product = ProductModel.fromJson(e['product']);

          return product.copyWith(favoriteId: e['id'].toString());
        }).toList();
      },
    );
  }

  Future<ApiResponse<void>> addFavorite({required String productId}) {
    return postEnvelope(
      '/favorites',
      data: {'product_id': productId},
      parser: (_) {},
    );
  }

  Future<ApiResponse<void>> removeFavorite({required String favoriteId}) {
    return deleteEnvelope('/favorites/$favoriteId');
  }
}
