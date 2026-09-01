import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/models/product_model.dart';
import '../../../core/pagination/pagination_meta.dart';
import '../domain/repositories/product_repository.dart';
import '../models/product_unit_model.dart';

class ProductController extends GetxController {
  ProductController(this._repository);

  final ProductRepository _repository;

  // ===========================================================================
  // Product Details
  // ===========================================================================

  ProductModel? _product;
  List<ProductUnitModel> _units = [];
  List<ProductModel> _related = [];

  bool _isLoading = false;
  String? _error;

  int _productRequestId = 0;

  int _selectedUnitIndex = 0;
  int _quantity = 1;

  ProductModel? get product => _product;

  List<ProductUnitModel> get units => List.unmodifiable(_units);

  List<ProductModel> get related => List.unmodifiable(_related);

  bool get isLoading => _isLoading;

  String? get error => _error;

  int get quantity => _quantity;

  int get selectedUnitIndex => _selectedUnitIndex;

  ProductUnitModel? get selectedUnit {
    if (_units.isEmpty) return null;

    if (_selectedUnitIndex < 0 || _selectedUnitIndex >= _units.length) {
      return _units.first;
    }

    return _units[_selectedUnitIndex];
  }

  // ===========================================================================
  // Load Product Details
  // ===========================================================================
  Future<void> loadProduct(String productId) async {
    final currentRequestId = ++_productRequestId;

    _product = null;
    _units = [];
    _related = [];
    _selectedUnitIndex = 0;
    _quantity = 1;
    _isLoading = true;
    _error = null;

    update();

    try {
      final productResponse = await _repository.getProductById(productId);

      if (currentRequestId != _productRequestId) {
        return;
      }

      if (!productResponse.isSuccess || productResponse.data == null) {
        _product = null;
        _units = [];
        _related = [];
        _error = productResponse.message;
        _isLoading = false;
        update();
        return;
      }

      _product = productResponse.data!;
      _units = _product!.units;

      if (_product!.categoryId.isNotEmpty) {
        final relatedResponse = await _repository.getProducts(
          categoryId: _product!.categoryId,
          page: 1,
        );

        if (currentRequestId != _productRequestId) {
          return;
        }

        if (relatedResponse.isSuccess && relatedResponse.data != null) {
          _related = relatedResponse.data!.items
              .where((e) => e.id != _product!.id)
              .take(6)
              .toList();
        } else {
          _related = [];
        }
      } else {
        _related = [];
      }

      if (currentRequestId != _productRequestId) {
        return;
      }

      _selectedUnitIndex = 0;
      _quantity = 1;
      _isLoading = false;
      _error = null;

      update();
    } catch (e, stackTrace) {
      if (currentRequestId != _productRequestId) {
        return;
      }

      debugPrint('Product load error: $e');
      debugPrintStack(stackTrace: stackTrace);

      _product = null;
      _units = [];
      _related = [];
      _error = 'تعذر تحميل بيانات المنتج';
      _isLoading = false;

      update();
    }
  }

  // ===========================================================================
  // Set Existing Product
  // ===========================================================================

  /// يستخدم عندما يكون المنتج موجودًا مسبقًا في الذاكرة
  /// مع وحداته، لتجنب طلب API إضافي.
  void setProduct(ProductModel product) {
    ++_productRequestId;

    _product = product;
    _units = List<ProductUnitModel>.from(product.units);
    _related = [];
    _selectedUnitIndex = 0;
    _quantity = 1;
    _isLoading = false;
    _error = null;

    update();
  }
  // ===========================================================================
  // Unit Selection
  // ===========================================================================

  void selectUnit(int index) {
    if (index < 0 || index >= _units.length) {
      return;
    }

    if (_selectedUnitIndex == index) {
      return;
    }

    _selectedUnitIndex = index;

    // عند تغيير الوحدة نعيد الكمية الافتراضية.
    _quantity = 1;

    update();
  }

  // ===========================================================================
  // Quantity
  // ===========================================================================

  void increaseQuantity() {
    _quantity++;
    update();
  }

  void decreaseQuantity() {
    if (_quantity <= 1) {
      return;
    }

    _quantity--;
    update();
  }

  // ===========================================================================
  // Reset
  // ===========================================================================

