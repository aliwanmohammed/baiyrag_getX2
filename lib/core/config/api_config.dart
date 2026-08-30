/// Central API configuration.
///
/// **Single branch today** — one global [baseUrl].
/// **Multi-branch tomorrow** — inject a branch-specific [baseUrl] via
/// [ApiClient.forBaseUrl] without rewriting datasources or repositories.
class ApiConfig {
  ApiConfig._();

  /// Laravel API root (includes `/api` prefix).
  static const String baseUrl = 'https://backend-albarqy.onrender.com/api';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 20);

  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Accept-Language': 'ar',
  };
}
