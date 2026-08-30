import '../../../../core/network/api_response.dart';
import '../../models/offer_model.dart';

abstract class OffersRepository {
  Future<ApiResponse<List<OfferModel>>> getOffers();
  Future<ApiResponse<OfferModel>> getOfferById(String id);
}
