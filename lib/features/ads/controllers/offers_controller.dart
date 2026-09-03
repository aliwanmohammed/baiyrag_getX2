import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../domain/repositories/offers_repository.dart';
import '../models/offer_model.dart';

class OffersController extends GetxController {
  OffersController(this._repository);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  final OffersRepository _repository;

  List<OfferModel> _offers = [];
  OfferModel? _selectedOffer;

  bool _isLoading = false;
  bool _isLoadingDetail = false;
  bool _inFlight = false;
  String? _error;
  String? _detailError;

  List<OfferModel> get offers => _offers;
  OfferModel? get selectedOffer => _selectedOffer;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;
  String? get detailError => _detailError;

  bool get isEmpty => !_isLoading && _offers.isEmpty && _error == null;

  /// The offers API already calculates fixed and percentage discounts in
  /// [OfferProductUnitModel.price]. Gift offers do not alter an item's price.
  /// Returns true when the given product unit is covered by an active offer
  /// whose date window is currently valid.
  bool hasApplicableOfferForUnit({
    required String productId,
    required String unitId,
  }) {
    return _offers.any((offer) =>
        _isApplicable(offer) &&
        offer.productUnits.any(
          (unit) => unit.productId == productId && unit.unitId == unitId,
        ));
  }

  OfferProductUnitModel? productUnitOffer({
    required String productId,
    required String unitId,
  }) {
    for (final offer in _offers) {
      if (offer.isGift || !_isApplicable(offer)) continue;
      for (final unit in offer.productUnits) {
        if (unit.productId == productId && unit.unitId == unitId) return unit;
      }
    }
    return null;
  }

  List<GiftRewardModel> giftRewardsFor(Iterable<OfferCartLine> cartLines) {
    final rewards = <String, GiftRewardModel>{};

    for (final offer in _offers) {
      final gift = offer.gift;
      final buyQuantity = offer.buyQuantity;
      if (!offer.isGift ||
          !_isApplicable(offer) ||
          gift == null ||
          buyQuantity == null ||
          buyQuantity <= 0 ||
          gift.quantity <= 0) {
        continue;
      }

      for (final line in cartLines) {
        if (line.quantity <= 0 ||
            !offer.productUnits.any(
              (unit) =>
                  unit.productId == line.productId &&
                  unit.unitId == line.unitId,
            )) {
          continue;
        }

        final giftCount = (line.quantity ~/ buyQuantity) * gift.quantity;
        if (giftCount == 0) continue;

        final key = '${offer.id}:${gift.productId}:${gift.unitId}';
        final previous = rewards[key];
        rewards[key] = GiftRewardModel(
          offerId: offer.id,
          gift: gift,
          quantity: (previous?.quantity ?? 0) + giftCount,
        );
      }
    }

    return rewards.values.toList(growable: false);
  }

  bool _isApplicable(OfferModel offer) {
    if (!offer.isActive) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = _dateOnly(offer.startDate);
    final endDate = _dateOnly(offer.endDate);

    if (startDate != null && today.isBefore(startDate)) return false;
    if (endDate != null && today.isAfter(endDate)) return false;
    return true;
  }

  DateTime? _dateOnly(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  // ── List ────────────────────────────────────────────────────────────────

  Future<void> load({bool showLoading = true}) async {
    if (_inFlight) {
      assert(() {
        debugPrint(
            '[OffersController] SKIPPED duplicate request (already in flight)');
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
      debugPrint('[OffersController] REQUEST OFFERS start');
      return true;
    }());

    try {
      final response = await _repository.getOffers();

      stopwatch.stop();

      assert(() {
        debugPrint(
          '[OffersController] RESPONSE OFFERS '
          '(success=${response.isSuccess}, count=${response.data?.length}, '
          'duration=${stopwatch.elapsedMilliseconds}ms)',
        );
        return true;
      }());

      if (response.isSuccess) {
        _offers = response.data ?? [];
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      stopwatch.stop();
      _error = lang.t('offers_load_error');
      debugPrint(
        '[OffersController] ERROR OFFERS '
        '(duration=${stopwatch.elapsedMilliseconds}ms, error=$e)',
      );
    } finally {
      _isLoading = false;
      _inFlight = false;
      update();
    }
  }

  Future<void> reload() {
    return load(showLoading: false);
  }

  // ── Detail ───────────────────────────────────────────────────────────────

  Future<void> loadOffer(String id) async {
    _selectedOffer = null;
    _isLoadingDetail = true;
    _detailError = null;
    update();

    final response = await _repository.getOfferById(id);

    if (response.isSuccess && response.data != null) {
      _selectedOffer = response.data;
    } else {
      _detailError = response.message;
    }

    _isLoadingDetail = false;
    update();
  }
}
