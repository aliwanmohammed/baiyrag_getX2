import 'package:flutter/foundation.dart';

/// Converts backend/network errors into safe Arabic messages for the UI.
/// Raw exceptions are intentionally never returned to users.
class AppErrorMessage {
  AppErrorMessage._();

  static String from({
    String? message,
    int? statusCode,
    String fallback = 'حدث خطأ غير متوقع. حاول مرة أخرى.',
  }) {
    final status = statusCode ?? 0;
    if (status == 401) return 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    if (status == 403) return 'ليست لديك صلاحية لتنفيذ هذا الإجراء.';
    if (status == 404) return 'البيانات المطلوبة غير موجودة.';
    if (status == 422) return 'البيانات المدخلة غير صحيحة.';
    if (status >= 500) return 'حدث خطأ في الخادم. حاول مرة أخرى لاحقاً.';

    final value = message?.trim() ?? '';
    if (value.isEmpty) return fallback;

    // Allow only known, intentionally user-facing Arabic messages.
    // Everything else is replaced with a safe generic message.
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(value);
    final looksTechnical = RegExp(
      r'(Exception|DioException|SocketException|Stack|TypeError|'
      r'Failed to fetch|Unauthorized|Undefined|SQL|HTTP\s+\d+|'
      r'FormatException|LateInitializationError)',
      caseSensitive: false,
    ).hasMatch(value);

    if (hasArabic && !looksTechnical) return value;

    if (kDebugMode) {
      debugPrint('[AppErrorMessage] sanitized backend message: $value');
    }
    return fallback;
  }
}
