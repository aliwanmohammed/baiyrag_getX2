import '../../../../core/network/api_response.dart';
import '../../../../core/pagination/pagination_meta.dart';
import '../../models/about_us_model.dart';
import '../../models/contact_info_model.dart';
import '../../models/faq_model.dart';
import '../../models/privacy_policy_model.dart';

abstract class InfoRepository {
  Future<ApiResponse<PaginatedResult<List<AboutUsModel>>>> getAboutUs({int page = 1, String? search, bool? status, int perPage = 10});
  Future<ApiResponse<PaginatedResult<List<ContactInfoModel>>>> getContactInfos({int page = 1, String? search, String? type, bool? status, int perPage = 10});
  Future<ApiResponse<PaginatedResult<List<FaqModel>>>> getFaqs({int page = 1, String? search, bool? status, int perPage = 10});
  Future<ApiResponse<PaginatedResult<List<PrivacyPolicyModel>>>> getPrivacyPolicies({int page = 1, String? search, bool? status, int perPage = 10});
}
