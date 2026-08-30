// import 'package:dio/dio.dart';

// import '../network/api_response.dart';
// import 'app_exception.dart';

// AppException mapDioException(DioException error) {
//   final status = error.response?.statusCode;
//   final body = error.response?.data;

//   // نحاول أولاً استخراج رسالة مفهومة من الـ Backend.
//   final extractedMessage = _extractUserMessage(body);

//   switch (error.type) {
//     case DioExceptionType.connectionTimeout:
//     case DioExceptionType.sendTimeout:
//     case DioExceptionType.receiveTimeout:
//       return const TimeoutException();

//     case DioExceptionType.connectionError:
//       return const NetworkException();

//     default:
//       break;
//   }

//   switch (status) {
//     case 400:
//       return ValidationException(
//         extractedMessage ?? 'البيانات المرسلة غير صحيحة',
//       );

//     case 401:
//       return const UnauthorizedException();

//     case 403:
//       return ValidationException(
//         extractedMessage ?? 'ليس لديك صلاحية لتنفيذ هذه العملية',
//       );

//     case 404:
//       return const NotFoundException();

//     case 422:
//       return ValidationException(
//         extractedMessage ?? 'يرجى التحقق من البيانات المدخلة',
//       );

//     default:
//       // أي خطأ 500 أو خطأ غير معروف:
//       // لا نعرض رسالة Laravel الخام للمستخدم.
//       if (status != null && status >= 500) {
//         return const ServerException(
//           'حدث خطأ في الخادم، حاول مرة أخرى لاحقاً',
//         );
//       }

//       return const ServerException(
//         'حدث خطأ غير متوقع، حاول مرة أخرى',
//       );
//   }
// }

// ApiResponse<T> apiResponseFromDioError<T>(DioException error) {
//   final exception = mapDioException(error);

//   return ApiResponse.failure(
//     exception.message,
//     statusCode: error.response?.statusCode,
//   );
// }

// /// استخراج رسالة مناسبة للمستخدم من استجابة Laravel.
// String? _extractUserMessage(dynamic body) {
//   if (body is! Map) {
//     return null;
//   }

//   final map = Map<String, dynamic>.from(body);

//   // ─────────────────────────────────────────────────────────────
//   // message
//   // ─────────────────────────────────────────────────────────────

//   final rawMessage = map['message'];

//   if (rawMessage != null) {
//     final message = _sanitizeMessage(rawMessage.toString());

//     if (message != null) {
//       return message;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // errors
//   // ─────────────────────────────────────────────────────────────

//   final errors = map['errors'];

//   if (errors is Map) {
//     for (final entry in errors.entries) {
//       final field = entry.key.toString();
//       final value = entry.value;

//       final message = _extractFieldError(
//         field: field,
//         value: value,
//       );

//       if (message != null) {
//         return message;
//       }
//     }
//   }

//   return null;
// }

// /// استخراج أول رسالة مفيدة من خطأ حقل معين.
// String? _extractFieldError({
//   required String field,
//   required dynamic value,
// }) {
//   String? raw;

//   if (value is List && value.isNotEmpty) {
//     raw = value.first?.toString();
//   } else if (value != null) {
//     raw = value.toString();
//   }

//   if (raw == null || raw.trim().isEmpty) {
//     return null;
//   }

//   // أخطاء تقنية لا نريد عرضها للمستخدم.
//   final sanitized = _sanitizeMessage(raw);

//   if (sanitized != null) {
//     return sanitized;
//   }

//   // إذا لم نستطع تحويل الرسالة، نحاول بناء رسالة مفهومة
//   // اعتماداً على اسم الحقل.
//   return _fieldMessage(field);
// }

// /// تنظيف رسالة الـ Backend ومنع ظهور أسماء الحقول/الأخطاء التقنية.
// String? _sanitizeMessage(String message) {
//   final value = message.trim();

//   if (value.isEmpty) {
//     return null;
//   }

//   final lower = value.toLowerCase();

//   // ─────────────────────────────────────────────────────────────
//   // أخطاء تقنية معروفة
//   // ─────────────────────────────────────────────────────────────

//   if (lower.contains('email_verified_at') ||
//       lower.contains('attempt to read property') ||
//       lower.contains('undefined property') ||
//       lower.contains('undefined variable') ||
//       lower.contains('sqlstate') ||
//       lower.contains('syntax error') ||
//       lower.contains('queryexception') ||
//       lower.contains('undefined index') ||
//       lower.contains('stack trace') ||
//       lower.contains('exception')) {
//     return null;
//   }

//   // Laravel/PHP errors التقنية.
//   if (lower.contains('trying to access array offset') ||
//       lower.contains('call to a member function') ||
//       lower.contains('internal server error')) {
//     return null;
//   }

