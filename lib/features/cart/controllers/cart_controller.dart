import 'package:get/get.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/product_model.dart';
import '../../../core/network/api_response.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../products/models/product_unit_model.dart';
import '../domain/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';

class CartController extends GetxController {
  final CartRepository _repository;
  final AuthController _auth;

  CartController(this._repository, this._auth);

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  final List<CartItemModel> _items = [];
  final Set<String> _processingItems = {};

  /// Lightweight reactive signal for small UI surfaces (e.g. cart badge and
  /// product quantity controls). The cart screen itself still uses GetBuilder
  /// because its state changes as a coherent snapshot.
  final RxInt _revision = 0.obs;
  RxInt get revision => _revision;

  void _notify() {
    _revision.value++;
    update();
  }

  bool _busy = false;
  bool _isLoading = false;
  bool _isMerging = false;

  bool get isLoading => _isLoading;
  bool get isMerging => _isMerging;

  List<CartItemModel> get items => List.unmodifiable(_items);

  bool isItemProcessing(String productId, String unitId) {
    return _processingItems.contains('${productId}_$unitId');
  }

  void _setItemProcessing(
    String productId,
    String unitId,
    bool processing,
  ) {
    final key = '${productId}_$unitId';

    if (processing) {
      _processingItems.add(key);
    } else {
      _processingItems.remove(key);
    }

    _notify();
  }

  bool get _hasAuthenticatedSession => _auth.isLoggedIn;

  int getProductQuantity(String productId, String unitId) {
    final index = getCartItemIndex(productId, unitId);

    if (index == -1) {
      return 0;
    }

    return _items[index].quantity;
  }

  int getCartItemIndex(String productId, String unitId) {
    return _items.indexWhere(
      (item) => item.product.id == productId && item.unit.id == unitId,
    );
  }

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  /// عدد أنواع المنتجات في السلة.
  int get itemsCount => _items.length;

  /// إجمالي عدد القطع.
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cache = prefs.getString('cart_items');