  void reset() {
    ++_productRequestId;

    _product = null;
    _units = [];
    _related = [];

    _selectedUnitIndex = 0;
    _quantity = 1;

    _error = null;
    _isLoading = false;

    update();
  }

  // ===========================================================================
  // Category Products
  // ===========================================================================

  List<ProductModel> _products = [];

  PaginationMeta? _paginationMeta;

  bool _isFetchingMore = false;

  int _listRequestId = 0;

  String _currentCategoryId = '';

  List<ProductModel> get products => List.unmodifiable(_products);

  PaginationMeta? get paginationMeta => _paginationMeta;

  bool get isFetchingMore => _isFetchingMore;

  bool get hasNextPage => _paginationMeta?.hasNext ?? false;

  // ===========================================================================
  // Load Category
  // ===========================================================================

  Future<void> loadCategory(
    String categoryId, {
    bool refresh = true,
  }) async {
    final requestId = ++_listRequestId;

    _currentCategoryId = categoryId;

    try {
      _isLoading = true;
      _error = null;

      if (refresh || _products.isEmpty) {
        _products = [];
        _paginationMeta = null;
      }

      update();

      final response = await _repository.getProducts(
        categoryId: categoryId,
        page: 1,
      );

      if (requestId != _listRequestId) {
        return;
      }

      if (response.isSuccess && response.data != null) {
        _products = List<ProductModel>.from(
          response.data!.items,
        );

        _paginationMeta = response.data!.meta;
        _error = null;

        if (categoryId.isEmpty) {
          _applyOfferFilter();
          while (_products.isEmpty && hasNextPage) {
            await loadMore();
          }
        }
      } else {
        if (refresh) {
          _products = [];
          _paginationMeta = null;
        }

        _error = response.message.isNotEmpty
            ? response.message
            : 'تعذر تحميل المنتجات';
      }
    } catch (e, stackTrace) {
      if (requestId != _listRequestId) {
        return;
      }

      debugPrint('[ProductController] loadCategory error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (refresh) {
        _products = [];
        _paginationMeta = null;
      }

      _error = 'تعذر تحميل المنتجات';
    } finally {
      if (requestId == _listRequestId) {
        _isLoading = false;
        update();
      }
    }
  }

  // ===========================================================================
  // Load More
  // ===========================================================================

  Future<void> loadMore() async {
    if (_isFetchingMore) {
      return;
    }

    if (_paginationMeta == null) {
      return;
    }

    if (!hasNextPage) {
      return;
    }

    final requestId = ++_listRequestId;
    final nextPage = _paginationMeta!.currentPage + 1;

    _isFetchingMore = true;
    update();

    try {
      final response = await _repository.getProducts(
        categoryId: _currentCategoryId,
        page: nextPage,
      );

      if (requestId != _listRequestId) {
        return;
      }

      if (response.isSuccess && response.data != null) {
        final existingIds = _products.map((p) => p.id).toSet();
        for (final product in response.data!.items) {
          if (existingIds.add(product.id)) {
            _products.add(product);
          }
        }

        _paginationMeta = response.data!.meta;
        if (_currentCategoryId.isEmpty) {
          _applyOfferFilter();
        }
      }
    } catch (e, stackTrace) {
      if (requestId != _listRequestId) {
        return;
      }

      debugPrint('[ProductController] loadMore error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (requestId == _listRequestId) {
        _isFetchingMore = false;
        update();
      }
    }
  }

  void _applyOfferFilter() {
    _products = _products
        .map((product) {
          final offerUnits = product.units
              .where((unit) => unit.offer != null && _isOfferActive(unit.offer!.startDate, unit.offer!.endDate))
              .toList();
          return offerUnits.isEmpty
              ? null
              : product.copyWith(units: offerUnits);
        })
        .whereType<ProductModel>()
        .toList();
  }

  bool _isOfferActive(String? startDate, String? endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = startDate == null ? null : DateTime.tryParse(startDate);
    final end = endDate == null ? null : DateTime.tryParse(endDate);
    if (start != null && today.isBefore(DateTime(start.year, start.month, start.day))) {
      return false;
    }
    if (end != null && today.isAfter(DateTime(end.year, end.month, end.day))) {
      return false;
    }
    return true;
  }

}
