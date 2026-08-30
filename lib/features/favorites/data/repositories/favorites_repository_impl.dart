import '../../../../core/models/product_model.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _remote;

  FavoritesRepositoryImpl(this._remote);

  @override
  Future<ApiResponse<List<ProductModel>>> getFavorites() {
    return _remote.getFavorites();
  }

  @override
  Future<ApiResponse<void>> addFavorite({required String productId}) {
    return _remote.addFavorite(productId: productId);
  }

  @override
  Future<ApiResponse<void>> removeFavorite({required String favoriteId}) {
    return _remote.removeFavorite(favoriteId: favoriteId);
  }
}
