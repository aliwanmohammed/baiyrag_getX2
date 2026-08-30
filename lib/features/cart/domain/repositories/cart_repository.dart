import '../../../../core/network/api_response.dart';
import '../../models/cart_item_model.dart';

abstract class CartRepository {
  Future<ApiResponse<List<CartItemModel>>> getCart();

  Future<ApiResponse<void>> addToCart({
    required String productId,
    required String unitId,
    required int quantity,
  });

  Future<ApiResponse<void>> updateQuantity({
    required String cartId,
    required int quantity,
  });

  Future<ApiResponse<void>> removeItem(String cartId);

  Future<ApiResponse<void>> clearCart();
}
