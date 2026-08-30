import '../../../../core/api/api_endpoints.dart';
import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_parser.dart';
import '../../models/offer_model.dart';

class OffersRemoteDataSource extends BaseRemoteDataSource {
  OffersRemoteDataSource(super.dio);

  /// GET /api/offers
  Future<ApiResponse<List<OfferModel>>> fetchOffers() {
    return getPaginated<List<OfferModel>>(
      ApiEndpoints.offers,
      parser: (json) => JsonParser.list(json, OfferModel.fromJson),
    );
  }

  /// GET /api/offers/{id}
  Future<ApiResponse<OfferModel>> fetchOfferById(String id) {
    return getEnvelope<OfferModel>(
      ApiEndpoints.offer(id),
      parser: (json) => OfferModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : {},
      ),
    );
  }
}
