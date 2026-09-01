import '../../../app/localization/lang.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/product_model.dart';
import '../../products/domain/repositories/product_repository.dart';

class SearchController extends GetxController {
  SearchController(this._repository);

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

  List<ProductModel> get results => _results;

  bool get isLoading => _isLoading;

  String? get error => _error;

  @override
  void onClose() {
    _debounce?.cancel();
    controller.dispose();
    super.onClose();
  }

  /// ظٹط³طھط¯ط¹ظ‰ ظ…ظ† ط§ظ„ظ€ TextField
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

    _debounce = Timer(const Duration(milliseconds: 350), () => search(_query));

    update();
  }

  Future<void> search(String value) async {
    _query = value.trim();

    final request = ++_requestId;

    if (_query.isNotEmpty) {
      _recentSearches.remove(_query);

      _recentSearches.insert(0, _query);

      if (_recentSearches.length > 8) {
        _recentSearches.removeLast();
      }
    }

    _isLoading = true;
    _error = null;

    update();

    try {
      final response = await _repository.getProducts(search: _query);

      if (request != _requestId) {
        return;
      }

      if (response.isSuccess && response.data != null) {
        _results = response.data!.items;
      } else {
        _results = [];
        _error = response.message;
      }
    } catch (_) {
      if (request != _requestId) {
        return;
      }

      _results = [];
      _error = lang.t('search_error_retry');
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
