import '../../../../core/network/api_response.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../models/user_model.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  @override
  Future<ApiResponse<UserModel>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'customer',
  }) async {
    final response = await _remote.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
    );

    // Backend currently doesn't return access_token after register.
    // We login automatically to obtain the token.

    if (response.isSuccess) {
      return await login(email: email, password: password);
    }
    return response;
  }

  @override
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await _remote.login(email: email, password: password);
    if (response.isSuccess && response.data != null) {
      final user = response.data!;
      await _storage.saveUserProfile(user);
    }

    return response;
  }

  @override
  Future<ApiResponse<void>> logout() async {
    final response = await _remote.logout();
    await _storage.clearAll();
    return response;
  }

  @override
  Future<UserModel?> loadStoredUser() async {
    final token = await _storage.readToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await _remote.me();

    if (response.isSuccess && response.data != null) {
      await _storage.saveUserProfile(response.data!);
      return response.data;
    }

    await _storage.clearAll();
    return null;
  }
}
