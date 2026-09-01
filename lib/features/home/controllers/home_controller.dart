import '../../../app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design_system/components/feedback/app_error_message.dart';
import '../../../core/models/product_model.dart';
import '../../../core/pagination/pagination_meta.dart';
import '../../products/domain/repositories/product_repository.dart';

/// Home data controller.
///
/// The backend is the source of truth for products and sections. Home only
/// renders the general paginated products feed; it does not manufacture
/// "best seller", "featured", "new", or "recommended" sections locally.
class HomeController extends GetxController {
  HomeController(this._repository);

  final ProductRepository _repository;

  List<ProductModel> _products = [];
  String _selectedCategory = '';

  PaginationMeta? _paginationMeta;
  bool _isFetchingMore = false;

  HomeLoadState _state = HomeLoadState.initial;
  String? _error;

  int _requestId = 0;
  int _listRequestId = 0;

  HomeLoadState get state => _state;
  bool get isLoading =>
      _state == HomeLoadState.loading || _state == HomeLoadState.initial;
  bool get isRefreshing => _state == HomeLoadState.refreshing;
  bool get hasError => _state == HomeLoadState.error;
  bool get isEmpty => _state == HomeLoadState.empty;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  List<ProductModel> get products => List.unmodifiable(_products);
  PaginationMeta? get paginationMeta => _paginationMeta;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasNextPage => _paginationMeta?.hasNext ?? false;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts({
    bool showLoading = true,
    bool resetData = false,
  }) async {
    final request = ++_requestId;
    ++_listRequestId;
    _isFetchingMore = false;

    if (showLoading && _products.isEmpty) {
      _state = HomeLoadState.loading;
    } else {
      _state = HomeLoadState.refreshing;
    }

    _error = null;
    if (resetData || _products.isEmpty) {
      _products = [];
    }
    _paginationMeta = null;
    update();

    try {
      final response = await _repository.getProducts(
        categoryId: _selectedCategory.isEmpty ||
                _selectedCategory == 'special_offers'
            ? null
            : _selectedCategory,
        page: 1,
      );

      if (request != _requestId) return;

      if (!response.isSuccess || response.data == null) {
        _error = AppErrorMessage.from(
          message: response.message,
          statusCode: response.statusCode,
          fallback: lang.t('products_load_error_retry'),
        );
        _state = HomeLoadState.error;
        return;
      }

      _appendPage(response.data!.items, response.data!.meta);

      // lang.t('offers') is a deliberate category/filter in the UI. The offer is
      // attached to the exact unit by the backend, so filter units using that
      // server-provided offer data only.
      if (_selectedCategory == 'special_offers') {
        _applyOffersFilter();
        while (_products.isEmpty && hasNextPage) {
          await loadMore();
        }
      }

      _state = _products.isEmpty
          ? HomeLoadState.empty
          : HomeLoadState.success;
    } catch (e, stackTrace) {
      if (request != _requestId) return;

      debugPrint('[HomeController] loadProducts error: $e');
      debugPrintStack(stackTrace: stackTrace);
      _error = lang.t('products_load_error_retry');
      _state = HomeLoadState.error;
    } finally {
      if (request == _requestId) {
        update();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isFetchingMore || !hasNextPage) return;

    final request = ++_listRequestId;
    final nextPage = _paginationMeta!.currentPage + 1;
    _isFetchingMore = true;
    update();

    try {
      final response = await _repository.getProducts(
        categoryId: _selectedCategory.isEmpty ||
                _selectedCategory == 'special_offers'
            ? null
            : _selectedCategory,
        page: nextPage,
      );

      if (request != _listRequestId) return;

      if (response.isSuccess && response.data != null) {
        _appendPage(response.data!.items, response.data!.meta);

        if (_selectedCategory == 'special_offers') {
          _applyOffersFilter();
        }

        if (_products.isNotEmpty) {
          _state = HomeLoadState.success;
        }
      }
    } catch (e, stackTrace) {
      if (request != _listRequestId) return;
      debugPrint('[HomeController] loadMore error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (request == _listRequestId) {
        _isFetchingMore = false;
        update();
      }
    }
  }

  void _appendPage(
    List<ProductModel> items,
    PaginationMeta meta,
  ) {
    final existingIds = _products.map((p) => p.id).toSet();
    for (final product in items) {
      if (existingIds.add(product.id)) {
        _products.add(product);
      }
    }
    _paginationMeta = meta;
  }

  void _applyOffersFilter() {
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
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);
    final start = startDate == null ? null : DateTime.tryParse(startDate);
    final end = endDate == null ? null : DateTime.tryParse(endDate);

    if (start != null && date.isBefore(DateTime(start.year, start.month, start.day))) {
      return false;
    }
    if (end != null && date.isAfter(DateTime(end.year, end.month, end.day))) {
      return false;
    }
    return true;
  }

  Future<void> reload() => loadProducts(showLoading: false);

  void selectCategory(String categoryId) {
    if (_selectedCategory == categoryId) return;
    _selectedCategory = categoryId;
    loadProducts(showLoading: false, resetData: true);
  }

  void clearCategory() {
    if (_selectedCategory.isEmpty) return;
    _selectedCategory = '';
    loadProducts(showLoading: false, resetData: true);
  }
}

enum HomeLoadState {
  initial,
  loading,
  refreshing,
  success,
  empty,
  error,
}
