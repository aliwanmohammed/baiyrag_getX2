import '../../../../core/api/api_endpoints.dart';
import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_parser.dart';

import '../../models/ad_model.dart';

class AdsRemoteDataSource extends BaseRemoteDataSource {
  AdsRemoteDataSource(super.dio);

  Future<ApiResponse<List<AdModel>>> fetchAds() {
    return getPaginated<List<AdModel>>(
      ApiEndpoints.ads,
      query: {'paginate': false, 'is_active': true},
      parser: (json) => JsonParser.list(json, AdModel.fromJson),
    );
  }
}
