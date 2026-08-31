import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigator.dart';
import '../../../app/router/app_routes.dart';
import '../../services/secure_storage_service.dart';

/// Adds the stored Bearer token when one exists.
///
/// Important for Guest mode:
/// A 401 does NOT automatically mean "login required".
/// Only treat it as an expired session when a local token actually exists.
class AuthInterceptor extends Interceptor {
  static bool _redirectingToLogin = false;

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

    final language = await storage.readLanguage();
    options.headers['Accept-Language'] = language;

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

    final path = err.requestOptions.path;
    final isLogoutRequest = path == '/logout' || path.endsWith('/logout');

    // Logout 401 is not a navigation event.
    if (isLogoutRequest) {
      handler.next(err);
      return;
    }

    // A 401 from a public/catalog/content endpoint must never log the
    // customer out. This is especially important when the backend has a
    // route-level auth configuration issue (for example /about-us).
    if (!_isSessionProtectedPath(path)) {
      handler.next(err);
      return;
    }

    // Critical Guest rule:
    // No stored token = this is a normal unauthenticated request.
    final token = await SecureStorageService.instance.readToken();

    if (token == null || token.isEmpty) {
      handler.next(err);
      return;
    }

    // A 401 from a genuinely protected endpoint means the current token
    // has been rejected. Treat it as an expired/invalid session.
    await SecureStorageService.instance.clearAll();

    if (!_redirectingToLogin) {
      _redirectingToLogin = true;

      final context = rootNavigatorKey.currentContext;

      if (context != null && context.mounted) {
        final router = GoRouter.of(context);
        final currentLocation = router.state.uri.toString();

        final isAlreadyLogin = currentLocation == AppRoutes.login ||
            currentLocation.startsWith('${AppRoutes.login}?');

        if (!isAlreadyLogin) {
          final redirect = Uri.encodeComponent(currentLocation);

          context.go(
            '${AppRoutes.login}?redirect=$redirect',
          );
        }
      }

      // Prevent multiple simultaneous 401 responses
      // from causing repeated navigation.
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        _redirectingToLogin = false;
      });
    }

    handler.next(err);
  }

  bool _isSessionProtectedPath(String path) {
    final normalized = path.toLowerCase();

    const exactProtected = {
      '/me',
      '/logout',
      '/refresh',
      '/orders',
      '/my-orders',
      '/favorites',
      '/notifications',
      '/addresses',
      '/locations',
      '/checkout',
      '/profile',
    };

    if (exactProtected.contains(normalized)) return true;

    // Protected resource families.
    return normalized.startsWith('/orders/') ||
        normalized.startsWith('/favorites/') ||
        normalized.startsWith('/addresses/') ||
        normalized.startsWith('/locations/') ||
        normalized.startsWith('/notifications/') ||
        normalized.startsWith('/checkout/') ||
        normalized.startsWith('/delivery/');
  }

}
