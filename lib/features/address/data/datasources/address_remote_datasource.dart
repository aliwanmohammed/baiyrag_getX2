import '../../../../core/api/api_endpoints.dart';
import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_parser.dart';
import '../../models/address_model.dart';

class AddressRemoteDataSource extends BaseRemoteDataSource {
  AddressRemoteDataSource(super.dio);

  Future<ApiResponse<List<AddressModel>>> getLocations() =>
      getPaginated<List<AddressModel>>(
        ApiEndpoints.locations,
        parser: (json) => JsonParser.list(json, AddressModel.fromJson),
      );

  Future<ApiResponse<AddressModel>> createLocation({
    required String title,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) {
    final data = <String, dynamic>{
      "title": title,
      "address": address,
      "is_default": isDefault,
    };

    if (latitude != null) {
      data["latitude"] = latitude;
    }

    if (longitude != null) {
      data["longitude"] = longitude;
    }

    return postEnvelope<AddressModel>(
      ApiEndpoints.locations,
      data: data,
      parser: (json) => AddressModel.fromJson(JsonParser.map(json)),
    );
  }

  Future<ApiResponse<AddressModel>> updateLocation({
    required String id,
    required String title,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) {
    final data = <String, dynamic>{
      "title": title,
      "address": address,
      "is_default": isDefault,
    };

    if (latitude != null) {
      data["latitude"] = latitude;
    }

    if (longitude != null) {
      data["longitude"] = longitude;
    }

    return putEnvelope<AddressModel>(
      "${ApiEndpoints.locations}/$id",
      data: data,
      parser: (json) => AddressModel.fromJson(JsonParser.map(json)),
    );
  }

  Future<ApiResponse<void>> deleteLocation(String id) =>
      deleteEnvelope("${ApiEndpoints.locations}/$id");
}
