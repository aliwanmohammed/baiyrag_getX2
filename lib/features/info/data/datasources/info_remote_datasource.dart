import '../../../../core/api/api_endpoints.dart';
import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/pagination/pagination_meta.dart';
import '../../../../core/utils/json_parser.dart';
import '../../models/about_us_model.dart';
import '../../models/contact_info_model.dart';
import '../../models/faq_model.dart';
import '../../models/privacy_policy_model.dart';

class InfoRemoteDataSource extends BaseRemoteDataSource {
  InfoRemoteDataSource(super.dio);

  Map<String, dynamic> _query({int page = 1, String? search, bool? status, String? type, int perPage = 10}) => {
    if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    if (status != null) 'status': status,
    if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
    'paginate': true,
    'per_page': perPage,
    'page': page,
  };

  Future<ApiResponse<PaginatedResult<List<AboutUsModel>>>> fetchAboutUs({int page = 1, String? search, bool? status, int perPage = 10}) => getWithMeta<List<AboutUsModel>>(ApiEndpoints.aboutUs, query: _query(page: page, search: search, status: status, perPage: perPage), parser: (json) => JsonParser.list(json, AboutUsModel.fromJson));

  Future<ApiResponse<PaginatedResult<List<ContactInfoModel>>>> fetchContactInfos({int page = 1, String? search, String? type, bool? status, int perPage = 10}) => getWithMeta<List<ContactInfoModel>>(ApiEndpoints.contactInfos, query: _query(page: page, search: search, type: type, status: status, perPage: perPage), parser: (json) => JsonParser.list(json, ContactInfoModel.fromJson));

  Future<ApiResponse<PaginatedResult<List<FaqModel>>>> fetchFaqs({int page = 1, String? search, bool? status, int perPage = 10}) => getWithMeta<List<FaqModel>>(ApiEndpoints.faqs, query: _query(page: page, search: search, status: status, perPage: perPage), parser: (json) => JsonParser.list(json, FaqModel.fromJson));

  Future<ApiResponse<PaginatedResult<List<PrivacyPolicyModel>>>> fetchPrivacyPolicies({int page = 1, String? search, bool? status, int perPage = 10}) => getWithMeta<List<PrivacyPolicyModel>>(ApiEndpoints.privacyPolicies, query: _query(page: page, search: search, status: status, perPage: perPage), parser: (json) => JsonParser.list(json, PrivacyPolicyModel.fromJson));
}
