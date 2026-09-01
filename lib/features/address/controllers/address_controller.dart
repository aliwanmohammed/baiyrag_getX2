import '../../../app/localization/lang.dart';
import 'package:get/get.dart';
import 'package:bhm_supermarket/core/services/secure_storage_service.dart';

import '../domain/repositories/address_repository.dart';
import '../models/address_model.dart';

class AddressController extends GetxController {
  AddressController(this._repository);

  final AddressRepository _repository;

  List<AddressModel> _addresses = [];

  bool _loading = false;

  bool _actionLoading = false;

  bool get loading => _loading;
  bool get actionLoading => _actionLoading;

  List<AddressModel> get addresses => _addresses;

  AddressModel? get selectedAddress {
    if (_addresses.isEmpty) return null;

    for (final e in _addresses) {
      if (e.isDefault) {
        return e;
      }
    }

    return _addresses.first;
  }

  Future<void> loadAddresses() async {
    final token = await SecureStorageService.instance.readToken();

    if (token == null || token.isEmpty) {
      return;
    }

    if (_loading) return;

    _loading = true;
    update();

    try {
      final response = await _repository.getLocations();

      if (response.isSuccess && response.data != null) {
        _addresses = response.data!;
      }
    } finally {
      _loading = false;
      update();
    }
  }

  Future<String?> addAddress({
    required String title,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    if (_actionLoading) return null;
    _actionLoading = true;
    update();

    try {
      final response = await _repository.createLocation(
        title: title,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

      if (!response.isSuccess) {
        return response.message.isNotEmpty
            ? response.message
            : lang.t('add_address_error');
      }

      await loadAddresses();
      return null;
    } finally {
      _actionLoading = false;
      update();
    }
  }

  Future<String?> editAddress({
    required String id,
    required String title,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    if (_actionLoading) return null;
    _actionLoading = true;
    update();

    try {
      final response = await _repository.updateLocation(
        id: id,
        title: title,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

      if (!response.isSuccess) {
        return response.message.isNotEmpty
            ? response.message
            : lang.t('edit_address_error');
      }

      await loadAddresses();
      return null;
    } finally {
      _actionLoading = false;
      update();
    }
  }

  Future<bool> deleteAddress(String id) async {
    if (_actionLoading) return false;
    _actionLoading = true;
    update();

    try {
      final response = await _repository.deleteLocation(id);

      if (!response.isSuccess) {
        return false;
      }

      await loadAddresses();
      return true;
    } finally {
      _actionLoading = false;
      update();
    }
  }

  Future<bool> setDefault(String id) async {
    if (_actionLoading) return false;

    final address = _addresses.firstWhere((e) => e.id == id);

    _actionLoading = true;
    update();

    try {
      final response = await _repository.updateLocation(
        id: id,
        title: address.title,
        address: address.address,
        latitude: address.latitude,
        longitude: address.longitude,
        isDefault: true,
      );

      if (!response.isSuccess) {
        return false;
      }

      await loadAddresses();
      return true;
    } finally {
      _actionLoading = false;
      update();
    }
  }
}