      if (cache != null && cache.isNotEmpty) {
        final decoded = jsonDecode(cache);

        if (decoded is List) {
          _items
            ..clear()
            ..addAll(
              decoded.whereType<Map>().map(
                    (item) => CartItemModel.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
                  ),
            );
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Cart local load error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    _notify();
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final encoded = jsonEncode(
        _items.map((item) => item.toJson()).toList(),
      );

      await prefs.setString('cart_items', encoded);
    } catch (error, stackTrace) {
      debugPrint('Cart local save error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> loadFromServer() async {
    if (!_hasAuthenticatedSession) {
      return;
    }

    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _notify();

    try {
      final response = await _repository.getCart();

      response.fold(
        onSuccess: (items) async {
          _items
            ..clear()
            ..addAll(items);

          await _saveCart();
        },
        onError: (message) {
          debugPrint('Cart server load failed: $message');
        },
      );
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<ApiResponse<void>> addItem({
    required ProductModel product,
    required ProductUnitModel unit,
    required double unitPrice,
    double? originalPrice,
    int quantity = 1,
  }) async {
    if (quantity <= 0) {
      return ApiResponse.failure('الكمية غير صحيحة');
    }

    final key = '${product.id}_${unit.id}';

    if (_busy || _processingItems.contains(key)) {
      return ApiResponse.failure('يرجى الانتظار');
    }

    _busy = true;

    _setItemProcessing(
      product.id,
      unit.id,
      true,
    );

    try {
      final index = getCartItemIndex(
        product.id,
        unit.id,
      );

      if (index != -1) {
        final currentItem = _items[index];

        final effectiveOriginalPrice = originalPrice ?? unitPrice;

        _items[index] = currentItem.copyWith(
          originalPrice: effectiveOriginalPrice,
          discount: (effectiveOriginalPrice - unitPrice)
              .clamp(0, double.infinity)
              .toDouble(),
          unitPrice: unitPrice,
          quantity: currentItem.quantity + quantity,
        );
      } else {
        final effectiveOriginalPrice = originalPrice ?? unitPrice;

        _items.add(
          CartItemModel(
            cartId: null,
            product: product,
            unit: unit,
            originalPrice: effectiveOriginalPrice,
            discount: (effectiveOriginalPrice - unitPrice)
                .clamp(0, double.infinity)
                .toDouble(),
            unitPrice: unitPrice,
            quantity: quantity,
          ),
        );
      }
      _notify();
      await _saveCart();

      // Guest:
      // احفظ السلة محلياً فقط ولا تستدعِ API محمية.
      if (!_hasAuthenticatedSession) {
        return ApiResponse.success(null);
      }

      final response = await _repository.addToCart(
        productId: product.id,
        unitId: unit.id,
        quantity: quantity,
      );

      if (!response.isSuccess) {
        await loadFromServer();

        return ApiResponse.failure(
          response.message,
        );
      }

      await loadFromServer();

      return ApiResponse.success(null);
    } catch (error, stackTrace) {
      debugPrint('Cart add error: $error');
      debugPrintStack(stackTrace: stackTrace);

      // لا نمسح السلة المحلية عند خطأ غير متوقع.
      return ApiResponse.failure(
        'تعذر إضافة المنتج إلى السلة',
      );
    } finally {
      _busy = false;

      _setItemProcessing(
        product.id,
        unit.id,
        false,
      );
    }
  }

  Future<void> increase(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }

    final item = _items[index];

    final key = '${item.product.id}_${item.unit.id}';

    if (_processingItems.contains(key)) {
      return;
    }

    _setItemProcessing(
      item.product.id,
      item.unit.id,
      true,
    );

    try {
      final newQuantity = item.quantity + 1;

      _items[index] = item.copyWith(
        quantity: newQuantity,
      );

      _notify();
      await _saveCart();

      if (!_hasAuthenticatedSession) {
        return;
      }

      if (item.cartId == null) {
        return;
      }

      final response = await _repository.updateQuantity(
        cartId: item.cartId!,
        quantity: newQuantity,
      );

      if (!response.isSuccess) {
        await loadFromServer();
        return;
      }

      await loadFromServer();
    } finally {
      _setItemProcessing(
        item.product.id,
        item.unit.id,
        false,
      );
    }
  }

  Future<void> decrease(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }

    final item = _items[index];

    final key = '${item.product.id}_${item.unit.id}';

    if (_processingItems.contains(key)) {
      return;
    }

    _setItemProcessing(
      item.product.id,
      item.unit.id,
      true,
    );

    try {
      if (item.quantity <= 1) {
        _items.removeAt(index);

        _notify();
        await _saveCart();

        if (!_hasAuthenticatedSession) {
          return;
        }

        if (item.cartId == null) {
          return;
        }

        final response = await _repository.removeItem(
          item.cartId!,
        );

        if (!response.isSuccess) {
          await loadFromServer();
          return;
        }

        await loadFromServer();
        return;
      }

      final newQuantity = item.quantity - 1;

      _items[index] = item.copyWith(
        quantity: newQuantity,
      );

      _notify();
      await _saveCart();

      if (!_hasAuthenticatedSession) {
        return;
      }

      if (item.cartId == null) {
        return;
      }

      final response = await _repository.updateQuantity(
        cartId: item.cartId!,
        quantity: newQuantity,
      );

      if (!response.isSuccess) {
        await loadFromServer();
        return;
      }

      await loadFromServer();
    } finally {
      _setItemProcessing(
        item.product.id,
        item.unit.id,
        false,
      );
    }
  }

  Future<void> setQuantity({
    required String productId,
    required String unitId,
    required int quantity,
  }) async {
    final index = getCartItemIndex(productId, unitId);

    // لا يوجد المنتج في السلة.
    if (index == -1) {
      return;
    }

    final item = _items[index];
    final key = '${productId}_$unitId';

    if (_processingItems.contains(key)) {
      return;
    }

    if (quantity <= 0) {
      await decrease(index);
      return;
    }

    if (quantity == item.quantity) {
      return;
    }

    _setItemProcessing(productId, unitId, true);

    try {
      _items[index] = item.copyWith(
        quantity: quantity,
      );

      _notify();
      await _saveCart();

      // Guest: local cart فقط.
      if (!_hasAuthenticatedSession) {
        return;
      }

      // إذا كان العنصر موجودًا على السيرفر، حدّثه.
      if (item.cartId != null) {
        final response = await _repository.updateQuantity(
          cartId: item.cartId!,
          quantity: quantity,
        );

        if (!response.isSuccess) {
          await loadFromServer();
          return;
        }

        await loadFromServer();
      }
    } finally {
      _setItemProcessing(productId, unitId, false);
    }
  }

  Future<void> clear() async {
    _items.clear();

    _notify();
    await _saveCart();

    // Guest: local clear only.
    if (!_hasAuthenticatedSession) {
      return;
    }

    try {
      await _repository.clearCart();
      await loadFromServer();
    } catch (error, stackTrace) {
      debugPrint('Cart clear error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// يدمج السلة المحلية الخاصة بالضيف مع السلة الموجودة على السيرفر.
  ///
  /// يتم استدعاؤه مرة واحدة بعد نجاح Login/Register.
  Future<void> mergeGuestCart() async {
    if (_isMerging) {
      return;
    }

    if (!_hasAuthenticatedSession) {
      return;
    }

    if (_items.isEmpty) {
      await loadFromServer();
      return;
    }

    _isMerging = true;
    _notify();

    try {
      // نحتفظ بنسخة مستقلة من سلة الضيف قبل أي مزامنة.
      final localItems = List<CartItemModel>.from(_items);

      // قراءة سلة السيرفر.
      final serverResponse = await _repository.getCart();

      if (!serverResponse.isSuccess || serverResponse.data == null) {
        // إذا فشل جلب سلة السيرفر، لا نلمس السلة المحلية.
        return;
      }

      final serverItems = List<CartItemModel>.from(serverResponse.data!);

      for (final localItem in localItems) {
        final serverIndex = serverItems.indexWhere(
          (serverItem) =>
              serverItem.product.id == localItem.product.id &&
              serverItem.unit.id == localItem.unit.id,
        );

        // ─────────────────────────────────────────────────────────────
        // المنتج غير موجود في سلة السيرفر → إضافة
        // ─────────────────────────────────────────────────────────────
        if (serverIndex == -1) {
          final response = await _repository.addToCart(
            productId: localItem.product.id,
            unitId: localItem.unit.id,
            quantity: localItem.quantity,
          );

          if (response.isSuccess) {
            _items.removeWhere((item) =>
                item.product.id == localItem.product.id &&
                item.unit.id == localItem.unit.id);
            await _saveCart();
          }

          continue;
        }

        // ─────────────────────────────────────────────────────────────
        // المنتج موجود → دمج الكمية
        // ─────────────────────────────────────────────────────────────
        final serverItem = serverItems[serverIndex];

        if (serverItem.cartId == null) {
          continue;
        }

        // BACKEND IDEMPOTENCY REQUIRED FOR FULL GUARANTEE
        // إذا فشل الاتصال بعد تحديث السيرفر بنجاح، ستتضاعف الكمية هنا
        // في المحاولة التالية لعدم وجود idempotency key من الـ Backend.
        final mergedQuantity = serverItem.quantity + localItem.quantity;

        final response = await _repository.updateQuantity(
          cartId: serverItem.cartId!,
          quantity: mergedQuantity,
        );

        if (response.isSuccess) {
          _items.removeWhere((item) =>
              item.product.id == localItem.product.id &&
              item.unit.id == localItem.unit.id);
          await _saveCart();
        }
      }

      // ─────────────────────────────────────────────────────────────
      // نحاول تحميل أحدث نسخة من السيرفر.
      // ─────────────────────────────────────────────────────────────
      final latestResponse = await _repository.getCart();

      if (latestResponse.isSuccess && latestResponse.data != null) {
        final mergedItems = List<CartItemModel>.from(
          latestResponse.data!,
        );

        // نعيد العناصر التي فشلت مزامنتها وظلت في _items
        for (final failedItem in _items) {
          final existingIndex = mergedItems.indexWhere(
            (serverItem) =>
                serverItem.product.id == failedItem.product.id &&
                serverItem.unit.id == failedItem.unit.id,
          );

          if (existingIndex != -1) {
            // نستخدم نسخة الضيف لأنها تمثل الكمية التي يريدها المستخدم.
            mergedItems[existingIndex] = failedItem.copyWith(
              cartId: mergedItems[existingIndex].cartId,
            );
          } else {
            mergedItems.add(failedItem);
          }
        }

        _items
          ..clear()
          ..addAll(mergedItems);

        await _saveCart();
      }
    } catch (error, stackTrace) {
      debugPrint('Guest cart merge error: $error');
      debugPrintStack(stackTrace: stackTrace);

      // الأهم: لا نمسح السلة المحلية عند حدوث خطأ غير متوقع.
      await _saveCart();
    } finally {
      _isMerging = false;
      _notify();
    }
  }

  double get originalSubtotal {
    return _items.fold(
      0.0,
      (sum, item) => sum + (item.originalPrice * item.quantity),
    );
  }

  double get offerDiscount {
    return _items.fold(
      0.0,
      (sum, item) => sum + (item.discountPerUnit * item.quantity),
    );
  }

  double get subtotal {
    return _items.fold(
      0.0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
  }
}
