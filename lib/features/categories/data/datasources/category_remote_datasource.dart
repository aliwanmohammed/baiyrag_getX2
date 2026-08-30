import '../../../../core/api/api_endpoints.dart';
import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/models/category_model.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_parser.dart';

class CategoryRemoteDataSource extends BaseRemoteDataSource {
  CategoryRemoteDataSource(super.dio);

  Future<ApiResponse<List<CategoryModel>>> fetchCategories() =>
      getPaginated<List<CategoryModel>>(
        ApiEndpoints.categories,
        parser: (json) => JsonParser.list(json, CategoryModel.fromJson),
      );
}
