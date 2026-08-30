import '../../../../core/network/api_response.dart';
import '../../models/address_model.dart';

abstract class AddressRepository {
  Future<ApiResponse<List<AddressModel>>> getLocations();

  Future<ApiResponse<AddressModel>> createLocation({
    required String title,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault,
  });

  Future<ApiResponse<AddressModel>> updateLocation({
    required String id,
    required String title,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault,
  });

  Future<ApiResponse<void>> deleteLocation(String id);
}
