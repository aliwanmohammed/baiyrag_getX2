import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../core/models/category_model.dart';
import '../../../core/design_system/components/feedback/app_error_message.dart';
import '../domain/repositories/category_repository.dart';

class CategoryController extends GetxController {
  CategoryController(this._repository);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  final CategoryRepository _repository;

  List<CategoryModel> _categories = [];
  // Pre-sorted cache — rebuilt only when _categories changes.
  List<CategoryModel> _cachedMainCategories = [];
  bool _isLoading = false;
  // guard لمنع double-load: إذا كان هناك طلب جارٍ، لا نُطلق طلباً آخر.
  bool _inFlight = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Returns main categories sorted by sortOrder.
  /// Result is cached; no allocation on repeated calls.
  List<CategoryModel> get mainCategories => _cachedMainCategories;

  Future<void> loadCategories({bool showLoading = true}) async {
    // ──────────────────────────────────────────────────────────────────────
    // Guard: لا نُطلق request جديد إذا كان هناك طلب جارٍ بالفعل.
    // هذا يمنع double-call من constructor + refresh() متزامنَين.
    // ──────────────────────────────────────────────────────────────────────
    if (_inFlight) {
      assert(() {
        debugPrint(
            '[CategoryController] SKIPPED duplicate request (already in flight)');
        return true;
      }());
      return;
    }

    _inFlight = true;

    if (showLoading) {
      _isLoading = true;
      _error = null;
      update();
    } else {
      _error = null;
    }

    final stopwatch = Stopwatch()..start();

    assert(() {
      debugPrint('[CategoryController] REQUEST CATEGORIES start');
      return true;
    }());

    try {
      final response = await _repository.getCategories();

      stopwatch.stop();

      assert(() {
        debugPrint(
          '[CategoryController] RESPONSE CATEGORIES '
          '(success=${response.isSuccess}, count=${response.data?.length}, '
          'duration=${stopwatch.elapsedMilliseconds}ms)',
        );
        return true;
      }());

      if (response.isSuccess && response.data != null) {
        _categories = response.data!;
        _error = null;
      } else {
        _error = AppErrorMessage.from(
            message: response.message,
            statusCode: response.statusCode,
            fallback: lang.t('categories_load_error_retry'));
      }
    } catch (e) {
      stopwatch.stop();
      _error = lang.t('categories_load_error_retry');
      debugPrint(
        '[CategoryController] ERROR CATEGORIES '
        '(duration=${stopwatch.elapsedMilliseconds}ms, error=$e)',
      );
    } finally {
      _cachedMainCategories = _categories
          .where((c) => c.parentId == null)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      _isLoading = false;
      _inFlight = false;
      update();
    }
  }

  Future<void> reload() {
    return loadCategories(showLoading: false);
  }
}
