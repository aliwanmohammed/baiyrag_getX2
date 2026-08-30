import '../../../../core/network/api_response.dart';
import '../../domain/repositories/offers_repository.dart';
import '../../models/offer_model.dart';
import '../datasources/offers_remote_datasource.dart';

class OffersRepositoryImpl implements OffersRepository {
  final OffersRemoteDataSource _remote;

  OffersRepositoryImpl(this._remote);

  @override
  Future<ApiResponse<List<OfferModel>>> getOffers() => _remote.fetchOffers();

  @override
  Future<ApiResponse<OfferModel>> getOfferById(String id) =>
      _remote.fetchOfferById(id);
}