//   // رسائل Laravel العامة التي لا تفيد المستخدم.
//   if (lower == 'server error' ||
//       lower == 'internal server error' ||
//       lower == 'something went wrong') {
//     return null;
//   }

//   return value;
// }

// /// تحويل أسماء الحقول إلى رسائل عربية مفهومة.
// String? _fieldMessage(String field) {
//   switch (field) {
//     case 'email':
//       return 'البريد الإلكتروني غير صحيح أو غير مسجل';

//     case 'password':
//       return 'كلمة المرور غير صحيحة';

//     case 'password_confirmation':
//       return 'تأكيد كلمة المرور غير مطابق';

//     case 'phone':
//       return 'رقم الهاتف غير صحيح';

//     case 'name':
//       return 'الاسم مطلوب';

//     case 'address':
//       return 'العنوان مطلوب';

//     case 'location_id':
//       return 'يرجى اختيار عنوان التوصيل';

//     case 'payment_method':
//       return 'طريقة الدفع غير صحيحة';

//     case 'items':
//       return 'يرجى التحقق من المنتجات في السلة';

//     case 'coupon_code':
//       return 'كود الكوبون غير صحيح';

//     default:
//       return null;
//   }
// }

import 'package:dio/dio.dart';

import 'api_response.dart';
import 'app_exception.dart';

