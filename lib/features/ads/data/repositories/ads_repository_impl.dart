import '../../../../core/network/api_response.dart';

import '../../models/ad_model.dart';
import '../../domain/repositories/ads_repository.dart';
import '../datasources/ads_remote_datasource.dart';

class AdsRepositoryImpl implements AdsRepository {
  AdsRepositoryImpl(this.remote);

  final AdsRemoteDataSource remote;

  @override
  Future<ApiResponse<List<AdModel>>> getAds() {
    return remote.fetchAds();
  }
}
