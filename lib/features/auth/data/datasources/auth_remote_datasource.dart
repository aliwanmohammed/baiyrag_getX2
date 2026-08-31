// import 'package:bhm_supermarket/core/network/dio_exception_mapper.dart';
// import 'package:bhm_supermarket/core/services/secure_storage_service.dart';
// import 'package:dio/dio.dart';

// import '../../../../core/api/api_endpoints.dart';
// import '../../../../core/datasource/base_remote_datasource.dart';
// import '../../../../core/network/api_response.dart';
// import '../../../../core/utils/json_parser.dart';
// import '../../models/user_model.dart';

// class AuthRemoteDataSource extends BaseRemoteDataSource {
//   AuthRemoteDataSource(super.dio);

//   Future<ApiResponse<UserModel>> register({
//     required String name,
//     required String phone,
//     required String email,
//     required String password,
//     required String passwordConfirmation,
//     String role = 'customer',
//   }) async {
//     try {
//       final body = <String, dynamic>{
//         'name': name,
//         'phone': phone,
//         'email': email,
//         'password': password,
//         'password_confirmation': passwordConfirmation,
//       };
//       // Only send role when it is explicitly non-customer.
//       if (role != 'customer') {
//         body['role'] = role;
//       }

//       final response = await dio.post(ApiEndpoints.authRegister, data: body);

//       final user = UserModel.fromJson({
//         ...response.data["user"],
//         "token": null,
//       });

//       return ApiResponse.success(
//         user,
//         message: response.data["message"] ?? "",
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return apiResponseFromDioError(e);
//     }
//   }

//   Future<ApiResponse<UserModel>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await dio.post(
//         ApiEndpoints.authLogin,
//         data: {"email": email, "password": password},
//       );

//       return ApiResponse.success(
//         _parseLogin(response.data),
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return apiResponseFromDioError(e);
//     }
//   }

//   UserModel _parseLogin(dynamic json) {
//     final map = JsonParser.map(json);

//     final user = JsonParser.map(map["user"]);

//     final token = JsonParser.map(map["token"]);

//     final original = JsonParser.map(token["original"]);

//     return UserModel(
//       id: user["id"].toString(),
//       name: user["name"] ?? "",
//       email: user["email"] ?? "",
//       phone: user["phone"] ?? "",
//       role: UserRole.values.firstWhere(
//         (e) => e.name == (user["role"] ?? "customer"),
//         orElse: () => UserRole.customer,
//       ),
//       token: original["access_token"],
//     );
//   }

//   Future<ApiResponse<void>> logout() async {
//     try {
//       final response = await dio.post(ApiEndpoints.authLogout);

//       return ApiResponse.success(
//         null,
//         message: response.data["message"] ?? "",
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return apiResponseFromDioError(e);
//     }
//   }

//   Future<ApiResponse<UserModel>> me() async {
//     try {
//       final response = await dio.post(ApiEndpoints.me);

//       final storedToken = await SecureStorageService.instance.readToken();

//       final map = JsonParser.map(response.data);

//       return ApiResponse.success(
//         UserModel(
//           id: map["id"].toString(),
//           name: map["name"] ?? "",
//           email: map["email"] ?? "",
//           phone: map["phone"],
//           role: UserRole.values.firstWhere(
//             (e) => e.name == (map["role"] ?? "customer"),
//             orElse: () => UserRole.customer,
//           ),
//           token: storedToken,
//         ),
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return apiResponseFromDioError(e);
//     }
//   }
// }

import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/utils/json_parser.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSource extends BaseRemoteDataSource {
  AuthRemoteDataSource(super.dio);

  // ===========================================================================
  // Register
  // ===========================================================================

  Future<ApiResponse<UserModel>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'customer',
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      if (role != 'customer') {
        body['role'] = role;
      }

      final response = await dio.post(
        ApiEndpoints.authRegister,
        data: body,
      );

      final map = JsonParser.map(response.data);
      final user = JsonParser.map(map['user']);

      return ApiResponse.success(
        UserModel.fromJson({
          ...user,
          'token': null,
        }),
        message: JsonParser.string(map['message']),
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return apiResponseFromDioError(e);
    } catch (_) {
      return ApiResponse.failure(
        'فشل تحليل بيانات التسجيل',
      );
    }
  }

  // ===========================================================================
  // Login
  // ===========================================================================

  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      final map = JsonParser.map(response.data);
      final accessToken = _extractAccessToken(map);

      if (accessToken.isEmpty) {
        return ApiResponse.failure(
          'لم يتم استلام رمز الدخول من الخادم',
          statusCode: response.statusCode,
        );
      }

      // Current backend response:
      // {
      //   access_token: '...',
      //   user: {...}
      // }
      // Older backend response may wrap user/token in nested objects.
      final userMap = _extractUserMap(map);

      if (userMap.isEmpty) {
        return ApiResponse.failure(
          'تم تسجيل الدخول لكن بيانات المستخدم غير مكتملة',
          statusCode: response.statusCode,
        );
      }

      final userModel = UserModel.fromJson({
        ...userMap,
        'token': accessToken,
      });

      return ApiResponse.success(
        userModel,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return apiResponseFromDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        'فشل تحليل بيانات تسجيل الدخول',
      );
    }
  }

  // ===========================================================================
  // Logout
  // ===========================================================================

  Future<ApiResponse<void>> logout() async {
    try {
      final response = await dio.post(
        ApiEndpoints.authLogout,
      );

      final map = JsonParser.map(response.data);

      return ApiResponse.success(
        null,
        message: JsonParser.string(map['message']),
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return apiResponseFromDioError(e);
    }
  }

  // ===========================================================================
  // Current User
  // ===========================================================================

  Future<ApiResponse<UserModel>> me() async {
    try {
      final response = await dio.post(ApiEndpoints.me);

      final root = JsonParser.map(response.data);
      final map = root['data'] is Map
          ? JsonParser.map(root['data'])
          : root;
      final storedToken = await SecureStorageService.instance.readToken();

      return ApiResponse.success(
        UserModel.fromJson({
          ...map,
          'token': storedToken,
        }),
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return apiResponseFromDioError(e);
    } catch (_) {
      return ApiResponse.failure(
        'فشل تحليل بيانات المستخدم',
      );
    }
  }

  String _extractAccessToken(Map<String, dynamic> root) {
    final direct = JsonParser.string(root['access_token']);
    if (direct.isNotEmpty) return direct;

    final data = JsonParser.map(root['data']);
    final dataToken = JsonParser.string(data['access_token']);
    if (dataToken.isNotEmpty) return dataToken;

    final token = JsonParser.map(root['token']);
    final tokenDirect = JsonParser.string(token['access_token']);
    if (tokenDirect.isNotEmpty) return tokenDirect;

    final original = JsonParser.map(token['original']);
    return JsonParser.string(original['access_token']);
  }

  Map<String, dynamic> _extractUserMap(Map<String, dynamic> root) {
    final direct = JsonParser.map(root['user']);
    if (direct.isNotEmpty) return direct;

    final data = JsonParser.map(root['data']);
    final nested = JsonParser.map(data['user']);
    if (nested.isNotEmpty) return nested;

    // Some responses return the user itself at the root/data level.
    if (data.containsKey('id') || data.containsKey('email')) {
      return data;
    }
    if (root.containsKey('id') || root.containsKey('email')) {
      return root;
    }

    return const {};
  }
}
