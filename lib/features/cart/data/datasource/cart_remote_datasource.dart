import 'package:bhm_supermarket/core/datasource/base_remote_datasource.dart';
import '../../../../core/network/api_response.dart';
import '../../models/cart_item_model.dart';

class CartRemoteDataSource extends BaseRemoteDataSource {
  CartRemoteDataSource(super.dio);

  /// GET /cart
  Future<ApiResponse<List<CartItemModel>>> getCart() {
    return getPaginated(
      '/cart',
      parser: (json) {
        return (json as List).map((e) => CartItemModel.fromJson(e)).toList();
      },
    );
  }

  /// POST /cart
  Future<ApiResponse<void>> addToCart({
    required String productId,
    required String unitId,
    required int quantity,
  }) {
    return postEnvelope<void>(
      '/cart',
      data: {'product_id': productId, 'unit_id': unitId, 'quantity': quantity},
      parser: (_) {},
    );
  }

  /// PUT /cart/{id}
  Future<ApiResponse<void>> updateQuantity({
    required String cartId,
    required int quantity,
  }) {
    return putEnvelope<void>(
      '/cart/$cartId',
      data: {'quantity': quantity},
      parser: (_) {},
    );
  }

  /// DELETE /cart/{id}
  Future<ApiResponse<void>> removeItem(String cartId) {
    return deleteEnvelope('/cart/$cartId');
  }

  /// DELETE /cart
  Future<ApiResponse<void>> clearCart() {
    return deleteEnvelope('/cart');
  }
}
