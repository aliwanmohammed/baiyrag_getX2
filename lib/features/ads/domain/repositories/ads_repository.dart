import '../../../../core/network/api_response.dart';
import '../../models/ad_model.dart';

abstract class AdsRepository {
  Future<ApiResponse<List<AdModel>>> getAds();
}
