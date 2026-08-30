import '../../../../core/network/api_response.dart';
import '../../models/address_model.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this._remote);

  final AddressRemoteDataSource _remote;

  @override
  Future<ApiResponse<List<AddressModel>>> getLocations() =>
      _remote.getLocations();

  @override
  Future<ApiResponse<AddressModel>> createLocation({
    required String title,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) =>
      _remote.createLocation(
        title: title,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

  @override
  Future<ApiResponse<AddressModel>> updateLocation({
    required String id,
    required String title,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) =>
      _remote.updateLocation(
        id: id,
        title: title,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

  @override
  Future<ApiResponse<void>> deleteLocation(String id) =>
      _remote.deleteLocation(id);
}
