import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/product_model.dart';
import '../../../core/design_system/components/feedback/app_error_message.dart';
import '../../products/domain/repositories/product_repository.dart';

class ProductSearchController extends GetxController {
  ProductSearchController(this._repository);

  final ProductRepository _repository;

  final TextEditingController controller = TextEditingController();
  Timer? _debounce;
  int _requestId = 0;

  final List<String> _recentSearches = [];
  String _query = '';
  List<ProductModel> _results = [];
  bool _isLoading = false;
  String? _error;

  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  String get query => _query;
  List<ProductModel> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void onClose() {
    _debounce?.cancel();
    controller.dispose();
    super.onClose();
  }

  void updateQuery(String value) {
    _query = value.trim();
    _debounce?.cancel();

    if (_query.isEmpty) {
      _requestId++;
      _results = [];
      _error = null;
      update();
      return;
    }

    update();
    final query = _query;
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => search(query),
    );
  }

  Future<void> search(String value) async {
    final query = value.trim();
    if (query.isEmpty) {
      clear();
      return;
    }

    _query = query;
    final request = ++_requestId;

    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) {
      _recentSearches.removeLast();
    }

    _isLoading = true;
    _error = null;
    update();

    try {
      final response = await _repository.getProducts(
        search: query,
        page: 1,
      );

      if (request != _requestId) return;

      if (response.isSuccess && response.data != null) {
        _results = response.data!.items;
        _error = null;

        // The documented API supports server-side ?search=. If the server
        // returns an empty successful page, do not invent an error state.
        // Keep the empty state honest and let the next diagnostic response
        // tell us whether the backend search itself is returning no matches.
      } else {
        debugPrint(
          '[ProductSearchController] API failure: '
          'status=${response.statusCode}, message=${response.message}',
        );
        _results = [];
        _error = AppErrorMessage.from(
          message: response.message,
          statusCode: response.statusCode,
          fallback: 'تعذر تنفيذ البحث. حاول مرة أخرى.',
        );
      }
    } catch (error, stackTrace) {
      if (request != _requestId) return;

      debugPrint('[ProductSearchController] search error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _results = [];
      _error = 'تعذر تنفيذ البحث. حاول مرة أخرى.';
    } finally {
      if (request == _requestId) {
        _isLoading = false;
        update();
      }
    }
  }

  void clear() {
    _debounce?.cancel();
    _requestId++;
    controller.clear();
    _query = '';
    _results = [];
    _error = null;
    _isLoading = false;
    update();
  }

  void removeRecent(String value) {
    _recentSearches.remove(value);
    update();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    update();
  }
}
