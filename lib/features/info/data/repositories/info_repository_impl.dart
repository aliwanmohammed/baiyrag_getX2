import '../../../../core/network/api_response.dart';
import '../../../../core/pagination/pagination_meta.dart';
import '../../models/about_us_model.dart';
import '../../models/contact_info_model.dart';
import '../../models/faq_model.dart';
import '../../models/privacy_policy_model.dart';
import '../../domain/repositories/info_repository.dart';
import '../datasources/info_remote_datasource.dart';

class InfoRepositoryImpl implements InfoRepository {
  InfoRepositoryImpl(this._remote);
  final InfoRemoteDataSource _remote;
  @override Future<ApiResponse<PaginatedResult<List<AboutUsModel>>>> getAboutUs({int page=1,String? search,bool? status,int perPage=10}) => _remote.fetchAboutUs(page:page,search:search,status:status,perPage:perPage);
  @override Future<ApiResponse<PaginatedResult<List<ContactInfoModel>>>> getContactInfos({int page=1,String? search,String? type,bool? status,int perPage=10}) => _remote.fetchContactInfos(page:page,search:search,type:type,status:status,perPage:perPage);
  @override Future<ApiResponse<PaginatedResult<List<FaqModel>>>> getFaqs({int page=1,String? search,bool? status,int perPage=10}) => _remote.fetchFaqs(page:page,search:search,status:status,perPage:perPage);
  @override Future<ApiResponse<PaginatedResult<List<PrivacyPolicyModel>>>> getPrivacyPolicies({int page=1,String? search,bool? status,int perPage=10}) => _remote.fetchPrivacyPolicies(page:page,search:search,status:status,perPage:perPage);
}
