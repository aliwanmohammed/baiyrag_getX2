import 'package:get/get.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/product_model.dart';
import '../../products/domain/repositories/product_repository.dart';

class ProductSearchController extends GetxController {
  ProductSearchController(this._repository);

  final ProductRepository _repository;

  final TextEditingController controller = TextEditingController();

  Timer? _debounce;

  int _requestId = 0;

  final RxList<String> _recentSearches = <String>[].obs;
  final RxString _query = ''.obs;
  final RxList<ProductModel> _results = <ProductModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString();

  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  String get query => _query.value;
  List<ProductModel> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  @override
  void onClose() {
    _debounce?.cancel();
    controller.dispose();
    super.onClose();
  }

  /// ظٹط³طھط¯ط¹ظ‰ ظ…ظ† ط§ظ„ظ€ TextField
  void updateQuery(String value) {
    _query.value = value.trim();

    _debounce?.cancel();

    if (_query.value.isEmpty) {
      _requestId++;

      _results.clear();
      _error.value = null;

      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () => search(_query.value));
  }

  Future<void> search(String value) async {
    _query.value = value.trim();

    final request = ++_requestId;

    if (_query.value.isNotEmpty) {
      _recentSearches.remove(_query.value);
      _recentSearches.insert(0, _query.value);

      if (_recentSearches.length > 8) {
        _recentSearches.removeLast();
      }
    }

    _isLoading.value = true;
    _error.value = null;

    try {
      final response = await _repository.getProducts(
        search: _query.value,
      );

      if (request != _requestId) {
        return;
      }

      if (response.isSuccess && response.data != null) {
        _results.assignAll(response.data!.items);
      } else {
        _results.clear();
        _error.value = response.message.isNotEmpty
            ? response.message
            : 'تعذر تنفيذ البحث. حاول مرة أخرى.';
      }
    } catch (error, stackTrace) {
      if (request != _requestId) {
        return;
      }

      debugPrint('[ProductSearchController] search error: $error');
      debugPrintStack(stackTrace: stackTrace);

      _results.clear();
      _error.value = 'تعذر تنفيذ البحث. حاول مرة أخرى.';
    } finally {
      if (request == _requestId) {
        _isLoading.value = false;
      }
    }
  }

  void clear() {
    _debounce?.cancel();

    _requestId++;

    controller.clear();

    _query.value = '';

    _results.clear();

    _error.value = null;
  }

  void removeRecent(String value) {
    _recentSearches.remove(value);
  }

  void clearRecentSearches() {
    _recentSearches.clear();
  }
}
