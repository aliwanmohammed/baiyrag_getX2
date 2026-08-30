import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../core/models/product_model.dart';
import '../../products/domain/repositories/product_repository.dart';

enum HomeLoadState {
  initial,
  loading,
  refreshing,
  success,
  empty,
  error,
}

class HomeController extends GetxController {
  HomeController(this._repository);

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  final ProductRepository _repository;

  List<ProductModel> _products = [];
  List<ProductModel> _flashDeals = [];
  List<ProductModel> _bestSellerProducts = [];
  List<ProductModel> _recommendedProducts = [];

  String _selectedCategory = '';

  HomeLoadState _state = HomeLoadState.initial;
  String? _error;

  int _requestId = 0;

  // ---------------------------------------------------------------------------
  // Public getters
  // ---------------------------------------------------------------------------

  HomeLoadState get state => _state;

  bool get isLoading =>
      _state == HomeLoadState.loading || _state == HomeLoadState.initial;

  bool get isRefreshing => _state == HomeLoadState.refreshing;

  bool get hasError => _state == HomeLoadState.error;

  bool get isEmpty => _state == HomeLoadState.empty;

  String? get error => _error;

  String get selectedCategory => _selectedCategory;

  List<ProductModel> get flashDeals => List.unmodifiable(_flashDeals);
  List<ProductModel> get bestSellerProducts => List.unmodifiable(_bestSellerProducts);
  List<ProductModel> get recommendedProducts => List.unmodifiable(_recommendedProducts);
  List<ProductModel> get products => List.unmodifiable(_products);

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> loadProducts({bool showLoading = true}) async {
    final request = ++_requestId;

    if (showLoading && _products.isEmpty) {
      _state = HomeLoadState.loading;
    } else if (!showLoading) {
      _state = HomeLoadState.refreshing;
    }

    _error = null;
    update();

    final stopwatch = Stopwatch()..start();

    assert(() {
      debugPrint(
        '[HomeController] REQUEST HOME start '
        '(requestId=$request, showLoading=$showLoading)',
      );
      return true;
    }());

    try {
      if (_selectedCategory.isNotEmpty) {
        // إذا كان هناك قسم محدد، نحتاج فقط منتجات هذا القسم
        final response = await _repository.getProducts(
          categoryId: _selectedCategory,
          page: 1,
        );

        stopwatch.stop();

        if (request != _requestId) return;

        if (!response.isSuccess || response.data == null) {
          _error = response.message;
          _state = HomeLoadState.error;
          return;
        }

        _products = List<ProductModel>.from(response.data!.items);
        _flashDeals = [];
        _bestSellerProducts = [];
        _recommendedProducts = [];

        _error = null;
        _state = _products.isEmpty ? HomeLoadState.empty : HomeLoadState.success;
      } else {
        // في الشاشة الرئيسية (بدون قسم)، نحتاج جميع الأقسام
        final responses = await Future.wait([
          _repository.getProducts(page: 1),
          _repository.getProducts(page: 1, isFlashDeal: true),
          _repository.getProducts(page: 1, isBestSeller: true),
          _repository.getProducts(page: 1, isRecommended: true),
        ]);

        stopwatch.stop();

        if (request != _requestId) return;

        final generalResponse = responses[0];
        final flashResponse = responses[1];
        final bestSellerResponse = responses[2];
        final recommendedResponse = responses[3];

        if (!generalResponse.isSuccess || generalResponse.data == null) {
          _error = generalResponse.message;
          _state = HomeLoadState.error;
          return;
        }

        final usedIds = <String>{};

        _flashDeals = flashResponse.isSuccess && flashResponse.data != null
            ? flashResponse.data!.items.where((p) => usedIds.add(p.id)).take(4).toList()
            : [];

        _bestSellerProducts = bestSellerResponse.isSuccess && bestSellerResponse.data != null
            ? bestSellerResponse.data!.items.where((p) => usedIds.add(p.id)).take(4).toList()
            : [];

        _recommendedProducts = recommendedResponse.isSuccess && recommendedResponse.data != null
            ? recommendedResponse.data!.items.where((p) => usedIds.add(p.id)).take(4).toList()
            : [];

        _products = generalResponse.data!.items.where((p) => usedIds.add(p.id)).toList();

        _error = null;
        _state = _products.isEmpty &&
                _flashDeals.isEmpty &&
                _bestSellerProducts.isEmpty &&
                _recommendedProducts.isEmpty
            ? HomeLoadState.empty
            : HomeLoadState.success;
      }

      assert(() {
        debugPrint(
          '[HomeController] RESPONSE HOME '
          '(general=${_products.length}, '
          'flash=${_flashDeals.length}, '
          'bestSeller=${_bestSellerProducts.length}, '
          'recommended=${_recommendedProducts.length}, '
          'duration=${stopwatch.elapsedMilliseconds}ms)',
        );
        return true;
      }());
    } catch (e) {
      stopwatch.stop();

      if (request != _requestId) {
        return;
      }

      _error = 'تعذر تحديث المنتجات';
      _state = HomeLoadState.error;

      debugPrint(
        '[HomeController] ERROR HOME '
        '(duration=${stopwatch.elapsedMilliseconds}ms, error=$e)',
      );
    } finally {
      if (request == _requestId) {
        assert(() {
          debugPrint(
            '[HomeController] UI UPDATED '
            '(state=$_state, '
            'general=${_products.length}, '
            'flash=${_flashDeals.length}, '
            'bestSeller=${_bestSellerProducts.length}, '
            'recommended=${_recommendedProducts.length})',
          );
          return true;
        }());

        update();
      }
    }
  }

  Future<void> reload() {
    return loadProducts(showLoading: false);
  }

  // ---------------------------------------------------------------------------
  // Category
  // ---------------------------------------------------------------------------

  void selectCategory(String categoryId) {
    if (_selectedCategory == categoryId) {
      return;
    }

    _selectedCategory = categoryId;
    loadProducts(showLoading: false);
  }

  void clearCategory() {
    if (_selectedCategory.isEmpty) {
      return;
    }

    _selectedCategory = '';
    loadProducts(showLoading: false);
  }
}
