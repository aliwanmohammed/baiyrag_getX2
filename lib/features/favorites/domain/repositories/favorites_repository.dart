import '../../../../core/network/api_response.dart';
import '../../../../core/models/product_model.dart';

abstract class FavoritesRepository {
  Future<ApiResponse<List<ProductModel>>> getFavorites();

  Future<ApiResponse<void>> addFavorite({required String productId});

  Future<ApiResponse<void>> removeFavorite({required String favoriteId});
}
