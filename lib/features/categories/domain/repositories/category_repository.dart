import '../../../../core/models/category_model.dart';
import '../../../../core/network/api_response.dart';

abstract class CategoryRepository {
  Future<ApiResponse<List<CategoryModel>>> getCategories();
}
