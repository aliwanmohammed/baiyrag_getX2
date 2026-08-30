import '../../../../core/models/category_model.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._remote);

  final CategoryRemoteDataSource _remote;

  @override
  Future<ApiResponse<List<CategoryModel>>> getCategories() =>
      _remote.fetchCategories();
}