AppException mapDioException(DioException error) {
  // ─────────────────────────────────────────────────────────────
  // أخطاء الاتصال
  // ─────────────────────────────────────────────────────────────

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutException();

    case DioExceptionType.connectionError:
      return const NetworkException();

    default:
      break;
  }

  final status = error.response?.statusCode;
  final body = error.response?.data;

  // نحتفظ بالرسالة الأصلية للـ log فقط.
  final rawMessage =
      _extractMessage(body) ?? error.message ?? 'حدث خطأ غير متوقع';

  // ─────────────────────────────────────────────────────────────
  // 401 — غير مصرح
  // ─────────────────────────────────────────────────────────────

  if (status == 401) {
    return const UnauthorizedException();
  }

  // ─────────────────────────────────────────────────────────────
  // 404 — غير موجود
  // ─────────────────────────────────────────────────────────────

  if (status == 404) {
    return const NotFoundException();
  }

  // ─────────────────────────────────────────────────────────────
  // 422 — أخطاء التحقق من البيانات
  // ─────────────────────────────────────────────────────────────

  if (status == 422) {
    final validationMessage = _extractValidationMessage(body);

    return ValidationException(
      validationMessage ?? 'البيانات المدخلة غير صحيحة',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 400 — طلب غير صحيح
  // ─────────────────────────────────────────────────────────────

  if (status == 400) {
    return ValidationException(
      _friendlyMessage(rawMessage) ?? 'البيانات المدخلة غير صحيحة',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 403 — ممنوع
  // ─────────────────────────────────────────────────────────────

  if (status == 403) {
    return ValidationException(
      _friendlyMessage(rawMessage) ?? 'ليس لديك صلاحية لتنفيذ هذه العملية',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 500+ — خطأ في الخادم
  //
  // لا نعرض رسالة Laravel التقنية للمستخدم.
  // ─────────────────────────────────────────────────────────────

  if (status != null && status >= 500) {
    return const ServerException(
      'حدث خطأ في الخادم، حاول مرة أخرى لاحقاً',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // أي خطأ آخر
  // ─────────────────────────────────────────────────────────────

  return ServerException(
    _friendlyMessage(rawMessage) ?? 'حدث خطأ غير متوقع',
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// تحويل DioException إلى ApiResponse
// ══════════════════════════════════════════════════════════════════════════════

ApiResponse<T> apiResponseFromDioError<T>(DioException error) {
  final exception = mapDioException(error);

  return ApiResponse.failure(
    exception.message,
    statusCode: error.response?.statusCode,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// استخراج رسالة Laravel
// ══════════════════════════════════════════════════════════════════════════════

String? _extractMessage(dynamic body) {
  if (body is! Map) {
    return null;
  }

  final map = Map<String, dynamic>.from(body);

  final message = map['message'];

  if (message != null && message.toString().trim().isNotEmpty) {
    return message.toString().trim();
  }

  return null;
}

// ══════════════════════════════════════════════════════════════════════════════
// استخراج أخطاء Laravel Validation
// ══════════════════════════════════════════════════════════════════════════════
//
// Laravel غالباً يرجع:
//
// {
//   "message": "The email field is required.",
//   "errors": {
//     "email": [
//       "The email field is required."
//     ]
//   }
// }
//
// نأخذ أول رسالة مفيدة ونحولها للعربية.
// ══════════════════════════════════════════════════════════════════════════════

String? _extractValidationMessage(dynamic body) {
  if (body is! Map) {
    return null;
  }

  final map = Map<String, dynamic>.from(body);

  final errors = map['errors'];

  if (errors is Map) {
    for (final entry in errors.entries) {
      final field = entry.key.toString();
      final value = entry.value;

      String? message;

      if (value is List && value.isNotEmpty) {
        message = value.first?.toString();
      } else if (value != null) {
        message = value.toString();
      }

      if (message != null && message.trim().isNotEmpty) {
        final friendly = _translateValidationMessage(
          field,
          message.trim(),
        );

        return friendly ?? message.trim();
      }
    }
  }

  // في حالة عدم وجود errors نستخدم message
  final message = map['message'];

  if (message != null && message.toString().trim().isNotEmpty) {
    return _friendlyMessage(message.toString().trim());
  }

  return null;
}

// ══════════════════════════════════════════════════════════════════════════════
// رسائل Validation عربية
// ══════════════════════════════════════════════════════════════════════════════

String? _translateValidationMessage(
  String field,
  String message,
) {
  final normalized = message.toLowerCase();

  // ─────────────────────────────────────────────────────────────
  // الاسم
  // ─────────────────────────────────────────────────────────────

  if (field == 'name') {
    if (normalized.contains('required')) {
      return 'الاسم الكامل مطلوب';
    }

    if (normalized.contains('string')) {
      return 'الاسم الكامل غير صحيح';
    }

    if (normalized.contains('min')) {
      return 'الاسم الكامل قصير جداً';
    }
  }

  // ─────────────────────────────────────────────────────────────
  // الهاتف
  // ─────────────────────────────────────────────────────────────

  if (field == 'phone') {
    if (normalized.contains('required')) {
      return 'رقم الهاتف مطلوب';
    }

    if (normalized.contains('unique')) {
      return 'رقم الهاتف مستخدم بالفعل';
    }

    if (normalized.contains('valid') ||
        normalized.contains('format') ||
        normalized.contains('regex')) {
      return 'رقم الهاتف غير صحيح';
    }
  }

  // ─────────────────────────────────────────────────────────────
  // البريد
  // ─────────────────────────────────────────────────────────────

  if (field == 'email') {
    if (normalized.contains('required')) {
      return 'البريد الإلكتروني مطلوب';
    }

    if (normalized.contains('email')) {
      return 'البريد الإلكتروني غير صحيح';
    }

    if (normalized.contains('unique')) {
      return 'البريد الإلكتروني مستخدم بالفعل';
    }
  }

  // ─────────────────────────────────────────────────────────────
  // كلمة المرور
  // ─────────────────────────────────────────────────────────────

  if (field == 'password') {
    if (normalized.contains('required')) {
      return 'كلمة المرور مطلوبة';
    }

    if (normalized.contains('min')) {
      return 'كلمة المرور قصيرة جداً';
    }

    if (normalized.contains('confirmed')) {
      return 'كلمتا المرور غير متطابقتين';
    }
  }

  // ─────────────────────────────────────────────────────────────
  // تأكيد كلمة المرور
  // ─────────────────────────────────────────────────────────────

  if (field == 'password_confirmation') {
    if (normalized.contains('required')) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (normalized.contains('same') || normalized.contains('confirmed')) {
      return 'كلمتا المرور غير متطابقتين';
    }
  }

  return null;
}

// ══════════════════════════════════════════════════════════════════════════════
// حماية المستخدم من رسائل Backend التقنية
// ══════════════════════════════════════════════════════════════════════════════

String? _friendlyMessage(String message) {
  final normalized = message.toLowerCase();

  // أخطاء Laravel / PHP التقنية
  if (normalized.contains('attempt to read property') ||
      normalized.contains('undefined property') ||
      normalized.contains('undefined variable') ||
      normalized.contains('undefined array key') ||
      normalized.contains('stack trace') ||
      normalized.contains('exception') ||
      normalized.contains('sqlstate') ||
      normalized.contains('syntax error') ||
      normalized.contains('fatal error')) {
    return 'حدث خطأ في الخادم، حاول مرة أخرى لاحقاً';
  }

  // مشاكل قاعدة البيانات
  if (normalized.contains('database') ||
      normalized.contains('query') ||
      normalized.contains('mysql') ||
      normalized.contains('pgsql')) {
    return 'حدث خطأ في الخادم، حاول مرة أخرى لاحقاً';
  }

  // مشاكل الاتصال بالخادم
  if (normalized.contains('connection refused') ||
      normalized.contains('connection reset') ||
      normalized.contains('connection failed')) {
    return 'تعذر الاتصال بالخادم، حاول مرة أخرى';
  }

  return message.trim().isEmpty ? null : message.trim();
}
