import 'package:bhm_supermarket/features/cart/data/datasource/cart_remote_datasource.dart';

import '../../../../core/network/api_response.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remote;

  CartRepositoryImpl(this._remote);

  @override
  Future<ApiResponse<List<CartItemModel>>> getCart() {
    return _remote.getCart();
  }

  @override
  Future<ApiResponse<void>> addToCart({
    required String productId,
    required String unitId,
    required int quantity,
  }) {
    return _remote.addToCart(
      productId: productId,
      unitId: unitId,
      quantity: quantity,
    );
  }

  @override
  Future<ApiResponse<void>> updateQuantity({
    required String cartId,
    required int quantity,
  }) {
    return _remote.updateQuantity(cartId: cartId, quantity: quantity);
  }

  @override
  Future<ApiResponse<void>> removeItem(String cartId) {
    return _remote.removeItem(cartId);
  }

  @override
  Future<ApiResponse<void>> clearCart() {
    return _remote.clearCart();
  }
}
