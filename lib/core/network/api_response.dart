import '../utils/json_parser.dart';

/// Standard Laravel envelope:
/// `{ "success": true, "message": "...", "data": ... }`
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  bool get isSuccess => success;
  bool get isFailure => !success;
  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422;
  bool get isServerError => (statusCode ?? 0) >= 500;

  factory ApiResponse.success(T data, {String message = '', int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure(String message, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromEnvelope(
    dynamic raw, {
    required T Function(dynamic json) parser,
    int? statusCode,
  }) {
    final map = JsonParser.map(raw);

    try {
      // الشكل الأول:
      // {
      //   success: true,
      //   message: "",
      //   data: {}
      // }
      if (map.containsKey('success')) {
        final success = JsonParser.boolValue(map['success']);
        final message = JsonParser.string(map['message']);

        if (!success) {
          return ApiResponse<T>.failure(message, statusCode: statusCode);
        }

        return ApiResponse<T>.success(
          parser(map['data']),
          message: message,
          statusCode: statusCode,
        );
      }

      // الشكل الثاني:
      // {
      //   data: [],
      //   links: {},
      //   meta: {}
      // }
      if (map.containsKey('data')) {
        return ApiResponse<T>.success(
          parser(map['data']),
          statusCode: statusCode,
        );
      }

      // الشكل الثالث:
      // []
      if (raw is List) {
        return ApiResponse<T>.success(parser(raw), statusCode: statusCode);
      }

      return ApiResponse<T>.failure(
        'صيغة البيانات غير معروفة',
        statusCode: statusCode,
      );
    } catch (_) {
      return ApiResponse<T>.failure(
        'فشل تحليل البيانات',
        statusCode: statusCode,
      );
    }
  }

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onError,
  }) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    }

    return onError(message.isNotEmpty ? message : 'حدث خطأ غير متوقع');
  }
}
