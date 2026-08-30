import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../domain/repositories/ads_repository.dart';
import '../models/ad_model.dart';

class AdsController extends GetxController {
  AdsController(this.repository);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  final AdsRepository repository;

  List<AdModel> _ads = [];

  bool _loading = false;
  bool _inFlight = false;
  String? _error;

  List<AdModel> get ads => _ads;

  bool get loading => _loading;

  String? get error => _error;

  Future<void> load({bool showLoading = true}) async {
    if (_inFlight) {
      assert(() {
        debugPrint(
            '[AdsController] SKIPPED duplicate request (already in flight)');
        return true;
      }());
      return;
    }

    _inFlight = true;

    if (showLoading) {
      _loading = true;
      _error = null;
      update();
    } else {
      _error = null;
    }

    final stopwatch = Stopwatch()..start();

    assert(() {
      debugPrint('[AdsController] REQUEST ADS start');
      return true;
    }());

    try {
      final response = await repository.getAds();

      stopwatch.stop();

      assert(() {
        debugPrint(
          '[AdsController] RESPONSE ADS '
          '(success=${response.isSuccess}, count=${response.data?.length}, '
          'duration=${stopwatch.elapsedMilliseconds}ms)',
        );
        return true;
      }());

      if (response.isSuccess) {
        _ads = response.data ?? [];
        _ads.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint('AdsController error: $e');
      debugPrintStack(stackTrace: stackTrace);
      _error = 'حدث خطأ أثناء تحميل الإعلانات';
    } finally {
      _loading = false;
      _inFlight = false;
      update();
    }
  }

  Future<void> reload() {
    return load(showLoading: false);
  }
}
