import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigator.dart';
import '../../../app/router/app_routes.dart';
import '../../api/api_endpoints.dart';
import '../../services/secure_storage_service.dart';

/// Adds the stored Bearer token and transparently refreshes an expired token.
///
/// The backend issues short-lived access tokens (the current response exposes
/// `expires_in: 3600`), so a valid stored session must not be treated as a
/// logout merely because the access token expired.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio);

  final Dio _dio;

  static bool _redirectingToLogin = false;
  Future<String?>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final storage = SecureStorageService.instance;
    final token = await storage.readToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }

    options.headers['Accept-Language'] = await storage.readLanguage();
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final path = _normalize(err.requestOptions.path);

    // Login/logout/refresh 401s are not session-refresh candidates.
    if (path == '/login' || path == '/logout' || path == '/refresh') {
      handler.next(err);
      return;
    }

    if (!_isSessionProtectedPath(path)) {
      handler.next(err);
      return;
    }

    final storage = SecureStorageService.instance;
    final token = await storage.readToken();

    // Guest request: a 401 is simply an unauthenticated response.
    if (token == null || token.isEmpty) {
      handler.next(err);
      return;
    }

    // Never retry the same request more than once.
    if (err.requestOptions.extra['authRetry'] == true) {
      await _expireSessionAndRedirect();
      handler.next(err);
      return;
    }

    try {
      final refreshedToken = await _refreshAccessToken();

      if (refreshedToken == null || refreshedToken.isEmpty) {
        await _expireSessionAndRedirect();
        handler.next(err);
        return;
      }

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $refreshedToken';
      retryOptions.extra['authRetry'] = true;

      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
      return;
    } catch (_) {
      await _expireSessionAndRedirect();
      handler.next(err);
    }
  }

  Future<String?> _refreshAccessToken() {
    final existing = _refreshFuture;
    if (existing != null) return existing;

    final future = _performRefresh();
    _refreshFuture = future;

    future.whenComplete(() {
      if (identical(_refreshFuture, future)) {
        _refreshFuture = null;
      }
    });

    return future;
  }

  Future<String?> _performRefresh() async {
    try {
      final response = await _dio.post(
        ApiEndpoints.refresh,
        options: Options(
          extra: const {'authRefreshRequest': true},
        ),
      );

      final data = response.data;
      if (data is! Map) return null;

      final token = data['access_token']?.toString();
      if (token == null || token.isEmpty) return null;

      await SecureStorageService.instance.saveToken(token);
      return token;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _expireSessionAndRedirect() async {
    await SecureStorageService.instance.clearAll();

    if (_redirectingToLogin) return;
    _redirectingToLogin = true;

    try {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        final router = GoRouter.of(context);
        final currentLocation = router.state.uri.toString();

        final isAlreadyLogin = currentLocation == AppRoutes.login ||
            currentLocation.startsWith('${AppRoutes.login}?');

        if (!isAlreadyLogin) {
          final redirect = Uri.encodeComponent(currentLocation);
          context.go('${AppRoutes.login}?redirect=$redirect');
        }
      }
    } finally {
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        _redirectingToLogin = false;
      });
    }
  }

  bool _isSessionProtectedPath(String path) {
    const exactProtected = {
      '/me',
      '/logout',
      '/orders',
      '/my-orders',
      '/favorites',
      '/notifications',
      '/addresses',
      '/locations',
      '/checkout',
      '/profile',
      '/cart',
    };

    if (exactProtected.contains(path)) return true;

    return path.startsWith('/orders/') ||
        path.startsWith('/favorites/') ||
        path.startsWith('/addresses/') ||
        path.startsWith('/locations/') ||
        path.startsWith('/notifications/') ||
        path.startsWith('/checkout/') ||
        path.startsWith('/delivery/') ||
        path == '/cart';
  }

  String _normalize(String path) {
    final value = path.trim().toLowerCase();
    if (value.isEmpty) return '/';
    final withoutQuery = value.split('?').first;
    if (withoutQuery.length > 1 && withoutQuery.endsWith('/')) {
      return withoutQuery.substring(0, withoutQuery.length - 1);
    }
    return withoutQuery;
  }
}
