import '../../../../core/network/api_response.dart';
import '../../models/user_model.dart';

abstract class AuthRepository {
  Future<ApiResponse<UserModel>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,

    /// Role sent to the API. Defaults to 'customer'.
    /// Pass 'delivery' from admin screens when creating driver accounts.
    String role = 'customer',
  });

  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  });

  Future<ApiResponse<void>> logout();

  Future<UserModel?> loadStoredUser();
}
